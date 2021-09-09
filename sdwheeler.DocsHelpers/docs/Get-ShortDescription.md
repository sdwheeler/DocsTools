---
external help file: sdwheeler.DocsHelpers-help.xml
Module Name: sdwheeler.DocsHelpers
ms.date: 09/09/2021
schema: 2.0.0
---

# Get-ShortDescription

## SYNOPSIS
Creates Markdown source listing each of cmdlet files in the folder and their **SYNOPSIS** text.

## SYNTAX

```
Get-ShortDescription
```

## DESCRIPTION

The cmdlet creates Markdown source listing each of cmdlet files in the folder and their **SYNOPSIS**
text. This text is useful for updating the module Markdown file created by PlatyPS.

The cmdlet must be run in the folder containing the Markdown files for all the cmdlets in the
module. The output can be sent to the clipboard for easy pasting into the `module.md` file.

## EXAMPLES

### Example 1 - Get the short descriptions for all cmdlets

This example assumes that you are running it the folder containing the Markdown files for a module.

```powershell
Get-ShortDescription | Set-Clipboard
```

The output is copied to the Clipboard for easy pasting into the `module.md` file.

## PARAMETERS

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

There are no parameter for this cmdlet.

## RELATED LINKS
