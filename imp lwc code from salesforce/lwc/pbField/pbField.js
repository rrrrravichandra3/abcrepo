/**
 * @description       : This LWC is a custom component to display a field with a label
 *                      for the preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 10-26-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/ 
import { LightningElement, api } from 'lwc';

export default class PbField extends LightningElement {
    @api label;
    @api value;
}