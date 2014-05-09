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
 #  2014/05/05  Version 0.13.0.0
 #  2014/05/06  Version 1.0.0.0
 #  2014/05/08  Version 1.0.3.0    Update help content of 'Start-Command' Cmdlet.
 #                                 Add error (exception) handling procedure of 'Start-Command' Cmdlet.
 #  2014/05/09  Version 1.0.4.0    Modify error (exception) handling procedure of 'Start-Command' Cmdlet.
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
$Global:BinPath = @{

    Cygwin = (

        # Cygwin
        'C:\cygwin\bin',
        'C:\cygwin64\bin'
    )

    WindowsKits = (

        # Windows Kits (WOW64)
        'C:\Program Files (x86)\Windows Kits\8.1\bin\x86',
        'C:\Program Files (x86)\Windows Kits\8.0\bin\x86',
        'C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Bin',
        'C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin',

        # Windows Kits (x86)
        'C:\Program Files\Windows Kits\8.1\bin\x86',
        'C:\Program Files\Windows Kits\8.0\bin\x86',
        'C:\Program Files\Microsoft SDKs\Windows\v7.1A\Bin',
        'C:\Program Files\Microsoft SDKs\Windows\v7.0A\Bin',

        # Windows Kits (x64)
        'C:\Program Files (x86)\Windows Kits\8.1\bin\x64',
        'C:\Program Files (x86)\Windows Kits\8.0\bin\x64',
        'C:\Program Files\Windows Kits\8.1\bin\x64',
        'C:\Program Files\Windows Kits\8.0\bin\x64'
    )
}

$Script:genisoimage_FileName = 'genisoimage.exe'
$Script:signtool_FileName    = 'signtool.exe'


#####################################################################################################################################################
# Aliases
Function CYGPATH { return ('/cygdrive/' + ($args[0] -replace '\\', '/').Remove(1, 1))  }

#####################################################################################################################################################
Function Get-MD5
{
    <#
        .SYNOPSIS
            ファイルの MD5 ハッシュ値を取得します。

        .DESCRIPTION
            System.Security.Cryptography.HashAlgorithm.ComputeHash メソッドを使用して、ファイルの MD5 ハッシュ値を計算して文字列として取得します。

            ファイルは複数指定することもできます。また、フォルダーを指定すると、そのフォルダー以下にある全てのファイルのハッシュ値を取得します。
            複数のファイルが指定されたときは、ファイル毎に改行されて出力されます。

            FileName または FullName パラメーターが指定されたときは、ハッシュ値とファイル名が出力されます。
            これらのパラメーターを指定しなかったときは MD5 ハッシュ値のみが出力されます。(デフォルトは指定なしです。)

            出力文字列のフォーマットは
                [MD5 ハッシュ値]([区切り文字][ファイル名またはファイルのパス])
            です。

        .PARAMETER Path
            入力ファイルを指定します。
            複数のファイルを指定するときは、それぞれのファイル名 (またはファイルパス) の文字列配列として指定します。

        .PARAMETER FileName
            MD5 ハッシュ値とファイル名を出力するときに指定します。
            (ファイル名にパスは含まれません。ファイル名ではなく、ファイルのフルパスを出力させたい場合は FullName パラメーターを指定してください。)
            複数のファイルが指定されたときは、ファイル毎に改行されます。

        .PARAMETER FullName
            MD5 ハッシュ値とファイルのフルパスを出力するときに指定します。
            複数のファイルが指定されたときは、ファイル毎に改行されます。

        .PARAMETER Separator
            FileName または FullName パラメーターが指定されたときに、MD5 ハッシュ値と、ファイル名 (またはファイルパス) を区切る文字列を指定します。
            デフォルトでは、タブ文字 ("`t") が使用されます。

        .INPUTS
            System.String
            パイプを使用して、Path パラメーターを Get-MD5 コマンドレットに渡すことができます。

        .OUTPUTS
            System.String
            ファイルの MD5 ハッシュ値を文字列として返します。

        .EXAMPLE
            Get-MD5 sample.dll
            カレントディレクトリにある sample.dll の MD5 ハッシュ値を文字列として取得します。

        .EXAMPLE
            Get-MD5 sample1.dll, sample2.dll
            カレントディレクトリにある sample.dll および sample2.dll の MD5 ハッシュ値を取得します。

        .EXAMPLE
            Get-MD5 C:\Sample -FileName -Separator ' '
            C:\Sample フォルダー以下にあるすべてのファイルの MD5 ハッシュ値を、ハッシュ値とファイル名がスペースで区切られた文字列配列として取得します。

        .LINK
            HashAlgorithm.ComputeHash Method (System.Security.Cryptography)
            http://msdn.microsoft.com/en-us/library/system.security.cryptography.hashalgorithm.computehash.aspx
    #>

    [CmdletBinding(DefaultParameterSetName=$false)]
    Param (
        [Parameter (Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript (
            {
                $_ | % { if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException } }
                return $true
            }
        )]
        [string[]]$Path,

        [Parameter (Mandatory=$false, Position=1, ParameterSetName='file')]
        [switch]$FileName,

        [Parameter (Mandatory=$false, Position=1, ParameterSetName='full')]
        [switch]$FullName,

        [Parameter (Mandatory=$false, Position=2, ParameterSetName='file')]
        [Parameter (Mandatory=$false, Position=2, ParameterSetName='full')]
        [char]$Separator = "`t"
    )

    Process
    {
        # Exception
        trap { break }

        $md5 = [System.Security.Cryptography.MD5]::Create()

        $Path | Convert-Path | Get-ChildItem -Recurse -Force -File | 
        % {
            $file = [System.IO.FileInfo]$_
            $inputStream = (New-Object System.IO.StreamReader (Convert-Path -Path $file.FullName)).BaseStream
            $hash = [System.BitConverter]::ToString($md5.ComputeHash($inputStream)) -replace '-', ''

            switch ($PSCmdlet.ParameterSetName)
            {
                'file'  { $text = $hash + $Separator + "'" + $file.Name + "'" }
                'full'  { $text = $hash + $Separator + "'" + $file.FullName + "'" }
                default { $text = $hash }
            }

            # Output
            Write-Output $text
        }
    }
}

#####################################################################################################################################################
Function Test-SameFile
{
    <#
        .SYNOPSIS
            ファイルが同じかどうかをテストします。

        .DESCRIPTION
            Get-MD5 コマンドレットを使用して、指定された 2 つのファイルが同じかどうかをテストします。
            フォルダーが指定されたときは、そのフォルダー以下にある全てのファイルについてテストを行います。

        .PARAMETER ReferenceObject
            比較の参照として使用されるファイル、またはフォルダーを指定します。

        .PARAMETER DifferenceObject
            ReferenceObject と比較するファイル、またはフォルダーを指定します。

        .INPUTS
            System.String
            パイプを使用して DifferenceObject パラメーターを Test-SameFile コマンドレットに渡すことができます。

        .OUTPUTS
            System.Boolean
            テスト対象に差異がない場合は TRUE、そうでない場合は FALSE を返します。

        .EXAMPLE
            Test-SameFile -ReferenceObject sample1.dll -DifferenceObject sample2.dll
            カレントディレクトリにある sample1.dll と sample2.dll が同じかどうかをテストします。

        .EXAMPLE
            Test-SameFile C:\sample1 C:\sample2
            C:\sample1 フォルダーと sample2 フォルダーについて、当該フォルダー以下にある全てのファイルが同じかどうかをテストします。
    #>

    [CmdletBinding()]
    Param (
        [Parameter (Mandatory=$true, Position=0)]
        [ValidateScript (
            {
                if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
                return $true
            }
        )]
        [string]$ReferenceObject,

        [Parameter (Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [ValidateScript (
            {
                if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
                return $true
            }
        )]
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
Function Start-Command
{
    <#
        .SYNOPSIS
            ファイルを実行します。

        .DESCRIPTION
            指定されたパスにあるファイルを実行します。

            Start-Process コマンドレットのラッパーとして実装されていますが、デフォルトでは同期処理で実行します。
            非同期モードで実行したい場合は Async パラメーターを指定してください。

            標準出力、および、標準エラー出力は一時的に WorkingDirectory (デフォルトはカレントディレクトリ) にファイルとして書き出された後に、
            それぞれ、標準出力、および、標準エラー出力に出力されます。
            これらのファイルは、コマンドレットの処理が終了すると削除されます。
            ただし、Debug パラメーターが指定されたときは削除されません。
            また、非同期処理モードの場合は、標準出力、および、標準エラー出力は、これらのファイルには出力されません。

        .PARAMETER FilePath
            実行するファイルを指定します。

        .PARAMETER ArgumentList
            実行時のパラメーターを文字列配列として指定します。
            ファイルパスなど、文字列を引用符で括る必要がある場合は、シングルクォーテーション ['] ではなく、ダブルクォーテーション ["] を
            使用してください。

        .PARAMETER WorkingDirectory
            作業フォルダーを指定します。
            デフォルトは、カレントディレクトリです。

        .PARAMETER BinPath
            実行ファイルのパスの配列を文字列配列として指定します。
            以下の順番で FilePath パラメーターで指定されたファイルを検索し、最初に検出したファイルが実行されます。

                1. カレントディレクトリ + FilePath
                2. カレントディレクトリ + FilePath + '.exe'
                3. スクリプトのあるフォルダー + FilePath
                4. スクリプトのあるフォルダー + FilePath + '.exe'
                5. BinPath で指定されたパス (0) + FilePath
                6. BinPath で指定されたパス (0) + FilePath + '.exe'
                7. BinPath で指定されたパス (1) + FilePath
                8. BinPath で指定されたパス (1) + FilePath + '.exe'
                        :
                N.   BinPath で指定されたパス (n) + FilePath
                N+1. BinPath で指定されたパス (n) + FilePath + '.exe'

            FilePath パラメーターに、ファイル名ではなくパスが指定されていた場合は、FilePath で指定されているファイル名が検索に使われます。

        .PARAMETER Retry
            ファイルの実行に失敗した時に、指定回数をリトライします。
            Retry パラメーターには、最初の試行を含めた数値を指定します。
            デフォルトはリトライなし (1) です。

            ファイルを実行した戻り値が 0 でない場合に、実行に失敗したと判定されます。
            そのため、適切に戻り値を返さないファイルを実行した場合、リトライは正しく試行されません。

        .PARAMETER Interval
            リトライ間隔の秒数を指定します。
            デフォルトは 1 [秒] です。

        .PARAMETER WindowStyle
            ウィンドウのスタイル (System.Diagnostics.ProcessWindowStyle) を指定します。

        .PARAMETER NoNewWindow
            ウィンドウを非表示にする場合に指定します。
            このパラメーターを指定すると、Start-Process コマンドレットの -NoNewWindow パラメーターが指定されます。

        .PARAMETER Async
            非同期で実行するときに指定します。
            デフォルトでは、Start-Process コマンドレットの -NoWait パラメーターが指定されていますが、Async パラメーターを指定すると、
            Start-Process コマンドレットの -NoWait パラメーターが指定されません。

        .PARAMETER OutputEncoding
            標準出力、および、標準エラー出力のエンコーディングを指定します。
            デフォルトは Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding.Default です。

            出力が文字化けしているときは、このパラメーターを変更してみてください。
            たとえば、Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding.UTF8 を指定すると、正しく表示される場合があります。

        .INPUTS
            System.String
            パイプを使用して、ArgumentList パラメーターを Start-Command コマンドレットに渡すことができます。

        .OUTPUTS
            None or System.Int32
            デフォルト (同期処理モード) では、Start-Command コマンドレットは値を返しません。
            非同期処理モードでは、実行したプロセスのプロセス ID を返します。

        .EXAMPLE
            Start-Command notepad
            メモ帳を同期モードで実行します。

        .EXAMPLE
            Start-Command calc -Async
            電卓を非同期モードで実行します。

        .EXAMPLE
            Start-Command fciv .\sample1.dll, .\sample2.dll -WrokingDirectory C:\Temp -BinPath C:\FCIV -Retry 5 -Interval 3
            FCIV (File Checksum Integrity Verifier) を実行します。

            Start-Command コマンドレットは C:\FCIV\fciv.exe を検出・実行し、カレントディレクトリにある sample1.dll と \sample2.dll のハッシュ値を
            表示します。作業フォルダーには C:\Temp を指定しています。
            何らかの理由で FCIV の実行に失敗すると、3 秒間隔で 4 回のリトライ (最初の試行を含めると、合計 5 回の試行) を実行します。

        .LINK
            Start-Process
            http://technet.microsoft.com/ja-JP/library/hh849848.aspx

            [MS-ERREF] Windows Error Codes    
            http://msdn.microsoft.com/en-us/library/cc231196.aspx
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0)][string]$FilePath,
        [Parameter(Mandatory=$false, Position=1, ValueFromPipeline=$true)][string[]]$ArgumentList,
        [Parameter(Mandatory=$false, Position=2)][string]$WorkingDirectory,
        [Parameter(Mandatory=$false, Position=3)][string[]]$BinPath,

        [Parameter(Mandatory=$false, Position=4)][ValidateRange(1,100)][int]$Retry = 1,
        [Parameter(Mandatory=$false, Position=5)][ValidateRange(1,60)][int]$Interval = 1,

        [Parameter(Mandatory=$false, Position=6)][System.Diagnostics.ProcessWindowStyle]$WindowStyle,
        [Parameter(Mandatory=$false)][switch]$NoNewWindow,

        [Parameter(Mandatory=$false)][switch]$Async,

        [Parameter(Mandatory=$false, Position=7)]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]$OutputEncoding `
            = [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::Default
    )

    Process
    {
        # -FilePath
        if (Test-Path -Path ($exe_filepath = (Get-Location | Join-Path -ChildPath ($FilePath | Split-Path -Leaf))))
        {
            # Current Directory
            $FilePath = $exe_filepath
        }
        elseif (Test-Path -Path ($exe_filepath += '.exe'))
        {
            # Current Directory + '.exe'
            $FilePath = $exe_filepath
        }
        elseif (Test-Path -Path ($exe_filepath = ($PSCommandPath | Split-Path -Parent | Join-Path -ChildPath ($FilePath | Split-Path -Leaf))))
        {
            # Module Path
            $FilePath = $exe_filepath
        }
        elseif (Test-Path -Path ($exe_filepath += '.exe'))
        {
            # Module Path + '.exe'
            $FilePath = $exe_filepath
        }
        elseif ($BinPath -and ($BinPath.Count -ge 1))
        {
            # -BinPath
            foreach ($i in 0..($BinPath.Count - 1))
            {
                if (Test-Path -Path $BinPath[$i] -PathType Container)
                {
                    if (Test-Path -Path ($exe_filepath = ($BinPath[$i] | Join-Path -ChildPath ($FilePath | Split-Path -Leaf))))
                    {
                        # $BinPath
                        $FilePath = $exe_filepath
                        break
                    }
                    elseif (Test-Path -Path ($exe_filepath += '.exe'))
                    {
                        # $BinPath + '.exe'
                        $FilePath = $exe_filepath
                        break
                    }
                }
            }
        }

        # Set FilePath
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


        # Repeat Retry times
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
            catch [System.Exception]
            {
                # [+]V1.0.3.0 (2014/05/08) / [*]V1.0.4.0 (2014/05/09)
                if ($proc -ne $null) { $proc.Kill() }

                throw $_
            }
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
Function New-ISOImageFile
{
    <#
        .SYNOPSIS
            ISO イメージファイルを作成します。

        .DESCRIPTION
            Cygwin ランタイム上で動作する genisoimage.exe を使用して、指定したフォルダーをルートディレクトリにした ISO イメージファイルを作成します。
            指定したパスがファイルだった場合はエラーになります。
            Cygwin および genisoimage.exe は、別途用意してください。

        .PARAMETER InputObject
            ISO イメージを作成した時に、ルートディレクトリになるフォルダーのパスを指定します。
            指定したパスがファイルだった場合はエラーになります。

        .PARAMETER Path
            作成した ISO イメージファイルを保存するパスを指定します。

            ファイルパスではなくフォルダーのパスが指定された場合、あるいは、このパラメーターが省略された場合、指定されたパス、あるいは、
            入力ファイルと同じフォルダーに、入力ファイル名 ($InputObject) に拡張子 '.iso' を付加したファイル名の ISO イメージファイルが作成されます。

            指定されたパスに既にファイルが存在する場合、そのファイルは上書きされます。

        .PARAMETER VolumeID
            ISO イメージのボリュームラベル文字列を指定します。

        .PARAMETER Publisher
            ISO イメージの発行者の文字列を指定します。

        .PARAMETER ApplicationID
            ISO イメージのアプリケーション ID 文字列を指定します。

        .PARAMETER ArgumentList
            genisoimage.exe へのパラメーターを個別に指定する場合に、文字列配列として指定します。
            New-ISOImageFile コマンドレットのプリセットのパラメーターと重複する場合は、このパラメーターの値が優先されます。

        .PARAMETER BinPath
            genisoimage.exe のパスを指定します。複数指定する場合は、文字列配列として指定します。
            Cygwin のデフォルトのインストールパスに genisoimage.exe をインストールしていれば、通常、このパラメーターを指定する必要はありません。

        .PARAMETER RedirectStandardError
            標準エラー出力を標準出力にリダイレクトします。

        .PARAMETER Recommended
            genisoimage.exe に対して、以下のパラメーターを指定します。

                -input-charset utf-8
                -output-charset utf-8
                -rational-rock
                -joliet
                -joliet-long
                -jcharset utf-8

        .INPUTS
            System.String
            パイプを使用して、InputObject パラメーターを New-ISOImageFile コマンドレットに渡すことができます。

        .OUTPUTS
            System.String or None
            ISO イメージファイルの作成に成功した場合は、作成した ISO イメージファイルのパスを返します。
            ISO イメージファイルの作成に失敗した場合は、なにも返しません。

        .NOTES
            MD5 チェックサムではなく、ISO イメージファイルのパスを返すよう、仕様変更しました。

        .EXAMPLE
            New-ISOImageFile -InputObject .\sample -Path .\sample.iso -VolumeID "Test" -Recommended
            カレントディレクトリにある sample フォルダーをルートディレクトリとする sample.iso というファイル名の ISO イメージファイルを作成します。

        .LINK
            Cygwin
            http://www.cygwin.com/

            cdrkit - portable command-line CD-DVD recorder software (for genisoimage.exe)
            http://www.cdrkit.org/
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript (
            {
                if (-not (Test-Path -Path $_ -PathType Container)) { throw New-Object System.IO.DirectoryNotFoundException }
                return $true
            }
        )]
        [string]$InputObject,

        [Parameter(Mandatory=$false, Position=1)]
        [ValidateScript (
            {
                if (-not ($_ | Split-Path -Parent | Test-Path)) { throw New-Object System.IO.DirectoryNotFoundException }
                return $true
            }
        )]
        [string]$Path = ($InputObject + '.iso'),

        [Parameter(Mandatory=$false, Position=2)][string]$VolumeID,
        [Parameter(Mandatory=$false, Position=3)][string]$Publisher,
        [Parameter(Mandatory=$false, Position=4)][string]$ApplicationID,

        [Parameter(Mandatory=$false, Position=5)][string[]]$ArgumentList,
        [Parameter(Mandatory=$false, Position=6)][string[]]$BinPath = $Global:BinPath.Cygwin,

        [Parameter(Mandatory=$false)][switch]$RedirectStandardError,
        [Parameter(Mandatory=$false)][switch]$Recommended
    )

    Process
    {
        # Command Path (genisoimage)
        $command = $Script:genisoimage_FileName

        # Input Path
        $input_path = ($InputObject | Resolve-Path)

        # Output Path (*.iso)
        if ($Path | Test-Path -PathType Container)
        {
            $output_path = $Path | Join-Path -ChildPath ($InputObject + '.iso')
        }
        else
        {
            $output_path = ($Path | Split-Path -Parent | Convert-Path | Join-Path -ChildPath ($Path | Split-Path -Leaf))
        }


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
            #############################################################################################################################
            Start-Command -FilePath $command -ArgumentList $arg_list -BinPath $BinPath -OutputEncoding UTF8 -WindowStyle Hidden -Debug
            #############################################################################################################################
        }
        else
        {
            #############################################################################################################################
            Start-Command -FilePath $command -ArgumentList $arg_list -BinPath $BinPath -OutputEncoding UTF8 -WindowStyle Hidden
            #############################################################################################################################
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
