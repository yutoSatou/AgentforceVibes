# フロー1: 完了予定日の１週間前に所有者にメール送信 (ClloseDateEmail)
## 種別
スケジュールトリガーフロー

## 処理概要
毎日決まった時間に起動し、商談の完了予定日がちょうど1週間後のものがあれば、商談所有者に通知メールを送信する。

## 処理詳細
1.  **起動条件 (Start)**
    * **オブジェクト**: 商談 (Opportunity)
    * **スケジュール**: 毎日 9:00
    * **トリガー**: スケジュールされたパスで実行
2.  **数式リソース (Formulas)**
    * `one_week_later`: `Today() + 7` (日付型)
3.  **決定 (Decision): 完了予定日が１週間後だったら**
    * **分岐1 (完了予定日が１週間後)**:
        * 条件: `{!$Record.CloseDate}` が `{!one_week_later}` と等しい
    * **デフォルト**: 何もしない
4.  **アクション (Action): メール送信**
    * **アクション種別**: メール送信 (emailSimple)
    * **宛先**: `{!$Record.Owner.Email}`
    * **件名**: 商談の完了予定日が1週間後になっています！
    * **本文**:
        ```text
        {!$Record.Owner.LastName}さん
        表題の通り、{!$Record.Name}の完了予定日が１週間後となっています。
        ご確認ください。
        金額：{!$Record.Amount}
        完了予定日：{!$Record.CloseDate}
        URL：{Lightning環境のURL}/r/Opportunity/{!$Record.Id}/view
        ```

---

# フロー2: 毎月月初にHotリードに対してToDoを作成 (CaateToDo)
## 種別
スケジュールトリガーフロー

## 処理概要
毎日起動し、当日が「月初（1日）」かつリードの評価が「Hot」である場合、フォローアップ用のToDoを作成する。

## 処理詳細
1.  **起動条件 (Start)**
    * **オブジェクト**: リード (Lead)
    * **条件**: `Rating` (評価) が `Hot` と等しい
    * **スケジュール**: 毎日 9:00
2.  **数式リソース (Formulas)**
    * `BeginOfMonth`: `DAY(TODAY())=1` (Boolean型)
3.  **決定 (Decision): 月初判定**
    * **分岐1 (月初である)**:
        * 条件: `{!BeginOfMonth}` が `true` と等しい
    * **デフォルト**: 終了
4.  **レコード作成 (Create Records): ToDo作成**
    * **オブジェクト**: ToDo (Task)
    * **項目設定**:
        * `OwnerId`: `{!$Record.CreatedById}`
        * `Priority`: High
        * `Subject`: Call

---

# フロー3: 項目をコピーして同じレコードの別項目に張り付ける (CopyTheItem...)
## 種別
自動起動フロー (または画面のないフロー)

## 処理概要
入力として受け取った商談IDをもとにレコードを取得し、その「金額(Amount)」をカスタム項目「CopiedAmount__c」にコピーして更新する。

## 処理詳細
1.  **変数 (Variables)**
    * `recordId`: テキスト型 (入力用)
    * `template`: 通貨型
2.  **レコード取得 (Get Records): 商談を取得**
    * **オブジェクト**: 商談 (Opportunity)
    * **条件**: `Id` が `{!recordId}` と等しい
    * **保存対象**: 最初のレコードのみ
3.  **割り当て (Assignment): テンプレに割り当て**
    * 変数 `{!template}` に `{!GetOppGetOpp.Amount}` を割り当て
4.  **レコード更新 (Update Records): レコードを更新**
    * **オブジェクト**: 商談 (Opportunity)
    * **条件**: `Id` が `{!recordId}` と等しい
    * **項目設定**:
        * `CopiedAmount__c`: `{!template}`

---

# フロー4: 商談金額の更新 (UpdateAmount)
## 種別
画面フロー

## 処理概要
ユーザーに商談金額を入力させ、更新を行う。入力金額が1,000万円以上の場合は警告画面を挟んでから更新する。

## 処理詳細
1.  **変数 (Variables)**
    * `recordId`: テキスト型 (入力用)
2.  **画面 (Screen): 商談金額の入力**
    * **コンポーネント**: 通貨入力 (`ScreenAmount`) - ラベル: 商談金額
3.  **決定 (Decision): 商談金額の異常値確認**
    * **分岐1 (1000万円以上)**:
        * 条件: `{!ScreenAmount}` >= 10,000,000
    * **デフォルト (1000万円未満)**: 更新へ進む
4.  **画面 (Screen): 金額の確認 (警告)**
    * **表示条件**: 分岐1の場合に表示
    * **表示テキスト**: 「商談金額が1,000万円を超えています。間違いであれば[前へ]ボタンで修正を…」
5.  **レコード更新 (Update Records): 商談金額の更新**
    * **オブジェクト**: 商談 (Opportunity)
    * **条件**: `Id` が `{!recordId}` と等しい
    * **項目設定**:
        * `Amount`: `{!ScreenAmount}`

---

# フロー5: 商談クローズ時取引先を更新 (Update_Opportunity_UpdateAccountInformation)
## 種別
レコードトリガーフロー

## 処理概要
商談が「Closed Won（受注）」に変更、または作成された際、関連する取引先の契約状況を「契約中」に更新する。

## 処理詳細
1.  **起動条件 (Start)**
    * **オブジェクト**: 商談 (Opportunity)
    * **トリガー**: 作成または更新時
    * **条件**: `StageName` が `Closed Won` と等しい
    * **実行タイミング**: レコード保存後
2.  **レコード更新 (Update Records): 取引先を更新**
    * **更新対象**: フローをトリガーした商談に関連する取引先 (`$Record.Account`)
    * **項目設定**:
        * `ContractStatus__c`: 契約中

---

# フロー6: 商談名を登録すると後ろに取引先名が自動で反映される (UpdateOppName)
## 種別
レコードトリガーフロー

## 処理概要
商談が新規作成された際、商談名を「入力された商談名 - 取引先名」の形式に自動更新する。

## 処理詳細
1.  **起動条件 (Start)**
    * **オブジェクト**: 商談 (Opportunity)
    * **トリガー**: 作成時
    * **実行タイミング**: レコード保存後
2.  **数式リソース (Formulas)**
    * `cal_name`: `{!$Record.Name} & '-' & {!$Record.Account.Name}`
3.  **レコード更新 (Update Records): 商談を更新**
    * **更新対象**: フローをトリガーした商談 (`$Record`)
    * **項目設定**:
        * `Name`: `{!cal_name}`

---

# フロー7: 完了予定日を変更したらスリップ回数に1追加 (AddSlipNum)
## 種別
レコードトリガーフロー

## 処理概要
既存の商談の完了予定日（CloseDate）が変更された場合、スリップ回数（SlipNum__c）をカウントアップ（+1）する。

## 処理詳細
1.  **起動条件 (Start)**
    * **オブジェクト**: 商談 (Opportunity)
    * **トリガー**: 更新時
    * **条件**: `CloseDate` が変更されている (`IsChanged` = true)
    * **実行タイミング**: レコード保存後
2.  **数式リソース (Formulas)**
    * `Add1`: `PRIORVALUE({!$Record.SlipNum__c}) + 1` (数値型)
3.  **レコード更新 (Update Records): スリップ回数に追加**
    * **更新対象**: フローをトリガーした商談 (`$Record`)
    * **項目設定**:
        * `SlipNum__c`: `{!Add1}`

---

# フロー8: 取引先と商談を一度に作成する (CreateAccountOpp)
## 種別
画面フロー

## 処理概要
入力画面で取引先名、商談名、完了予定日を受け付け、取引先を作成した後、その取引先に紐づく商談を作成する。

## 処理詳細
1.  **画面 (Screen): 取引先と商談の登録**
    * **入力項目**:
        * `AccountName` (テキスト): 取引先名
        * `OpportunityName` (テキスト): 商談名
        * `EndDate` (日付): 完了予定日
2.  **レコード作成 (Create Records): 取引先の作成**
    * **オブジェクト**: 取引先 (Account)
    * **項目設定**:
        * `Name`: `{!AccountName}`
    * **出力**: 作成したIDを自動保存
3.  **レコード作成 (Create Records): 商談を作成**
    * **オブジェクト**: 商談 (Opportunity)
    * **項目設定**:
        * `AccountId`: `{!CreateAccount.Id}` (上記で作成した取引先ID)
        * `CloseDate`: `{!EndDate}`
        * `Name`: `{!OpportunityName}`
        * `StageName`: Prospecting

---

# フロー9: ケースがクレームフラグ「true」で作成されたらChatter通知 (PostChatterFlow)
## 種別
レコードトリガーフロー

## 処理概要
クレームフラグがONの状態でケースが新規作成された際、取引先の所有者宛にメンション付きでChatter投稿を行う。

## 処理詳細
1.  **起動条件 (Start)**
    * **オブジェクト**: ケース (Case)
    * **トリガー**: 作成時
    * **条件**: `ClaimFlg__c` が `true` と等しい
    * **実行タイミング**: レコード保存後
2.  **テキストテンプレート (Text Templates)**
    * `ChatterText`: `@[{!$Record.Account.OwnerId}] クレームフラグ「true」でケースが作成されました。至急確認ください。`
3.  **アクション (Action): Chatterに投稿**
    * **アクション種別**: Chatterへの投稿 (chatterPost)
    * **メッセージ**: `{!ChatterText}`
    * **対象ID**: `{!$Record.Id}`

---

# フロー10: 活動件数を取引先に積み上げ集計 (SumNumberOfAcitivities)
## 種別
レコードトリガーフロー

## 処理概要
ToDo（Task）が作成・更新された際、関連する取引先に紐づく全てのToDoの件数を集計し、取引先の項目「ActivityNumber__c」を更新する。

## 処理詳細
1.  **起動条件 (Start)**
    * **オブジェクト**: ToDo (Task)
    * **トリガー**: 作成または更新時
    * **条件**: `AccountId` が `null` (空文字) でない
    * **実行タイミング**: レコード保存後
2.  **レコード取得 (Get Records): 同じ取引先に紐づく活動を取得する**
    * **オブジェクト**: ToDo (Task)
    * **条件**: `AccountId` が `{!$Record.AccountId}` と等しい
    * **保存対象**: すべてのレコード
3.  **割り当て (Assignment): 活動レコードを割り当てる**
    * 変数 `ActivityNum` (数値型) に `{!GetTodoRecord}` (取得したレコードコレクション) の件数 (Equals Count) を割り当て
4.  **レコード更新 (Update Records): 取引先の活動件数を変更**
    * **オブジェクト**: 取引先 (Account)
    * **条件**: `Id` が `{!$Record.AccountId}` と等しい
    * **項目設定**:
        * `AcitivityNumber__c`: `{!ActivityNum}`