﻿######## LICENSE ####################################################################################################################################
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
 #  2014/01/17  Version 0.5.0.0
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
    LoadLibraryEx function (Windows)
    http://msdn.microsoft.com/en-us/library/windows/desktop/ms684179.aspx
#>

    [CmdletBinding()] Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript ( {
            if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
            if ((Get-Item -Path $_) -isnot [System.IO.FileInfo]) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
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
        try { return [BUILDLet.PowerShell.PackageBuilder.Win32.Kernel32]::FreeLibrary($hModule) }
        catch { throw }
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
            if ((Get-Item -Path $_) -isnot [System.IO.FileInfo]) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$Path,

        [Parameter(Mandatory=$true, Position=1)][int[]]$uID,
        [Parameter(Mandatory=$false, Position=2)][int]$nBufferMax = 1024
    )

    Process
    {
        try
        {
            # LoadLibraryEx
            [IntPtr]$lib = Invoke-LoadLibraryEx -lpLibFileName $Path -dwFlags ($LOAD_LIBRARY_AS_DATAFILE = 2)

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
            if ((Get-Item -Path $_) -isnot [System.IO.FileInfo]) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$Path,

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
