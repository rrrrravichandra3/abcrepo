import {LightningElement, api, track} from 'lwc';
import StockGrantAmountLabel from '@salesforce/label/c.MA_StockGrantAmount_Label';
import AdditionalStockGrantAmountLabel from '@salesforce/label/c.MA_AdditionalStockGrantAmountLabel';
import MA_DefaultUSDCurrencyCodeLabel from '@salesforce/label/c.MA_DefaultUSDCurrencyCode';

export default class MaFormattedFieldSetMember extends LightningElement {
    isTypeOther = false;
    isTypeDate = false;
    isTypeBoolean = false;
    isTypeCurrency = false;
    isStockGrantField = false;


    _fieldSetMember;
    fieldSetMemberValue;

    label = {
        StockGrantAmountLabel,
        AdditionalStockGrantAmountLabel,
        MA_DefaultUSDCurrencyCodeLabel
    }

    @api currency;
    @api sobjRecord;

    @api
    get fieldSetMember() {
        return this._fieldSetMember;
    }

    set fieldSetMember(value) {
        if(this._fieldSetMember !== value) {
            this._fieldSetMember = value;
            const fieldType = this._fieldSetMember.type;
            const fieldName = this._fieldSetMember.fieldPath;
            this.isTypeDate = (fieldType === "date");
            this.isTypeBoolean = (fieldType === "boolean");
            this.isTypeCurrency = (fieldType === "currency" && fieldName != this.label.AdditionalStockGrantAmountLabel);
            this.isStockGrantField = (fieldName === this.label.StockGrantAmountLabel || fieldName === this.label.AdditionalStockGrantAmountLabel)? true :false;
            this.isTypeOther = (!this.isTypeDate && !this.isTypeBoolean && !this.isTypeCurrency && !this.isTypeNumber && !this.isStockGrantField);
        }
    }

    connectedCallback() {
        let fieldPath = this._fieldSetMember.fieldPath;
        this.fieldSetMemberValue = this.sobjRecord[fieldPath];
    }
}