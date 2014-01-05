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
 #              Update
 #  2013/09/04  Update
 #  2013/10/24  Update
 #
 #>
#####################################################################################################################################################

#####################################################################################################################################################
Function Shutdown-Computer {

<#
.SYNOPSIS
Shutdown the computer.


.DESCRIPTION
    PC をシャットダウンします。


.PARAMETER ComputerName
    Type: System.String
    If omitted, this computer may be shut down.


.PARAMETER UserName
    Type: System.String
    If omitted, shutdown is tryed by your privilege.


.PARAMETER Password
    Type: System.String
    Password of those who tries to shut down the computer.


.INPUTS
    System.String


.OUTPUTS
    None


.NOTES
    Shutdown Computer Cmdlet
    
    2013/08/17  Create
    2013/09/02  Update
    2013/09/04  Update
    2013/10/23  Modify


.EXAMPLE
(None)


.LINK
(None)
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
            if ($Password)
            {
                # w/ Credential        
                $credential = New-Object System.Management.Automation.PSCredential $UserName, (ConvertTo-SecureString $Password -AsPlainText -Force)

                if ($Force)
                {
                    Stop-Computer -ComputerName $ComputerName -Credential $credential -Force
                }
                else
                {
                    Stop-Computer -ComputerName $ComputerName -Credential $credential
                }
            }
            else
            {
                # w/o Credential
                if ($Force)
                {
                    Stop-Computer -ComputerName $ComputerName -Force
                }
                else
                {
                    Stop-Computer -ComputerName $ComputerName
                }
            }
        }
    }
}

#####################################################################################################################################################
Function Reboot-Computer {

<#
.SYNOPSIS
Shutdown the computer.


.DESCRIPTION
    PC を再起動します。


.PARAMETER ComputerName
    Type: System.String
    If omitted, this computer may be shut down.


.PARAMETER UserName
    Type: System.String
    If omitted, shutdown is tryed by your privilege.


.PARAMETER Password
    Type: System.String
    Password of those who tries to shut down the computer.


.INPUTS
    System.String


.OUTPUTS
    None


.NOTES
    Shutdown Computer Cmdlet
    

.EXAMPLE
(None)


.LINK
(None)
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
            if ($Password)
            {
                # w/ Credential        
                $credential = New-Object System.Management.Automation.PSCredential $UserName, (ConvertTo-SecureString $Password -AsPlainText -Force)

                if ($Force)
                {
                    Restart-Computer -ComputerName $ComputerName -Credential $credential -Force
                }
                else
                {
                    Restart-Computer -ComputerName $ComputerName -Credential $credential
                }
            }
            else
            {
                # w/o Credential
                if ($Force)
                {
                    Restart-Computer -ComputerName $ComputerName -Force
                }
                else
                {
                    Restart-Computer -ComputerName $ComputerName
                }
            }
        }
    }
}

#####################################################################################################################################################
Function Reboot-Computer {

<#
.SYNOPSIS


.DESCRIPTION
    Wake on LAN


.PARAMETER ComputerName
    Type: System.String
    If omitted, this computer may be shut down.


.PARAMETER UserName
    Type: System.String
    If omitted, shutdown is tryed by your privilege.


.PARAMETER Password
    Type: System.String
    Password of those who tries to shut down the computer.


.INPUTS
    System.String


.OUTPUTS
    None


.NOTES
    Shutdown Computer Cmdlet
    

.EXAMPLE
(None)


.LINK
(None)
#>

    [CmdletBinding ()]
    Param (
        [Parameter (Mandatory=$true, Position=0, ValueFromPipeline=$true)][string]$MacAddress
    )

    Process
    {
    }
}
