import { LightningElement,api } from 'lwc';

export default class StartDateDetail extends LightningElement {
    @api startDateDay;
    @api startDateMonth;
}