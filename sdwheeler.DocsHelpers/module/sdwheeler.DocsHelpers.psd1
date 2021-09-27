#
# Module manifest for module 'sdwheeler.DocHelpers'
#

@{
    RootModule        = '.\sdwheeler.DocsHelpers.psm1'
    ModuleVersion     = '1.0.4'
    GUID              = '87d8c619-ccd7-43a6-8687-dacc24357910'
    Author            = 'Sean D. Wheeler <sewhee@microsoft.com>'
    CompanyName       = 'Microsoft'
    Copyright         = '(c) Microsoft. All rights reserved.'

    Description       = @'
This module is a collection of tools for working with Markdown files and
docs.microsoft.com articles.
'@

    FunctionsToExport = @(
        'Get-ContentWithoutHeader',
        'Get-HtmlMetaTags',
        'Get-LocaleFreshness',
        'Get-MDLinks',
        'Get-Metadata',
        'Get-OutputType',
        'Get-ShortDescription',
        'Get-Syntax',
        'Get-YamlBlock',
        'hash2yaml',
        'New-LinkRefs',
        'Remove-Metadata',
        'Set-Metadata',
        'Sort-Parameters',
        'Test-YamlTOC',
        'Update-Headings',
        'Update-Metadata'
    )
    CmdletsToExport   = ''
    VariablesToExport = ''
    AliasesToExport   = 'syntax'

    PrivateData       = @{
        PSData = @{
            # Tags = @()
            LicenseUri = 'https://github.com/sdwheeler/DocsTools/LICENSE'
            ProjectUri = 'https://github.com/sdwheeler/DocsTools'
            # IconUri = ''
            ReleaseNotes = 'https://github.com/sdwheeler/DocsTools/CHANGELOG.md'
            # Prerelease = ''
            # RequireLicenseAcceptance = $false
            # ExternalModuleDependencies = @()
        } # End of PSData hashtable
    } # End of PrivateData hashtable

    # HelpInfoURI = ''
}

