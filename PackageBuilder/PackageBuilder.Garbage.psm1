######## LICENSE ####################################################################################################################################
<#
 # Copyright (c) 2014, Daiki Sakamoto
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
 #  2014/03/05  Create
 #
 #>
#####################################################################################################################################################

#####################################################################################################################################################
# Variables
$Script:FCIV_BinPath  = 'C:\FCIV'
$Script:FCIV_FileName = 'fciv.exe'

#####################################################################################################################################################
Function Invoke-LoadLibrary
{

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
            if ((Get-Item -Path $_) -isnot [System.IO.FileInfo]) { throw New-Object System.IO.FileNotFoundException }
            return $true
        } )]
        [string]$lpFileName
    )

    Process
    {
        $signature = @'
[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
public static extern IntPtr LoadLibrary(
    string lpFileName // モジュールのファイル名
);
'@
        # LoadLibrary
        return (Add-Type -MemberDefinition $signature -Name 'Win32LoadLibrary' -PassThru)::LoadLibrary($lpFileName)
    }
}

#####################################################################################################################################################
Function Get-CheckSum
{

<#
    .SYNOPSIS
        チェックサムを取得します。


    .DESCRIPTION
        Microsoft の FCIV (File Checksum Integrity Verifier / version 2.05) を実行します。
        FCIV は、別途ご用意してください。


    .PARAMETER InputObject


    .PARAMETER BinPath
        fciv.exe が保存されているフォルダーのパスを指定します。
        省略すると、C:\FCIV を検索します。
        あるいは、環境変数の PATH に保存されていても実行可能です。

    .PARAMETER MD5


    .PARAMETER SHA1


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
        Availability and description of the File Checksum Integrity Verifier utility
        http://support.microsoft.com/kb/841290
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

        if ($BinPath) { $command = ($BinPath | Resolve-Path | Join-Path -ChildPath $Script:FCIV_FileName) }
        else
        {
            if (-not (($command = ($Script:FCIV_BinPath | Join-Path -ChildPath $Script:FCIV_FileName)) | Test-Path)) { $command = $Script:FCIV_FileName }
        }

        if($SHA1)
        {
            [string[]]$out = (Start-Command -FilePath $command -ArgumentList ('"' + $InputObject + '"'), '-sha1' -WindowStyle Hidden) -as [string[]]
        }
        else
        {
            [string[]]$out = (Start-Command -FilePath $command -ArgumentList ('"' + $InputObject + '"') -WindowStyle Hidden) -as [string[]]
        }

        for ($i=3; $i -lt $out.Count; $i++)
        {
            Write-Output ($out[$i] -split ' ')[0]
        }
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
