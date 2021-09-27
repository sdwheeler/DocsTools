---
external help file: sdwheeler.DocsHelpers-help.xml
Module Name: sdwheeler.DocsHelpers
ms.date: 09/09/2021
schema: 2.0.0
---

# Get-LocaleFreshness

## Synopsis
Gets the `ms.date` metadata information of a Docs article for every locale.

## Syntax

```
Get-LocaleFreshness [[-Uri] <Uri>] [<CommonParameters>]
```

## Description

Gets the `ms.date` metadata information of a Docs article for every locale. The output includes the
locale information and the translation method. This is useful to see whether or not the localization
process has picked up the latest changes made to the English version of the article.

## Examples

### Example 1 - Get the freshness date for an article

In this example you can see that the English version of the article was updated on 08/02/2021, but
there are several localized version that still show the older version of the article.

The meaning of the values of `ms.translationtype` are:

- **HT** - human translated
- **MT** - machine translated

```powershell
$url = 'https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows'
Get-LocaleFreshness $url
```

```Output
locale ms.contentlocale ms.translationtype ms.date
------ ---------------- ------------------ -------
de-de  de-DE            HT                 04/27/2021
es-es  es-ES            HT                 04/27/2021
fr-fr  fr-FR            HT                 04/27/2021
ja-jp  ja-JP            HT                 04/27/2021
ko-kr  ko-KR            HT                 04/27/2021
pt-br  pt-BR            HT                 04/27/2021
ru-ru  ru-RU            HT                 04/27/2021
zh-cn  zh-CN            HT                 04/27/2021
en-us                                      08/02/2021
cs-cz  cs-CZ            MT                 08/02/2021
hu-hu  hu-HU            MT                 08/02/2021
it-it  it-IT            MT                 08/02/2021
nl-nl  nl-NL            MT                 08/02/2021
pl-pl  pl-PL            MT                 08/02/2021
pt-pt  pt-PT            MT                 08/02/2021
sv-se  sv-SE            MT                 08/02/2021
tr-tr  tr-TR            MT                 08/02/2021
zh-tw  zh-TW            MT                 08/02/2021
```

## Parameters

### -Uri

The URL to the article being inspected. The URL must contain a locale.

```yaml
Type: System.Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## Inputs

### None

## Outputs

### System.Object

## Notes

## Related links
