import { LightningElement,api } from 'lwc';
import preboardingResources from '@salesforce/resourceUrl/preboardingResources';


export default class NewHireInfo extends LightningElement {
    _sfLogo = preboardingResources + '/preboardingResources/sflogo.png';
    @api provCase;

    get name() {
      return this.provCase.fields.First_Name__c.value +" "+ this.provCase.fields.Last_Name__c.value;
    }
}