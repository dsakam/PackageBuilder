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
 #  2014/01/16  Version 0.4.0.0
 #
 #>
#####################################################################################################################################################

######## NOTE #######################################################################################################################################
<#
 # P/Invoke 関連のリソース URL
 #
 # アンマネージ DLL 関数の処理
 # http://msdn.microsoft.com/ja-jp/library/26thfadc.aspx
 #
 # プラットフォーム呼び出しのデータ型
 # http://msdn.microsoft.com/ja-jp/library/ac7ay120.aspx
 #>
<#
 # Win32 関連のリソース URL
 #
 # LoadLibrary 関数
 # http://msdn.microsoft.com/ja-jp/library/cc429241.aspx
 #
 # LoadLibraryEx 関数
 # http://msdn.microsoft.com/ja-jp/library/cc429243.aspx
 #
 # FreeLibrary 関数
 # http://msdn.microsoft.com/ja-jp/library/cc429103.aspx
 #
 # LoadString 関数
 # http://msdn.microsoft.com/ja-jp/library/cc410872.aspx
 #>
#####################################################################################################################################################

#####################################################################################################################################################
# Variables
$script:Win32Namespace = "BUILDLet.PowerShell.PackageBuilder"

#####################################################################################################################################################
Function Invoke-LoadLibrary {

<#
.SYNOPSIS
    LoadLibrary()


.DESCRIPTION
    使用しないでください。


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

    [CmdletBinding()] Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript ( {
            if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
            elseif ((Get-Item -Path $_).GetType() -ne [System.IO.FileInfo]) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$lpFileName
    )

    Process
    {
        $signature = @"
[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
public static extern IntPtr LoadLibrary(
    string lpFileName // モジュールのファイル名
);
"@
        # LoadLibrary
        return (Add-Type -MemberDefinition $signature -Name "Win32LoadLibrary" -Namespace $script:Win32Namespace -PassThru)::LoadLibrary($lpFileName)
    }
}

#####################################################################################################################################################
Function Invoke-LoadLibraryEx {

<#
.SYNOPSIS
    LoadLibraryEx()


.DESCRIPTION


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

    [CmdletBinding()] Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript ( {
            if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
            elseif ((Get-Item -Path $_).GetType() -ne [System.IO.FileInfo]) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$lpLibFileName,

        [Parameter(Mandatory=$false, Position=1)][UInt32]$dwFlags = ($LOAD_LIBRARY_AS_DATAFILE = 2)
    )

    Process
    {
        $signature = @"
[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
public static extern IntPtr LoadLibraryEx(
    string lpLibFileName,  // 実行可能モジュール名へのポインタ
    IntPtr hFile,          // 予約されています。NULL を指定してください
    uint dwFlags           // エントリポイント実行フラグ
);
"@
        # LoadLibraryEx
        $win32 = Add-Type -MemberDefinition $signature -Name "Win32LoadLibraryEx" -Namespace $script:Win32Namespace -PassThru

        return $win32::LoadLibraryEx($lpLibFileName, [IntPtr]::Zero, $dwFlags)
    }
}

#####################################################################################################################################################
Function Invoke-FreeLibrary {

<#
.SYNOPSIS
    FreeLibrary()


.DESCRIPTION


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

    [CmdletBinding()] Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript ( {$_ -ne [IntPtr]::Zero } )]
        [IntPtr]$hModule
    )

    Process
    {
        $signature = @"
[DllImport("kernel32.dll")]
public static extern bool FreeLibrary(
    IntPtr hModule        // DLL モジュールのハンドル
);
"@
        # FreeLibrary
        return (Add-Type -MemberDefinition $signature -Name "Win32FreeLibrary" -Namespace $script:Win32Namespace -PassThru)::FreeLibrary($hModule)
    }
}

#####################################################################################################################################################
Function Invoke-LoadString {

<#
.SYNOPSIS
    LoadString()


.DESCRIPTION


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

    [CmdletBinding()] Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript ( {$_ -ne [IntPtr]::Zero } )]
        [IntPtr]$hInstance,

        [Parameter(Mandatory=$true, Position=1)][int]$uID,
        [Parameter(Mandatory=$false, Position=2)][int]$nBufferMax = 1024
    )

    Process
    {
        $signature = @"
[DllImport("user32.dll", CharSet = CharSet.Unicode)]
public static extern int LoadString(
    IntPtr hInstance,                    // リソースモジュールのハンドル
    uint uID,                            // リソース識別子
    [MarshalAs(UnmanagedType.LPTStr)]
    System.Text.StringBuilder lpBuffer,  // リソースが格納されるバッファ
    int nBufferMax                       // バッファのサイズ
);
"@
        $win32 = Add-Type -MemberDefinition $signature -Name "Win32LoadString" -Namespace $script:Win32Namespace -PassThru
        $lpBuffer = New-Object -TypeName System.Text.StringBuilder($nBufferMax)

        # LoadString
        if ($win32::LoadString($hInstance, $uID, $lpBuffer, $nBufferMax) -gt $nBufferMax) { throw Exception }
        
        return $lpBuffer.ToString()
    }
}

#####################################################################################################################################################
Function Get-ResourceString {

<#
.SYNOPSIS
    文字列リソースを取得します。


.DESCRIPTION


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

    [CmdletBinding()] Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript ( {
            if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
            elseif ((Get-Item -Path $_).GetType() -ne [System.IO.FileInfo]) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$Path,

        [Parameter(Mandatory=$true, Position=1)][int[]]$uID,
        [Parameter(Mandatory=$false, Position=2)][int]$nBufferMax = 1024
    )

    Process
    {

        # LoadLibraryEx
        [IntPtr]$lib = Invoke-LoadLibraryEx -lpLibFileName $Path -dwFlags ($LOAD_LIBRARY_AS_DATAFILE = 2)

        # LoadString
        foreach ($i in $uID)
        {
            [string[]]$texts += Invoke-LoadString -hInstance $lib -uID $i -nBufferMax $nBufferMax
        }

        # FreeLibrary
        if ((Invoke-FreeLibrary -hModule $lib) -eq 0) { throw Exception }
        
        return $texts
    }
}

#####################################################################################################################################################
Function Invoke-HtmlHelp {

<#
.SYNOPSIS
    HTML ヘルプを開きます。


.DESCRIPTION


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
    Microsoft HTML Help とは
    http://msdn.microsoft.com/ja-jp/library/cc344272.aspx

    Microsoft HTML Help 1.4 (Windows)
    http://msdn.microsoft.com/en-us/library/windows/desktop/ms670169.aspx

    About the HTML Help API Function (Windows)
    http://msdn.microsoft.com/en-us/library/windows/desktop/ms670172.aspx

    Microsoft HTML Help Downloads (Windows)
    http://msdn.microsoft.com/en-us/library/windows/desktop/ms669985.aspx

    HTML Help End-User License Agreement (Windows)
    http://msdn.microsoft.com/en-us/library/windows/desktop/ms669979.aspx
#>

    [CmdletBinding()] Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript ( {
            if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
            elseif ((Get-Item -Path $_).GetType() -ne [System.IO.FileInfo]) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$Path,

        [Parameter(Mandatory=$false, Position=1)][UInt32]$uCommand,
        [Parameter(Mandatory=$false, Position=2)][IntPtr]$hwndCaller =[IntPtr]::Zero,
        [Parameter(Mandatory=$false, Position=3)][int]$dwData = 0
    )

    Process
    {
        $signature = @"
[DllImport("hhctrl.ocx")]
public static extern IntPtr HtmlHelp(IntPtr hwndCaller, string pszFile, uint uCommand, int dwData);
"@

        $HTMLHelpCommand = @{
            HH_DISPLAY_TOPIC = 0;
            HH_DISPLAY_TOC = 1;
            HH_DISPLAY_INDEX = 2;
            HH_DISPLAY_SEARCH = 3;
            HH_HELP_CONTEXT = 0x000F;
            HH_CLOSE_ALL = 0x0012;
        }
        
        if (-not $uCommand) { $uCommand = $HTMLHelpCommand.HH_DISPLAY_TOC }

        $win32 = Add-Type -MemberDefinition $signature -Name "Win32HtmlHelp" -Namespace $script:Win32Namespace -PassThru
        $win32::HtmlHelp($hwndCaller, $Path, $uCommand, $dwData)
    }
}

#####################################################################################################################################################
