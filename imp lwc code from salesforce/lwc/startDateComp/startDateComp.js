import { LightningElement,api } from 'lwc';

const MONTHS = ['Jan','Feb','Mar','Apr','May','June','Jul','Aug','Sep','Oct','Nov','Dec'];


export default class StartDateComp extends LightningElement {
    _startDate;
    _startDateDay;
    _startDateMonth;
    @api provCase;
    
    connectedCallback() {
        this._startDate=this.provCase.fields.NHW_Start_Date__c.value;
        let dateSplit = this._startDate.split('-');
        this._startDateDay=dateSplit[2];
        this._startDateMonth = MONTHS[parseInt(dateSplit[1])];
    }
}