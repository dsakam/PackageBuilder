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

#####################################################################################################################################################
Function Invoke-LoadLibrary
{
    <#
        .SYNOPSIS
            LoadLibrary 関数を使用して、ライブラリーファイルをロードします。

        .DESCRIPTION
            使用しないでください。

        .PARAMETER Path
            ライブラリーファイルのパスを指定します。

        .INPUTS
            None
            パイプを使用してこのコマンドレットに入力を渡すことはできません。

        .OUTPUTS
            System.IntPtr
            ロードに成功したライブラリーファイルのハンドルを返します。

        .LINK
            LoadLibrary function (Windows)
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms684175.aspx

            LoadLibrary 関数
            http://msdn.microsoft.com/ja-jp/library/cc429241.aspx
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateScript (
            {
                if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
                if ((Get-Item -Path $_) -isnot [System.IO.FileInfo]) { throw New-Object System.IO.FileNotFoundException }
                return $true
            }
        )]
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
            FCIV は、別途用意してください。

        .PARAMETER InputObject
            入力ファイルあるいはフォルダーのパスを指定します。

        .PARAMETER BinPath
            fciv.exe が保存されているフォルダーのパスを指定します。
            省略すると、C:\FCIV を検索します。
            あるいは、環境変数の PATH に保存されていても実行可能です。

        .PARAMETER MD5
            MD5 (デフォルト)

        .PARAMETER SHA1
            SHA1

        .INPUTS
            System.String

        .OUTPUTS
            System.String

        .NOTES
            FCIV の出力である下記の 'ffffffffffffffffffffffffffffffff' の部分を出力します。

                //
                // File Checksum Integrity Verifier version 2.05.
                //
                ffffffffffffffffffffffffffffffff test.txt

        .LINK
            Availability and description of the File Checksum Integrity Verifier utility
            http://support.microsoft.com/kb/841290
    #>

    [CmdletBinding()]
    Param (
        [Parameter (Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateScript (
            {
                if (-not (Test-Path -Path $_)) { throw New-Object System.IO.FileNotFoundException }
                return $true
            }
        )]
        [string]$InputObject,

        [Parameter (Mandatory=$false, Position=1)][string]$BinPath,
        [Parameter (Mandatory=$false)][switch]$MD5,
        [Parameter (Mandatory=$false)][switch]$SHA1
    )

    Process
    {
        $FCIV_BinPath  = 'C:\FCIV'
        $FCIV_FileName = 'fciv.exe'

        # Exception
        trap { break }

        if ($BinPath) { $command = ($BinPath | Resolve-Path | Join-Path -ChildPath $FCIV_FileName) }
        else
        {
            if (-not (($command = ($FCIV_BinPath | Join-Path -ChildPath $FCIV_FileName)) | Test-Path)) { $command = $FCIV_FileName }
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
Function Send-Mail
{
    <#
        .SYNOPSIS
            E メールを送信します。

        .DESCRIPTION
            Send-MailMessage コマンドレットを使用してください。

        .PARAMETER To
            E メールの宛先 (To) を指定します。

        .PARAMETER From
            E メールの送信者 (From) を指定します。

        .PARAMETER Host
            E メールを送信する SMTP サーバーを指定します。

        .PARAMETER Subject
            E メールの件名 (Subject) を指定します。

        .PARAMETER Body
            E メールの本文 (Body) を指定します。

        .PARAMETER UserName
            E メールを送信する SMTP サーバーへのログインアカウントのユーザー名を指定します。

        .PARAMETER Password
            E メールを送信する SMTP サーバーへのログインアカウントのパスワードを指定します。

        .PARAMETER Domain
            E メールを送信する SMTP サーバーへのログインアカウントのドメインを指定します。

        .PARAMETER Port
            E メールを送信する SMTP サーバーのポート番号を指定します。

        .INPUTS
            System.String

        .OUTPUTS
            None
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
