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
 #  2013/11/02  Version 0.0.0.1
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
 #  2014/04/30  Version 0.12.0.0
 #  2014/05/05  Version 0.13.0.0
 #  2014/05/06  Version 1.0.0.0
 #
 #>
#####################################################################################################################################################

######## NOTE #######################################################################################################################################
<#
 # P/Invoke 関連のリソース URL
 #
 #  アンマネージ DLL 関数の処理
 #  http://msdn.microsoft.com/ja-jp/library/26thfadc.aspx
 #
 #  プラットフォーム呼び出しのデータ型
 #  http://msdn.microsoft.com/ja-jp/library/ac7ay120.aspx
 #>
<#
 # Win32 関連のリソース URL
 #
 #  LoadLibrary 関数
 #  http://msdn.microsoft.com/ja-jp/library/cc429241.aspx
 #
 #  LoadLibraryEx 関数
 #  http://msdn.microsoft.com/ja-jp/library/cc429243.aspx
 #
 #  FreeLibrary 関数
 #  http://msdn.microsoft.com/ja-jp/library/cc429103.aspx
 #
 #  LoadString 関数
 #  http://msdn.microsoft.com/ja-jp/library/cc410872.aspx
 #>
#####################################################################################################################################################

#####################################################################################################################################################
# Variables

# Namespace
$Global:Win32Namespace = 'BUILDLet.PowerShell.PackageBuilder.Win32'

# Type Name
$Script:Kernel32  = 'Kernel32'
$Script:User32    = 'User32'
$Script:HHCtrl    = 'HHCtrl'

# LoadLibraryEx() Function
$Script:Kernel32_Signature =
@'
[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
public static extern IntPtr LoadLibraryEx(
    string lpLibFileName,  // 実行可能モジュール名へのポインタ
    IntPtr hFile,          // 予約されています。NULL を指定してください
    uint dwFlags           // エントリポイント実行フラグ
);
'@

# FreeLibrary() Function
$Script:Kernel32_Signature +=
@'
[DllImport("kernel32.dll")]
public static extern bool FreeLibrary(
    IntPtr hModule        // DLL モジュールのハンドル
);
'@

# LoadString() Function
$Script:User32_Signature =
@'
[DllImport("user32.dll", CharSet = CharSet.Unicode)]
public static extern int LoadString(
    IntPtr hInstance,                    // リソースモジュールのハンドル
    uint uID,                            // リソース識別子
    [MarshalAs(UnmanagedType.LPTStr)]
    System.Text.StringBuilder lpBuffer,  // リソースが格納されるバッファ
    int nBufferMax                       // バッファのサイズ
);
'@

# HtmlHelp() Function
$Script:HHCtrl_Signature =
@'
[DllImport("hhctrl.ocx")]
public static extern IntPtr HtmlHelp(
    IntPtr hwndCaller,
    string pszFile,
    uint uCommand,
    int dwData
);
'@

# HTML Help Command
$Script:HTMLHelpCommand_Signature = 
@'
public enum HTMLHelpCommand
{
    HH_DISPLAY_TOPIC  = 0x0000,
    HH_DISPLAY_TOC    = 0x0001,
    HH_DISPLAY_INDEX  = 0x0002,
    HH_DISPLAY_SEARCH = 0x0003,
    HH_HELP_CONTEXT   = 0x000F,
    HH_CLOSE_ALL      = 0x0012
};
'@

$Script:LoadLibraryEx_dwFlags_Signature = 
@'
public enum LoadLibraryEx_dwFlags
{
    DONT_RESOLVE_DLL_REFERENCES         = 0x00000001,
    LOAD_IGNORE_CODE_AUTHZ_LEVEL        = 0x00000010,
    LOAD_LIBRARY_AS_DATAFILE            = 0x00000002,
    LOAD_LIBRARY_AS_DATAFILE_EXCLUSIVE  = 0x00000040,
    LOAD_LIBRARY_AS_IMAGE_RESOURCE      = 0x00000020,
    LOAD_LIBRARY_SEARCH_APPLICATION_DIR = 0x00000200,
    LOAD_LIBRARY_SEARCH_DEFAULT_DIRS    = 0x00001000,
    LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR    = 0x00000100,
    LOAD_LIBRARY_SEARCH_SYSTEM32        = 0x00000800,
    LOAD_LIBRARY_SEARCH_USER_DIRS       = 0x00000400,
    LOAD_WITH_ALTERED_SEARCH_PATH       = 0x00000008
};
'@

#####################################################################################################################################################
# Scripts
Add-Type -MemberDefinition $Script:Kernel32_Signature -Name $Script:Kernel32 -Namespace $Global:Win32Namespace
Add-Type -MemberDefinition $Script:User32_Signature   -Name $Script:User32   -Namespace $Global:Win32Namespace
Add-Type -MemberDefinition $Script:HHCtrl_Signature   -Name $Script:HHCtrl   -Namespace $Global:Win32Namespace

Add-Type -TypeDefinition $Script:HTMLHelpCommand_Signature
Add-Type -TypeDefinition $Script:LoadLibraryEx_dwFlags_Signature

#####################################################################################################################################################
Function Invoke-LoadLibraryEx
{
    <#
        .SYNOPSIS
            LoadLibraryEx 関数を使用して、ライブラリーファイルをロードします。

        .DESCRIPTION
            LoadLibraryEx 関数を使用して、指定された実行可能モジュールを呼び出し側プロセスのアドレス空間にマップします。
            実行可能モジュールは .DLL ファイルまたは .EXE ファイルです。

        .PARAMETER lpLibFileName
            Windows の実行可能モジュール (.DLL ファイルまたは .EXE ファイル) のパスを指定します。
            このパラメーターは LoadLibraryEx 関数の lpLibFileName パラメーターとして使用されます。

        .PARAMETER dwFlags
            モジュールをロードするときのアクションを指定します。デフォルトは LOAD_LIBRARY_AS_DATAFILE です。
            LoadLibraryEx_dwFlags 列挙体として定義済みの値を指定することができます。

            このパラメーターは LoadLibraryEx 関数の dwFlags パラメーターとして使用されます。
            詳細は LoadLibraryEx 関数の使用方法を参照ください。

        .INPUTS
            None
            パイプを使用してこのコマンドレットに入力を渡すことはできません。

        .OUTPUTS
            System.IntPtr
            Invoke-LoadLibraryEx コマンドレットは、LoadLibraryEx 関数が成功すると、マップされた実行可能モジュールのハンドルを返します。

        .NOTES
            PackageBuilder モジュールがインポートされると、P/Invoke を使用して、いくつかの Win32 API 関数が、
            名前空間 BUILDLet.PowerShell.PackageBuilder.Win32 にロードされます。
            (この名前空間は、PackageBuilder モジュールで $Global:Win32Namespace として定義されています。)
            
            ロードされる関数は

                LoadLibraryEx 関数
                FreeLibrary 関数
                LoadString 関数
                HtmlHelp 関数

            です。

            また、これらの関数で使用するいくつかの列挙体が同時に定義されます。

            定義される列挙体は

                HTMLHelpCommand 列挙体
                LoadLibraryEx_dwFlags 列挙体

            です。

        .EXAMPLE
            Invoke-LoadLibraryEx .\Resource.dll
            カレントディレクトリにある Resource.dll をライブラリーファイルとしてロードします。

        .LINK
            LoadLibraryEx function (Windows)
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms684179.aspx

            LoadLibraryEx 関数
            http://msdn.microsoft.com/ja-jp/library/cc429243.aspx
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript (
            {
                if (-not (Test-Path -Path $_ -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }
                return $true
            }
        )]
        [string]$lpLibFileName,

        [Parameter(Mandatory=$false, Position=1)][UInt32]$dwFlags = [LoadLibraryEx_dwFlags]::LOAD_LIBRARY_AS_DATAFILE
    )

    Process
    {
        try { return [BUILDLet.PowerShell.PackageBuilder.Win32.Kernel32]::LoadLibraryEx($lpLibFileName, [IntPtr]::Zero, $dwFlags) }
        catch { throw }
    }
}

#####################################################################################################################################################
Function Invoke-FreeLibrary
{
    <#
        .SYNOPSIS
            FreeLibrary 関数を使用して、ライブラリーファイルを開放します。

        .DESCRIPTION
            FreeLibrary 関数を使用して、ロード済みのダイナミックリンクライブラリ (DLL) モジュールの参照カウントを 1 つ減らします。
            参照カウントが 0 になると、モジュールは呼び出し側プロセスのアドレス空間からマップ解除され、そのモジュールのハンドルは無効になります。

        .PARAMETER hModule
            ロード済みの DLL モジュールのハンドルを指定します。
            LoadLibrary 関数または GetModuleHandle 関数が、このハンドルを返します。 
            このパラメーターは FreeLibrary 関数の hModule パラメーターとして使用されます。

        .INPUTS
            None
            パイプを使用してこのコマンドレットに入力を渡すことはできません。

        .OUTPUTS
            System.Int32
            LoadLibrary 関数が成功すると、0 以外の値を返します。

        .LINK
            FreeLibrary function (Windows)
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms683152.aspx

            FreeLibrary 関数
            http://msdn.microsoft.com/ja-jp/library/cc429103.aspx
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript ( {$_ -ne [IntPtr]::Zero } )]
        [IntPtr]$hModule
    )

    Process
    {
        try { return [BUILDLet.PowerShell.PackageBuilder.Win32.Kernel32]::FreeLibrary($hModule) }
        catch { throw }
    }
}

#####################################################################################################################################################
Function Invoke-LoadString
{
    <#
        .SYNOPSIS
            LoadString 関数を使用して、文字列リソースを取得します。

        .DESCRIPTION
            LoadString 関数を使用して、指定されたモジュールに関連付けられている実行可能ファイルから文字列リソースをロードし、
            バッファへコピーして、最後に 1 つの NULL 文字を追加します。

        .PARAMETER hInstance
            モジュールインスタンスのハンドルを指定します。このモジュールの実行可能ファイルは、ロードするべき文字列のリソースを保持しています。
            このパラメーターは LoadString 関数の hInstance パラメーターとして使用されます。

        .PARAMETER uID
            ロードするべき文字列の整数の識別子 (リソース ID) を指定します。
            このパラメーターは LoadString 関数の nID パラメーターとして使用されます。

        .PARAMETER nBufferMax
            バッファのサイズを TCHAR 単位で指定します。デフォルトは 1024 です。
            バッファのサイズが不足して、指定された文字列の一部を格納できない場合、文字列は途中で切り捨てられます。
            このパラメーターは LoadString 関数の nBufferMax パラメーターとして使用されます。

        .INPUTS
            None
            パイプを使用してこのコマンドレットに入力を渡すことはできません。

        .OUTPUTS
            System.String
            関数が成功すると、バッファにコピーされた文字の数が TCHAR 単位で返します (終端の NULL は含まない) 。
            文字列リソースが存在しない場合は 0 を返します。

        .LINK
            LoadString function (Windows)
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms647486.aspx

            LoadString 関数
            http://msdn.microsoft.com/ja-jp/library/cc410872.aspx
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript ( {$_ -ne [IntPtr]::Zero } )]
        [IntPtr]$hInstance,

        [Parameter(Mandatory=$true, Position=1)][int]$uID,
        [Parameter(Mandatory=$false, Position=2)][int]$nBufferMax = 1024
    )

    Process
    {
        try
        {
            $lpBuffer = New-Object -TypeName System.Text.StringBuilder($nBufferMax)
            if ([BUILDLet.PowerShell.PackageBuilder.Win32.User32]::LoadString($hInstance, $uID, $lpBuffer, $nBufferMax) -gt $nBufferMax) { throw }
        }
        catch { throw }

        return $lpBuffer.ToString()
    }
}

#####################################################################################################################################################
Function Get-ResourceString
{
    <#
        .SYNOPSIS
            Win32 API を使用して、文字列リソースを取得します。

        .DESCRIPTION
            Invoke-LoadLibraryEx コマンドレット、Invoke-LoadString コマンドレット、 および、Invoke-FreeLibrary コマンドレットを使用して、
            ライブラリーファイルに格納されている文字列リソースを取得します。

        .PARAMETER Path
            ライブラリーファイルのパスを指定します。
            ライブラリーファイルは、Windows の実行可能モジュール (.DLL ファイルまたは .EXE ファイル) です。

        .PARAMETER uID
            ロードするべき文字列の整数の識別子 (リソース ID) を指定します。
            配列として複数の識別子を指定することができます。

        .PARAMETER nBufferMax
            バッファのサイズを TCHAR 単位で指定します。デフォルトは 1024 です。
            バッファのサイズが不足して、指定された文字列の一部を格納できない場合、文字列は途中で切り捨てられます。
            このパラメーターは LoadString 関数の nBufferMax パラメーターとして使用されます。

        .INPUTS
            None
            パイプを使用してこのコマンドレットに入力を渡すことはできません。

        .OUTPUTS
            System.String or System.String[]
            Get-ResourceString コマンドレットは、System.String または System.String[] を返します。

        .EXAMPLE
            Get-ResourceString -Path .\Resource.dll -uID (201..203) | Write-Host
            カレントディレクトリにある Resource.dll から、リソース ID が 201、202 および 203 の文字列を取得し、コンソールに表示します。
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript (
            {
                if (-not (Test-Path -Path $_ -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }
                return $true
            }
        )]
        [string]$Path,

        [Parameter(Mandatory=$true, Position=1)][int[]]$uID,
        [Parameter(Mandatory=$false, Position=2)][int]$nBufferMax = 1024
    )

    Process
    {
        try
        {
            # LoadLibraryEx
            [IntPtr]$lib = Invoke-LoadLibraryEx -lpLibFileName $Path

            # LoadString
            foreach ($i in $uID)
            {
                [string[]]$texts += Invoke-LoadString -hInstance $lib -uID $i -nBufferMax $nBufferMax
            }

            # FreeLibrary
            if ((Invoke-FreeLibrary -hModule $lib) -eq 0) { throw }
        }
        catch { throw }
        
        return $texts
    }
}

#####################################################################################################################################################
Function Invoke-HtmlHelp
{
    <#
        .SYNOPSIS
            HtmlHelp 関数を使用して、HTML ヘルプを開きます。

        .DESCRIPTION
            HtmlHelp 関数を使用して、HTML ヘルプを開きます。

        .PARAMETER Path
            HTML ヘルプファイルのパスを指定します。
            このパラメーターは HtmlHelp 関数の pszFile パラメーターとして使用されます。

        .PARAMETER uCommand
            HTML Help API でサポートされているコマンドを指定します。デフォルトは HH_DISPLAY_TOC です。
            HTMLHelpCommand 列挙体として定義済みの値を指定することができます。

            このパラメーターは HtmlHelp 関数の uCommand パラメーターとして使用されます。
            詳細は Microsoft の Web サイトを参照してください。

        .PARAMETER hwndCaller
            HtmlHelp 関数をコールするウィンドウのウィンドウ ハンドル (HWND) を指定します。
            デフォルトは System.IntPtr.Zero です。
            このパラメーターは HtmlHelp 関数の hwnCaller パラメーターとして使用されます。

        .PARAMETER dwData
            このパラメーターは HtmlHelp 関数の dwData パラメーターとして使用されます。
            デフォルトは 0 です。

        .INPUTS
            System.String
            パイプを使用して、HTML ヘルプファイルのパス (Path パラメーター) を Invoke-HtmlHelp コマンドレットに渡すことができます。

        .OUTPUTS
            None
            このコマンドレットの出力はありません。

        .EXAMPLE
            Invoke-HtmlHelp -Path 'C:\Windows\Help\mui\0411\mmc.CHM' -hwndCaller (Get-WindowHandler)
            指定された HTML ヘルプファイルを開きます。uCommand には、デフォルトである HH_DISPLAY_TOC が指定されます。
            
        .EXAMPLE
            Invoke-HtmlHelp -uCommand ([HTMLHelpCommand]::HH_CLOSE_ALL)
            現在のウィンドウから開かれた HTML ヘルプファイルを全て閉じます。

        .LINK
            Microsoft HTML Help とは
            http://msdn.microsoft.com/ja-jp/library/cc344272.aspx

            About the HTML Help API Function (Windows)
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms670172.aspx

            About Commands (Windows)
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms644704.aspx


            Microsoft HTML Help 1.4 (Windows)
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms670169.aspx

            Microsoft HTML Help Downloads (Windows)
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms669985.aspx

            HTML Help End-User License Agreement (Windows)
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms669979.aspx
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false, Position=0)][string]$Path,
        [Parameter(Mandatory=$false, Position=1)][UInt32]$uCommand,
        [Parameter(Mandatory=$false, Position=2)][IntPtr]$hwndCaller =[IntPtr]::Zero,
        [Parameter(Mandatory=$false, Position=3)][int]$dwData = 0
    )

    Process
    {
        if (-not $uCommand) { $uCommand = [HTMLHelpCommand]::HH_DISPLAY_TOC }

        [BUILDLet.PowerShell.PackageBuilder.Win32.HHCtrl]::HtmlHelp($hwndCaller, $Path, $uCommand, $dwData)
    }
}

#####################################################################################################################################################
