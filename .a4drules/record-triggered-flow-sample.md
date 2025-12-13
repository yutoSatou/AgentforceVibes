# サンプル
下記は商談のフェーズが「Closed Won」になった際に関連する取引先の契約状況という選択リストを「契約中」に更新するレコードトリガーフローです(保存後起動のフロー)。

## 🤖 Salesforce Flowの定義: Opportunity Stage Won: Update Account Contract Status

### 📝 フローの基本情報

| XML要素 | Markdown項目 | 値 |
| :--- | :--- | :--- |
| `apiVersion` | API バージョン | `65.0` |
| `areMetricsLoggedToDataCloud` | データクラウドにメトリクスを記録 | `false` |
| `environments` | 環境 | `Default` |
| `interviewLabel` | インタビュー表示ラベル | `Opportunity Stage Won: Update Account Contract Status {!$Flow.CurrentDateTime}` |
| `label` | フロー表示ラベル | `Opportunity Stage Won: Update Account Contract Status` |
| `processType` | プロセス種別 | `AutoLaunchedFlow` |
| `status` | ステータス | `Active` |

### 🛠️ メタデータ (Metadata Values)

| XML要素名 | Markdown項目名 | 値 |
| :--- | :--- | :--- |
| `BuilderType` | ビルダー種別 | `LightningFlowBuilder` |
| `CanvasMode` | キャンバスモード | `AUTO_LAYOUT_CANVAS` |
| `OriginBuilderType` | 作成元ビルダー種別 | `LightningFlowBuilder` |

---

### ⚡️ 開始 (Start) 要素 - トリガー設定

| XML要素 | Markdown項目 | 値 |
| :--- | :--- | :--- |
| `object` | オブジェクト | `Opportunity` |
| `recordTriggerType` | レコードトリガーの種別 | `CreateAndUpdate` (作成と更新) |
| `triggerType` | トリガーのタイミング | `RecordAfterSave` (レコード保存後) |
| `doesRequireRecordChangedToMeetCriteria` | 条件変更時にのみ実行 | `true` |

#### フィルター (Filters)

| XML要素 (フィールド) | XML要素 (演算子) | XML要素 (値) |
| :--- | :--- | :--- |
| `field` | `operator` | `stringValue` |
| `StageName` | `EqualTo` | `Closed Won` |

---

### 🔄 レコード更新 (RecordUpdates) 要素

| XML要素 | Markdown項目 | 値 |
| :--- | :--- | :--- |
| `name` | API 参照名 | `Update_RelatedAccount` |
| `label` | 表示ラベル | `取引先を更新` |
| `inputReference` | 更新対象レコード | `$Record.Account` |

#### 割り当て (InputAssignments)

| XML要素 (フィールド) | XML要素 (値) |
| :--- | :--- |
| `field` | `stringValue` |
| `ContractStatus__c` | `契約中` |

### 🔗 接続 (Connector)

開始要素 (`start`) から次の要素への接続:

* **`targetReference`**: `Update_RelatedAccount`

## 🤖 Salesforce Flowの定義: Opportunity Stage Won: Update Account Contract Status

### 📝 フローの基本情報

| XML要素 | Markdown項目 | 値 |
| :--- | :--- | :--- |
| `apiVersion` | API バージョン | `65.0` |
| `areMetricsLoggedToDataCloud` | データクラウドにメトリクスを記録 | `false` |
| `environments` | 環境 | `Default` |
| `interviewLabel` | インタビュー表示ラベル | `Opportunity Stage Won: Update Account Contract Status {!$Flow.CurrentDateTime}` |
| `label` | フロー表示ラベル | `Opportunity Stage Won: Update Account Contract Status` |
| `processType` | プロセス種別 | `AutoLaunchedFlow` |
| `status` | ステータス | `Active` |

### 🛠️ メタデータ (Metadata Values)

| XML要素名 | Markdown項目名 | 値 |
| :--- | :--- | :--- |
| `BuilderType` | ビルダー種別 | `LightningFlowBuilder` |
| `CanvasMode` | キャンバスモード | `AUTO_LAYOUT_CANVAS` |
| `OriginBuilderType` | 作成元ビルダー種別 | `LightningFlowBuilder` |

---

### ⚡️ 開始 (Start) 要素 - トリガー設定

| XML要素 | Markdown項目 | 値 |
| :--- | :--- | :--- |
| `object` | オブジェクト | `Opportunity` |
| `recordTriggerType` | レコードトリガーの種別 | `CreateAndUpdate` (作成と更新) |
| `triggerType` | トリガーのタイミング | `RecordAfterSave` (レコード保存後) |
| `doesRequireRecordChangedToMeetCriteria` | 条件変更時にのみ実行 | `true` |

#### フィルター (Filters)

| XML要素 (フィールド) | XML要素 (演算子) | XML要素 (値) |
| :--- | :--- | :--- |
| `field` | `operator` | `stringValue` |
| `StageName` | `EqualTo` | `Closed Won` |

---

### 🔄 レコード更新 (RecordUpdates) 要素

| XML要素 | Markdown項目 | 値 |
| :--- | :--- | :--- |
| `name` | API 参照名 | `Update_RelatedAccount` |
| `label` | 表示ラベル | `取引先を更新` |
| `inputReference` | 更新対象レコード | `$Record.Account` |

#### 割り当て (InputAssignments)

| XML要素 (フィールド) | XML要素 (値) |
| :--- | :--- |
| `field` | `stringValue` |
| `ContractStatus__c` | `契約中` |

### 🔗 接続 (Connector)

開始要素 (`start`) から次の要素への接続:

* **`targetReference`**: `Update_RelatedAccount`