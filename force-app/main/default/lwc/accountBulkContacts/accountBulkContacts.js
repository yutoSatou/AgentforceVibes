import { LightningElement, api, track } from "lwc";
import insertContacts from "@salesforce/apex/AccountBulkContactsController.insertContacts";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class AccountBulkContacts extends LightningElement {
  @api recordId; // Account Id from record page
  @track rows = [];
  isSaving = false;
  errorMessage;

  connectedCallback() {
    this.addEmptyRow();
  }

  get hasRows() {
    return this.rows && this.rows.length > 0;
  }

  addEmptyRow() {
    const key = `${Date.now()}-${Math.random().toString(36).substring(2, 8)}`;
    this.rows = [
      ...this.rows,
      {
        key,
        LastName: "",
        FirstName: "",
        Email: "",
        Title: "",
        Phone: "",
        Department: ""
      }
    ];
  }

  handleAddRow() {
    if (this.rows.length >= 50) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "上限",
          message: "一度に作成できるのは最大50件です。",
          variant: "warning"
        })
      );
      return;
    }
    this.addEmptyRow();
  }

  handleDeleteRow(event) {
    const index = Number(event.currentTarget.dataset.index);
    const newRows = [...this.rows];
    newRows.splice(index, 1);
    this.rows = newRows.length ? newRows : [];
    this.errorMessage = undefined;
  }

  handleInputChange(event) {
    const index = Number(event.target.dataset.index);
    const field = event.target.dataset.field;
    const value = event.target.value;
    const newRows = [...this.rows];
    newRows[index] = { ...newRows[index], [field]: value };
    this.rows = newRows;
  }

  renderedCallback() {
    // No need for custom event listener - use standard LWC data binding
  }

  validate() {
    if (!this.hasRows) {
      this.errorMessage = "最低1行は必要です。";
      return false;
    }
    // Validate LastName and Email format (if provided)
    const emailRegex =
      /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@(([^<>()[\]\\.,;:\s@"]+\.)+[^<>()[\]\\.,;:\s@"]{2,})$/i;

    for (let i = 0; i < this.rows.length; i++) {
      const r = this.rows[i];
      if (!r.LastName || r.LastName.trim().length === 0) {
        this.errorMessage = `行 ${i + 1}: 姓(LastName) は必須です。`;
        return false;
      }
      if (r.Email && !emailRegex.test(r.Email)) {
        this.errorMessage = `行 ${i + 1}: メール形式が不正です。`;
        return false;
      }
    }
    this.errorMessage = undefined;
    return true;
  }

  async handleSave() {
    if (!this.validate()) {
      return;
    }
    this.isSaving = true;
    try {
      // Debug: log the payload structure
      console.log("Sending payload:", this.rows);

      // Create a clean payload with explicit null handling
      const payload = this.rows.map((r) => {
        const contactData = {
          LastName: r.LastName?.trim(),
          FirstName: r.FirstName?.trim(),
          Email: r.Email?.trim(),
          Title: r.Title?.trim(),
          Phone: r.Phone?.trim(),
          Department: r.Department?.trim()
        };

        // Explicitly set null values for empty strings
        Object.keys(contactData).forEach((key) => {
          if (contactData[key] === "") {
            contactData[key] = null;
          }
        });

        return contactData;
      });

      console.log("Mapped payload:", payload);

      const result = await insertContacts({
        accountId: this.recordId,
        contacts: payload
      });
      if (result && result.success) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "成功",
            message: `${payload.length}件の取引先責任者を作成しました。`,
            variant: "success"
          })
        );
        // reset table to a single empty row
        this.rows = [];
        this.addEmptyRow();
      } else {
        const msg =
          (result && result.message) || "保存中にエラーが発生しました。";
        this.errorMessage = msg;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "失敗",
            message: msg,
            variant: "error"
          })
        );
      }
    } catch (e) {
      const msg =
        e?.body?.message || e?.message || "不明なエラーが発生しました。";
      this.errorMessage = msg;
      this.dispatchEvent(
        new ShowToastEvent({
          title: "失敗",
          message: msg,
          variant: "error"
        })
      );
    } finally {
      this.isSaving = false;
    }
  }
}