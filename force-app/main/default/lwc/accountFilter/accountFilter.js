import { api, LightningElement } from 'lwc';

export default class AccountFilter extends LightningElement {
    /**
     * 読み取り専用フラグ
     * @type {boolean}
     */
    @api
    get readOnly() {
        return this._readOnly;
    }
    set readOnly(value) {
        this._readOnly = value;
    }
    _readOnly = false;

    /**
     * 親からの初期値/双方向バインド用
     * 形: { accountNameLike: string, maxSize: number }
     */
    @api
    get value() {
        return this._value;
    }
    set value(v) {
        this._value = v;
    }
    _value;

    accountNameLike;
    maxSize;

    connectedCallback() {
        if (this.value) {
            this.accountNameLike = this.value?.accountNameLike || '';
            this.maxSize = this.value?.maxSize ?? '';
        }
    }

    handleInputChange(event) {
        event.stopPropagation();
        const { name, value } = event.target;
        this[name] = value;

        this.dispatchEvent(
            new CustomEvent('valuechange', {
                detail: {
                    value: {
                        accountNameLike: this.accountNameLike,
                        // 数値入力は空の場合 '' のままにして親側で扱えるようにする
                        maxSize: this.maxSize === '' ? '' : Number(this.maxSize)
                    }
                }
            })
        );
    }
}