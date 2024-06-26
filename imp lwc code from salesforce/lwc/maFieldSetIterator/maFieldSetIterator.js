import {LightningElement, api} from 'lwc';

export default class MaFieldSetIterator extends LightningElement {
    @api fieldSet;
    @api currency;
    @api sobjRecord;
}