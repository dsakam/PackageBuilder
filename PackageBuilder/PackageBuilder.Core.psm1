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
 #  2013/09/02  Version 0.0.0.1
 #
 #>
#####################################################################################################################################################

#####################################################################################################################################################
# Variables
$script:CygwinBinPath = "C:\cygwin\bin"
$script:Cygwin64BinPath = "C:\cygwin64\bin"
$script:FCIVBinPath = "C:\FCIV"

#####################################################################################################################################################
# Aliases
Function CygPath { return ("/cygdrive/" + ($args[0] -replace "\\","/").Remove(1,1))  }

#####################################################################################################################################################
Function Start-Command {

<#
.SYNOPSIS
    ファイルを実行します。


.DESCRIPTION
    Start-Process コマンドレットのラッパーです。


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
    [MS-ERREF] Windows Error Codes    
    http://msdn.microsoft.com/en-us/library/cc231196.aspx

    2.1 HRESULT
    http://msdn.microsoft.com/en-us/library/cc231198.aspx

    2.1.1 HRESULT Values
    http://msdn.microsoft.com/en-us/library/cc704587.aspx

    2.2 Win32 Error Codes
    http://msdn.microsoft.com/en-us/library/cc231199.aspx

    2.3 NTSTATUS
    http://msdn.microsoft.com/en-us/library/cc231200.aspx

    2.3.1 NTSTATUS values
    http://msdn.microsoft.com/en-us/library/cc704588.aspx
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
        [Parameter(Mandatory=$false)][switch]$Async
    )

    Process
    {
        # -FilePath
        if (Test-Path -Path ($exe_filepath = (Get-Location | Join-Path -ChildPath $FilePath)))
        {
            # Current Directory
            $FilePath = $exe_filepath
        }
        elseif (Test-Path -Path ($exe_filepath += ".exe"))
        {
            # Current Directory + ".exe"
            $FilePath = $exe_filepath
        }
        elseif (Test-Path -Path ($exe_filepath = ($PSCommandPath | Split-Path -Parent | Join-Path -ChildPath $FilePath)))
        {
            # Module Path
            $FilePath = $exe_filepath
        }
        elseif (Test-Path -Path ($exe_filepath += ".exe"))
        {
            # Module Path + ".exe"
            $FilePath = $exe_filepath
        }
        [string]$commandline_base = "Start-Process -FilePath `"$FilePath`""


        # -ArgumentList
        if ($ArgumentList)
        {
            $commandline_base += " -ArgumentList"
            for ($i = 0; $i -lt $ArgumentList.Count ; $i ++)
            {
                $commandline_base += " '" + $ArgumentList[$i] + "'"
                if ($i -lt $ArgumentList.Count - 1) { $commandline_base += "," }
            }
        }


        # -WorkingDirectory / -WindowStyle / -NoNewWindow
        if ($WorkingDirectory) { $commandline_base += " -WorkingDirectory" + " `"" + (Resolve-Path -Path $WorkingDirectory) + "`"" }
        if ($WindowStyle) { $commandline_base += " -WindowStyle $WindowStyle" }
        if ($NoNewWindow) { $commandline_base += " -NoNewWindow" }


        # -PassThru
        $commandline_base += " -PassThru"


        # Not Asynchronous (-Wait)
        if (-not $Async)
        {
            $commandline_base += " -Wait"

            if ($WorkingDirectory)
            {
                $output_filepath = Resolve-Path -Path $WorkingDirectory
            }
            else
            {
                $output_filepath = Get-Location
            }

            $output_filepath = ($output_filepath | Join-Path -ChildPath (`
                (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss.FFFFFF") `
                + "_" + $MyInvocation.MyCommand.Name `
                + "_" + (Split-Path -Path $FilePath -Leaf)))
        }


        for ($i = 0; $i -lt $Retry; $i++)
        {
            $commandline = $commandline_base

            # Not Asynchronous (-RedirectStandardOutput / -RedirectStandardError)
            if (-not $Async)
            {
                $stdout_filepath = "$output_filepath($i).out"
                $stderr_filepath = "$output_filepath($i).err"

                $commandline += " -RedirectStandardOutput" + " `"" + $stdout_filepath + "`""
                $commandline += " -RedirectStandardError" + " `"" + $stderr_filepath + "`""
            }

            # Verbose
            Write-Verbose ("[" + $MyInvocation.MyCommand.Name + "] " + $commandline)

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
                        Get-Content -Path $stdout_filepath -Encoding UTF8 | Write-Output
                        if ($DebugPreference -eq "SilentlyContinue") { Remove-Item -Path $stdout_filepath -Force }
                    }

                    # Output Standard Error
                    if (Test-Path -Path $stderr_filepath)
                    {
                        Get-Content -Path $stderr_filepath -Encoding UTF8 | Write-Warning
                        if ($DebugPreference -eq "SilentlyContinue") { Remove-Item -Path $stderr_filepath -Force }
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
                    Write-Warning ("[" + $MyInvocation.MyCommand.Name + "] Exit Code: " + "0x" + $proc.ExitCode.ToString("x8"))

                    if ($i -lt ($Retry-1))
                    {
                        Write-Warning ("[" + $MyInvocation.MyCommand.Name + "] Retry Count(" + ($i+1) + "): Waiting " + $Interval + " Seconds...")
                        Start-Sleep -Seconds $Interval
                    }
                    else { throw New-Object System.Runtime.InteropServices.ExternalException("0x" + $proc.ExitCode.ToString("x8")) }
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
Function Get-CheckSum {

<#
.SYNOPSIS
    Get Checksum.

.DESCRIPTION
    ファイルのチェックサムを取得します。


.PARAMETER Path
    File Path of target file.
    Type: System.String


.INPUTS
    System.String


.OUTPUTS
    System.String


.NOTES

    //
    // File Checksum Integrity Verifier version 2.05.
    //
    ffffffffffffffffffffffffffffffff test.txt

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
        [string]$InputObject,

        [Parameter (Mandatory=$false, Position=1)][string]$BinPath,
        [Parameter (Mandatory=$false)][switch]$MD5,
        [Parameter (Mandatory=$false)][switch]$SHA1
    )

    Process
    {
        # Exception
        trap { break }

        if ($BinPath) { $command = ($BinPath | Resolve-Path | Join-Path -ChildPath "fciv.exe") }
        else
        {
            if (-not (($command = ($script:FCIVBinPath | Join-Path -ChildPath "fciv.exe")) | Test-Path)) { $command = "fciv.exe" }
        }

        if($SHA1)
        {
            [string[]]$out = (Start-Command -FilePath $command -ArgumentList ("`"" + $InputObject + "`""), "-sha1" -WindowStyle Hidden) -as [string[]]
        }
        else
        {
            [string[]]$out = (Start-Command -FilePath $command -ArgumentList ("`"" + $InputObject + "`"") -WindowStyle Hidden) -as [string[]]
        }

        for ($i=3; $i -lt $out.Count; $i++)
        {
            Write-Output ($out[$i] -split ' ')[0]
        }
    }
}

#####################################################################################################################################################
Function Test-SameFile {

<#
.SYNOPSIS
    Test difference of two files.

.DESCRIPTION
    2つのオブジェクトに違いがあるかをテストします。


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
        [string]$DifferenceObject,

        [Parameter (Mandatory=$false, Position=2)][string]$BinPath
    )

    Process
    {
        if (-not $BinPath)
        {
            [string[]]$a = Get-CheckSum -InputObject $ReferenceObject
            [string[]]$b = Get-CheckSum -InputObject $DifferenceObject
        }
        else
        {
            [string[]]$a = Get-CheckSum -InputObject $ReferenceObject -BinPath $BinPath
            [string[]]$b = Get-CheckSum -InputObject $DifferenceObject -BinPath $BinPath
        }

        if ($a.Count -ne $b.Count) { return $false }
        else
        {
            for ($i=0; $i -lt $a.Count; $i++)
            {
                if ($a[$i] -ne $b[$i]) { return $false }
            }
        }
        
        return $true
    }
}

#####################################################################################################################################################
Function New-ISOImageFile {

<#
.SYNOPSIS
    Generate ISO Image File.

.DESCRIPTION
    ISO イメージファイルを作成します。


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
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript ( {
            if (-not (Test-Path -Path $_)) { throw New-Object System.IO.DirectoryNotFoundException }
            if ((Get-Item $_).GetType() -ne [System.IO.DirectoryInfo]) { throw New-Object System.ArgumentException }
            return $true
        } )]
        [string]$InputObject,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateScript ( {
            if (-not ($_ | Split-Path -Parent | Test-Path)) { throw New-Object System.IO.DirectoryNotFoundException }
            return $true
        } )]
        [string]$Path = ($InputObject | Resolve-Path | Split-Path -Parent),

        [Parameter(Mandatory=$false, Position=2)]
        [ValidateScript ( {
            if (-not ($_ | Resolve-Path | Join-Path -ChildPath "genisoimage.exe" | Test-Path)) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$BinPath,

        [Parameter(Mandatory=$true)][string]$VolumeID,
        [Parameter(Mandatory=$false)][string]$Publisher,
        [Parameter(Mandatory=$false)][string]$ApplicationID,
        [Parameter(Mandatory=$false)][string[]]$ArgumentList,

        [Parameter(Mandatory=$false)][switch]$RedirectStandardError,
        [Parameter(Mandatory=$false)][switch]$Recommended,

        [Parameter(Mandatory=$false)][string]$FCIVBinPath
    )

    Process
    {
        # Command Path (genisoimage)
        if ($BinPath)
        {
            $command = ($BinPath | Resolve-Path | Join-Path -ChildPath "genisoimage.exe")
        }
        else
        {
            if (-not (($command = ($script:Cygwin64BinPath | Join-Path -ChildPath "genisoimage.exe")) | Test-Path))
            {
                if (-not (($command = ($script:CygwinBinPath | Join-Path -ChildPath "genisoimage.exe")) | Test-Path))
                {
                    $command = "genisoimage.exe"
                }
            }
        }

        # Input Path
        $input_path = ($InputObject | Resolve-Path)

        # Output Path (*.iso)
        $output_path = ($Path | Split-Path -Parent | Convert-Path | Join-Path -ChildPath ($Path | Split-Path -Leaf))


        # ArgumentList
        [string[]]$arg_list = @()

        $arg_list += "-output " + "`"" + (CygPath($output_path)) + "`""
        $arg_list += "-volid `"" + $VolumeID +"`""

        if ($Publisher) { $arg_list += "-publisher `"" + $Publisher +"`"" }
        if ($ApplicationID) { $arg_list += "-appid `"" + $ApplicationID +"`"" }

        if ($VerbosePreference -ne "SilentlyContinue") { $arg_list += "-verbose" }
        if ($DebugPreference -ne "SilentlyContinue") { $arg_list += "-debug" }


        # RedirectStandardError
        if ($RedirectStandardError)
        {
            $log_filepath = $MyInvocation.MyCommand.Name `
                + "_" + (Get-Date).ToString("yyyy-MM-dd-HHmmss") `
                + "_" + ([System.IO.FileInfo]$Path).BaseName + ".tmp"
            $log_filepath = (Get-Location | Join-Path -ChildPath $log_filepath)

            $arg_list += "-log-file `"/cygdrive/" + ($log_filepath -replace "\\","/").Remove(1,1) + "`""
        }


        # Recommended
        if ($Recommended)
        {
            $arg_list += "-input-charset utf-8"
            $arg_list += "-output-charset utf-8"
            $arg_list += "-rational-rock"
            $arg_list += "-joliet"
            $arg_list += "-joliet-long"
            $arg_list += "-jcharset utf-8"
        }


        # ArgumentList (Additional)
        if ($ArgumentList)
        {
            $ArgumentList | % {

                [bool]$found = $false
                for ($i = 0; $i -lt $arg_list.Count; $i++)
                {
                    # Check if additional parameter is already defined
                    if (($_.Trim() -split " ")[0] -eq ($arg_list[$i].Trim() -split " ")[0])
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
        $arg_list += ("`"" + (CygPath($input_path)) + "`"")
        if ($DebugPreference -ne "SilentlyContinue")
        {
            #####################################################################################
            Start-Command -FilePath $command -ArgumentList $arg_list -WindowStyle Hidden -Debug
            #####################################################################################
        }
        else
        {
            #####################################################################################
            Start-Command -FilePath $command -ArgumentList $arg_list -WindowStyle Hidden
            #####################################################################################
        }


        # RedirectStandardError
        if ($RedirectStandardError)
        {
            if (Test-Path $log_filepath)
            {
                # Output Standard Error from log-file
                Get-Content -Path $log_filepath -Encoding UTF8 | Write-Output

                # remove log-file
                if ($DebugPreference -eq "SilentlyContinue") { Remove-Item $log_filepath }
            }
        }


        # RETURN
        try
        {
            if ($FCIVBinPath)
            {
                return Get-CheckSum -InputObject $Path -BinPath $FCIVBinPath
            }
            else
            {
                return Get-CheckSum -InputObject $Path
            }
        }
        catch { Write-Warning ("[" + $MyInvocation.MyCommand.Name + "] Get-CheckSum: " + $_.ToString()) }
    }
}

#####################################################################################################################################################
