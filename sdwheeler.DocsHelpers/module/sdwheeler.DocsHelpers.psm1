#-------------------------------------------------------
function Get-ContentWithoutHeader {
    [CmdletBinding()]
    param(
        [string]$Path
    )

    $doc = Get-Content $path -Encoding UTF8
    $hasFrontmatter = Select-String -Pattern '^---$' -Path $path
    $start = 0
    $end = $doc.count

    if ($hasFrontmatter) {
        $start = $hasFrontmatter[-1].LineNumber
    }
    $doc[$start..$end]
}
#-------------------------------------------------------
function Get-HtmlMetaTags {
    [CmdletBinding()]
    param(
        [uri]$ArticleUrl,
        [switch]$ShowRequiredMetadata
    )

    $hash = [ordered]@{}

    $x = Invoke-WebRequest $ArticleUrl
    $lines = (($x -split "`n").trim() | Select-String -Pattern '\<meta').line | ForEach-Object {
        $_.trimstart('<meta ').trimend(' />') | Sort-Object
    }
    $pattern = '(name|property)="(?<key>[^"]+)"\s*content="(?<value>[^"]+)"'
    foreach ($line in $lines) {
        if ($line -match $pattern) {
            if ($hash.Contains($Matches.key)) {
                $hash[($Matches.key)] += ',' + $Matches.value
            }
            else {
                $hash.Add($Matches.key, $Matches.value)
            }
        }
    }

    $result = New-Object -type psobject -prop ($hash)
    if ($ShowRequiredMetadata) {
        $result | Select-Object title, 'og:title', description, 'ms.manager', 'ms.author', author, 'ms.service', 'ms.date', 'ms.topic', 'ms.subservice', 'ms.prod', 'ms.technology', 'ms.custom', 'ROBOTS'
    }
    else {
        $result
    }
}
#-------------------------------------------------------
function Get-LocaleFreshness {
    [CmdletBinding()]
    param(
        [uri]$Uri
    )

    $locales = 'en-us', 'cs-cz', 'de-de', 'es-es', 'fr-fr', 'hu-hu', 'it-it', 'ja-jp', 'ko-kr',
    'nl-nl', 'pl-pl', 'pt-br', 'pt-pt', 'ru-ru', 'sv-se', 'tr-tr', 'zh-cn', 'zh-tw'
    $locale = $uri.Segments[1].Trim('/')
    $url = $uri.OriginalString
    $locales | ForEach-Object { Get-HtmlMetaTags ($url -replace $locale, $_) |
            Select-Object locale, 'ms.contentlocale', 'ms.translationtype', 'ms.date' } |
            Sort-Object 'ms.date', 'ms.contentlocale'
}
#-------------------------------------------------------
function Get-MDLinks {
    [CmdletBinding()]
    param(
        [Parameter()]
        [SupportsWildcards()]
        [string]$Path
    )
    $linkpattern = '(?<link>!?\[(?<label>[^\]]*)\]\((?<file>[^)#\?]*)?(?<anchor>#[^\?]+)?(?<query>\?[^#]+)?\))'
    $mdtext = Select-String -Path $Path -Pattern $linkpattern
    $mdtext | ForEach-Object {
        if ($_ -match $linkpattern) {
            $Matches |
                Select-Object @{l = 'link'; e = { $_.link } },
                @{l = 'label'; e = { $_.label } },
                @{l = 'file'; e = { $_.file } },
                @{l = 'anchor'; e = { $_.anchor } },
                @{l = 'query'; e = { $_.query } }
        }
    }
}
#-------------------------------------------------------
function Get-Metadata {
    [CmdletBinding()]
    param(
        [Parameter()]
        [SupportsWildcards()]
        [string]$Path,
        [switch]$Recurse,
        [switch]$AsObject
    )


    foreach ($file in (Get-ChildItem -rec:$Recurse -File $path)) {
        $ignorelist = 'keywords', 'helpviewer_keywords', 'ms.assetid'
        $lines = Get-YamlBlock $file
        $meta = @{}
        foreach ($line in $lines) {
            $i = $line.IndexOf(':')
            if ($i -ne -1) {
                $key = $line.Substring(0, $i)
                if (!$ignorelist.Contains($key)) {
                    $value = $line.Substring($i + 1).replace('"', '')
                    switch ($key) {
                        'title' {

                            $value = $value.split('|')[0].trim()
                        }
                        'ms.date' {
                            $value = Get-Date $value -Format 'MM/dd/yyyy'
                        }
                        Default {
                            $value = $value.trim()
                        }
                    }

                    $meta.Add($key, $value)
                }
            }
        }
        if ($AsObject) {
            $meta.Add('file', $file.FullName)
            [pscustomobject]$meta
        }
        else {
            $meta
        }
    }
}
#-------------------------------------------------------
function Get-ShortDescription {
    $crlf = "`r`n"
    Get-ChildItem *.md | ForEach-Object {
        if ($_.directory.basename -ne $_.basename) {
            $filename = $_.Name
            $name = $_.BaseName
            $headers = Select-String -Path $filename -Pattern '^## \w*' -AllMatches
            $mdtext = Get-Content $filename
            $start = $headers[0].LineNumber
            $end = $headers[1].LineNumber - 2
            $short = $mdtext[($start)..($end)] -join ' '
            if ($short -eq '') { $short = '{{Placeholder}}' }

            '### [{0}]({1}){3}{2}{3}' -f $name, $filename, $short.Trim(), $crlf
        }
    }
}
#-------------------------------------------------------
function Get-Syntax {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$CmdletName,
        [switch]$Markdown
    )

    function formatString {
        param(
            $cmd,
            $pstring
        )

        $parts = $pstring -split ' '
        $parameters = @()
        for ($x = 0; $x -lt $parts.Count; $x++) {
            $p = $parts[$x]
            if ($x -lt $parts.Count - 1) {
                if (!$parts[$x + 1].StartsWith('[')) {
                    $p += ' ' + $parts[$x + 1]
                    $x++
                }
                $parameters += , $p
            }
        }

        $line = $cmd + ' '
        $temp = ''
        for ($x = 0; $x -lt $parameters.Count; $x++) {
            if ($line.Length + $parameters[$x].Length + 1 -lt 100) {
                $line += $parameters[$x] + ' '
            }
            else {
                $temp += $line + "`r`n"
                $line = ' ' + $parameters[$x] + ' '
            }
        }
        $temp + $line.TrimEnd()
    }


    try {
        $cmdlet = Get-Command $cmdletname -ea Stop
        if ($cmdlet.CommandType -eq 'Alias') { $cmdlet = Get-Command $cmdlet.Definition }

        $syntax = (Get-Command $cmdlet.name).ParameterSets |
            Select-Object -Property @{n = 'Cmdlet'; e = { $cmdlet.name } },
            @{n = 'ParameterSetName'; e = { $_.name } },
            IsDefault,
            @{n = 'Parameters'; e = { $_.ToString() } }
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        $_.Exception.Message
    }

    $mdHere = @'
### {0}{1}

```
{2}
```

'@

    if ($Markdown) {
        foreach ($s in $syntax) {
            $string = $s.Cmdlet, $s.Parameters -join ' '
            if ($s.IsDefault) { $default = ' (Default)' } else { $default = '' }
            if ($string.Length -gt 100) {
                $string = formatString $s.Cmdlet $s.Parameters
            }
            $mdHere -f $s.ParameterSetName, $default, $string
        }
    }
    else {
        $syntax
    }
}
Set-Alias syntax Get-Syntax
#-------------------------------------------------------
function Get-YamlBlock {
    [CmdletBinding()]
    param([string]$Path)

    $doc = Get-Content $path -Encoding UTF8
    $hasFrontmatter = Select-String -Pattern '^---$' -Path $path
    $start = 0
    $end = $doc.count

    if ($hasFrontmatter) {
        $start = $hasFrontmatter[0].LineNumber
        $end = $hasFrontmatter[1].LineNumber-2
    }
    $doc[$start..$end]
}
#-------------------------------------------------------
function hash2yaml {
    [CmdletBinding()]
    param([hashtable]$MetaHash)
    ForEach-Object {
        '---'
        ForEach ($key in ($MetaHash.keys | Sort-Object)) {
            if ('' -ne $MetaHash.$key) {
                '{0}: {1}' -f $key, $MetaHash.$key
            }
        }
        '---'
    }
}
#-------------------------------------------------------
function New-LinkRefs {
    param(
        [Parameter()]
        [SupportsWildcards()]
        [string[]]$Path
    )
    foreach ($p in $path) {
        $linkpattern = '(?<link>!?\[(?<label>[^\]]*)\]\((?<file>[^)#]*)?(?<anchor>#.+)?\))'
        $mdtext = Select-String -Path $p -Pattern $linkpattern

        $mdtext.matches | ForEach-Object {
            $link = @()
            foreach ($g in $_.Groups) {
                if ($g.Name -eq 'label') { $link += $g.value }
                if ($g.Name -eq 'file') { $link += $g.value }
                if ($g.Name -eq 'anchor') { $link += $g.value }
            }
            '[{0}]: {1}{2}' -f $link #$link[0],$link[1],$link[2]
        }
    }
}
#-------------------------------------------------------
function Remove-Metadata {
    param(
        [Parameter()]
        [SupportsWildcards()]
        [string]$Path,
        [string[]]$KeyName,
        [switch]$Recurse
    )

    foreach ($file in (Get-ChildItem $path -Recurse:$Recurse)) {
        $file.name
        $metadata = Get-Metadata -path $file
        $mdtext = Get-ContentWithoutHeader -path $file

        foreach ($key in $KeyName) {
            if ($metadata.ContainsKey($key)) {
                $metadata.Remove($key)
            }
        }

        Set-Content -Value (hash2yaml $metadata) -Path $file -Force -Encoding utf8
        Add-Content -Value $mdtext -Path $file -Encoding utf8
    }
}
#-------------------------------------------------------
function Set-Metadata {
    param(
        [Parameter()]
        [SupportsWildcards()]
        [string]$Path,
        [hashtable]$NewMetadata,
        [switch]$Recurse
    )

    foreach ($file in (Get-ChildItem $path -Recurse:$Recurse)) {
        $file.name
        $mdtext = Get-ContentWithoutHeader -path $file
        Set-Content -Value (hash2yaml $NewMetadata) -Path $file -Force -Encoding utf8
        Add-Content -Value $mdtext -Path $file -Encoding utf8
    }
}
#-------------------------------------------------------
function Sort-Parameters {
    [CmdletBinding()]
    param (
        [Parameter()]
        [SupportsWildcards()]
        [string[]]$Path
    )

    # ----------------------
    function findparams {
        param($matchlist)

        $paramlist = @()

        $inParams = $false
        foreach ($hdr in $matchlist) {
            if ($hdr.Line -eq '## Parameters') {
                $inParams = $true
            }
            if ($inParams) {
                if ($hdr.Line -match '^### -') {
                    $param = [PSCustomObject]@{
                        Name      = $hdr.Line.Trim()
                        StartLine = $hdr.LineNumber - 1
                        EndLine   = -1
                    }
                    $paramlist += $param
                }
                if ((
                        ($hdr.Line -match '^## ' -and $hdr.Line -ne '## Parameters') -or
                        ($hdr.Line -eq '### CommonParameters')
                    ) -and
                    ($paramlist.Count -gt 0)
                ) {
                    $inParams = $false
                    $paramlist[-1].EndLine = $hdr.LineNumber - 2
                }
            }
        }
        if ($paramlist.Count -gt 0) {
            for ($x = 0; $x -lt $paramlist.Count; $x++) {
                if ($paramlist[$x].EndLine -eq -1) {
                    $paramlist[$x].EndLine = $paramlist[($x + 1)].StartLine - 1
                }
            }
        }
        $paramlist
    }
    # ----------------------

    $mdfiles = Get-ChildItem $path

    foreach ($file in $mdfiles) {
        $file.Name
        $mdtext = Get-Content $file -Encoding utf8
        $mdheaders = Select-String -Pattern '^#' -Path $file

        $unsorted = findparams $mdheaders
        if ($unsorted.Count -gt 0) {
            $sorted = $unsorted | Sort-Object Name
            $newtext = $mdtext[0..($unsorted[0].StartLine - 1)]
            $confirmWhatIf = @()
            foreach ($p in $sorted) {
                if ( '### -Confirm', '### -WhatIf' -notcontains $p.Name) {
                    $newtext += $mdtext[$p.StartLine..$p.EndLine]
                }
                else {
                    $confirmWhatIf += $p
                }
            }
            foreach ($p in $confirmWhatIf) {
                $newtext += $mdtext[$p.StartLine..$p.EndLine]
            }
            $newtext += $mdtext[($unsorted[-1].EndLine + 1)..($mdtext.Count - 1)]

            Set-Content -Value $newtext -Path $file.FullName -Encoding utf8 -Force
        }
    }
}
#-------------------------------------------------------
function Update-Metadata {
    param(
        [Parameter()]
        [SupportsWildcards()]
        [string]$Path,
        [hashtable]$NewMetadata,
        [switch]$Recurse
    )

    foreach ($file in (Get-ChildItem $path -Recurse:$Recurse)) {
        $file.name
        $oldMetadata = Get-Metadata -path $file
        $mdtext = Get-ContentWithoutHeader -path $file

        $update = $oldMetadata.Clone()
        foreach ($key in $NewMetadata.Keys) {
            if ($update.ContainsKey($key)) {
                $update[$key] = $NewMetadata[$key]
            }
            else {
                $update.Add($key, $NewMetadata[$key])
            }
        }

        Set-Content -Value (hash2yaml $update) -Path $file -Force -Encoding utf8
        Add-Content -Value $mdtext -Path $file -Encoding utf8
    }
}
#-------------------------------------------------------
