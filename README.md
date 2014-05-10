PackageBuilder
==============

Package Builder Toolkit for PowerShell Version **1.0.5.0**

概要
----
ソフトウェアをパッケージングして、最終的に ISO イメージファイルを作成するためのコマンドレット群です。  
詳細は、各コマンドレットのヘルプを参照してください。


### PackageBuilder.Core.psm1
このモジュールの目的である ISO イメージファイルを作成するためのコマンドレット群を含みます。

* **Get-MD5**  
MD5 ハッシュ値を取得します。  

* **Start-Command**  
任意のファイルを実行します。  

* **Test-SameFile**  
2つのファイルやフォルダーが同一かどうかを調べます。  

* **New-ISOImageFile**  
ISO イメージファイルを作成します。   
  
  
### PackageBuilder.Utilities.psm1
ソフトウェアをパッケージングする際に、あると便利なコマンドレット群を含みます。

* **New-GUID**  
新しい GUID を生成します。  

* **New-HR**  
水平線を出力します。  

* **Write-Title**  
コンソールにタイトルを表示します。  

* **Write-Boolean**  
テスト結果の真偽に応じた色で、コンソールに出力します。  

* **Show-Message**  
メッセージボックスを表示します。  

* **Get-DateString**  
日付文字列を取得します。  

* **Get-FileVersionInfo**  
ファイルのバージョン情報を取得します。  

* **Get-ProductName**  
ファイルのバージョン情報 (製品名) を取得します。  

* **Get-FileDescription**  
ファイルのバージョン情報 (ファイルの説明) を取得します。  

* **Get-FileVersion**  
ファイルのバージョン情報 (ファイルバージョン) を取得します。  

* **Get-ProductVersion**  
ファイルのバージョン情報 (製品バージョン) を取得します。  

* **Get-HTMLString**  
HTML ファイルから指定した要素を取得します。  

* **Get-PrivateProfileString**  
INI ファイル (初期化ファイル) から設定値を取得します。  

* **Update-Content**  
テキストファイルの内容を更新します。  

* **Get-WindowHandler**  
ウィンドウ ハンドル (HWND) を取得します。  

* **New-StructArray**  
構造体配列のようなカスタムオブジェクトの配列を作成します。  

* **Get-ByteArray**  
ファイルからバイト配列を取得します。  

* **ConvertFrom-ByteArray**  
バイト配列を文字列へ変換します。  

* **ConvertTo-ByteArray**  
文字列をバイト配列へ変換します。  


### PackageBuilder.Win32.psm1
P/Invoke を使用して Win32 API を呼び出します。

* **Invoke-LoadLibraryEx**  
LoadLibraryEx 関数を使用して、ライブラリーファイルをロードします。  

* **Invoke-FreeLibrary**  
FreeLibrary 関数を使用して、ロード済みのライブラリーファイルを解放します。  

* **Invoke-LoadString**  
LoadString 関数を使用して、文字列リソースを取得します。  

* **Get-ResourceString**  
文字列リソースを取得します。  

* **Invoke-HtmlHelp**  
HTML ヘルプファイルを開きます。  


### PackageBuilder.Remote.psm1
リモートコンピューターの操作に関連したコマンドレット群を含みます。

* **Stop-Host**  
ローカルとリモートのコンピューターを停止 (シャットダウン) します。  

* **Restart-Host**  
ローカルとリモートのコンピューターを再起動 (リブート) します。  

* **Start-Computer**  
Wake on LAN で、リモートコンピューターを起動します。


### PackageBuilder.Legacy.psm1
Version 1 までに使用しなくなったコマンドレット群を含みます。  
基本的に、これらのコマンドレットは使用しないでください。

* **Invoke-LoadLibrary**  
LoadLibrary 関数を使用して、ライブラリーファイルをロードします。  

* **Get-CheckSum**  
FCIV (File Checksum Integrity Verifier / version 2.05) を使用して、ファイルのハッシュ値を取得します。  

* **Send-Mail**  
E メールを送信します。  
Send-MailMessage コマンドレットを使用してください。


履歴
----

**V1.0.5.0** (2014/05/10)  
Update-Content コマンドレットの空文字 (String.Empty) の処理を再度修正。  
Start-Command コマンドレットの標準出力および標準エラー出力の一時ファイル名を変更。

**V1.0.4.0** (2014/05/09)  
Update-Content コマンドレットの空文字 (String.Empty) の処理を修正。  
Start-Command コマンドレットの例外処理を再度修正。

**V1.0.3.0** (2014/05/08)  
ヘルプコンテンツの修正。  
Show-Message コマンドレットの引数の型の修正。  
Start-Command コマンドレットの例外処理を修正。

**V1.0.2.0** (2014/05/06)  
モジュールのバージョン誤り (PackageBuilder.psd1) を修正。

**V1.0.1.0** (2014/05/06)  
Update README.md  
ヘルプコンテンツの一部を修正。

**V1.0.0.0** (2014/05/06)  
1st Public Release

**V0.12.0.0** (2014/04/30)  
Pre-Release

**V0.11.0.0** (2014/04/23)  
Pre-Release

**V0.10.0.0** (2014/04/17)  
Pre-Release

**V0.9.0.0** (2014/04/06)  
Pre-Release

**V0.8.0.0** (2014/03/16)  
Pre-Release

**V0.7.0.0** (2014/03/10)  
Pre-Release

**V0.6.0.0** (2014/03/06)  
Pre-Release

**V0.5.0.0** (2014/02/27)  
Pre-Release

**V0.4.0.0** (2014/01/16)  
Pre-Release

**V0.3.0.0** (2014/01/10)  
Pre-Release

**V0.2.0.0** (2014/01/05)  
Pre-Release including Get-PrivateProfileString bug fix

**V0.1.0.0** (2013/12/30)  
Pre-Release
