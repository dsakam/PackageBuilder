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
 #  2013/09/02  Version 0.0.0.1
 #  2014/01/16  Version 0.4.0.0
 #  2014/01/17  Version 0.5.0.0
 #  2014/03/01  Version 0.6.0.0
 #
 #>
#####################################################################################################################################################

######## NOTE #######################################################################################################################################
<#
 # 引用符使用のガイドライン
 #
 # 下記にはシングルクォーテーション ('') を使用する。
 #
 #    1. 単語
 #    2. PATH
 #
 #
 # 下記にはダブルクォーテーション ("") を使用する。
 #
 #    1. メッセージ
 #    2. 内部で変数等を使用している
 #
 #>
#####################################################################################################################################################

#####################################################################################################################################################
# Variables
$Script:BinPath_Cygwin   = 'C:\cygwin\bin'
$Script:BinPath_Cygwin64 = 'C:\cygwin64\bin'



$Script:BinPath_signtool_WOW64_WDK8_1_x86 = 'C:\Program Files (x86)\Windows Kits\8.1\bin\x86'

$Script:BinPath_signtool_WOW64_WDK8_1_x64 = 'C:\Program Files (x86)\Windows Kits\8.1\bin\x64'
$Script:BinPath_signtool_WOW64_WDK8_1_x86 = 'C:\Program Files (x86)\Windows Kits\8.1\bin\x86'
$Script:BinPath_signtool_WOW64_WDK8_0_x64 = 'C:\Program Files (x86)\Windows Kits\8.0\bin\x64'
$Script:BinPath_signtool_WOW64_WDK8_0_x86 = 'C:\Program Files (x86)\Windows Kits\8.0\bin\x86'
$Script:BinPath_signtool_WOW64_WDK7_1     = 'C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Bin'
$Script:BinPath_signtool_WOW64_WDK7_0     = 'C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin'

$Script:BinPath_signtool_WDK8_1_x64 = 'C:\Program Files\Windows Kits\8.1\bin\x64'
$Script:BinPath_signtool_WDK8_1_x86 = 'C:\Program Files\Windows Kits\8.1\bin\x86'
$Script:BinPath_signtool_WDK8_0_x64 = 'C:\Program Files\Windows Kits\8.0\bin\x64'
$Script:BinPath_signtool_WDK8_0_x86 = 'C:\Program Files\Windows Kits\8.0\bin\x86'
$Script:BinPath_signtool_WDK7_1     = 'C:\Program Files\Microsoft SDKs\Windows\v7.1A\Bin'
$Script:BinPath_signtool_WDK7_0     = 'C:\Program Files\Microsoft SDKs\Windows\v7.0A\Bin'




$Script:genisoimage_FileName = 'genisoimage.exe'
$Script:signtool_FileName    = 'signtool.exe'


#####################################################################################################################################################
# Aliases
Function CYGPATH { return ('/cygdrive/' + ($args[0] -replace '\\', '/').Remove(1, 1))  }

#####################################################################################################################################################
Function Get-MD5 {

<#
.SYNOPSIS
    ファイルの MD5 チェックサムを取得します。


.DESCRIPTION


.PARAMETER InputObject


.INPUTS
    System.String


.OUTPUTS
    System.String


.NOTES


.EXAMPLE


.LINK

#>

    [CmdletBinding(DefaultParameterSetName=$false)]
    Param (
        [Parameter (Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript ( {
            $_ | % { if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException } }
            return $true
        } )]
        [string[]]$Path,

        [Parameter (Mandatory=$false, Position=1, ParameterSetName='file')]
        [switch]$FileName,

        [Parameter (Mandatory=$false, Position=1, ParameterSetName='full')]
        [switch]$FullName
    )

    Process
    {
        # Exception
        trap { break }

        $md5 = [System.Security.Cryptography.MD5]::Create()

        $Path | Convert-Path | Get-ChildItem -Recurse -Force -File | % {

            $file = [System.IO.FileInfo]$_
            $inputStream = (New-Object System.IO.StreamReader (Convert-Path -Path $file.FullName)).BaseStream
            $hash = [System.BitConverter]::ToString($md5.ComputeHash($inputStream)) -replace '-', ''

            switch ($PSCmdlet.ParameterSetName)
            {
                'file'  { $text = $hash + "`t'" + $file.Name + "'" }
                'full'  { $text = $hash + "`t'" + $file.FullName + "'" }
                default { $text = $hash }
            }

            # Output
            Write-Output $text
        }
    }
}

#####################################################################################################################################################
Function Test-SameFile {

<#
.SYNOPSIS
    2 つのファイルが同じかどうかをテストします。

.DESCRIPTION
    Get-CheckSum


.PARAMETER ReferenceObject


.PARAMETER DifferenceObject


.PARAMETER BinPath
    fciv.exe が保存されているフォルダーのパスを指定します。


.INPUTS
    System.String


.OUTPUTS
    System.Boolean


.NOTES
    fciv.exe を 使って検証する 'Get-CheckSum' コマンドレットから 'Get-MD5' コマンドレットを使って検証するよう変更。


.EXAMPLE


.LINK

#>

    [CmdletBinding()]
    Param (
        [Parameter (Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript ( {
            if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$ReferenceObject,

        [Parameter (Mandatory=$true, Position=1)]
        [ValidateScript ( {
            if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$DifferenceObject
    )

    Process
    {
        [string[]]$ref  = Get-MD5 -Path $ReferenceObject | Sort-Object
        [string[]]$diff = Get-MD5 -Path $DifferenceObject | Sort-Object

        if ($ref.Count -ne $diff.Count) { return $false }
        else
        {
            foreach ($i in 0..($ref.Count - 1))
            {
                if ($ref[$i] -ne $diff[$i]) { return $false }
            }
        }
        
        return $true
    }
}

#####################################################################################################################################################
Function Start-Command {

<#
.SYNOPSIS
    ファイルを実行します。


.DESCRIPTION
    Start-Process コマンドレットのラッパーです。


.PARAMETER FilePath


.PARAMETER ArgumentList


.PARAMETER WorkingDirectory


.PARAMETER Retry


.PARAMETER Interval


.PARAMETER WindowStyle


.PARAMETER NoNewWindow


.PARAMETER Async


.INPUTS
    None


.OUTPUTS
    System.String


.NOTES


.EXAMPLE


.LINK
    [MS-ERREF] Windows Error Codes    
    http://msdn.microsoft.com/en-us/library/cc231196.aspx
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0)][string]$FilePath,
        [Parameter(Mandatory=$false, Position=1)][string[]]$ArgumentList,
        [Parameter(Mandatory=$false, Position=2)][string]$WorkingDirectory,

        [Parameter(Mandatory=$false, Position=3)][ValidateRange(1,10)][int]$Retry = 1,
        [Parameter(Mandatory=$false, Position=4)][ValidateRange(1,60)][int]$Interval = 1,

        [Parameter(Mandatory=$false, Position=5)][System.Diagnostics.ProcessWindowStyle]$WindowStyle,
        [Parameter(Mandatory=$false)][switch]$NoNewWindow,

        [Parameter(Mandatory=$false)][switch]$Async,

        [Parameter(Mandatory=$false, Position=6)][Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]$OutputEncoding `
            = [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::Default
    )

    Process
    {
        # -FilePath
        if (Test-Path -Path ($exe_filepath = (Get-Location | Join-Path -ChildPath $FilePath)))
        {
            # Current Directory
            $FilePath = $exe_filepath
        }
        elseif (Test-Path -Path ($exe_filepath += '.exe'))
        {
            # Current Directory + '.exe'
            $FilePath = $exe_filepath
        }
        elseif (Test-Path -Path ($exe_filepath = ($PSCommandPath | Split-Path -Parent | Join-Path -ChildPath $FilePath)))
        {
            # Module Path
            $FilePath = $exe_filepath
        }
        elseif (Test-Path -Path ($exe_filepath += '.exe'))
        {
            # Module Path + ".exe"
            $FilePath = $exe_filepath
        }
        [string]$commandline_base = "Start-Process -FilePath '" + $FilePath + "'"


        # -ArgumentList
        if ($ArgumentList)
        {
            $commandline_base += ' -ArgumentList'
            for ($i = 0; $i -lt $ArgumentList.Count ; $i ++)
            {
                $commandline_base += " '" + $ArgumentList[$i] + "'"
                if ($i -lt $ArgumentList.Count - 1) { $commandline_base += ',' }
            }
        }


        # -WorkingDirectory / -WindowStyle / -NoNewWindow
        if ($WorkingDirectory) { $commandline_base += " -WorkingDirectory '" + (Resolve-Path -Path $WorkingDirectory) + "'" }
        if ($WindowStyle) { $commandline_base += " -WindowStyle $WindowStyle" }
        if ($NoNewWindow) { $commandline_base += ' -NoNewWindow' }


        # -PassThru
        $commandline_base += ' -PassThru'


        # Not Asynchronous (-Wait)
        if (-not $Async)
        {
            $commandline_base += ' -Wait'

            if ($WorkingDirectory)
            {
                $output_filepath = Resolve-Path -Path $WorkingDirectory
            }
            else
            {
                $output_filepath = Get-Location
            }

            $output_filepath = ($output_filepath | Join-Path -ChildPath (`
                (Get-Date).ToString('yyyy-MM-dd-HH-mm-ss.FFFFFF') `
                + '_' + $MyInvocation.MyCommand.Name `
                + '_' + (Split-Path -Path $FilePath -Leaf)))
        }


        for ($i = 0; $i -lt $Retry; $i++)
        {
            $commandline = $commandline_base

            # Not Asynchronous (-RedirectStandardOutput / -RedirectStandardError)
            if (-not $Async)
            {
                $stdout_filepath = "$output_filepath($i).out"
                $stderr_filepath = "$output_filepath($i).err"

                $commandline += " -RedirectStandardOutput '$stdout_filepath'"
                $commandline += " -RedirectStandardError '$stderr_filepath'"
            }

            # Verbose
            Write-Verbose ('[' + $MyInvocation.MyCommand.Name + ']' + " $commandline")

            try
            {
                ####################################################################################################
                $proc = [System.Diagnostics.Process](Invoke-Expression -Command $commandline)
                ####################################################################################################
            }
            catch [System.Exception] { throw $_ }
            finally
            {
                # Not Asynchronous (-Wait)
                if (-not $Async)
                {
                    # Output Standard Output
                    if (Test-Path -Path $stdout_filepath)
                    {
                        Get-Content -Path $stdout_filepath -Encoding $OutputEncoding | Write-Output
                        if ($DebugPreference -eq 'SilentlyContinue') { Remove-Item -Path $stdout_filepath -Force }
                    }

                    # Output Standard Error
                    if (Test-Path -Path $stderr_filepath)
                    {
                        Get-Content -Path $stderr_filepath -Encoding $OutputEncoding | Write-Warning
                        if ($DebugPreference -eq 'SilentlyContinue') { Remove-Item -Path $stderr_filepath -Force }
                    }
                }
            }

            # Not Asynchronous (-Wait)
            if (-not $Async)
            {
                if ($proc.ExitCode -eq 0) { return }
                else
                {
                    # 失敗 (終了コードが 0 ではない)

                    # Error Message
                    Write-Warning ('[' + $MyInvocation.MyCommand.Name + ']' + ' Exit Code: 0x' + $proc.ExitCode.ToString('x8'))

                    if ($i -lt ($Retry-1))
                    {
                        Write-Warning ('[' + $MyInvocation.MyCommand.Name + ']' + ' Retry Count: ' + ($i+1))
                        Write-Warning ('[' + $MyInvocation.MyCommand.Name + ']' + " Waiting $Interval Seconds...")
                        Start-Sleep -Seconds $Interval
                    }
                    else { throw New-Object System.Runtime.InteropServices.ExternalException('0x' + $proc.ExitCode.ToString('x8')) }
                }
            }
            else
            {
                # return Process ID when Asyncronouns
                return $proc.Id
            }
        }
    }
}

#####################################################################################################################################################
Function New-ISOImageFile {

<#
.SYNOPSIS
    ISO イメージファイルを作成します。

.DESCRIPTION


.PARAMETER InputObject


.PARAMETER Path


.PARAMETER VolumeID


.PARAMETER Publisher


.PARAMETER ApplicationID


.PARAMETER ArgumentList


.PARAMETER BinPath


.PARAMETER FCIVBinPath


.PARAMETER RedirectStandardError


.PARAMETER Recommended


.INPUTS
    System.String


.OUTPUTS
    System.String


.NOTES
    MD5 チェックサムではなく、iso ファイルのパスを返すように変更。


.EXAMPLE


.LINK
    Cygwin
    http://www.cygwin.com/

    cdrkit - portable command-line CD-DVD recorder software (for genisoimage.exe)
    http://www.cdrkit.org/
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript ( {
            if (-not (Test-Path -Path $_)) { throw New-Object System.IO.DirectoryNotFoundException }
            if ((Get-Item -Path $_) -isnot [System.IO.DirectoryInfo]) { throw New-Object System.IO.DirectoryNotFoundException }
            return $true
        } )]
        [string]$InputObject,

        [Parameter(Mandatory=$false, Position=1)]
        [ValidateScript ( {
            if (-not ($_ | Split-Path -Parent | Test-Path)) { throw New-Object System.IO.DirectoryNotFoundException }
            return $true
        } )]
        [string]$Path = ($InputObject + '.iso'),

        [Parameter(Mandatory=$false, Position=2)][string]$VolumeID,
        [Parameter(Mandatory=$false, Position=3)][string]$Publisher,
        [Parameter(Mandatory=$false, Position=4)][string]$ApplicationID,

        [Parameter(Mandatory=$false, Position=5)][string[]]$ArgumentList,

        [Parameter(Mandatory=$false, Position=6)][string]$BinPath,

        [Parameter(Mandatory=$false)][switch]$RedirectStandardError,
        [Parameter(Mandatory=$false)][switch]$Recommended
    )

    Process
    {
        # Command Path (genisoimage)
        if ($BinPath)
        {
            $command = ($BinPath | Resolve-Path | Join-Path -ChildPath $Script:genisoimage_FileName)
        }
        else
        {
            if (-not (($command = ($Script:BinPath_Cygwin64 | Join-Path -ChildPath $Script:genisoimage_FileName)) | Test-Path))
            {
                if (-not (($command = ($Script:BinPath_Cygwin | Join-Path -ChildPath $Script:genisoimage_FileName)) | Test-Path))
                {
                    $command = $Script:genisoimage_FileName
                }
            }
        }

        # Input Path
        $input_path = ($InputObject | Resolve-Path)

        # Output Path (*.iso)
        $output_path = ($Path | Split-Path -Parent | Convert-Path | Join-Path -ChildPath ($Path | Split-Path -Leaf))


        # ArgumentList
        [string[]]$arg_list = @()

        $arg_list += '-output "' + (CYGPATH($output_path)) + '"'

        if ($VolumeID) { $arg_list += '-volid "' + $VolumeID + '"' }
        if ($Publisher) { $arg_list += '-publisher "' + $Publisher + '"' }
        if ($ApplicationID) { $arg_list += '-appid "' + $ApplicationID + '"' }

        if ($VerbosePreference -ne 'SilentlyContinue') { $arg_list += '-verbose' }
        if ($DebugPreference -ne 'SilentlyContinue') { $arg_list += '-debug' }


        # RedirectStandardError
        if ($RedirectStandardError)
        {
            $log_filepath = $MyInvocation.MyCommand.Name `
                + '_' + (Get-Date).ToString('yyyy-MM-dd-HHmmss') `
                + '_' + ([System.IO.FileInfo]$Path).BaseName + '.tmp'
            $log_filepath = (Get-Location | Join-Path -ChildPath $log_filepath)

            $arg_list += '-log-file "/cygdrive/' + ($log_filepath -replace '\\', '/').Remove(1,1) + '"'
        }


        # Recommended
        if ($Recommended)
        {
            $arg_list += '-input-charset utf-8'
            $arg_list += '-output-charset utf-8'
            $arg_list += '-rational-rock'
            $arg_list += '-joliet'
            $arg_list += '-joliet-long'
            $arg_list += '-jcharset utf-8'
        }


        # ArgumentList (Additional)
        if ($ArgumentList)
        {
            $ArgumentList | % {

                [bool]$found = $false
                for ($i = 0; $i -lt $arg_list.Count; $i++)
                {
                    # Check if additional parameter is already defined
                    if (($_.Trim() -split ' ')[0] -eq ($arg_list[$i].Trim() -split ' ')[0])
                    {
                        # Overwrite aditional parameter
                        $arg_list[$i] = $_
                        $found = $true
                    }
                }

                # Add aditional parameter
                if (-not $found) { $arg_list += $_ }
            }
        }


        # Last entry of ArgumentList (file directory)
        $arg_list += ('"' + (CYGPATH($input_path)) + '"')
        if ($DebugPreference -ne 'SilentlyContinue')
        {
            #########################################################################################################
            Start-Command -FilePath $command -ArgumentList $arg_list -OutputEncoding UTF8 -WindowStyle Hidden -Debug
            #########################################################################################################
        }
        else
        {
            #########################################################################################################
            Start-Command -FilePath $command -ArgumentList $arg_list -OutputEncoding UTF8 -WindowStyle Hidden
            #########################################################################################################
        }


        # RedirectStandardError
        if ($RedirectStandardError)
        {
            if (Test-Path $log_filepath)
            {
                # Output Standard Error from log-file
                Get-Content -Path $log_filepath -Encoding UTF8 | Write-Output

                # remove log-file
                if ($DebugPreference -eq 'SilentlyContinue') { Remove-Item $log_filepath }
            }
        }


        # RETURN
        return $output_path
    }
}

#####################################################################################################################################################
