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
 #  2013/08/17  Create
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
 #  2014/04/30  Version 0.12.0.0
 #  2014/05/05  Version 0.13.0.0
 #  2014/05/06  Version 1.0.0.0
 #
 #>
#####################################################################################################################################################

#####################################################################################################################################################
Function Stop-Host
{
    <#
        .SYNOPSIS
            ローカルとリモートのコンピューターを停止 (シャットダウン) します。

        .DESCRIPTION
            Stop-Computer コマンドレットのラッパーです。
            資格情報をプレーンテキストで扱うので、使用する際は十分注意してください。

        .PARAMETER ComputerName
            指定されたコンピューターを停止します。既定値はローカル コンピューターです。

        .PARAMETER UserName
            この処理を実行するアクセス許可を持つユーザー アカウントのユーザー名を指定します。既定値は現在のユーザーです。

        .PARAMETER Password
            この処理を実行するアクセス許可を持つユーザー アカウントのパスワードを指定します。既定値は 'なし' です。

        .PARAMETER Silent
            このパラメーターが指定されたときは、確認ダイアログによるユーザーへの確認を行わずに処理を実行します。

        .PARAMETER Force
            コンピューターの即時シャットダウンを強制します。

        .INPUTS
            System.String
            パイプを使用して、ComputerName パラメーターを Stop-Host コマンドレットに渡すことができます。

        .OUTPUTS
            None
            このコマンドレットの出力はありません。

        .EXAMPLE
            Stop-Host -ComputerName 'PC1' -UserName 'Administrator' -Password '12345'
            コンピューター名 'PC1' のコンピューターに対して、'Administrator' の権限でのシャットダウンを試みます。

        .LINK
            Stop-Computer
            http://technet.microsoft.com/ja-JP/library/hh849839.aspx
    #>

    [CmdletBinding ()]
    Param (
        [Parameter (Mandatory=$false, Position=0, ValueFromPipeline=$true)][string]$ComputerName = $env:COMPUTERNAME,
        [Parameter (Mandatory=$false, Position=1)][string]$UserName = $env:USERNAME,
        [Parameter (Mandatory=$false, Position=2)][string]$Password,
        [Parameter (Mandatory=$false)] [switch]$Silent,
        [Parameter (Mandatory=$false)] [switch]$Force
    )

    Process
    {
        # Confirmation
        $result = [System.Windows.Forms.DialogResult]::OK
        if (-not $Silent)
        {
            $result = Show-Message `
                -Text "Are you sure you want to shut down the computer '$ComputerName' now?" `
                -Caption $MyInvocation.MyCommand.Name `
                -Buttons ([system.windows.forms.messageboxbuttons]::OKCancel)
        }

        if ($result -eq [System.Windows.Forms.DialogResult]::OK)
        {
            try
            {
                if ($Password)
                {
                    # w/ Credential        
                    $credential = New-Object System.Management.Automation.PSCredential $UserName, (ConvertTo-SecureString $Password -AsPlainText -Force)

                    if ($Force)
                    {
                        Stop-Computer -ComputerName $ComputerName -Credential $credential -ErrorAction Stop -Force
                    }
                    else
                    {
                        Stop-Computer -ComputerName $ComputerName -Credential $credential -ErrorAction Stop
                    }
                }
                else
                {
                    # w/o Credential
                    if ($Force)
                    {
                        Stop-Computer -ComputerName $ComputerName -ErrorAction Stop -Force
                    }
                    else
                    {
                        Stop-Computer -ComputerName $ComputerName -ErrorAction Stop
                    }
                }
            }
            catch
            {
                if ($Silent) { throw }
                else { [void](Show-Message -Text $_ -Caption $MyInvocation.MyCommand.Name) }
            }
        }
    }
}

#####################################################################################################################################################
Function Restart-Host
{
    <#
        .SYNOPSIS
            ローカル コンピューターおよびリモート コンピューター上でオペレーティング システムを再起動 (リブート) します。

        .DESCRIPTION
            Restart-Computer コマンドレットのラッパーです。
            資格情報をプレーンテキストで扱うので、使用する際は十分注意してください。

        .PARAMETER ComputerName
            指定されたコンピューターを再起動します。既定値はローカル コンピューターです。

        .PARAMETER UserName
            この処理を実行するアクセス許可を持つユーザー アカウントのユーザー名を指定します。既定値は現在のユーザーです。

        .PARAMETER Password
            この処理を実行するアクセス許可を持つユーザー アカウントのパスワードを指定します。既定値は 'なし' です。

        .PARAMETER Silent
            このパラメーターが指定されたときは、確認ダイアログによるユーザーへの確認を行わずに処理を実行します。

        .PARAMETER Force
            コンピューターの即時再起動を強制します。

        .INPUTS
            System.String
            パイプを使用して、ComputerName パラメーターを Restart-Host コマンドレットに渡すことができます。

        .OUTPUTS
            None
            このコマンドレットの出力はありません。

        .EXAMPLE
            Restart-Host -ComputerName 'PC1' -UserName 'Administrator' -Password '12345'
            コンピューター名 'PC1' のコンピューターに対して、'Administrator' の権限での再起動を試みます。

        .LINK
            Restart-Computer
            http://technet.microsoft.com/ja-JP/library/hh849837.aspx
    #>

    [CmdletBinding ()]
    Param (
        [Parameter (Mandatory=$false, Position=0, ValueFromPipeline=$true)][string]$ComputerName = $env:COMPUTERNAME,
        [Parameter (Mandatory=$false, Position=1)][string]$UserName = $env:USERNAME,
        [Parameter (Mandatory=$false, Position=2)][string]$Password,
        [Parameter (Mandatory=$false)] [switch]$Silent,
        [Parameter (Mandatory=$false)] [switch]$Force
    )

    Process
    {
        # Confirmation
        $result = [System.Windows.Forms.DialogResult]::OK
        if (-not $Silent)
        {
            $result = Show-Message `
                -Text "Are you sure you want to reboot the computer '$ComputerName' now?" `
                -Caption $MyInvocation.MyCommand.Name `
                -Buttons ([system.windows.forms.messageboxbuttons]::OKCancel)
        }

        if ($result -eq [System.Windows.Forms.DialogResult]::OK)
        {
            try
            {
                if ($Password)
                {
                    # w/ Credential        
                    $credential = New-Object System.Management.Automation.PSCredential $UserName, (ConvertTo-SecureString $Password -AsPlainText -Force)

                    if ($Force)
                    {
                        Restart-Computer -ComputerName $ComputerName -Credential $credential -ErrorAction Stop -Force
                    }
                    else
                    {
                        Restart-Computer -ComputerName $ComputerName -Credential $credential -ErrorAction Stop
                    }
                }
                else
                {
                    # w/o Credential
                    if ($Force)
                    {
                        Restart-Computer -ComputerName $ComputerName -ErrorAction Stop -Force
                    }
                    else
                    {
                        Restart-Computer -ComputerName $ComputerName -ErrorAction Stop
                    }
                }
            }
            catch
            {
                if ($Silent) { throw }
                else { [void](Show-Message -Text $_ -Caption $MyInvocation.MyCommand.Name) }
            }
        }
    }
}

#####################################################################################################################################################
Function Start-Computer
{
    <#
        .SYNOPSIS
            リモートコンピューターを開始 (起動) します。

        .DESCRIPTION
            Wake on LAN で、リモートコンピューターを開始 (起動) します。

        .PARAMETER MacAddress
            リモートコンピューターの MAC アドレスを文字列で指定します。
            1 バイトずつコロン (':') で区切り、たとえば 'EE:EE:EE:00:00:01' のように指定します。

        .PARAMETER Port
            リモートコンピューターのポート番号を指定します。
            デフォルトは 2304 です。

        .PARAMETER Retry
            マジックパケットを送信する回数を指定します。
            デフォルトは 3 [回] です。

        .INPUTS
            System.String
            パイプを使用して、リモートコンピューターの MAC アドレス (MacAddress パラメーター) を Start-Computer コマンドレットに渡すことができます。

        .OUTPUTS
            None
            このコマンドレットの出力はありません。

        .EXAMPLE
            Start-Computer -MacAddress 'EE:EE:EE:00:00:01' -Verbose
            MAC アドレスが EE:EE:EE:00:00:01 であるリモートコンピューターの起動を試みます。

        .LINK
            Wake-on-LAN - Wikipedia
            http://ja.wikipedia.org/wiki/Wake-on-LAN

            方法 16 進文字列と数値型の間で変換する (C# プログラミング ガイド)
            http://msdn.microsoft.com/ja-jp/library/bb311038.aspx
    #>

    [CmdletBinding ()]
    Param (
        [Parameter (Mandatory=$true, Position=0, ValueFromPipeline=$true)][string]$MacAddress,
        [Parameter (Mandatory=$false, Position=1)][int]$Port = 2304,
        [Parameter (Mandatory=$false, Position=2)][int]$Retry = 3
    )

    Process
    {
        [string[]]$mac = $MacAddress -split ":"
        [byte[]]$packet = [byte[]]0xFF * 6

        0..15 | % {
            $mac | % { $packet += [System.Convert]::ToInt32($_, 16) }
        }

        $udp = New-Object System.Net.Sockets.UdpClient
        foreach ($i in 0..($Retry - 1))
        {
            $sent = $udp.Send($packet, $packet.Count, (New-Object System.Net.IPEndPoint -ArgumentList ([System.Net.IPAddress]::Broadcast, $Port)))
            Write-Verbose ("[" + $MyInvocation.MyCommand.Name + "] $sent Bytes were sent... ($i)")
            Start-Sleep -Seconds 1
        }
    }
}

#####################################################################################################################################################
