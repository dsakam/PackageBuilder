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
 #  2013/12/31  Version 0.1.0.0
 #  2014/01/05  Version 0.2.0.0
 #  2014/01/10  Version 0.3.0.0
 #  2014/01/16  Version 0.4.0.0
 #  2014/01/17  Version 0.5.0.0
 #  2014/03/01  Version 0.6.0.0
 #  2014/03/10  Version 0.7.0.0
 #  2014/03/17  Version 0.8.0.0
 #  2014/04/07  Version 0.9.0.0
 #  2014/04/17  Version 0.10.0.0
 #  2014/04/20  Version 0.11.0.0
 #  2014/04/27  Version 0.12.0.0
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
Function New-GUID
{
    <#
        .SYNOPSIS
            GUID を生成します。

        .DESCRIPTION
            System.Guid.NewGUID メソッドを使って新しい GUID を生成します。

        .INPUTS
            None
            パイプを使用してこのコマンドレットに入力を渡すことはできません。

        .OUTPUTS
            System.String
            生成した GUID を文字列として返します。

        .EXAMPLE
            $guid = New-GUID
            GUID を生成し、String 型の文字列として変数 guid に格納します。

        .LINK
            Guid.NewGuid メソッド (System)
            http://msdn.microsoft.com/ja-jp/library/system.guid.newguid.aspx
    #>

    [CmdletBinding()]Param()

    Process
    {
        return [guid]::NewGuid().ToString()
    }
}

#####################################################################################################################################################
Function New-HR
{
    <#
        .SYNOPSIS
            水平線を出力します。

        .DESCRIPTION
            指定された文字で構成される水平線を出力します。

        .PARAMETER Char
            水平線を構成する System.Char 型の文字を指定します。
            デフォルトは '-' です。

        .PARAMETER Length
            水平線の幅を指定します。
            デフォルトは [コンソールのウィンドウの幅 - 1] です。

        .INPUTS
            System.Char
            パイプを使用して、Char パラメーターを New-HR コマンドレットに渡すことができます。

        .OUTPUTS
            System.String
            水平線を文字列として取得します。

        .NOTES
            New-HR コマンドレットから取得するのは文字列なので、このコマンドのみを実行した場合、水平線は標準出力に表示されます。

        .EXAMPLE
            New-HR | Write-Host -ForegroundColor Red
            赤い色の水平線を、コンソールに出力します。

        .LINK
            PSHostRawUserInterface.BufferSize Property (System.Management.Automation.Host)
            http://msdn.microsoft.com/en-us/library/system.management.automation.host.pshostrawuserinterface.buffersize.aspx
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
Function Write-Title
{
    <#
        .SYNOPSIS
            コンソールにタイトルを表示します。

        .DESCRIPTION
            指定されたテキストを矩形に囲われた文字列を Write-Host コマンドレットを使って、コンソールに表示します。

        .PARAMETER Text
            タイトル文字列を指定します。
            複数行を指定するときは、1 行ずつ文字列配列で指定してください。
            指定した幅に収まらない場合は、必要に応じて、末尾 (あるいは全文) が '...' で省略されます。

        .PARAMETER Char
            囲いを構成する System.Char 型の文字を指定します。
            デフォルトは '#' です。

        .PARAMETER Width
            囲いの幅を指定します。
            デフォルトは [コンソールのウィンドウの幅 - 1] です。

        .PARAMETER Color
            表示色を (System.ConsoleColor 型で) 指定します。
            デフォルトは白 (System.ConsoleColor.White)です。

        .PARAMETER Padding
            タイトル文字列と囲いの上部および下部との間を何行空けるかを指定します。
            デフォルトは 0 [行] です。5 [行] までの値を指定することができます。

            タイトル文字列と囲いの囲いの左右の間は 2 文字分固定です。

        .PARAMETER ColumnWidth
            囲いを構成する左右の柱部分の幅を文字数で指定します。
            デフォルトは 2 [文字] です。5 [文字] までの値を指定することができます。

        .PARAMETER MinWidth
            囲いの幅の最小値を指定します。
            このパラメーターよりも Width パラメーターの方が小さかった場合に、囲いの幅は Width ではなく MinWidth になります。
            デフォルトは 6 です。6 から 512 までの値を指定することができます。

        .PARAMETER MaxWidth
            囲いの幅の最大値を指定します。
            このパラメーターよりも Width パラメーターの方が大きかった場合に、囲いの幅は Width ではなく MaxWidth になります。
            デフォルトは 256 です。6 から 1024 までの値を指定することができます。

        .INPUTS
            System.String
            パイプを使用して、Text パラメーターを Write-Title コマンドレットに渡すことができます。

        .OUTPUTS
            None

        .NOTES
            Write-Boolean コマンドレットの出力先はコンソールなので、標準出力には、通常、何も出力されません。

        .EXAMPLE
            Write-Title hoge
            コンソールのウィンドウ幅 (-1) の '#' で囲われたタイトル文字列 'hoge' を、コンソールに出力します。

        .EXAMPLE
            Write-Title -Text 'This is', 'miltiple-line', 'title.' -Char "*" -Width 42 -Padding 2 -ColumnWidth 1 -Color Yellow
            幅 42 [文字] の '*' で囲われた 'This is miltiple-line title.' というタイトルを、黄色い文字列でコンソールに出力します。
            タイトル文字列と囲いの上部および下部との間には 2 行のスペースがあり、左右の柱部分の文字列の幅は 1 文字です。

        .LINK
            Write-Host
            http://technet.microsoft.com/ja-JP/library/dd347596.aspx
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
        [ValidateRange((1+2+0+2+1),512)]
        [int]$MinWidth = (1+2+0+2+1),

        [Parameter(Mandatory=$false, Position=7)]
        [ValidateRange((1+2+0+2+1),1024)]
        [int]$MaxWidth = 256
    )

    Process
    {
        # Set minimum text length
        $minLength = $Text[0].Length
        $Text | % {
            if ($_.Length -gt '...'.Length) { $minLength = 1 + '...'.Length }
            elseif ($_.Length -gt $minLength) { $minLength = $_.Length }
        }

        # Validations (Update $MinWidth / $MaxWidth)
        if ($MinWidth -lt ($minLength + ($offsetLength = (($ColumnWidth + (' '.Length * 2)) * 2)))) { $MinWidth = ($minLength + $offsetLength) }
        if ($MaxWidth -lt ($minLength + $offsetLength)) { $MaxWidth = ($minLength + $offsetLength) }

        # Validations (Update $Width)
        if ($Width -lt $MinWidth) { $Width = $MinWidth }
        if ($Width -gt $MaxWidth) { $Width = $MaxWidth }

        # Cut text if needed
        foreach ($i in 0..($Text.Count - 1))
        {
            if (($Text[$i].Length + $offsetLength) -gt $Width)
            {
                $Text[$i] = $Text[$i].Substring(0, $Width - ($offsetLength + '...'.Length)) + '...'
            }
        }

        $hr = New-HR -Char $Char -Length $Width
        $side = "$Char" * $ColumnWidth
        $pad = $side + (' ' * ($Width - ($side.Length * 2))) + $side


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
                Write-Host ($side `
                    + (' ' * 2) `
                    + $_ `
                    + (' ' * ($Width - ($_.Length + (' '.Length * 2) + ($side.Length * 2)))) `
                    + $side) -ForegroundColor $Color
            }
        }

        # Padding
        for ($i = 0; $i -lt $Padding; $i++) { Write-Host $pad  -ForegroundColor $Color}

        # Tail
        Write-Host $hr -ForegroundColor $Color
    }
}

#####################################################################################################################################################
Function Write-Boolean
{
    <#
        .SYNOPSIS
            入力となるテスト対象の結果に応じて、指定された文字列を指定された色でコンソールに表示します。

        .DESCRIPTION
            入力となるテスト対象の結果を Boolean 型の真の場合、およびそれ以外の場合で、それぞれ異なる文字列を、指定された色でコンソールに表示します。
            デフォルトでは、真の場合は緑色の 'TRUE' の文字、それ以外の場合は赤い 'FALSE' の文字を表示します。

        .PARAMETER TestObject
            テスト対象を指定します。

        .PARAMETER Green
            TestObject の結果が真の場合に、緑色で表示する文字列を指定します。
            デフォルトは 'TRUE' です。

        .PARAMETER Red
            TestObject の結果が真でない場合に、赤く表示する文字列を指定します。
            デフォルトは 'FALSE' です。

        .INPUTS
            System.Boolean
            パイプを使用して、TestObject パラメーターを Write-Boolean コマンドレットに渡すことができます。

        .OUTPUTS
            None

        .NOTES
            Write-Boolean コマンドレットの出力先はコンソールなので、標準出力には、通常、何も出力されません。

        .EXAMPLE
            Write-Boolean $true
            緑色の 'TRUE' の文字をコンソールに表示します。

        .EXAMPLE
            Write-Boolean $false -Green 'Pass' -Red 'Fail'
            赤い 'Fail' の文字をコンソールに表示します。

        .LINK
            Write-Host
            http://technet.microsoft.com/ja-JP/library/dd347596.aspx
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
Function Show-Message
{
    <#
        .SYNOPSIS
            メッセージ ボックスを表示します。 

        .DESCRIPTION
            Show-Message コマンドレットは、System.Windows.Forms (System.Windows.Forms.dll) のロードを試みます。
            System.Windows.Forms のロードに成功すると、System.Windows.Forms.MessageBox.Show メソッドを使用して、メッセージ ボックスを表示します。 

        .PARAMETER Text
            メッセージ ボックスに表示するテキストを指定します。

        .PARAMETER Caption
            メッセージ ボックスのタイトル バーに表示するテキストを指定します。
            デフォルトでは、ホストセッションの名前 ($PSSessionApplicationName) が表示されます。

        .PARAMETER Buttons
            メッセージ ボックスに表示するボタンを [System.Windows.Forms.MessageBoxButtons] 型で指定します。
            デフォルトは、指定なしです。

        .INPUTS
            System.String
            パイプを使用して、Text パラメーターを Show-Message コマンドレットに渡すことができます。

        .OUTPUTS
            System.Windows.Forms.DialogResult
            System.Windows.Forms.MessageBox.Show メソッドの戻り値を、コマンドレットの戻り値として返します。

        .EXAMPLE
            Show-Message hoge
            メッセージ 'hoge' のメッセージ ボックスを表示します。

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
Function Get-DateString
{
    <#
        .SYNOPSIS
            指定した時刻に対する日付を、指定した書式の文字列として取得します。

        .DESCRIPTION
            指定した時刻に対する日付に対して、ロケール ID (LCID) および 標準またはカスタムの日時書式指定文字列を指定して、文字列として取得します。

        .PARAMETER Date
            表示する日付を指定します。
            デフォルトは本日です。

        .PARAMETER LCID
            ロケール ID (LCID) を指定します。
            デフォルトは、現在のカルチャーの LCID です。

        .PARAMETER Format
            書式指定文字列を指定します。
            デフォルトは 'D' です。

        .INPUTS
            System.DateTime
            パイプを使用して、Date パラメーターを Get-DateString コマンドレットに渡すことができます。

        .OUTPUTS
            System.String
            Show-Message コマンドレットは、日付文字列を返します。

        .NOTES
            Show-Message コマンドレットは、System.Globalization.CultureInfo() メソッドを使用しています。

        .EXAMPLE
            Get-DateString
            今日の日付を文字列として取得します。
            書式指定文字列はデフォルトの 'D' なので、日本であれば 'yyyy年M月d日' になります。

        .EXAMPLE 
            Get-DateString -Date 2014/4/29 -LCID en-US -Format m
            2014年4月29日 (0:00) に対する日付文字列を、ロケール ID 'en-US' および書式指定文字列 'm' の文字列として取得します。

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
Function Get-FileVersionInfo
{
    <#
        .SYNOPSIS
            ディスク上の物理ファイルのバージョン情報を取得します。

        .DESCRIPTION
            指定したファイルのバージョン情報を System.Diagnostics.FileVersionInfo として取得します。

        .PARAMETER Path
            ファイルバージョンを取得するファイルのパスを指定します。

        .PARAMETER ProductName
            バージョン情報 (System.Diagnostics.FileVersionInfo) ではなく、
            製品名 (System.Diagnostics.FileVersionInfo.ProductName) を文字列として取得します。

        .PARAMETER FileDescription
            バージョン情報 (System.Diagnostics.FileVersionInfo) ではなく、
            ファイルの説明 (System.Diagnostics.FileVersionInfo.FileDescription) を文字列として取得します。

        .PARAMETER FileVersion
            バージョン情報 (System.Diagnostics.FileVersionInfo) ではなく、
            ファイルバージョン (System.Diagnostics.FileVersionInfo.FileVersion) を文字列として取得します。

        .PARAMETER ProductVersion
            バージョン情報 (System.Diagnostics.FileVersionInfo) ではなく、
            製品バージョン (System.Diagnostics.FileVersionInfo.ProductVersion) を文字列として取得します。

        .PARAMETER Major
            ファイルバージョン (System.Diagnostics.FileVersionInfo.FileVersion) あるいは
            製品バージョン (System.Diagnostics.FileVersionInfo.ProductVersion) のメジャーバージョンのみを取得します。

        .PARAMETER Minor
            ファイルバージョン (System.Diagnostics.FileVersionInfo.FileVersion) あるいは
            製品バージョン (System.Diagnostics.FileVersionInfo.ProductVersion) のマイナーバージョンのみを取得します。

        .PARAMETER Build
            ファイルバージョン (System.Diagnostics.FileVersionInfo.FileVersion) あるいは
            製品バージョン (System.Diagnostics.FileVersionInfo.ProductVersion) のビルド番号のみを取得します。

        .PARAMETER Private
            ファイルバージョン (System.Diagnostics.FileVersionInfo.FileVersion) あるいは
            製品バージョン (System.Diagnostics.FileVersionInfo.ProductVersion) のプライベートビルド番号 (リビジョン) のみを取得します。

        .PARAMETER Composite
            ファイルバージョン (System.Diagnostics.FileVersionInfo.FileVersion) あるいは
            製品バージョン (System.Diagnostics.FileVersionInfo.ProductVersion) ではなく、メジャーバージョン、マイナーバージョン、ビルド番号、
            および、プライベートビルド番号 (リビジョン) を組み合わせた文字列として取得します。

        .INPUTS
            System.String
            パイプを使用して、ファイルのパス (Path パラメーター) を Get-GetFileVersionInfo コマンドレットに渡すことができます。

        .OUTPUTS
            System.Diagnostics.FileVersionInfo or System.String or System.Int32
            Get-FileVersionInfo コマンドレットは、System.Diagnostics.FileVersionInfo、System.String または System.Int32 を返します。

        .EXAMPLE
            Get-FileVersion -Path .\setup.exe
            カレントディレクトリにある setup.exe のバージョン情報を取得します。

        .EXAMPLE 
            Get-FileVersion -Path .\setup.exe -ProductVersion
            カレントディレクトリにある setup.exe の製品バージョンを取得します。

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
        [ValidateScript (
            {
                if (-not (Test-Path -Path $_ -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }
                return $true
            }
        )]
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
Function Get-ProductName
{
    <#
        .SYNOPSIS
            ファイルの製品名 (System.Diagnostics.FileVersionInfo.ProductName) を取得します。

        .DESCRIPTION
            Get-FileVersionInfo -ProductName のエイリアスです。

        .PARAMETER Path
            製品名を取得するファイルのパスを指定します。

        .INPUTS
            System.String
            パイプを使用して、ファイルのパス (Path パラメーター) を Get-ProductName コマンドレットに渡すことができます。

        .OUTPUTS
            System.String
            Get-ProductName コマンドレットは、System.String を返します。

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
Function Get-FileDescription
{
    <#
        .SYNOPSIS
            ファイルの説明 (System.Diagnostics.FileVersionInfo.FileDescription) を取得します。

        .DESCRIPTION
            Get-FileVersionInfo -FiletDescription のエイリアスです。

        .PARAMETER Path
            ファイルの説明を取得するファイルのパスを指定します。

        .INPUTS
            System.String
            パイプを使用して、ファイルのパス (Path パラメーター) を Get-FileDescription コマンドレットに渡すことができます。

        .OUTPUTS
            System.String
            Get-FileDescription コマンドレットは、System.String を返します。

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
Function Get-FileVersion
{
    <#
        .SYNOPSIS
            ファイルのファイルバージョン (System.Diagnostics.FileVersionInfo.FileVersion) を取得します。

        .DESCRIPTION
            Get-FileVersionInfo -FiletVersion のエイリアスです。

        .PARAMETER Path
            ファイルバージョンを取得するファイルのパスを指定します。

        .INPUTS
            System.String
            パイプを使用して、ファイルのパス (Path パラメーター) を Get-FileVersion コマンドレットに渡すことができます。

        .OUTPUTS
            System.String
            Get-FileVersion コマンドレットは、System.String を返します。

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
Function Get-ProductVersion
{
    <#
        .SYNOPSIS
            ファイルの製品バージョン (System.Diagnostics.FileVersionInfo.ProductVersion) を取得します。

        .DESCRIPTION
            Get-FileVersionInfo -ProductVersion のエイリアスです。

        .PARAMETER Path
            製品バージョンを取得するファイルのパスを指定します。

        .INPUTS
            System.String
            パイプを使用して、ファイルのパス (Path パラメーター) を Get-ProductVersion コマンドレットに渡すことができます。

        .OUTPUTS
            System.String
            Get-ProductVersion コマンドレットは、System.String を返します。

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
Function Get-HTMLString
{
    <#
        .SYNOPSIS
            HTML ファイルから HTML 要素を取得します。

        .DESCRIPTION
            HTML ファイルから、指定した HTML 要素を文字列として取得します。
            属性は取得できません。
            同名の要素が複数ある場合は、文字列配列として取得されます。

        .PARAMETER Path
            HTML 要素を取得するファイルのパスを指定します。

        .PARAMETER Tag
            取得する HTML 要素のタグを指定します。

        .INPUTS
            System.String
            パイプを使用して、ファイルのパス (Path パラメーター) を Get-ProductVersion コマンドレットに渡すことができます。

        .OUTPUTS
            System.String or System.String[]
            Get-HTMLString コマンドレットは、System.String または System.String[] を返します。

        .EXAMPLE
            Get-HtmlElement -Path .\sample.html -Tag h1
            カレントディレクトリにある sample.html から <H1> タグの要素を全て取得します。
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript (
            {
                if (-not (Test-Path -Path $_ -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }
                return $true
            }
        )]
        [string]$Path,

        [Parameter(Mandatory=$true, Position=1)][string]$Tag
    )

    Process
    {
        return ((Get-Content -Path $Path) -as [string]) -split '<' | ? { ($_ -split '>').Trim() -eq $Tag.Trim() } | % { (($_ -split '>')[1]).Trim() }
    }
}

#####################################################################################################################################################
Function Get-PrivateProfileString
{
    <#
        .SYNOPSIS
            INI ファイル (初期化ファイル) の設定値を取得します。

        .DESCRIPTION
            INI ファイル (初期化ファイル) の指定されたセクションとキーの組み合わせに関連付けられている値を文字列として取得します。

            同じセクションとキーの組み合わせが存在した場合は、ファイルの先頭から検索し、最初に検出した値を取得します。

        .PARAMETER Path
            INI ファイルのパスを指定します。

        .PARAMETER Section
            取得する設定値に関連付けられたセクションを指定します。

        .PARAMETER Key
            取得する設定値に関連付けられたキーを指定します。

        .INPUTS
            System.String
            パイプを使用して、ファイルのパス (Path パラメーター) を Get-PrivateProfileString コマンドレットに渡すことができます。

        .OUTPUTS
            System.String
            Get-PrivateProfileString コマンドレットは System.String を返します。

        .EXAMPLE
            Get-PrivateProfileString -Path .\toastpkg.inf -Section Version -Key DriverVer
            カレントディレクトリにある toastpkg.inf から、'Version' セクションの 'DriverVer' キーに対応する値を文字列として取得します。

        .NOTES
            コマンドレットの名前は Win32 API の GetPrivateProfileString を参考にしています。

        .LINK
            GetPrivateProfileString 関数
            http://msdn.microsoft.com/ja-jp/library/cc429779.aspx
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript (
            {
                if (-not (Test-Path -Path $_ -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }
                return $true
            }
        )]
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
Function Update-Content
{
    <#
        .SYNOPSIS
            テキストを更新します。

        .DESCRIPTION
            文字列配列型のテキストデータに対して、条件に合う文字列あるいは行全体を、指定された文字列に置き換えます。
            置き換え後の文字列を含むテキスト全体を出力します。

            置き換え対象は、検索対象となる文字列、あるいは、行番号で指定します。
            検索文字列と行番号の両方を指定することはできません。

            検索文字列が指定された場合は、読み込んだテキストを検索し、検索文字列を検出した箇所全てに対して、文字列の置き換えを行います。

            行番号が指定された場合は、指定された行全体を指定された文字列に置き換えます。

        .PARAMETER Line
            テキストの置き換えを行う行番号を指定します。
            SearchText パラメーターと同時に指定することはできません。

        .PARAMETER SearchText
            検索文字列を指定します。
            Line パラメーターと同時に指定することはできません。

        .PARAMETER UpdateText
            置換文字列を指定します。

        .PARAMETER InputObject
            置き換え対象のテキストデータを文字列配列として指定します。

        .INPUTS
            System.String
            パイプを使用して、テキストデータ (InputObject パラメーター) を Update-Content コマンドレットに渡すことができます。

        .OUTPUTS
            System.String
            Update-Content コマンドレットは、置換文字列を含むテキストデータ全体を返します。

        .EXAMPLE
            Update-Content -SearchText 'Hello' -UpdateText 'Good Morning' -InputObject (Get-Content -Path .\hello.txt) | % { Write-Host $_ }
            カレントディレクトリにある hello.txt を読み込んで、'Hello' の箇所を 'Good Morning' に置き換えた結果をコンソールに表示します。

        .EXAMPLE
            Update-Content -Line 8 -UpdateText "`t`t<H1>HELLO, WORLD!</H1>" -InputObject (Get-Content -Path .\example.html) | Out-File -FilePath .\out.html
            カレントディレクトリにあるを example.html を読み込んで、8 行目を指定した文字列に置き換えた結果を、カレントディレクトの out.html ファイルに保存します。
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
Function Get-WindowHandler
{
    <#
        .SYNOPSIS
            ウィンドウ ハンドル (HWND) を取得します。

        .DESCRIPTION
            指定したプロセス ID に対応するウィンドウのウィンドウ ハンドル (HWND) を取得します。
            プロセス ID を指定しなかった場合は、現在のプロセスに対するプロセス ID ($PID) が取得されます。

        .PARAMETER PID
            取得するウィンドウ ハンドルのプロセス ID を指定します。
            デフォルトは、コンソールのプロセス ID ($PID) です。

        .INPUTS
            System.Int32
            パイプを使用して、プロセス ID (PID パラメーター) を Get-WindowHandler コマンドレットに渡すことができます。

        .OUTPUTS
            System.IntPtr
            Get-WindowHandler コマンドレットは System.IntPtr を返します。

        .EXAMPLE
            Get-WindowHandler
            現在のプロセス (ホスト コンソール) に対するウィンドウ ハンドルを取得します。

        .LINK
            Process.MainWindowHandle プロパティ (System.Diagnostics)
            http://msdn.microsoft.com/ja-jp/library/system.diagnostics.process.mainwindowhandle.aspx
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
Function New-StructArray
{
    <#
        .SYNOPSIS
            構造体の配列ようなをコンテナを作成します。

        .DESCRIPTION
            任意の (静的な) メンバー変数 (プロパティー) を持つカスタムオブジェクトの配列を作成します。
            
            作成したカスタムオブジェクトに対して ToString メソッドを使用すると、HTML の Table 要素として取り出すことができます。
            引数を指定しない場合、 ToString メソッドは下記のような書式で出力されます。 (改行は挿入されません。)

                <TR>
                    <TH>Name</TH>
                    <TD>Value</TD>
                </TR>

            ToString メソッドの 1 番目の引数に 'TABLE' を指定すると、下記のような出力になります。 (改行は挿入されません。)

                <TABLE>
                    <TR>
                        <TH>Name</TH>
                        <TD>Value</TD>
                    </TR>
                </TABLE>

            ToString メソッドの 2 番目、3 番目 および 4 番目の引数は、それぞれ、<TR>、<TH> および <TD> タグの要素名に対応します。
            たとえば、ToString('A', 'B', 'C', 'D') のようにコールすると、下記のような出力になります。 (改行は挿入されません。)

                <A>
                    <B>
                        <C>Name</C>
                        <D>Value</D>
                    </B>
                </A>

        .PARAMETER Members
            静的なメンバー変数 (NoteProperty) の名前を文字列配列として指定します。
            '=' に続けて初期値を設定することもできます。

        .PARAMETER Count
            作成する配列の個数を指定します。
            デフォルトは 1 [個] です。

        .INPUTS
            System.String[]
            パイプを使用して、Members パラメーターを New-StructArray コマンドレットに渡すことができます。

        .OUTPUTS
            System.Object[]
            New-StructArray コマンドレットは System.Object[] を返します。

        .NOTES
            構造体 (の配列) の代用として使用されることを想定しています。

        .EXAMPLE
            $obj = New-StructArray -Members a=1,b=2,c=3 -Count 3
            メンバー変数が a, b および c であるカスタムオブジェクトの配列を作成します。
            配列の個数は 3 です。
            a, b および c の初期値は、それぞれ 1, 2 および 3 です。

        .EXAMPLE
            $obj[0].ToString('TABLE')
            obj オブジェクトの最初 (0 番目) の要素を HTML 文字列として表示します。
            表示される文字列は、たとえば、下記のようなものになります。 (改行は挿入されません。)

                <TABLE>
                    <TR>
                        <TH>a</TH>
                        <TD>1</TD>
                    </TR>
                    <TR>
                        <TH>b</TH>
                        <TD>2</TD>
                    </TR>
                    <TR>
                        <TH>c</TH>
                        <TD>3</TD>
                    </TR>
                </TABLE>

        .LINK
            Add-Member
            http://technet.microsoft.com/ja-JP/library/dd347695.aspx
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
                        $text += ("<$Name>" + ([Microsoft.PowerShell.Commands.MemberDefinition]$_).Name + "</$Name>")
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
Function Get-ByteArray
{
    <#
        .SYNOPSIS
            ファイルからバイト配列を取得します。

        .DESCRIPTION
            指定したファイルの中身をバイト配列 (System.Byte[]) として読み込みます。

        .PARAMETER Path
            バイト配列を読み込むファイルのパスを指定します。

        .INPUTS
            System.String[]
            パイプを使用して、ファイルのパス (Path パラメーター) を Get-ByteArray コマンドレットに渡すことができます。

        .OUTPUTS
            System.Object[]
            Get-ByteArray コマンドレットは System.Object[] を返します。

        .EXAMPLE
            $bin = Get-ByteArray -Path .\test.bin
            カレントディレクトリにある test.bin をバイト配列として読み込み、変数 bin に格納します。
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript(
            {
                if (-not (Test-Path -Path $_ -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }
                return $true
            }
        )]
        [string]$Path
    )

    Process
    {
        try
        {
            $file = New-Object System.IO.FileStream ((Convert-Path -Path $Path), [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
            $data = New-Object byte[] $file.Length

            foreach ($i in 0..($file.Length - 1))
            {
                $data[$i] += $file.ReadByte() -as [byte]
            }

            return $data
        }
        catch { throw }
        finally { $file.Close() }
    }
}

#####################################################################################################################################################
Function ConvertFrom-ByteArray
{
    <#
        .SYNOPSIS
            バイト配列を文字列に変換します。

        .DESCRIPTION
            バイト配列 (System.Byte[]) として読み込んだデータを、文字列 (System.String) に変換して出力します。

        .PARAMETER InputObject
            読み込むバイト配列 (System.Byte[]) を指定します。

        .PARAMETER Separator
            バイト配列を文字列として出力する際に、各バイトデータを区切る System.Char 型の文字として指定します。
            デフォルトでは、Hex パラメーターが指定されているときは ':'、それ以外は '.' です。

        .PARAMETER Hex
            9 より大きいデータを 16進数で表現するときに指定します。
            文字列の取得は System.BitConverter.ToString メソッドにより行われます。

            このパラメーターが指定されていないときは、10進数で表現されます。

        .INPUTS
            System.Byte[]
            パイプを使用して、InputObject パラメーターを ConvertFrom-ByteArray コマンドレットに渡すことができます。

        .OUTPUTS
            System.String
            ConvertFrom-ByteArray コマンドレットは System.String を返します。

        .NOTES
            出力は、文字列配列 (System.String[]) ではなく、文字列 (System.String) です。

        .EXAMPLE
            Get-ByteArray -Path .\test.bin | ConvertFrom-ByteArray -Hex | Write-Host -ForegroundColor Red
            カレントディレクトリにある test.bin をバイト配列として読み込み、16進文字列としてコンソールに表示します。

        .LINK
            BitConverter.ToString メソッド (System)
            http://msdn.microsoft.com/ja-jp/library/system.bitconverter.tostring.aspx
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][byte[]]$InputObject,
        [Parameter(Mandatory=$false, Position=1)][char]$Separator,
        [Parameter(Mandatory=$false)][switch]$Hex
    )

    Begin
    {
        # Set Separator
        if (-not $Separator)
        {
            if ($Hex) { $Separator = ':' }
            else { $Separator = '.' }
        }

        # Prepare return value
        $text = [string]::Empty
    }

    Process
    {
        if ($Hex)
        {
            # Hexadecimal
            if ($text -ne [string]::Empty) { $text += $Separator }
            $text += [System.BitConverter]::ToString($InputObject) -replace '-', $Separator
        }
        else
        {
            # Decimal
            $InputObject | % {
                if ($text -ne [string]::Empty) { $text += $Separator }
                $text += $_.ToString()
            }
        }
    }

    End
    {
        # Return
        return $text
    }
}

#####################################################################################################################################################
Function ConvertTo-ByteArray
{
    <#
        .SYNOPSIS
            文字列をバイト配列に変換します。

        .DESCRIPTION
            文字列 (System.String) として読み込んだデータを、バイト配列 (System.Byte[]) に変換して出力します。

        .PARAMETER InputObject
            入力文字列 (System.String) を指定します。

        .PARAMETER Separator
            入力文字列をバイト配列として解釈するために、各バイトデータの要素を区切る System.Char 型の文字を指定します。
            デフォルトでは、Hex パラメーターが指定されているときは ':'、それ以外は '.' です。

        .PARAMETER Hex
            入力文字列が 16進数で表現されているときに指定します。
            文字列の解析は System.Convert.ToInt32 メソッドにより行われます。

            このパラメーターが指定されていないときは、10進数で表現されているものと解釈します。

        .INPUTS
            System.String
            パイプを使用して、InputObject パラメーターを ConvertTo-ByteArray コマンドレットに渡すことができます。

        .OUTPUTS
            System.Object[]
            ConvertFrom-ByteArray コマンドレットは System.Object[] を返します。

        .NOTES
            出力は System.Object[] ですが、各要素は System.Byte です。

        .EXAMPLE
            [byte[]]$bin = ConvertTo-ByteArray -InputObject '1.3.6.1.2.1.1.5'
            文字列 '1.3.6.1.2.1.1.5' をバイト配列に変換して、変数 bin に格納します。

        .LINK
            Convert.ToInt32 メソッド (System)
            http://msdn.microsoft.com/ja-jp/library/system.convert.toint32.aspx
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][string]$InputObject,
        [Parameter(Mandatory=$false, Position=1)][char]$Separator,
        [Parameter(Mandatory=$false)][switch]$Hex
    )

    Begin
    {
        # Set Separator
        if (-not $Separator)
        {
            if ($Hex) { $Separator = ':' }
            else { $Separator = '.' }
        }

        # Prepare return value
        [byte[]]$bin = $null
    }

    Process
    {
        $InputObject.Split($Separator) | % {

            if ($Hex)
            {
                # Hexadecimal (Text)
                try { [byte[]]$bin += [System.Convert]::ToInt32($_, 16) -as [byte] }
                catch { throw New-Object System.ArgumentException }
            }
            else
            {
                # Decimal
                if (($_ -as [int]) -le [byte]::MaxValue) { [byte[]]$bin += $_ -as [int] }
                else { throw New-Object System.ArgumentOutOfRangeException }
            }
        }
    }

    End
    {
        # Return
        return $bin
    }
}

#####################################################################################################################################################
