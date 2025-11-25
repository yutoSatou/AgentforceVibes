import { LightningElement, api } from 'lwc';

export default class AccountDisplay extends LightningElement {
    @api value;
    accounts = [];

    connectedCallback() {
        // Ensure accounts is always an array
        const results = this.value?.accounts || [];
        this.accounts = results;
    }
}