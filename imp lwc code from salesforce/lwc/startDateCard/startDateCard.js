import { LightningElement, api } from 'lwc';

export default class StartDateCard extends LightningElement {
    @api startDateDay;
    @api startDateMonth;
}