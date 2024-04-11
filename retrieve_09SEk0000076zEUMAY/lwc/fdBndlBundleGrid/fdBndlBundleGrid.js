import { LightningElement, wire, track } from 'lwc';
import getBundles from '@salesforce/apex/FdBndl_GetBundles.getBundles';
import header from '@salesforce/label/c.FdBndle_Bundle_Header';

export default class fdBndlBundleGrid extends LightningElement {
  data = [];
  error;
  @track dataAvailable = false;

  label = {
    header,
  };

  @wire(getBundles)
  wiredGetBundles({ error, data }) {
    if (data) {
      this.data = data.map((value, index) => {
        return {
          ...value,
          index: index,
          buttons: [
            {
              label: value.Button_1__r?.Label__c,
              searchterm: value.Button_1__r?.Search_Query__c,
              org: value.Button_1__r?.Data_Source__c,
              article: value.Button_1__r?.Knowledge_Article__c,
              formId: value.Button_1__r?.Configurable_Form_Id__c,
              URL: value.Button_1__r?.URL__c,
              type: value.Button_1__r?.RecordType.Name,
            },
            {
              label: value.Button_2__r?.Label__c,
              searchterm: value.Button_2__r?.Search_Query__c,
              org: value.Button_2__r?.Data_Source__c,
              article: value.Button_2__r?.Knowledge_Article__c,
              formId: value.Button_2__r?.Configurable_Form_Id__c,
              URL: value.Button_2__r?.URL__c,
              type: value.Button_2__r?.RecordType.Name,
            },
          ],
          links: [
            {
              label: value.Link_1__r?.Label__c,
              searchterm: value.Link_1__r?.Search_Query__c,
              org: value.Link_1__r?.Data_Source__c,
              article: value.Link_1__r?.Knowledge_Article__c,
              formId: value.Link_1__r?.Configurable_Form_Id__c,
              URL: value.Link_1__r?.URL__c,
              type: value.Link_1__r?.RecordType.Name,
            },
            {
              label: value.Link_2__r?.Label__c,
              searchterm: value.Link_2__r?.Search_Query__c,
              org: value.Link_2__r?.Data_Source__c,
              article: value.Link_2__r?.Knowledge_Article__c,
              formId: value.Link_2__r?.Configurable_Form_Id__c,
              URL: value.Link_2__r?.URL__c,
              type: value.Link_2__r?.RecordType.Name,
            },
            {
              label: value.Link_3__r?.Label__c,
              searchterm: value.Link_3__r?.Search_Query__c,
              org: value.Link_3__r?.Data_Source__c,
              article: value.Link_3__r?.Knowledge_Article__c,
              formId: value.Link_3__r?.Configurable_Form_Id__c,
              URL: value.Link_3__r?.URL__c,
              type: value.Link_3__r?.RecordType.Name,
            },
            {
              label: value.Link_4__r?.Label__c,
              searchterm: value.Link_4__r?.Search_Query__c,
              org: value.Link_4__r?.Data_Source__c,
              article: value.Link_4__r?.Knowledge_Article__c,
              formId: value.Link_4__r?.Configurable_Form_Id__c,
              URL: value.Link_4__r?.URL__c,
              type: value.Link_4__r?.RecordType.Name,
            },
            {
              label: value.Link_5__r?.Label__c,
              searchterm: value.Link_5__r?.Search_Query__c,
              org: value.Link_5__r?.Data_Source__c,
              article: value.Link_5__r?.Knowledge_Article__c,
              formId: value.Link_5__r?.Configurable_Form_Id__c,
              URL: value.Link_5__r?.URL__c,
              type: value.Link_5__r?.RecordType.Name,
            },
          ],
        };
      });
    } else if (error) {
      this.data = [];
      this.error = error;
    }
    if (this.data.length > 0) {
      this.dataAvailable = true;
    }
  }
}