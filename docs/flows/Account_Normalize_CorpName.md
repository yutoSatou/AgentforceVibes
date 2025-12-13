# Flow Spec: Account Normalize CorpName

Purpose
- Normalize Japanese corporate abbreviations in Account Name by converting the short form “(株)” to the full form “株式会社”.
- Runs automatically after Account insert/update; only updates when “(株)” is present.

Metadata
- apiVersion: 65.0
- environments: Default
- interviewLabel: Account Normalize CorpName {!$Flow.CurrentDateTime}
- isTemplate: false
- label: Account Normalize CorpName
- processType: AutoLaunchedFlow
- status: Active
- Builder metadata values:
  - BuilderType: LightningFlowBuilder
  - CanvasMode: AUTO_LAYOUT_CANVAS
  - OriginBuilderType: LightningFlowBuilder

Trigger (Start)
- Object: Account
- Trigger Timing: RecordAfterSave
- Record Trigger Type: CreateAndUpdate
- Does Require Record Changed To Meet Criteria: false
- Connector: targetReference → Entry_Decision

Elements

1) Formula: Formula_NormalizedName
- API Name: Formula_NormalizedName
- Data Type: String
- Expression:
  SUBSTITUTE({!$Record.Name}, &#39;(株)&#39;, &#39;株式会社&#39;)
- Behavior: Returns a string where the first argument’s occurrences of “(株)” are replaced by “株式会社”.

2) Variable: Replaced_Name
- API Name: Replaced_Name
- Data Type: String
- isCollection: false
- isInput: false
- isOutput: false
- Purpose: Holds the computed normalized name prior to update.

3) Decision: Entry_Decision
- Label: Should Normalize
- Default Outcome Label: Default Outcome
- Rules:
  - Rule API Name: Has_Kabu
  - Label: Name contains (株)
  - Condition Logic: and
  - Conditions:
    - leftValueReference: $Record.Name
    - operator: Contains
    - rightValue.stringValue: (株)
  - Connector on True: targetReference → Compute_Replaced_Name
- Behavior: If Account Name contains “(株)”, proceed to compute the normalized name. Otherwise, no action (default outcome).

4) Assignment: Compute_Replaced_Name
- Label: Compute Replaced Name
- Assignment Items:
  - assignToReference: Replaced_Name
  - operator: Assign
  - value: elementReference → Formula_NormalizedName
- Connector: targetReference → Update_Account_Name
- Outcome: Copies the formula result into Replaced_Name.

5) Record Update: Update_Account_Name
- Label: Update Account Name
- inputReference: $Record
- inputAssignments:
  - field: Name
  - value: elementReference → Replaced_Name
- Outcome: Persists the normalized Account Name on the triggering record.

Flow Connectivity (Wiring)
- Start → Entry_Decision
- Entry_Decision (Has_Kabu = true) → Compute_Replaced_Name
- Compute_Replaced_Name → Update_Account_Name
- If Entry_Decision default outcome applies, flow ends without changes.

Exact Values for AI Re-creation
- Object: Account
- Trigger: After Save, on Create and Update
- Condition to proceed:
  - $Record.Name Contains “(株)”
- Formula:
  - Name: Formula_NormalizedName
  - DataType: String
  - Expression: SUBSTITUTE({!$Record.Name}, &#39;(株)&#39;, &#39;株式会社&#39;)
- Variable:
  - Name: Replaced_Name
  - Type: Text (String), not a collection, not input, not output
- Update:
  - Target: $Record
  - Field: Name
  - Value: {!Replaced_Name}
- Process metadata (BuilderType/CanvasMode/OriginBuilderType): LightningFlowBuilder / AUTO_LAYOUT_CANVAS / LightningFlowBuilder
- Status: Active
- Process Type: AutoLaunchedFlow
- Environments: Default
- Label: Account Normalize CorpName
- Interview Label: Account Normalize CorpName {!$Flow.CurrentDateTime}

Implementation Notes and Guardrails
- Use an After-Save Record-Triggered Flow to avoid recursion issues and to ensure the record Id is available.
- doesRequireRecordChangedToMeetCriteria = false allows the flow to run on every save; the Decision ensures updates occur only when needed.
- The SUBSTITUTE function is case-sensitive and exact; ensure the literal “(株)” is used (full-width parentheses).
- Avoid infinite update loops; since the replacement changes “(株)” to “株式会社”, subsequent saves won’t match the Decision condition anymore.
- If additional abbreviations must be normalized, chain SUBSTITUTE calls in the Formula (outermost SUBSTITUTE wraps the previous).
- Ensure the FlowDefinition metadata exists and references this flow version if deploying as metadata (present in repo at force-app/main/default/flowDefinitions/Account_Normalize_CorpName.flowDefinition-meta.xml).

Test Scenarios
- Insert Account with Name = “テスト(株)ABC” → After save, Name = “テスト株式会社ABC”.
- Update Account where Name already contains “株式会社” and no “(株)” → No change.
- Insert Account with Name not containing “(株)” → No change.
- Update an Account from containing “(株)” to a string without it → No post-update change needed; Decision branch not taken.

Deployment/Activation
- Flow file path: force-app/main/default/flows/Account_Normalize_CorpName.flow-meta.xml
- FlowDefinition file path: force-app/main/default/flowDefinitions/Account_Normalize_CorpName.flowDefinition-meta.xml
- Status should be Active post-deploy.
