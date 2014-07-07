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
 #  2014/06/22  Version 1.1.0.0    Create
 #                                 Separeted from PackageBuilder.Utilities.psm1 (only Show-Message Cmdlet)
 #  2014/07/07                     Change type of parameter 'Buttons' of 'Show-Message' CmdLet.
 #
 #>
#####################################################################################################################################################

#####################################################################################################################################################
# Load Assembly
try {
    [void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
}
catch {
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms.dll')
}

#####################################################################################################################################################
Function Show-Message
{
    <#
        .SYNOPSIS
            メッセージ ボックスを表示します。 

        .DESCRIPTION
            System.Windows.Forms.MessageBox.Show メソッドを使用して、メッセージ ボックスを表示します。 

        .PARAMETER Text
            メッセージ ボックスに表示するテキストを指定します。

        .PARAMETER Caption
            メッセージ ボックスのタイトル バーに表示するテキストを指定します。
            デフォルトでは、ホストセッションの名前 ($PSSessionApplicationName) が表示されます。

        .PARAMETER Buttons
            メッセージ ボックスに表示するボタンを System.Windows.Forms.MessageBoxButtons の値で指定します。
            デフォルトは、指定なしです。

        .INPUTS
            System.String
            パイプを使用して、Text パラメーターを Show-Message コマンドレットに渡すことができます。

        .OUTPUTS
            System.Windows.Forms.DialogResult
            System.Windows.Forms.MessageBox.Show メソッドの戻り値を、コマンドレットの戻り値として返します。

        .NOTES
            Show-Message コマンドレットは System.Windows.Forms.MessageBox.Show メソッドを使用して、メッセージ ボックスを表示します。 

        .EXAMPLE
            Show-Message hoge
            メッセージ 'hoge' と表示されたメッセージ ボックスを表示します。

        .LINK
            System.Windows.Forms 名前空間
            http://msdn.microsoft.com/library/system.windows.forms.aspx

            MessageBox クラス (System.Windows.Forms)
            http://msdn.microsoft.com/library/system.windows.forms.messagebox.aspx
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][string]$Text,
        [Parameter(Mandatory=$false, Position=1)][string]$Caption = $PSSessionApplicationName,
        [Parameter(Mandatory=$false, Position=2)][System.Windows.Forms.MessageBoxButtons]$Buttons
    )

    Process
    {
        if ($Buttons) { return [System.Windows.Forms.MessageBox]::Show($Text, $Caption, $Buttons) }
        else { return [System.Windows.Forms.MessageBox]::Show($Text, $Caption) }
    }
}

#####################################################################################################################################################
Function Show-InputBox
{
    <#
        .SYNOPSIS
            ユーザーに入力を求めるメッセージ ボックスを表示します。 

        .DESCRIPTION
            テキスト ボックスもしくはコンボ ボックスのついたメッセージ ボックスを表示します。
            テキスト ボックスにユーザーが入力した文字列、または、コンボ ボックスからユーザーが選択した文字列を取得します。

        .PARAMETER Text
            メッセージ ボックスに表示するテキストを指定します。

        .PARAMETER DefaultValue
            ユーザーに任意の文字列を入力させたい場合に、テキスト ボックスのデフォルトの文字列を指定します。

        .PARAMETER DefaultValue
            あらかじめ設定しておいた値のいずれかをユーザーに選択させる場合、コンボボックスに表示される選択肢を文字列配列で指定します。

        .PARAMETER Caption
            メッセージ ボックスのタイトル バーに表示するテキストを指定します。
            デフォルトでは、ホストセッションの名前 ($PSSessionApplicationName) が表示されます。

        .INPUTS
            System.String
            パイプを使用して、Text パラメーターを Show-Message コマンドレットに渡すことができます。

        .OUTPUTS
            System.String
            ユーザーがテキスト ボックスに入力した文字列、もしくは、コンボ ボックスから選択した文字列を、コマンドレットの戻り値として返します。
            キャンセルした場合は、System.String.Empty を返します。

        .NOTES
            Show-InputBox コマンドレットは System.Windows.Forms 名前空間に含まれる諸種のクラスを使用します。 

        .EXAMPLE
            Show-InputBox -Text "Please input your name:" -Caption "TextBox"
            メッセージとタイトルバーに、それぞれ "Please input your name:"、"TextBox" と表示された
            テキスト ボックス付きのメッセージ ボックスを表示します。
            

        .EXAMPLE
            Show-InputBox -Text "Please select a value:" -Selectable "abc", "xyz" -Caption "ComboBox"
            メッセージとタイトルバーに、それぞれ "Please select a value:"、"ComboBox" と表示された
            コンボ ボックス付きのメッセージ ボックスを表示します。
            コンボボックスの選択肢は "abc" と "xyz" です。

        .LINK
            System.Windows.Forms 名前空間
            http://msdn.microsoft.com/library/system.windows.forms.aspx
    #>

    [CmdletBinding(DefaultParameterSetName='text')]
    Param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][string]$Text,
        [Parameter(Mandatory=$false, Position=1, ParameterSetName='text')][string]$DefaultValue = [string]::Empty,
        [Parameter(Mandatory=$true, Position=1, ParameterSetName='list')][string[]]$Selectable,
        [Parameter(Mandatory=$false, Position=2)][string]$Caption = $PSSessionApplicationName
    )

    Process
    {
        if ($PSCmdlet.ParameterSetName -eq 'list')
        {
            # ComboBox
            $control = New-Object System.Windows.Forms.ComboBox
            $control.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList

            $Selectable | % { [void]$control.Items.Add($_) }
            $control.SelectedIndex = 0
        }
        else
        {
            # TextBox
            $control = New-Object System.Windows.Forms.TextBox
            $control.Text = $DefaultValue
        }
        


        # New
        $form = New-Object System.Windows.Forms.Form
        $label = New-Object System.Windows.Forms.Label
        $okButton = New-Object System.Windows.Forms.Button
        $cancelButton = New-Object System.Windows.Forms.Button

        # Size (/ Width)
        $form.Size = New-Object System.Drawing.Size(340, 135)
        $controlWidth = 305

        # Location
        $label.Location = New-Object System.Drawing.Point(15, 15)
        $Control.Location = New-Object System.Drawing.Point(15, 40)
        $okButton.Location = New-Object System.Drawing.Point(155, 70)
        $cancelButton.Location = New-Object System.Drawing.Point(245, 70)


        # Form
        $form.Text = $Caption
        $form.ShowIcon = $false
        $form.MaximizeBox = $false
        $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
        $form.AcceptButton = $okButton
        $form.CancelButton = $cancelButton


        # Label
        $label.Text = $Text
        $label.Width = $controlWidth


        # control (TextBox or ComboBox)
        $control.Width = $controlWidth


        # OK Button
        $okButton.Text = "&OK"
        $okButton.add_Click({
            $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $input = $textBox.Text
            $form.Close()
        })


        # Cancel Button
        $cancelButton.Text = "&Cancel"
        $cancelButton.add_Click({
            $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $form.Close()
        })


        # Add Controls
        $form.Controls.AddRange(($label, $control, $okButton, $cancelButton))


        # Show
        [void]$form.ShowDialog()


        # Return
        if ($form.DialogResult -eq [System.Windows.Forms.DialogResult]::OK)
        {
            switch ($PSCmdlet.ParameterSetName)
            {
                'text' { return $control.Text }
                'list' { return $control.SelectedItem }
            }
        }
        else { return [string]::Empty }
    }
}

#####################################################################################################################################################
