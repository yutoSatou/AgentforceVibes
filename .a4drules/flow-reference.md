# Flow

フローに関連付けられたメタデータを表します。フローを使用すると、ユーザーが一連のページを移動してデータベース内のレコードをクエリおよび更新するアプリケーションを作成できます。また、ユーザー入力に基づいてロジックを実行して分岐機能を提供し、動的なアプリケーションを構築できます。

> **重要**
>
> * 可能な場合は、Equality の会社の値に一致するように、含めない用語を変更しました。顧客の実装に対する影響を回避するために、一部の用語は変更されていません。
> * 対応する UI ベースのフロー作成ツールについての詳細は、Salesforce ヘルプの「Flow Builder」を参照してください。
> * メタデータ API を使用してフローを操作する場合、次の点に留意してください。
>     * フローがテンプレートである場合を除き、管理パッケージからインストールされたフローへのアクセスには、メタデータ API を使用できません。
>     * フローファイル名にスペースがあると、リリース時にエラーが発生する可能性があります。先頭と末尾の空白は許可されますが、リリース時に削除されます。
> * メタデータ API を使用する場合、特定の状況で有効なフローへの変更をリリースできます。
>     * 組織が、スクラッチ組織や Sandbox など、本番組織でない場合：有効なフローが最新バージョンになります。
>     * 組織がリリースプロセスおよびフローを有効な設定として有効化した本番組織である場合：有効なフローが最新バージョンになります。
> * 有効なフローへの変更をリリースすると、フローの詳細ページに有効な新しいフローバージョンが表示されます。この新しいバージョンには変更が含まれています。たとえば、myflow のバージョン 3 が有効な最新バージョンだとします。バージョン 3 を変更してリリースすると、myflow の詳細ページに有効なバージョンとしてバージョン 4 が表示されます。
> * フローバージョンが有効でなく、一時停止中のインタビューがなければ削除できます。フローバージョンに一時停止中のインタビューがある場合は、これらのインタビューが再開または終了するまで待機するか、インタビューを削除します。

> **警告**
>
> processType が Workflow または InvocableProcess であるフローコンポーネントなど、取得したプロセスビルダープロセスのメタデータを編集しないでください。編集したプロセスメタデータをリリースした場合、対象組織でプロセスを開くことができない可能性があります。

## 宣言的なメタデータファイルのサフィックスおよびディレクトリの場所

フローは、対応するパッケージディレクトリの `Flow` ディレクトリに保存されます。ファイル名はフローの一意の完全名と一致し、拡張子は `.flow` です。

## バージョン

フローメタデータ API は、API バージョン 24.0 以降で使用できます。

---

## Flow (メタデータ型)

このメタデータ型はフローの有効な定義を表します。Metadata メタデータ型を拡張し、その fullName 項目を継承します。

| 項目名 | 項目の型 | 説明 |
| :--- | :--- | :--- |
| actionCalls | FlowActionCall[] | アクションへのコールを定義するノードの配列。この項目は、API バージョン 31.0 以降で使用できます。 |
| apexPluginCalls | FlowApexPluginCall[] | Apex プラグインへのコールを定義するノードの配列。 |
| apiVersion | number | フローの実行動作を定義する API バージョン。この項目は、API バージョン 50.0 以降で利用できます。<br>※API バージョン 50.0 より前に作成されたフローは、[設定] の [フロー] リストビューで API バージョンが 0 と表示されます。正しい API バージョン番号を表示するには、別のフローを作成し、フローを実行する API バージョンを 49.0 以降に設定します。 |
| assignments | FlowAssignment[] | 割り当てノードの配列。 |
| choices | FlowChoice[] | 静的選択オプションの配列。 |
| collectionProcessors | FlowCollectionProcessor[] | コレクションを処理するノードの配列。この項目は、API バージョン 50.0 以降で利用できます。 |
| constants | FlowConstant[] | 定数の配列。 |
| decisions | FlowDecision[] | 決定ノードの配列。 |
| description | string | フローの説明。 |
| dynamicChoiceSets | FlowDynamicChoiceSet[] | データベースルックアップに基づく選択オプションのセットを構成する配列。 |
| environments | FlowEnvironment (string 型の列挙) | フローを実行できる環境。この項目は、API バージョン 55.0 以降で使用できます。<br>有効な値：<br>・`Default` — フローは、オフラインで実行するか、または Visualforce コンポーネント、Lightning ページ、フローアクション、カスタム Aura コンポーネントから実行できます。<br>・`Slack` — フローは Slack およびデフォルトの環境で実行できます。フローを保存するときに、Slack フロー環境を指定します。 |
| formulas | FlowFormula[] | 数式の配列。 |
| fullName | string | **必須。** Metadata コンポーネントから継承されます。メタデータ API 内のファイルの名前。アンダースコアと英数字のみで構成されるフローの一意の名前。<br>組織全体で一意であること、最初は文字であること、空白は使用しない、最後にアンダースコアを使用しない、2 つ続けてアンダースコアを使用しないという制約があります。<br>バージョンをリリースまたは取得するには、バージョン番号を指定します（例: `sampleFlow-3`）。バージョン番号を指定しない場合、フローは最新バージョンになります。<br>※API バージョン 44 以降では、この項目にバージョン番号が含まれなくなりました。 |
| interviewLabel | string | インタビューの表示ラベル。ユーザーとシステム管理者が同じフローからのインタビューを区別するのに役立ちます。 |
| isAdditionalPermissionRequiredToRun | boolean | デフォルト動作を上書きし、有効化されたプロファイルまたは権限セットにアクセスを制限するか (true)、否か (false) を示します。デフォルト値は false です。この項目は、API バージョン 47.0 以降で利用できます。 |
| isTemplate | boolean | プロセスまたはフローがテンプレートであるかどうかを示します。管理パッケージからインストールされた場合、IP保護により参照やコピーが制限されますが、テンプレートの場合はカスタマイズ可能です。デフォルト: false。API バージョン 45.0 以降。 |
| label | string | **必須。** フローの表示ラベル。 |
| loops | FlowLoop[] | コレクションを反復処理するためのノードの配列。この項目は、API バージョン 30.0 以降で使用できます。 |
| migratedFromWorkflowRuleName | string | フローの移行元であるワークフロールールの名前。この項目は、API バージョン 54.0 以降で利用できます。 |
| orchestratedStages | FlowOrchestratedStage[] | オーケストレーションのフェーズノードの配列。この項目は、API バージョン 53.0 以降で利用できます。 |
| processMetadataValues | FlowMetadataValue[] | フローのメタデータ値。この項目は、API バージョン 31.0 以降で使用できます。 |
| processType | FlowProcessType (string 型の列挙) | フローの種別。フローの有効なバージョンによって決まります。<br>※有効な値のリストは後述。 |
| recordCreates | FlowRecordCreate[] | データベース内のレコードを作成するためのノードの配列。 |
| recordDeletes | FlowRecordDelete[] | データベース内のレコードを削除するためのノードの配列。 |
| recordLookups | FlowRecordLookup[] | データベース内のレコードを検索するためのノードの配列。 |
| recordRollbacks | FlowRecordRollback[] | 画面フロー内のトランザクションをロールバックするためのノードの配列。API バージョン 52.0 以降。 |
| recordUpdates | FlowRecordUpdate[] | データベース内のレコードを更新するためのノードの配列。 |
| runInMode | FlowRunInMode (string 型の列挙) | フローが実行されるコンテキスト。API バージョン 48.0 以降。<br>・`DefaultMode`<br>・`SystemModeWithSharing`<br>・`SystemModeWithoutSharing` (API v49.0以降) |
| screens | FlowScreen[] | 画面ノードの配列。 |
| segment | string | 将来の使用のために予約されています。 |
| stages | FlowStage[] | フロー全体で使用できるフェーズリソースの配列。API バージョン 42.0 以降。 |
| start | FlowStart | フローを開始する方法やタイミングを指定するフローの開始要素。API バージョン 47.0 以降。 |
| startElementReference | string | フローの開始点となるノードまたは要素を指定します。Winter '20 以降の Flow Builder で作成されたフローでは使用されません（代わりに `start` 項目を使用）。 |
| status | FlowVersionStatus (string 型の列挙) | フローの有効化状況。<br>・`Active`<br>・`Draft` (UIでは[無効])<br>・`Obsolete` (UIでは[無効])<br>・`InvalidDraft` (UIでは[ドラフト]) |
| steps | FlowStep[] | ステップノードの配列。 |
| subflows | FlowSubflow[] | サブフローの配列。API バージョン 25.0 以降。 |
| textTemplates | FlowTextTemplate[] | テキストテンプレートの配列。 |
| timeZoneSidKey | string | フローを実行するタイムゾーンを定義する ID。API バージョン 56.0 以降。 |
| triggerOrder | int | レコードトリガーフローの実行順序 (1 ～ 2000)。API バージョン 54.0 以降。 |
| variables | FlowVariable[] | 変数定義の配列。 |
| waits | FlowWait[] | 待機ノードの配列。API バージョン 32.0 以降。 |

### processType の有効な値

* `ActionCadence` (API 56.0+)
* `ActionCadenceStepFlow` (API 56.0+)
* `Appointments` (Lightning Scheduler, API 44.0+)
* `AutoLaunchedFlow` (ユーザー操作を必要としない)
* `CheckoutFlow` (B2B Commerce, API 48.0+)
* `ContactRequestFlow` (API 45.0+)
* `CustomerLifecycle` (Salesforce Surveys, API 49.0+)
* `CustomEvent` (プラットフォームイベント受信, API 41.0+)
* `EvaluationFlow` (オーケストレーション評価, API 54.0+)
* `FieldServiceMobile` (API 39.0+)
* `FieldServiceWeb` (Field Service 組み込みフロー, API 41.0+)
* `Flow` (画面フロー。ユーザー操作を必要とする)
* `FSCLending` (Financial Services Cloud, API 46.0+)
* `IndicatorResultFlow` (API 60.0+)
* `IndividualObjectLinkingFlow` (API 58.0+)
* `InvocableProcess` (API 38.0+)
* `Journey` (Marketing Cloud, API 57.0+)
* `LoginFlow` (API 51.0+)
* `LoyaltyManagementFlow` (API 54.0+)
* `Orchestrator` (API 53.0+)
* `RecommendationStrategy` (API 54.0+)
* `RoutingFlow` (API 52.0+)
* `Survey` (API 42.0+)
* `SurveyEnrich` (API 49.0+)
* `Workflow` (レコード変更プロセス)
* その他、将来の使用または内部使用のために予約されている値（`ActionCadenceFlow`, `ActionPlan`など）。

---

## FlowActionCall

フローからアクションへのコールを定義します。FlowNode を拡張します。API バージョン 31.0 以降。

| 項目名 | 項目の型 | 説明 |
| :--- | :--- | :--- |
| actionName | string | **必須。** アクションの名前。同じ `actionType` のアクション間で一意である必要があります。 |
| actionType | InvocableActionType (string 型の列挙) | **必須。** アクションの種別（例: `apex`, `chatterPost`, `emailSimple`, `submit`, `slackPostMessage` など多数）。 |
| connector | FlowConnector | このアクションコールの後に実行するノードを指定します。 |
| dataTypeMappings | FlowDataTypeMapping[] | 汎用 sObject データ型を持つ入力値と出力値のデータ型を対応付ける配列。API バージョン 48.0 以降。 |
| faultConnector | FlowConnector | アクションコールの結果がエラーの場合に実行するノードを指定します。 |
| flowTransactionModel | FlowTransactionModel (string 型の列挙) | **必須。** トランザクションモデルを指定します（`Automatic`, `CurrentTransaction`, `NewTransaction`）。API バージョン 51.0 以降。 |
| inputParameters | FlowActionCallInputParameter[] | フローからアクションへの入力パラメーターの配列。 |
| nameSegment | string | バージョン管理されたアクションの名前を指定します。API バージョン 58.0 以降。 |
| outputParameters | FlowActionCallOutputParameter[] | アクションからフローへの出力パラメーターの配列。 |
| storeOutputAutomatically | boolean | アクションの出力パラメーターが変数を作成せずに自動的にフローで使用可能になるかどうかを示します。デフォルト: false。API バージョン 48.0 以降。 |
| versionSegment | int | バージョン管理されたアクションの高さを指定します。デフォルト: 1。API バージョン 58.0 以降。 |

---

## FlowAssignment

フロー内の変数の値を動的に変更できる割り当てノードを定義します。FlowNode を拡張します。

| 項目名 | 項目の型 | 説明 |
| :--- | :--- | :--- |
| assignmentItems | FlowAssignmentItem[] | 割り当て操作の配列。 |
| connector | FlowConnector | この割り当てノードの後に実行するノードを指定します。 |

### FlowAssignmentItem

| 項目名 | 項目の型 | 説明 |
| :--- | :--- | :--- |
| assignToReference | string | **必須。** 指定した演算子を適用する変数への参照。 |
| operator | FlowAssignmentOperator (string 型の列挙) | **必須。** 適用する操作（`Add`, `Subtract`, `Assign`, `AssignCount`, `RemoveAll` など）。 |
| value | FlowElementReferenceOrValue | 適用する値を定義します。 |

---

## FlowChoice & FlowDynamicChoiceSet

### FlowChoice
スタンドアロンの選択オプション。

| 項目名 | 項目の型 | 説明 |
| :--- | :--- | :--- |
| choiceText | string | **必須。** 画面に表示する選択肢の表示ラベル。 |
| dataType | FlowDataType | **必須。** `Currency`, `Date`, `Number`, `String`, `Boolean`。 |
| userInput | FlowChoiceUserInput | 選択肢が選択されたときに選択肢でユーザー入力を許可できるようにします。 |
| value | FlowElementReferenceOrValue | フロー実行時に使用される実際の値。 |

### FlowDynamicChoiceSet
オブジェクトからデータまたはメタデータを検索して動的に選択肢のセットを生成します。

| 項目名 | 項目の型 | 説明 |
| :--- | :--- | :--- |
| collectionReference | string | 選択肢の生成に使用するコレクション (API 54.0+)。 |
| dataType | FlowDataType | **必須。** `Boolean`, `Currency`, `Date`, `Multipicklist`, `Number`, `Picklist`, `Record`, `String`。 |
| displayField | string | レコード選択肢で必須。表示ラベルとして使用する項目名。 |
| filters | FlowRecordFilter[] | レコード選択肢で適用する検索条件の配列。 |
| object | string | レコード選択肢で必須。対象オブジェクト名。 |
| outputAssignments | FlowOutputFieldAssignment[] | 選択したレコードの値をフロー変数に割り当てる配列。 |
| picklistField | string | 選択リスト選択肢で必須。項目名。 |
| picklistObject | string | 選択リスト選択肢で必須。オブジェクト名。 |
| valueField | string | 選択肢の保存値（displayFieldと異なる場合）。 |

---

## FlowDecision (決定)

一連のルールを評価し、分岐を行うノード。

| 項目名 | 項目の型 | 説明 |
| :--- | :--- | :--- |
| defaultConnector | FlowConnector | true と評価されたルールがない場合に実行するノード。 |
| defaultConnectorLabel | string | デフォルトコネクタの表示ラベル。 |
| rules | FlowRule[] | 決定用のルールの配列。リストされた順序で評価されます。 |

### FlowRule

| 項目名 | 項目の型 | 説明 |
| :--- | :--- | :--- |
| conditionLogic | string | `and`, `or`, またはカスタムロジック。 |
| conditions | FlowCondition[] | ルールの条件の配列。 |
| connector | FlowConnector | ルールが true の場合に実行するノード。 |
| label | string | **必須。** コネクタの表示ラベル。 |

---

## FlowLoop (ループ)

コレクションを反復処理します。API バージョン 30.0 以降。

| 項目名 | 項目の型 | 説明 |
| :--- | :--- | :--- |
| assignNextValueToReference | string | 現在の値に割り当てられる変数。 |
| collectionReference | string | **必須。** ループ対象のコレクション。 |
| iterationOrder | string | `Asc` (最初から最後へ) または `Desc` (最後から最初へ)。 |
| nextValueConnector | FlowConnector | 次の値を処理するために移動する場所。 |
| noMoreValuesConnector | FlowConnector | ループ終了時に移動する場所。 |

---

## FlowRecord (Create / Delete / Lookup / Update / Rollback)

データベース操作を行うノード群です。

* **FlowRecordCreate**: レコード作成。`inputAssignments` (項目への値割り当て) や `object` を指定。
* **FlowRecordDelete**: レコード削除。`filters` や `inputReference` を使用。
* **FlowRecordLookup**: レコード取得 (Get)。`filters`, `sortField`, `sortOrder`, `limit`, `outputAssignments` などを指定。
* **FlowRecordUpdate**: レコード更新。`filters`, `inputAssignments`, `inputReference` を使用。
* **FlowRecordRollback**: トランザクションのロールバック (画面フローのみ)。

---

## FlowScreen (画面)

ユーザーから情報を収集・表示します。

| 項目名 | 項目の型 | 説明 |
| :--- | :--- | :--- |
| allowBack / allowFinish / allowPause | boolean | 各ボタンの表示/非表示制御。 |
| fields | FlowScreenField[] | 画面に表示する項目の配列。 |
| showFooter / showHeader | boolean | フッター/ヘッダーの表示制御 (Lightning ランタイム)。 |

### FlowScreenField (画面コンポーネント)

| 項目名 | 項目の型 | 説明 |
| :--- | :--- | :--- |
| fieldType | FlowScreenFieldType | **必須。** `DisplayText`, `InputField`, `RadioButtons`, `ComponentInstance` (LWC/Aura) など。 |
| fieldText | string | 表示ラベル。 |
| isRequired | boolean | 必須入力かどうか。 |
| validationRule | FlowInputValidationRule | 入力検証ルール。 |
| visibilityRule | FlowVisibilityRule | 表示/非表示ルール。 |

---

## FlowStart (開始要素)

フローの開始方法、トリガー、スケジュールを定義します。API バージョン 47.0 以降。

| 項目名 | 項目の型 | 説明 |
| :--- | :--- | :--- |
| connector | FlowConnector | 最初に実行する要素。 |
| object | string | トリガー対象のオブジェクト。 |
| recordTriggerType | RecordTriggerType | `Create`, `Update`, `CreateAndUpdate`, `Delete`, `None`。 |
| schedule | FlowSchedule | スケジュール実行のタイミングと頻度。 |
| triggerType | FlowTriggerType | `RecordAfterSave`, `RecordBeforeSave`, `Scheduled`, `PlatformEvent`, `DataCloudDataChange` など。 |

---

## その他の重要な要素

* **FlowSubflow**: 別のフロー（サブフロー）を呼び出します。入力/出力の割り当てが可能です。
* **FlowVariable**: フロー内で使用する変数 (`Boolean`, `Currency`, `String`, `SObject` など)。`isInput` / `isOutput` で外部とのやり取りを制御します。
* **FlowFormula**: 数式リソース。
* **FlowConstant**: 定数リソース。
* **FlowTextTemplate**: フォーマットされたテキストテンプレート。

---

## XML 定義のサンプル

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Flow xmlns="[http://soap.sforce.com/2006/04/metadata](http://soap.sforce.com/2006/04/metadata)">
    <actionCalls>
        <name>Get_Info</name>
        <label>Get Info</label>
        <locationX>380</locationX>
        <locationY>242</locationY>
        <actionName>GetFirstFromCollection</actionName>
        <actionType>apex</actionType>
        <connector>
            <targetReference>Update_If_Existing</targetReference>
        </connector>
        <dataTypeMappings>
            <typeName>T__inputCollection</typeName>
            <typeValue>Account</typeValue>
        </dataTypeMappings>
        <dataTypeMappings>
            <typeName>U__outputMember</typeName>
            <typeValue>Account</typeValue>
        </dataTypeMappings>
        <flowTransactionModel>CurrentTransaction</flowTransactionModel>
        <inputParameters>
            <name>inputCollection</name>
            <value>
                <elementReference>accts.accounts</elementReference>
            </value>
        </inputParameters>
        <nameSegment>GetFirstFromCollection</nameSegment>
        <storeOutputAutomatically>true</storeOutputAutomatically>
        <versionSegment>1</versionSegment>
    </actionCalls>
    <actionCalls>
        <name>Post_to_Contact_s_Feed</name>
        <label>Post to Contact&apos;s Feed</label>
        <locationX>50</locationX>
        <locationY>890</locationY>
        <actionName>chatterPost</actionName>
        <actionType>chatterPost</actionType>
        <connector>
            <targetReference>Confirm</targetReference>
        </connector>
        <flowTransactionModel>CurrentTransaction</flowTransactionModel>
        <inputParameters>
            <name>text</name>
            <value>
                <elementReference>chatterMessage</elementReference>
            </value>
        </inputParameters>
        <inputParameters>
            <name>subjectNameOrId</name>
            <value>
                <elementReference>contact.Id</elementReference>
            </value>
        </inputParameters>
        <nameSegment>chatterPost</nameSegment>
        <storeOutputAutomatically>true</storeOutputAutomatically>
        <versionSegment>1</versionSegment>
    </actionCalls>
    <apiVersion>49.0</apiVersion>
    <assignments>
        <name>Set_Contact_ID</name>
        <label>Set Contact ID</label>
        <locationX>50</locationX>
        <locationY>674</locationY>
        <assignmentItems>
            <assignToReference>contact.Id</assignToReference>
            <operator>Assign</operator>
            <value>
                <elementReference>existingId</elementReference>
            </value>
        </assignmentItems>
        <connector>
            <targetReference>Update_Contact</targetReference>
        </connector>
    </assignments>
    <decisions>
        <name>Update_If_Existing</name>
        <label>Update If Existing?</label>
        <locationX>380</locationX>
        <locationY>350</locationY>
        <defaultConnector>
            <isGoTo>true</isGoTo>
            <targetReference>Create_Contact</targetReference>
        </defaultConnector>
        <defaultConnectorLabel>No</defaultConnectorLabel>
        <rules>
            <name>Update_Yes</name>
            <conditionLogic>and</conditionLogic>
            <conditions>
                <leftValueReference>updateExisting</leftValueReference>
                <operator>EqualTo</operator>
                <rightValue>
                    <booleanValue>true</booleanValue>
                </rightValue>
            </conditions>
            <connector>
                <targetReference>Find_a_Match</targetReference>
            </connector>
            <label>Yes</label>
        </rules>
    </decisions>
    <decisions>
        <name>Update_or_Create</name>
        <label>Update or Create?</label>
        <locationX>182</locationX>
        <locationY>566</locationY>
        <defaultConnector>
            <targetReference>Create_Contact</targetReference>
        </defaultConnector>
        <defaultConnectorLabel>Create New</defaultConnectorLabel>
        <rules>
            <name>Update_Existing</name>
            <conditionLogic>and</conditionLogic>
            <conditions>
                <leftValueReference>existingId</leftValueReference>
                <operator>IsNull</operator>
                <rightValue>
                    <booleanValue>false</booleanValue>
                </rightValue>
            </conditions>
            <connector>
                <targetReference>Set_Contact_ID</targetReference>
            </connector>
            <label>Update Existing</label>
        </rules>
    </decisions>
    <dynamicChoiceSets>
        <name>accounts</name>
        <dataType>String</dataType>
        <displayField>Name</displayField>
        <object>Account</object>
        <outputAssignments>
            <assignToReference>contact.AccountId</assignToReference>
            <field>Id</field>
        </outputAssignments>
        <valueField>Id</valueField>
    </dynamicChoiceSets>
    <environments>Default</environments>
    <formulas>
        <name>created_or_updated</name>
        <dataType>String</dataType>
        <expression>IF({!Create_Contact}, &quot;created&quot;, &quot;updated&quot;)</expression>
    </formulas>
    <interviewLabel>New Contact {!$Flow.CurrentDateTime}</interviewLabel>
    <isAdditionalPermissionRequiredToRun>true</isAdditionalPermissionRequiredToRun>
    <isTemplate>true</isTemplate>
    <label>New Contact</label>
    <processMetadataValues>
        <name>BuilderType</name>
        <value>
            <stringValue>LightningFlowBuilder</stringValue>
        </value>
    </processMetadataValues>
    <processMetadataValues>
        <name>CanvasMode</name>
        <value>
            <stringValue>AUTO_LAYOUT_CANVAS</stringValue>
        </value>
    </processMetadataValues>
    <processMetadataValues>
        <name>OriginBuilderType</name>
        <value>
            <stringValue>LightningFlowBuilder</stringValue>
        </value>
    </processMetadataValues>
    <processType>Flow</processType>
    <recordCreates>
        <name>Create_Contact</name>
        <label>Create Contact</label>
        <locationX>314</locationX>
        <locationY>674</locationY>
        <connector>
            <isGoTo>true</isGoTo>
            <targetReference>Post_to_Contact_s_Feed</targetReference>
        </connector>
        <inputReference>contact</inputReference>
    </recordCreates>
    <recordLookups>
        <name>Find_a_Match</name>
        <label>Find a Match</label>
        <locationX>182</locationX>
        <locationY>458</locationY>
        <assignNullValuesIfNoRecordsFound>true</assignNullValuesIfNoRecordsFound>
        <connector>
            <targetReference>Update_or_Create</targetReference>
        </connector>
        <filterLogic>and</filterLogic>
        <filters>
            <field>FirstName</field>
            <operator>EqualTo</operator>
            <value>
                <elementReference>contact.FirstName</elementReference>
            </value>
        </filters>
        <filters>
            <field>LastName</field>
            <operator>EqualTo</operator>
            <value>
                <elementReference>contact.LastName</elementReference>
            </value>
        </filters>
        <object>Contact</object>
        <outputAssignments>
            <assignToReference>existingId</assignToReference>
            <field>Id</field>
        </outputAssignments>
    </recordLookups>
    <recordUpdates>
        <name>Update_Contact</name>
        <label>Update Contact</label>
        <locationX>50</locationX>        <locationY>782</locationY>
        <connector>
            <targetReference>Post_to_Contact_s_Feed</targetReference>
        </connector>
        <inputReference>contact</inputReference>
    </recordUpdates>
    <screens>
        <name>Confirm</name>
        <label>Confirm</label>
        <locationX>50</locationX>
        <locationY>998</locationY>
        <allowBack>false</allowBack>
        <allowFinish>true</allowFinish>
        <allowPause>true</allowPause>
        <fields>
            <name>confirmation_message</name>
            <fieldText>Thanks! &lt;a href=&quot;/{!contact.Id}&quot;&gt;The contact&lt;/a&gt; was {!created_or_updated}.</fieldText>
            <fieldType>DisplayText</fieldType>
        </fields>
        <showFooter>true</showFooter>
        <showHeader>true</showHeader>
    </screens>
    <screens>
        <name>Contact_Info</name>
        <label>Contact Info</label>
        <locationX>380</locationX>
        <locationY>134</locationY>
        <allowBack>true</allowBack>
        <allowFinish>true</allowFinish>
        <allowPause>true</allowPause>
        <connector>
            <targetReference>Get_Info</targetReference>
        </connector>
        <fields>
            <name>contactName</name>
            <extensionName>flowruntime:name</extensionName>
            <fieldType>ComponentInstance</fieldType>
            <inputsOnNextNavToAssocScrn>UseStoredValues</inputsOnNextNavToAssocScrn>
            <isRequired>true</isRequired>
            <outputParameters>
                <assignToReference>contact.FirstName</assignToReference>
                <name>firstName</name>
            </outputParameters>
            <outputParameters>
                <assignToReference>contact.LastName</assignToReference>
                <name>lastName</name>
            </outputParameters>
        </fields>
        <fields>
            <name>Account</name>
            <choiceReferences>accounts</choiceReferences>
            <dataType>String</dataType>
            <fieldText>Account</fieldText>
            <fieldType>DropdownBox</fieldType>
            <isRequired>true</isRequired>
        </fields>
        <fields>
            <name>update_toggle</name>
            <extensionName>flowruntime:toggle</extensionName>
            <fieldType>ComponentInstance</fieldType>
            <inputParameters>
                <name>label</name>
                <value>
                    <stringValue>If this contact already exists, update the existing record.</stringValue>
                </value>
            </inputParameters>
            <inputParameters>
                <name>messageToggleActive</name>
                <value>
                    <stringValue>Update existing</stringValue>
                </value>
            </inputParameters>
            <inputParameters>
                <name>messageToggleInactive</name>
                <value>
                    <stringValue>Create other contact</stringValue>
                </value>
            </inputParameters>
            <inputsOnNextNavToAssocScrn>UseStoredValues</inputsOnNextNavToAssocScrn>
            <isRequired>true</isRequired>
            <outputParameters>
                <assignToReference>updateExisting</assignToReference>
                <name>value</name>
            </outputParameters>
        </fields>
        <showFooter>true</showFooter>
        <showHeader>true</showHeader>
    </screens>
    <start>
        <locationX>254</locationX>
        <locationY>0</locationY>
        <connector>
            <targetReference>Contact_Info</targetReference>
        </connector>
    </start>
    <status>Draft</status>
    <textTemplates>
        <name>chatterMessage</name>
        <isViewedAsPlainText>false</isViewedAsPlainText>
        <text>The contact was {!created_or_updated}.</text>
    </textTemplates>
    <variables>
        <name>accts</name>
        <apexClass>ComplexObjectExample</apexClass>
        <dataType>Apex</dataType>
        <isCollection>false</isCollection>
        <isInput>false</isInput>
        <isOutput>false</isOutput>
    </variables>
    <variables>
        <name>contact</name>
        <dataType>SObject</dataType>
        <isCollection>false</isCollection>
        <isInput>false</isInput>
        <isOutput>false</isOutput>
        <objectType>Contact</objectType>
    </variables>
    <variables>
        <name>existingId</name>
        <dataType>String</dataType>
        <isCollection>false</isCollection>
        <isInput>false</isInput>
        <isOutput>false</isOutput>
    </variables>
    <variables>
        <name>updateExisting</name>
        <dataType>Boolean</dataType>
        <isCollection>false</isCollection>
        <isInput>false</isInput>
        <isOutput>false</isOutput>
    </variables>
</Flow>