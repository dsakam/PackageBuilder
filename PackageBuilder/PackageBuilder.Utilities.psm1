######## LICENSE ####################################################################################################################################
<#
 # Copyright (c) 2013-2014, Daiki Sakamoto
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
 #  2014/01/16  Version 0.4.0.0
 #  2014/01/17  Version 0.5.0.0
 #
 #>
#####################################################################################################################################################

#####################################################################################################################################################
# Aliases
Function LINE { return ("`r`n" + (New-HR)) }
Function VERBOSE_LINE {

    if ((Get-Host).CurrentCulture -eq (New-Object System.Globalization.CultureInfo 'ja-JP'))
    {
        $header_Length = ([System.Text.Encoding]::Unicode).GetByteCount('詳細') + ': '.Length
    }
    else { $header_Length = 'VERBOSE: '.Length }

    return (New-HR -Length ((Get-Host).UI.RawUI.BufferSize.Width - $header_Length - 1))
}

Function PRINT { return ('[' + (Get-Date).ToString('yyyy/MM/dd HH:mm:ss') + ']' + ' ' + $args[0]) }

Function MESSAGE {
    Param ([Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][string[]]$Texts)
    Process
    {
        $text = $Texts[0]
        for ($i=1; $i -lt $Texts.Count; $i++)
        {
            # Head
            if ($i -eq 1) { $text += ' (' }

            $text += $Texts[$i]

            # Tail
            if ($i -lt $Texts.Count - 1) { $text += ', ' }
            else { $text += ')' }
        }
        return $text
    }
}


Function MAIN_TITLE { Write-Title -Text $args[0] -Padding 1 -MaxWidth 128 }
Function TITLE { Write-Title -Text $args[0] }

Function TRUE_FALSE { Write-Boolean -TestObject $args[0] -Green 'True' -Red 'False' }
Function PASS_FAIL { Write-Boolean -TestObject $args[0] -Green 'Pass' -Red 'Fail' }
Function YES_NO { Write-Boolean -TestObject $args[0] -Green 'Yes' -Red 'No' }

#####################################################################################################################################################
Function New-GUID {

<#
.SYNOPSIS
    GUID を生成します。


.DESCRIPTION


.INPUTS
    None


.OUTPUTS
    System.String


.NOTES


.EXAMPLE
    $guid = New-GUID
    GUID を生成し、String 型の文字列として取得します。


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
    水平線を出力します。


.DESCRIPTION


.PARAMETER Char
    デフォルトは '-'


.PARAMETER Length
    デフォルトは (コンソールの幅 - 1)


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
        [Parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true)][char]$Char = '-',
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
    コンソールにタイトルを表示します。


.DESCRIPTION


.PARAMETER Text


.PARAMETER Char
    デフォルトは '#'


.PARAMETER Width
    デフォルトは (コンソールの幅 - 1)


.PARAMETER Color
    デフォルトは白


.PARAMETER 
    デフォルトは 0


.PARAMETER ColumnWidth
    デフォルトは 2


.PARAMETER MinWidth
    デフォルトは 64


.PARAMETER MaxWidth
    デフォルトは 256


.INPUTS
    System.String


.OUTPUTS
    None


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

        [Parameter(Mandatory=$false, Position=1)][char]$Char = '#',
        [Parameter(Mandatory=$false, Position=2)][int]$Width = (Get-Host).UI.RawUI.BufferSize.Width - 1,
        [Parameter(Mandatory=$false, Position=3)][System.ConsoleColor]$Color = [System.ConsoleColor]::White,

        [Parameter(Mandatory=$false, Position=4)]
        [ValidateRange(0,5)]
        [int]$Padding = 0,

        [Parameter(Mandatory=$false, Position=5)]
        [ValidateRange(1,5)]
        [int]$ColumnWidth = 2,

        [Parameter(Mandatory=$false, Position=6)]
        [ValidateRange(0,512)]
        [int]$MinWidth = 64,

        [Parameter(Mandatory=$false, Position=7)]
        [ValidateRange(0,1024)]
        [int]$MaxWidth = 256
    )

    Process
    {
        # Validations
        if ($Width -lt $MinWidth) { $Width = $MinWidth }
        if ($Width -gt $MaxWidth) { $Width = $MaxWidth }

        $Text | % {
            if ($_.Length -gt ($maxLength = $Width - 2 - ($ColumnWidth * 2)))
            {
                $_ = $_.Substring(0, $maxLength - 2 - '...'.Length) + '...'
            }
        }

        $hr = New-HR -Char $Char -Length $Width
        $side = "$Char" * $ColumnWidth
        $pad = $side + (' ' * ($hr.Length - ($side.Length * 2))) + $side

        # Brerak Line
        Write-Host

        # Head
        Write-Host $hr -ForegroundColor $Color

        # Padding
        for ($i = 0; $i -lt $Padding; $i++)
        {
            Write-Host $pad -ForegroundColor $Color
        }

        # Main
        $Text | % {
            if ([string]::IsNullOrEmpty($_)) { Write-Host $pad -ForegroundColor $Color }
            else
            {
                Write-Host ($side + (' ' * 2) + $_ + (' ' * ($hr.Length - $_.Length - 2 - ($side.Length * 2))) + $side) -ForegroundColor $Color
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
    入力が真の場合は緑、偽の場合は赤でコンソールに文字列を表示します。


.DESCRIPTION


.PARAMETER TestObject
    

.PARAMETER Green


.PARAMETER Red


.INPUTS
    System.Boolean


.OUTPUTS
    None


.NOTES


.EXAMPLE


.LINK
    (None)
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][bool]$TestObject,
        [Parameter(Mandatory=$false, Position=1)][string]$Green = 'TRUE',
        [Parameter(Mandatory=$false, Position=2)][string]$Red = 'FALSE'
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
    指定したテキストとキャプションを表示するメッセージ ボックスを表示します。 


.DESCRIPTION
    System.Windows.Forms.MessageBox.Show()


.PARAMETER Text
    メッセージ ボックスに表示するテキストを指定します。


.PARAMETER Caption
    メッセージ ボックスのタイトル バーに表示するテキストを指定します。


.PARAMETER Buttons


.INPUTS
    System.String


.OUTPUTS
    System.Windows.Forms.DialogResult


.NOTES


.EXAMPLE


.LINK
    MessageBox クラス (System.Windows.Forms)
    http://msdn.microsoft.com/library/system.windows.forms.messagebox.aspx
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
            [void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
        }
        catch {
            [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms.dll')
        }

        if ($Buttons) { return [System.Windows.Forms.MessageBox]::Show($Text, $Caption, $Buttons) }
        else { return [System.Windows.Forms.MessageBox]::Show($Text, $Caption) }
    }
}

#####################################################################################################################################################
Function Get-DateString {

<#
.SYNOPSIS
    ロケール ID (LCID) および 標準またはカスタムの日時書式指定文字列 を使用して、日付文字列を取得します。


.DESCRIPTION


.PARAMETER Date
    表示する日付を指定します。
    デフォルトは本日です。


.PARAMETER LCID
    ロケール ID (LCID) を指定します。

    This parameter is argument of System.Globalization.CultureInfo Constructor (String). 
    Type: System.String
    A predefined CultureInfo name, Name of an existing CultureInfo, or Windows-only culture name. 

    If ommited, CultureInfo of your system is used.


.PARAMETER Format
    書式指定文字列を指定します。
    デフォルトは "D" です。

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
    Get-DateString -LCID 'ja-JP' -Format 'm'


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
        [Parameter(Mandatory=$false, Position=2)][string]$Format = 'D'
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
    ディスク上の物理ファイルのバージョン情報を取得します。


.DESCRIPTION


.PARAMETER Path


.PARAMETER ProductName


.PARAMETER FileDescription


.PARAMETER FileVersion
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
            elseif ((Get-Item -Path $_).GetType() -ne [System.IO.FileInfo]) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$Path,


        [Parameter(Mandatory=$true, ParameterSetName='name')]
        [switch]$ProductName,

        [Parameter(Mandatory=$true, ParameterSetName='description')]
        [switch]$FileDescription,

        [Parameter(Mandatory=$true, ParameterSetName='file')]
        [switch]$FileVersion,

        [Parameter(Mandatory=$true, ParameterSetName='product')]
        [switch]$ProductVersion,


        [Parameter(Mandatory=$false, ParameterSetName='file')]
        [Parameter(Mandatory=$false, ParameterSetName='product')]
        [switch]$Major,

        [Parameter(Mandatory=$false, ParameterSetName='file')]
        [Parameter(Mandatory=$false, ParameterSetName='product')]
        [switch]$Minor,

        [Parameter(Mandatory=$false, ParameterSetName='file')]
        [Parameter(Mandatory=$false, ParameterSetName='product')]
        [switch]$Build,

        [Parameter(Mandatory=$false, ParameterSetName='file')]
        [Parameter(Mandatory=$false, ParameterSetName='product')]
        [switch]$Private,

        [Parameter(Mandatory=$false, ParameterSetName='file')]
        [Parameter(Mandatory=$false, ParameterSetName='product')]
        [switch]$Composite
    )

    Process
    {
        $info = (Get-Item -Path $Path).VersionInfo

        switch ($PSCmdlet.ParameterSetName) 
        {
            'name' { return $info.ProductName }
            'description' { return $info.FileDescription }
            'file' {
                if ($Composite) { return [string]::Join('.', ($info.FileMajorPart, $info.FileMinorPart, $info.FileBuildPart, $info.FilePrivatePart)) }
                elseif ($Major) { return $info.FileMajorPart }
                elseif ($Minor) { return $info.FileMinorPart }
                elseif ($Build) { return $info.FileBuildPart }
                elseif ($Private) { return $info.FilePrivatePart }
                else { return $info.FileVersion.Trim() }
            }
            'product' {
                if ($Composite) { return [string]::Join('.', ($info.ProductMajorPart, $info.ProductMinorPart, $info.ProductBuildPart, $info.ProductPrivatePart)) }
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
    ファイルの製品名を取得します。


.DESCRIPTION
    Get-FileVersionInfo -ProductName のエイリアスです。


.PARAMETER Path


.INPUTS
    System.String


.OUTPUTS
    System.String


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
    ファイルの説明を取得します。


.DESCRIPTION
    Get-FileVersionInfo -FiletDescription のエイリアスです。


.PARAMETER Path


.INPUTS
    System.String


.OUTPUTS
    System.String


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
    ファイルのファイルバージョンを取得します。


.DESCRIPTION
    Get-FileVersionInfo -FiletVersion のエイリアスです。


.PARAMETER Path


.INPUTS
    System.String


.OUTPUTS
    System.String


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
    ファイルの製品バージョンを取得します。


.DESCRIPTION
    Get-FileVersionInfo -ProductVersion のエイリアスです。


.PARAMETER Path


.INPUTS
    System.String


.OUTPUTS
    System.String


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
    HTML ファイルから HTML 要素を取得します。


.DESCRIPTION


.PARAMETER Path


.PARAMETER Tag


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
            elseif ((Get-Item -Path $_).GetType() -ne [System.IO.FileInfo]) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$Path,

        [Parameter(Mandatory=$true, Position=1)][string]$Tag
    )

    Process
    {
        return ((Get-Content -Path $Path) -as [string]) -split '<' | ? { ($_ -split '>').Trim() -eq $Tag.Trim() } | % { (($_ -split '>')[1]).Trim() }
    }
}

#####################################################################################################################################################
Function Get-PrivateProfileString {

<#
.SYNOPSIS
    指定された .ini ファイル（初期化ファイル）の指定されたセクション内にある、指定されたキーに関連付けられている文字列を取得します。


.DESCRIPTION


.PARAMETER Path


.PARAMETER Section


.PARAMETER Key


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
            elseif ((Get-Item -Path $_).GetType() -ne [System.IO.FileInfo]) { throw New-Object System.IO.FileNotFoundException }
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
            if (($texts[$i].Trim()[0] -eq '[') -and (($texts[$i] -as [char[]]) -contains ']'))
            {
                if (((($texts[$i] -split '\[')[1]) -split '\]')[0].Trim() -eq $Section)
                {
                    for ($j = $i + 1; $j -lt ([string[]]$texts).Count; $j = $j +1)
                    {
                        if (($texts[$j] -split '=')[0].Trim() -eq $Key)
                        {
                            return (($texts[$j] -split '=')[1] -split ';')[0].Trim()
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
    ファイルの内容を更新します。


.DESCRIPTION


.PARAMETER Line

.PARAMETER SearchText

.PARAMETER UpdateText

.PARAMETER InputObject


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
        [Parameter(Mandatory=$true, Position=0, ParameterSetName='line')][int]$Line,
        [Parameter(Mandatory=$true, Position=0, ParameterSetName='word')][string]$SearchText,
        [Parameter(Mandatory=$true, Position=1)][string]$UpdateText,
        [Parameter(Mandatory=$true, Position=2, ValueFromPipeline=$true)][string[]]$InputObject
    )

    Begin
    {
        if ($PSCmdlet.ParameterSetName -eq 'line')
        {
            if ($Line -le 0) { throw New-Object System.ArgumentOutOfRangeException }
        }
    }

    Process
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            'line'
            {
                [string[]]$texts += $InputObject
            }
            default #('Word')
            {
                return ($InputObject -replace $SearchText, $UpdateText)
            }
        }
    }

    End
    {
        if ($PSCmdlet.ParameterSetName -eq 'line')
        {
            if ($Line -ge $texts.Count) { throw New-Object System.ArgumentOutOfRangeException }

            $texts[$Line - 1] = $UpdateText
            return $texts
        }
    }
}

#####################################################################################################################################################
Function Get-WindowHandler {

<#
.SYNOPSIS
    指定したプロセス ID に対応するウィンドウのウィンドウ ハンドル (HWND) を取得します。


.DESCRIPTION
    


.PARAMETER PID
    デフォルトはコンソールのプロセス ID ($PID)


.INPUTS
    System.Int32


.OUTPUTS
    System.IntPtr


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
Function New-Struct {

<#
.SYNOPSIS
    構造体の配列ようなをコンテナを作成します。


.DESCRIPTION


.PARAMETER Members


.PARAMETER Count


.INPUTS
    System.String[]


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
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][string[]]$Members,
        [Parameter(Mandatory=$false, Position=1)][int]$Count = 1
    )

    Process
    {
        $obj = New-Object -TypeName psobject[] -ArgumentList $Count

        for ($i = 0; $i -lt $Count; $i++)
        {
            # Add NoteProperty ($Members)
            $obj[$i] = New-Object -TypeName psobject
            $Members | % { Add-Member -InputObject $obj[$i] -MemberType NoteProperty -Name ($_ -split '=')[0] -Value ($_ -split '=')[1] -Force }

            # Add ScriptMethod
            Add-Member `
                -InputObject $obj[$i] `
                -MemberType ScriptMethod `
                -Name ToString `
                -Force `
                -Value {
                    
                    # Parameters
                    Param ([string]$Table=[string]::Empty, [string]$Item='TR', [string]$Name='TH', [string]$Value='TD')

                    # Process

                    [string]$text = [string]::Empty

                    # Head
                    if ($Table -ne [string]::Empty) { $text += "<$Table>" }
                    # Body
                    $this | Get-Member -MemberType NoteProperty | % {
                        $text += "<$Item>"
                        $text += ("<$Name>" + ([Microsoft.PowerShell.Commands.MemberDefinition]$_).Name + "</$_Name>")
                        $text += ("<$Value>" + (([Microsoft.PowerShell.Commands.MemberDefinition]$_).Definition -split '=')[1] + "</$Value>")
                        $text += "</$Item>"
                    }
                    # Tail
                    if ($Table -ne [string]::Empty) { $text += '</' + ($Table -split ' ')[0] + '>' }

                    return $text
                }
        }

        return $obj
    }
}

#####################################################################################################################################################
Function Send-Mail {

<#
.SYNOPSIS
    E メールを送信します。


.DESCRIPTION
    Send-MailMessage コマンドレットを使用してください。


.PARAMETER To
.PARAMETER From
.PARAMETER Host
.PARAMETER Subject
.PARAMETER Body
.PARAMETER UserName
.PARAMETER Password
.PARAMETER Domain
.PARAMETER Port


.INPUTS
    System.String


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
        [Parameter(Mandatory=$true, Position=0)][string[]]$To,
        [Parameter(Mandatory=$true, Position=1)][string]$From,
        [Parameter(Mandatory=$true, Position=2)][string]$Host,

        [Parameter(Mandatory=$false, Position=3)][string]$Subject = [string]::Empty,
        [Parameter(Mandatory=$false, Position=4, ValueFromPipeline=$true)][string]$Body = [string]::Empty,

        [Parameter(Mandatory=$false, Position=5)][string]$UserName = $env:USERNAME,
        [Parameter(Mandatory=$false, Position=6)][string]$Password = [string]::Empty,
        [Parameter(Mandatory=$false, Position=7)][string]$Domain,

        [Parameter(Mandatory=$false, Position=8)][int]$Port
    )

    Process
    {
        # MailMessage
        $mail = New-Object System.Net.Mail.MailMessage
        $mail.Subject = $Subject
        $mail.Body = $Body
        $mail.From = $From
        $To | % { $mail.To.Add($_) }

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
