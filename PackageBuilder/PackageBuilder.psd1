#
# モジュール 'Package Builder Toolkit for PowerShell' のモジュール マニフェスト
#
# 生成者: Daiki Sakamoto
#
# 生成日: 2013/10/11
#

@{

# このマニフェストに関連付けられているスクリプト モジュール ファイルまたはバイナリ モジュール ファイル。
# RootModule = ''

# このモジュールのバージョン番号です。
ModuleVersion = '1.1.0.0'

# このモジュールを一意に識別するために使用される ID
GUID = '3ac21d6a-8d73-4fc2-a732-fdc1e8b4eea9'

# このモジュールの作成者
Author = 'Daiki Sakamoto'

# このモジュールの会社またはベンダー
CompanyName = 'BUILDLet'

# このモジュールの著作権情報
Copyright = '(c) 2013-2014 Daiki Sakamoto. All rights reserved.'

# このモジュールの機能の説明
Description = 'Package Builder Toolkit for PowerShell'

# このモジュールに必要な Windows PowerShell エンジンの最小バージョン
PowerShellVersion = '3.0'

# このモジュールに必要な Windows PowerShell ホストの名前
# PowerShellHostName = ''

# このモジュールに必要な Windows PowerShell ホストの最小バージョン
# PowerShellHostVersion = ''

# このモジュールに必要な .NET Framework の最小バージョン
# DotNetFrameworkVersion = ''

# このモジュールに必要な共通言語ランタイム (CLR) の最小バージョン
# CLRVersion = ''

# このモジュールに必要なプロセッサ アーキテクチャ (なし、X86、Amd64)
# ProcessorArchitecture = ''

# このモジュールをインポートする前にグローバル環境にインポートされている必要があるモジュール
# RequiredModules = @()

# このモジュールをインポートする前に読み込まれている必要があるアセンブリ
# RequiredAssemblies = @()

# このモジュールをインポートする前に呼び出し元の環境で実行されるスクリプト ファイル (.ps1)。
# ScriptsToProcess = @()

# このモジュールをインポートするときに読み込まれる型ファイル (.ps1xml)
# TypesToProcess = @()

# このモジュールをインポートするときに読み込まれる書式ファイル (.ps1xml)
# FormatsToProcess = @()

# RootModule/ModuleToProcess に指定されているモジュールの入れ子になったモジュールとしてインポートするモジュール
NestedModules = @(
    'PackageBuilder.Core.psm1',
    'PackageBuilder.Utilities.psm1',
    'PackageBuilder.Forms.psm1',
    'PackageBuilder.Win32.psm1',
    'PackageBuilder.Remote.psm1',
    'PackageBuilder.Legacy.psm1'
)

# このモジュールからエクスポートする関数
FunctionsToExport = '*'

# このモジュールからエクスポートするコマンドレット
CmdletsToExport = '*'

# このモジュールからエクスポートする変数
VariablesToExport = '*'

# このモジュールからエクスポートするエイリアス
AliasesToExport = '*'

# このモジュールに同梱されているすべてのモジュールのリスト。
# ModuleList = @()

# このモジュールに同梱されているすべてのファイルのリスト
# FileList = @()

# RootModule/ModuleToProcess に指定されているモジュールに渡すプライベート データ
# PrivateData = ''

# このモジュールの HelpInfo URI
# HelpInfoURI = ''

# このモジュールからエクスポートされたコマンドの既定のプレフィックス。既定のプレフィックスをオーバーライドする場合は、Import-Module -Prefix を使用します。
# DefaultCommandPrefix = ''

}
