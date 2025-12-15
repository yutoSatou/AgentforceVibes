# Salesforce Flow Implementation Specifications

このドキュメントは、提供されたXMLメタデータに基づき、Salesforceフローの実装要件を定義したものである。

## ⚠️ AIエージェントへの指示 (Instructions for AI Agent)
この仕様書に基づいてFlowのメタデータXMLを作成する際は、以下のルールを厳守すること：
1.  **`<label>`タグ**: 各フロー定義にある **`Flow Label`** の値を必ず `<label>` タグとして出力する。これが欠落するとデプロイエラーになる。
2.  **`<status>`タグ**: 特段の指定がない限り、`<status>Active</status>` を含める。
3.  **`<processType>`タグ**: フローの種類（画面フロー、自動起動フロー等）に合わせて適切な値を設定する。

---

## 1. レコードトリガーフロー (Record-Triggered Flows)

### 1.1. 商談クローズ時取引先を更新
* **Flow Label:** 商談クローズ時取引先を更新
* **API Name (suggested):** `Update_Opportunity_UpdateAccountInformation`
* **概要:** 商談が「Closed Won」になった際、関連する取引先の契約ステータスを更新する。
* **Trigger Object:** Opportunity
* **Trigger Type:** Record After Save (Create & Update)
* **Entry Conditions:**
    * `StageName` Equals `Closed Won`
    * *Does Require Record Changed To Meet Criteria:* True
* **Elements:**
    1.  **Update Records (取引先を更新)**
        * **Target:** `$Record.Account`
        * **Field:** `ContractStatus__c` <= "契約中"

### 1.2. 完了予定日を変更したらスリップ回数に1追加
* **Flow Label:** 完了予定日を変更したらスリップ回数に1追加
* **API Name (suggested):** `AddSlipNum`
* **概要:** 商談の完了予定日が変更された場合、スリップ回数項目をインクリメントする。
* **Trigger Object:** Opportunity
* **Trigger Type:** Record After Save (Update Only)
* **Entry Conditions:**
    * `CloseDate` IsChanged `true`
* **Formulas:**
    * `Add1` (Number, Scale 0): `PRIORVALUE({!$Record.SlipNum__c}) + 1`
* **Elements:**
    1.  **Update Records (スリップ回数に追加)**
        * **Target:** `$Record`
        * **Field:** `SlipNum__c` <= `{!Add1}`

### 1.3. 商談名を登録すると後ろに取引先名が自動で反映される
* **Flow Label:** 商談名を登録すると後ろに取引先名が自動で反映される
* **API Name (suggested):** `UpdateOppName`
* **概要:** 商談作成時、商談名の末尾に取引先名を自動付与する。
* **Trigger Object:** Opportunity
* **Trigger Type:** Record After Save (Create Only)
* **Formulas:**
    * `cal_name` (String): `{!$Record.Name} & '-' & {!$Record.Account.Name}`
* **Elements:**
    1.  **Update Records (商談を更新)**
        * **Target:** `$Record`
        * **Field:** `Name` <= `{!cal_name}`

### 1.4. ケースがクレームフラグ「true」で作成されたらChatter通知
* **Flow Label:** ケースがクレームフラグ「true」で作成されたらChatter通知
* **API Name (suggested):** `PostChatterFlow`
* **概要:** クレームフラグが立っているケースが作成された際、取引先所有者宛にChatter通知を行う。
* **Trigger Object:** Case
* **Trigger Type:** Record After Save (Create Only)
* **Entry Conditions:**
    * `ClaimFlg__c` Equals `true`
* **Text Templates:**
    * `ChatterText`:
        ```text
        @[{!$Record.Account.OwnerId}]
        クレームフラグ「true」でケースが作成されました。
        至急確認ください。
        ```
* **Elements:**
    1.  **Action (Chatterに投稿)**
        * **Action Type:** `chatterPost`
        * **Message:** `{!ChatterText}`
        * **Target Name or ID:** `{!$Record.Id}`

### 1.5. 活動件数を取引先に積み上げ集計
* **Flow Label:** 活動件数を取引先に積み上げ集計
* **API Name (suggested):** `SumNumberOfAcitivities`
* **概要:** ToDo（タスク）が作成・更新された際、関連する取引先に紐づく活動総数をカウントし、取引先項目を更新する。
* **Trigger Object:** Task
* **Trigger Type:** Record After Save (Create & Update)
* **Entry Conditions:**
    * `AccountId` Not Equal To `null` (Empty String)
* **Variables:**
    * `ActivityNum` (Number, Scale 0, Default 0)
* **Elements:**
    1.  **Get Records (同じ取引先に紐づく活動を取得する)**
        * **Object:** Task
        * **Filter:** `AccountId` Equals `{!$Record.AccountId}`
        * **Records:** All records
    2.  **Assignment (活動レコードを割り当てる)**
        * `ActivityNum` Equals Count `{!GetTodoRecord}`
    3.  **Update Records (取引先の活動件数を変更)**
        * **Object:** Account
        * **Filter:** `Id` Equals `{!$Record.AccountId}`
        * **Field:** `AcitivityNumber__c` <= `{!ActivityNum}`

---

## 2. スケジュールトリガーフロー (Schedule-Triggered Flows)

### 2.1. 完了予定日の１週間前に所有者にメール送信
* **Flow Label:** 完了予定日の１週間前に所有者にメール送信
* **API Name (suggested):** `ClloseDateEmail`
* **概要:** 毎日9:00に起動し、完了予定日がちょうど1週間後の商談がある場合、所有者にメールを送信する。
* **Trigger Object:** Opportunity
* **Frequency:** Daily (Start: 2025-12-16 09:00:00 Z)
* **Formulas:**
    * `one_week_later` (Date): `Today() + 7`
* **Text Templates:**
    * `Title`: `商談の完了予定日が1週間後になっています！`
    * `Body`:
        ```text
        {!$Record.Owner.LastName}さん
        表題の通り、{!$Record.Name}の完了予定日が１週間後となっています。
        ご確認ください。
        金額：{!$Record.Amount}
        完了予定日：{!$Record.CloseDate}
        URL：https://[MyDomain][.lightning.force.com/lightnint/r/Opportunity/](https://.lightning.force.com/lightnint/r/Opportunity/){!$Record.Id}/view
        ```
* **Elements:**
    1.  **Decision (完了予定日が１週間後だったら)**
        * Condition: `{!$Record.CloseDate}` Equals `{!one_week_later}`
    2.  **Action (メール送信)**
        * **Action Type:** `emailSimple`
        * **Recipient:** `{!$Record.Owner.Email}`
        * **Subject:** `{!Title}`
        * **Body:** `{!Body}`

### 2.2. 毎月月初にHotリードに対してToDoを作成
* **Flow Label:** 毎月月初にHotリードに対してToDoを作成
* **API Name (suggested):** `CaateToDo`
* **概要:** 毎日9:00に「Hot」なリードに対して起動するが、月初（1日）の場合のみToDoを作成する。
* **Trigger Object:** Lead
* **Frequency:** Daily (Start: 2025-12-16 09:00:00 Z)
* **Entry Conditions:**
    * `Rating` Equals `Hot`
* **Formulas:**
    * `BeginOfMonth` (Boolean): `DAY(TODAY())=1`
* **Elements:**
    1.  **Decision (月初判定)**
        * Condition: `{!BeginOfMonth}` Equals `true`
    2.  **Create Records (ToDo作成)**
        * **Object:** Task
        * **Fields:**
            * `OwnerId`: `{!$Record.CreatedById}`
            * `Priority`: `High`
            * `Subject`: `Call`
            * `WhoId`: (Implicitly associated via Lead context)

---

## 3. 画面フロー (Screen Flows)

### 3.1. 項目をコピーして同じレコードの別項目に張り付ける
* **Flow Label:** 項目をコピーして同じレコードの別項目に張り付ける
* **API Name (suggested):** `CopyTheItemAndPasteItntoAnotherFieldWithInTheSameRecord`
* **概要:** 指定された商談IDに基づき、金額（Amount）を取得して別項目（CopiedAmount__c）にコピーする。
* **Input Variables:** `recordId` (String)
* **Variables:** `template` (Currency)
* **Elements:**
    1.  **Get Records (商談を取得)**
        * **Object:** Opportunity
        * **Filter:** `Id` Equals `{!recordId}`
    2.  **Assignment (テンプレに割り当て)**
        * `template` Assign `{!GetOppGetOpp.Amount}`
    3.  **Update Records (レコードを更新)**
        * **Object:** Opportunity
        * **Filter:** `Id` Equals `{!recordId}`
        * **Field:** `CopiedAmount__c` <= `{!template}`

### 3.2. 取引先と商談を一度に作成する
* **Flow Label:** 取引先と商談を一度に作成する
* **API Name (suggested):** `CreateAccountOpp`
* **概要:** 画面入力に基づき、取引先とそれに紐づく商談を同時作成する。
* **Elements:**
    1.  **Screen (取引先と商談の登録)**
        * **Inputs:**
            * `AccountName` (Text)
            * `OpportunityName` (Text)
            * `EndDate` (Date)
    2.  **Create Records (取引先の作成)**
        * **Object:** Account
        * **Field:** `Name` <= `{!AccountName}`
        * **Store Output:** `CreateAccount.Id`
    3.  **Create Records (商談を作成)**
        * **Object:** Opportunity
        * **Fields:**
            * `AccountId`: `{!CreateAccount.Id}`
            * `CloseDate`: `{!EndDate}`
            * `Name`: `{!OpportunityName}`
            * `StageName`: `Prospecting`

### 3.3. 商談金額の更新
* **Flow Label:** 商談金額の更新
* **API Name (suggested):** `UpdateAmount`
* **概要:** 商談金額を入力・更新する画面フロー。1,000万円以上の場合は警告画面を表示する。
* **Input Variables:** `recordId` (String)
* **Elements:**
    1.  **Screen (商談金額の入力)**
        * **Inputs:** `ScreenAmount` (Currency)
    2.  **Decision (商談金額の異常値確認)**
        * **Rule (more1000):** `{!ScreenAmount}` >= `10,000,000`
        * **Default:** "1000万円未満" -> Updateへ
    3.  **Screen (金額の確認)** - *Displayed if >= 10M*
        * **Display Text:** "商談金額が1,000万円を超えています。間違いであれば[前へ]ボタンで修正を、間違いでなければそのまま進んでください。" (Red text)
    4.  **Update Records (商談金額の更新)**
        * **Object:** Opportunity
        * **Filter:** `Id` Equals `{!recordId}`
        * **Field:** `Amount` <= `{!ScreenAmount}`