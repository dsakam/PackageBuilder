######## LICENSE ####################################################################################################################################
<#
 # Copyright (c) 2013, Daiki Sakamoto
 # All rights reserved.
 #
 # Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 #   - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 #   - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
 #     in the documentation and/or other materials provided with the distribution.
 #
 # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 # THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 # HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 # LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 # ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 # USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 #
 #>
 # http://opensource.org/licenses/BSD-2-Clause
#####################################################################################################################################################

######## HISTORY ####################################################################################################################################
<#
 # Package Builder Toolkit for PowerShell
 #
 #  2013/03/28  Create
 #  2013/09/02  Version 0.0.0.1
 #  2013/09/03  Get-CommandPath -> Run-Command
 #  2013/09/09  Update
 #  2013/09/16  Update
 #
 #>
#####################################################################################################################################################

#####################################################################################################################################################
# Aliases
Function LINE { return ("`r`n" + (New-HR)) }
Function VERBOSE_LINE {

    if ((Get-Host).CurrentCulture -eq (New-Object System.Globalization.CultureInfo "ja-JP"))
    {
        $header_Length = ([System.Text.Encoding]::Unicode).GetByteCount("詳細") + ": ".Length
    }
    else { $header_Length = "VERBOSE: ".Length }

    return (New-HR -Length ((Get-Host).UI.RawUI.BufferSize.Width - $header_Length - 1))
}

Function PRINT { return ("[" + (Get-Date).ToString("yyyy/MM/dd HH:mm:ss") + "]" + " " + $args[0]) }

Function MESSAGE {
    Param ([Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][string[]]$Texts)
    Process
    {
        $text = $Texts[0]
        for ($i=1; $i -lt $Texts.Count; $i++)
        {
            # Head
            if ($i -eq 1) { $text += " (" }

            $text += $Texts[$i]

            # Tail
            if ($i -lt $Texts.Count - 1) { $text += ", " }
            else { $text += ")" }
        }
        return $text
    }
}


Function MAIN_TITLE { Write-Title -Text $args[0] -Padding 1 }
Function TITLE { Write-Title -Text $args[0] }

Function TRUE_FALSE { Write-Boolean -TestObject $args[0] -Green "True" -Red "False" }
Function PASS_FAIL { Write-Boolean -TestObject $args[0] -Green "Pass" -Red "Fail" }
Function YES_NO { Write-Boolean -TestObject $args[0] -Green "Yes" -Red "No" }

#####################################################################################################################################################
Function New-GUID {

<#
.SYNOPSIS
    Get command path.


.DESCRIPTION
    GUID を生成します。


.PARAMETER Path


.INPUTS
    None


.OUTPUTS
    System.String


.NOTES
    (None)


.EXAMPLE
    (None)


.LINK
    (None)
#>

    [CmdletBinding()]Param()

    Process
    {
        return [guid]::NewGuid().ToString()
    }
}

#####################################################################################################################################################
Function New-HR {

<#
.SYNOPSIS
    Write Horizontal Ruled Line.


.DESCRIPTION
    水平線を出力します。


.PARAMETER Char
    Type: System.Char


.PARAMETER Length
    Type: System.Int


.INPUTS
    System.Char


.OUTPUTS
    System.String


.NOTES


.EXAMPLE


.LINK
    (None)
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true)][char]$Char = "-",
        [Parameter(Mandatory=$false, Position=2)][int]$Length = (Get-Host).UI.RawUI.BufferSize.Width - 1
    )

    Process
    {
        return ("$Char" * $Length)
    }
}

#####################################################################################################################################################
Function Write-Title {

<#
.SYNOPSIS
    Write Horizontal Ruled Line.


.DESCRIPTION
    水平線を出力します。


.PARAMETER Char
    Type: System.Char


.PARAMETER Length
    Type: System.Int


.INPUTS
    System.Char


.OUTPUTS
    System.String


.NOTES


.EXAMPLE


.LINK
    (None)
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [AllowEmptyString()]
        [string[]]$Text,

        [Parameter(Mandatory=$false, Position=1)][char]$Char = "#",
        [Parameter(Mandatory=$false, Position=2)][int]$Width = (Get-Host).UI.RawUI.BufferSize.Width - 1,
        [Parameter(Mandatory=$false, Position=3)][System.ConsoleColor]$Color = [System.ConsoleColor]::White,

        [Parameter(Mandatory=$false, Position=4)]
        [ValidateRange(0,5)]
        [int]$Padding = 0,

        [Parameter(Mandatory=$false, Position=5)]
        [ValidateRange(1,3)]
        [int]$ColumnWidth = 2,

        [Parameter(Mandatory=$false, Position=6)]
        [ValidateRange(0,512)]
        [int]$MinWidth = 64,

        [Parameter(Mandatory=$false, Position=7)]
        [ValidateRange(0,512)]
        [int]$MaxWidth = 200
    )

    Process
    {
        # Validations
        if ($Width -lt $MinWidth) { $Length = $MinWidth }
        if ($Width -gt $MaxWidth) { $Length = $MaxWidth }

        $Text | % {
            if ($_.Length -gt ($maxLength = $Width - 2 - ($ColumnWidth * 2)))
            {
                $_ = $_.Substring(0, $maxLength - 2 - "...".Length) + "..."
            }
        }

        $hr = New-HR -Char $Char -Length $Width
        $side = "$Char" * $ColumnWidth


        Write-Host

        # Head
        Write-Host $hr -ForegroundColor $Color

        # Padding
        for ($i = 0; $i -lt $Padding; $i++)
        {
            Write-Host ($pad = $side + (" " * ($hr.Length - ($side.Length * 2))) + $side) -ForegroundColor $Color
        }

        # Main
        $Text | % {
            if ([string]::IsNullOrEmpty($_)) { Write-Host $pad -ForegroundColor $Color }
            else
            {
                Write-Host ($side + (" " * 2) + $_ + (" " * ($hr.Length - $_.Length - 2 - ($side.Length * 2))) + $side) -ForegroundColor $Color
            }
        }

        # Padding
        for ($i = 0; $i -lt $Padding; $i++) { Write-Host $pad  -ForegroundColor $Color}

        # Tail
        Write-Host $hr -ForegroundColor $Color
    }
}

#####################################################################################################################################################
Function Write-Boolean {

<#
.SYNOPSIS
    Write Horizontal Ruled Line.


.DESCRIPTION


.PARAMETER Char
    Type: System.Char


.PARAMETER Length
    Type: System.Int


.INPUTS
    System.Char


.OUTPUTS
    System.String


.NOTES


.EXAMPLE


.LINK
    (None)
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][bool]$TestObject,
        [Parameter(Mandatory=$false, Position=1)][string]$Green = "TRUE",
        [Parameter(Mandatory=$false, Position=2)][string]$Red = "FALSE"
    )

    Process
    {
        if ($TestObject) { Write-Host $Green -ForegroundColor Green -NoNewline }
        else { Write-Host $Red -ForegroundColor Red -NoNewline }
    }
}

#####################################################################################################################################################
Function Show-Message {

<#
.SYNOPSIS
    Show MessageBox


.DESCRIPTION
    指定したテキストとキャプションを表示するメッセージ ボックスを表示します。 


.PARAMETER Text
    Type: System.String
    メッセージ ボックスに表示するテキスト。


.PARAMETER Caption
    Type: System.String
    メッセージ ボックスのタイトル バーに表示するテキスト。


.INPUTS
    System.String


.OUTPUTS
    System.Windows.Forms.DialogResult


.NOTES


.EXAMPLE


.LINK
    (None)
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][string]$Text,
        [Parameter(Mandatory=$false, Position=1)][string]$Caption = $PSSessionApplicationName,
        [Parameter(Mandatory=$false, Position=2)][System.Windows.Forms.MessageBoxButtons]$Buttons
    )

    Process
    {
        # Load Assembly
        try {
            [void][System.Reflection.Assembly]::Load("System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
        }
        catch {
            [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.dll")
        }

        if ($Buttons) { return [System.Windows.Forms.MessageBox]::Show($Text, $Caption, $Buttons) }
        else { return [System.Windows.Forms.MessageBox]::Show($Text, $Caption) }
    }
}

#####################################################################################################################################################
Function Get-DateString {

<#
.SYNOPSIS
    Get date string using CultureInfo and format.


.DESCRIPTION
    ロケール ID (LCID) および 標準またはカスタムの日時書式指定文字列 を使用して、日付文字列を取得します。


.PARAMETER Date
    Type: System.DateTime
    If omitted, today is used.


.PARAMETER LCID
    Locale ID.

    This parameter is argument of System.Globalization.CultureInfo Constructor (String). 
    Type: System.String
    A predefined CultureInfo name, Name of an existing CultureInfo, or Windows-only culture name. 

    If ommited, CultureInfo of your system is used.


.PARAMETER Format
    This parameter is 1st argument of System.DateTime.ToString Method (String, IFormatProvider).
    Type: System.String
    A standard or custom date and time format string. 

    If ommited, The Long Date ("D") Format Specifier is used.


.INPUTS
    System.DateTime


.OUTPUTS
    System.String


.NOTES
    Get Date As String Cmdlet

    2013/03/28  Version 0.0.0.1
                Create
    2013/03/29  Change Comment Style
    2013/09/02  Update
    2013/09/03  Update
    2013/09/04  Update
                Verion 1.0.0.0

.EXAMPLE
    Get-DateString


.EXAMPLE 
    Get-DateString -LCID "ja-JP" -Format "m"


.LINK
    [MS-LCID] Windows Language Code Identifier (LCID) Reference
    http://msdn.microsoft.com/en-us/library/cc233965.aspx

    ロケール ID (LCID) の一覧
    http://msdn.microsoft.com/ja-jp/library/cc392381.aspx

    標準の日付と時刻の書式指定文字列
    http://msdn.microsoft.com/ja-jp/library/az4se3k1.aspx

    カスタムの日付と時刻の書式指定文字列
    http://msdn.microsoft.com/ja-jp/library/8kb3ddd4.aspx

    DateTime.ToString メソッド (String, IFormatProvider) (System)
    http://msdn.microsoft.com/ja-jp/library/8tfzyc64.aspx

    CultureInfo コンストラクター (String) (System.Globalization)
    http://msdn.microsoft.com/ja-jp/library/ky2chs3h.aspx

    ISO 639 - Wikipedia
    http://ja.wikipedia.org/wiki/ISO_639
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true)][System.DateTime]$Date = (Get-Date),
        [Parameter(Mandatory=$false, Position=1)][string]$LCID = (Get-Culture).ToString(),
        [Parameter(Mandatory=$false, Position=2)][string]$Format = "D"
    )

    Process
    {
        ($Date).ToString($Format, (New-Object System.Globalization.CultureInfo($LCID)))
    }
}

#####################################################################################################################################################
Function Get-FileVersionInfo {

<#
.SYNOPSIS
    Get version information for a physical file on disk.


.DESCRIPTION
    ディスク上の物理ファイルのバージョン情報を取得します。


.PARAMETER Path
    File Path of target file.
    Type: System.String


.PARAMETER ProductName


.PARAMETER FileDescription


.PARAMETER VersionInfo
    If specified, File Version is acquired.


.PARAMETER ProductVersion
    If specified, Product Version is acquired instead of File Version.


.PARAMETER Major

.PARAMETER Minor

.PARAMETER Build

.PARAMETER Private

.PARAMETER Composite


.INPUTS
    System.String


.OUTPUTS
    System.String


.NOTES
    If any parameter is not specified, [System.Diagnostics.FileVersionInfo] is acquired.


.EXAMPLE
    Get-FileVersion -Path .\setup.exe


.EXAMPLE 
    Get-FileVersion -Path .\setup.exe -ProductVersion


.LINK
    FileVersionInfo プロパティ (System.Diagnostics)
    http://msdn.microsoft.com/ja-jp/library/System.Diagnostics.FileVersionInfo.aspx    

    FileVersionInfo.ProductName プロパティ (System.Diagnostics)
    http://msdn.microsoft.com/ja-jp/library/system.diagnostics.fileversioninfo.productname.aspx

    FileVersionInfo.FileDescription プロパティ (System.Diagnostics)
    http://msdn.microsoft.com/ja-jp/library/system.diagnostics.fileversioninfo.filedescription.aspx

    FileVersionInfo.FileVersion プロパティ (System.Diagnostics)
    http://msdn.microsoft.com/ja-jp/library/system.diagnostics.fileversioninfo.fileversion.aspx

    FileVersionInfo.ProductVersion プロパティ (System.Diagnostics)
    http://msdn.microsoft.com/ja-jp/library/system.diagnostics.fileversioninfo.productversion.aspx
#>

    [CmdletBinding(DefaultParameterSetName=$false)]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript ( {
            if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$Path,


        [Parameter(Mandatory=$true, ParameterSetName="name")]
        [switch]$ProductName,

        [Parameter(Mandatory=$true, ParameterSetName="description")]
        [switch]$FileDescription,

        [Parameter(Mandatory=$true, ParameterSetName="file")]
        [switch]$FileVersion,

        [Parameter(Mandatory=$true, ParameterSetName="product")]
        [switch]$ProductVersion,


        [Parameter(Mandatory=$false, ParameterSetName="file")]
        [Parameter(Mandatory=$false, ParameterSetName="product")]
        [switch]$Major,

        [Parameter(Mandatory=$false, ParameterSetName="file")]
        [Parameter(Mandatory=$false, ParameterSetName="product")]
        [switch]$Minor,

        [Parameter(Mandatory=$false, ParameterSetName="file")]
        [Parameter(Mandatory=$false, ParameterSetName="product")]
        [switch]$Build,

        [Parameter(Mandatory=$false, ParameterSetName="file")]
        [Parameter(Mandatory=$false, ParameterSetName="product")]
        [switch]$Private,

        [Parameter(Mandatory=$false, ParameterSetName="file")]
        [Parameter(Mandatory=$false, ParameterSetName="product")]
        [switch]$Composite
    )

    Process
    {
        $info = (Get-Item -Path $Path).VersionInfo

        switch ($PSCmdlet.ParameterSetName) 
        {
            "name" { return $info.ProductName }
            "description" { return $info.FileDescription }
            "file" {
                if ($Composite) { return [string]::Join(".", ($info.FileMajorPart, $info.FileMinorPart, $info.FileBuildPart, $info.FilePrivatePart)) }
                elseif ($Major) { return $info.FileMajorPart }
                elseif ($Minor) { return $info.FileMinorPart }
                elseif ($Build) { return $info.FileBuildPart }
                elseif ($Private) { return $info.FilePrivatePart }
                else { return $info.FileVersion.Trim() }
            }
            "product" {
                if ($Composite) { return [string]::Join(".", ($info.ProductMajorPart, $info.ProductMinorPart, $info.ProductBuildPart, $info.ProductPrivatePart)) }
                elseif ($Major) { return $info.ProductMajorPart }
                elseif ($Minor) { return $info.ProductMinorPart }
                elseif ($Build) { return $info.ProductBuildPart }
                elseif ($Private) { return $info.ProductPrivatePart }
                else { return $info.ProductVersion.Trim() }
            }
            default { return $info }
        }
    }
}

#####################################################################################################################################################
Function Get-ProductName {

<#
.SYNOPSIS
    Get Product Name of FileInfo.


.DESCRIPTION
    ファイルの製品名を取得します。
    Get-FileVersionInfo -ProductName のエイリアスです。


.LINK
    FileVersionInfo.ProductName プロパティ (System.Diagnostics)
    http://msdn.microsoft.com/ja-jp/library/system.diagnostics.fileversioninfo.productname.aspx
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][string]$Path
    )

    Process
    {
        return (Get-FileVersionInfo -Path $Path -ProductName)
    }
}

#####################################################################################################################################################
Function Get-FileDescription {

<#
.SYNOPSIS
    Get File Description of FileInfo.


.DESCRIPTION
    ファイルの説明を取得します。
    Get-FileVersionInfo -FiletDescription のエイリアスです。


.LINK
    FileVersionInfo.FileDescription プロパティ (System.Diagnostics)
    http://msdn.microsoft.com/ja-jp/library/system.diagnostics.fileversioninfo.filedescription.aspx
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][string]$Path
    )

    Process
    {
        return (Get-FileVersionInfo -Path $Path -FileDescription)
    }
}

#####################################################################################################################################################
Function Get-FileVersion {

<#
.SYNOPSIS
    Get File Version of FileInfo.


.DESCRIPTION
    ファイルのファイルバージョンを取得します。
    Get-FileVersionInfo -FiletVersion のエイリアスです。


.LINK
    FileVersionInfo.FileVersion プロパティ (System.Diagnostics)
    http://msdn.microsoft.com/ja-jp/library/system.diagnostics.fileversioninfo.fileversion.aspx
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][string]$Path
    )

    Process
    {
        return (Get-FileVersionInfo -Path $Path -FileVersion)
    }
}

#####################################################################################################################################################
Function Get-ProductVersion {

<#
.SYNOPSIS
    Get Product Version of FileInfo.


.DESCRIPTION
    ファイルの製品バージョンを取得します。
    Get-FileVersionInfo -ProductVersion のエイリアスです。


.LINK
    FileVersionInfo.ProductVersion プロパティ (System.Diagnostics)
    http://msdn.microsoft.com/ja-jp/library/system.diagnostics.fileversioninfo.productversion.aspx
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][string]$Path
    )

    Process
    {
        return (Get-FileVersionInfo -Path $Path -ProductVersion)
    }
}

#####################################################################################################################################################
Function Get-HTMLString {

<#
.SYNOPSIS
    Get HTML element from HTML file.


.DESCRIPTION
    HTML ファイルから HTML 要素を取得します。


.PARAMETER Path
    File Path of target file.
    Type: System.String


.PARAMETER Tag
    Tag name of HTML element.
    Type: System.String


.INPUTS
    System.String


.OUTPUTS
    System.String


.NOTES
    Get String from HTML Document Cmdlet

    2013/09/09  Version 0.0.0.1
                Create


.EXAMPLE
    Get-HtmlElement -Path .\sample.html -Tag h1


.LINK
    
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript ( {
            if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$Path,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Tag
    )

    Process
    {
        return ((Get-Content -Path $Path) -as [string]) -split "<" | ? { ($_ -split ">").Trim() -eq $Tag.Trim() } | % { (($_ -split ">")[1]).Trim() }
    }
}

#####################################################################################################################################################
Function Get-PrivateProfileString {

<#
.SYNOPSIS
    Get string from .ini file.


.DESCRIPTION
    指定された .ini ファイル（初期化ファイル）の指定されたセクション内にある、指定されたキーに関連付けられている文字列を取得します。


.PARAMETER Path
    File Path of target file.
    Type: System.String


.INPUTS
    System.String


.OUTPUTS
    System.String


.NOTES
    Get HTML Element Cmdlet

    2013/10/02  Version 0.0.0.1
                Create


.EXAMPLE


.LINK
    
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript ( {
            if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$Path,

        [Parameter(Mandatory=$true, Position=1)][string]$Section,
        [Parameter(Mandatory=$true, Position=2)][string]$Key
    )

    Process
    {
        $texts = (Get-Content -Path $Path) -as [string[]]

        for ($i = 0; $i -lt ([string[]]$texts).Count; $i = $i + 1)
        {
            if (($texts[$i].Trim()[0] -eq "[") -and (($texts[$i] -as [char[]]) -contains "]"))
            {
                if (((($texts[$i] -split "\[")[1]) -split "\]")[0].Trim() -eq $Section)
                {
                    for ($j = $i + 1; ([string[]]$texts).Count; $j = $j +1)
                    {
                        if (($texts[$j] -split "=")[0].Trim() -eq $Key)
                        {
                            return (($texts[$j] -split "=")[1] -split ";")[0].Trim()
                        }
                    }
                }
            }
        }
        return [string]::Empty
    }
}

#####################################################################################################################################################
Function Update-Content {

<#
.SYNOPSIS


.DESCRIPTION


.PARAMETER Path
    File Path of target file.
    Type: System.String


.INPUTS
    System.String


.OUTPUTS
    System.String


.NOTES


.EXAMPLE


.LINK
    
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ParameterSetName="line")]
        [ValidateScript ( {
            if (($_ -le 0) -and ($_ -gt $InputObject.Count)) { throw New-Object System.IndexOutOfRangeException }
            return $true
         } )]
        [int]$Line,

        [Parameter(Mandatory=$true, Position=0, ParameterSetName="word")]
        [ValidateNotNullOrEmpty()]
        [string]$SearchText,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$UpdateText,

        [Parameter(Mandatory=$true, Position=2, ValueFromPipeline=$true)]
        [string[]]$InputObject
    )

    Process
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            "line"
            {
                [string[]]$texts += $InputObject
            }
            default #("Word")
            {
                return (($texts = $InputObject) -replace $SearchText, $UpdateText)
            }
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq "line")
        {
            $texts[$Line - 1] = $UpdateText
            return $texts
        }
    }
}

#####################################################################################################################################################
Function Get-WindowHandler {

<#
.SYNOPSIS
    Get Window Handler.


.DESCRIPTION
    


.PARAMETER Path
    None


.INPUTS
    None


.OUTPUTS
    IntPtr


.NOTES
    (None)


.EXAMPLE
    (None)


.LINK
    (None)
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false, Position=0)][int]$ID = $PID
    )

    Process
    {
        return (Get-Process -Id $ID).MainWindowHandle
    }
}

#####################################################################################################################################################
Function Send-Mail {

<#
.SYNOPSIS
    Eメールを送信します。


.DESCRIPTION
    Send-MailMessage コマンドレットを使用してください。


.PARAMETER Path


.INPUTS
    None


.OUTPUTS
    System.String


.NOTES
    (None)


.EXAMPLE
    (None)


.LINK
    (None)
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript ( {
            if ([string]::IsNullOrEmpty($_)) { throw New-Object System.ArgumentException }
            else { return $true }
        } )]
        [string]$From,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateScript ( {
            if (([string[]]$_).Count -le 0) { throw New-Object System.ArgumentException }
            $_ | % { if ([string]::IsNullOrEmpty($_)) { throw New-Object System.ArgumentException } }
            return $true
        } )]
        [string[]]$To,

        [Parameter(Mandatory=$false, Position=2)][string]$Subject,
        [Parameter(Mandatory=$false, Position=3)][string]$Body,

        [Parameter(Mandatory=$true, Position=4)]
        [ValidateScript ( {
            if ([string]::IsNullOrEmpty($_)) { throw New-Object System.ArgumentException }
            else { return $true }
        } )]
        [string]$UserName,

        [Parameter(Mandatory=$true, Position=5)]
        [ValidateScript ( {
            if ([string]::IsNullOrEmpty($_)) { throw New-Object System.ArgumentException }
            else { return $true }
        } )]
        [string]$Password,

        [Parameter(Mandatory=$false, Position=6)][string]$Domain,

        [Parameter(Mandatory=$true, Position=7)]
        [ValidateScript ( {
            if ([string]::IsNullOrEmpty($_)) { throw New-Object System.ArgumentException }
            else { return $true }
        } )]
        [string]$Host,

        [Parameter(Mandatory=$false, Position=8)][int]$Port
    )

    Process
    {
        if (-not $Subject) { $Subject = [string]::Empty }
        if (-not $Body) { $Body = [string]::Empty }

        # Mail
        $mail = New-Object System.Net.Mail.MailMessage
        $mail.From = $From
        $To | % { $mail.To.Add($_) }
        $mail.Subject = $Subject
        $mail.Body = $Body

        # Credential
        $cred = New-Object System.Net.NetworkCredential($UserName, $Password)
        if ($Domain) {$cred.Domain = $Domain }

        # SMTP Client
        $client = New-Object System.Net.Mail.SmtpClient($Host)
        $client.Credentials = $cred
        if ($Port) { $client.Port = $Port }

        # Send
        $client.Send($mail)
    }
}

#####################################################################################################################################################
