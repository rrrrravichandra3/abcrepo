import { LightningElement, api, wire, track } from 'lwc';
import getKnowledgeArticle from '@salesforce/apex/FdEmp_KnowledgeArticleController.getKnowledgeArticle';
import updated from '@salesforce/label/c.FdEmp_Updated';
import managerOnly from '@salesforce/label/c.FdEmp_Manager_Only';

export default class FdEmpknowledgeContent extends LightningElement {
  @api recordId;
  @api urlName;
  knowledgeArticle;
  @track error;
  label = {
    updated,
    managerOnly,
  };
  @wire(getKnowledgeArticle, { recordId: '$recordId' })
  wiredKnowledgeArticle({ error, data }) {
    if (data) {
      this.knowledgeArticle = data;
    } else {
      this.error = error;
    }
  }

  get formattedDate() {
    const options = { year: 'numeric', month: 'short', day: 'numeric' };
    const lastPublishedDate = this.knowledgeArticle.Front_Desk_Knowledge__r[0].Source_LastPublishedDate__c;
    const lastModifiedDate = this.knowledgeArticle.LastModifiedDate;
    const updatedDate = lastPublishedDate ?? lastModifiedDate;
    return new Date(updatedDate).toLocaleDateString(undefined, options);
  }

  get regionLabels() {
    return this.knowledgeArticle?.Front_Desk_Regions__c?.split(';') || [];
  }

  get countryLabels() {
    return this.knowledgeArticle?.Front_Desk_Countries__c?.split(';') || [];
  }

  get isManagerOnly() {
    return this.knowledgeArticle?.Front_Desk_Permissions__c?.includes('Manager') || false;
  }
}