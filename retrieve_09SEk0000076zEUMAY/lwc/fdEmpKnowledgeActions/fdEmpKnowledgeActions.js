/*
Example usage
<c-fd-emp-knowledge-actions 
    knowledge-id="<knowledge id>"
></c-fd-emp-knowledge-actions> 
*/
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fdResources from '@salesforce/resourceUrl/FrontDeskCustom';
import getKnowledgeArticle from '@salesforce/apex/FdEmp_KnowledgeArticleController.getKnowledgeArticle';
import getConfigurationValue from '@salesforce/apex/FdEmp_ConfigurationValue.getConfigurationValue';
import getKnowledgeMetadata from '@salesforce/apex/FdEmp_KnowledgeArticleController.getKnowledgeMetadata';
import getKnowledgeActions from '@salesforce/apex/FdEmp_KnowledgeArticleController.getKnowledgeActions';
import getActionById from '@salesforce/apex/FdEmp_KnowledgeArticleController.getActionById';
import urlLabel from '@salesforce/label/c.FdEmp_Action_URL';
import caseLabel from '@salesforce/label/c.FdEmp_Action_Case';
import { FdShActionHandlerFactory } from 'c/fdShActionHandlerFactory';

const ICONS = {
  URL: `${fdResources}/images/icons/open_secondary.svg`,
  URL_PRIMARY: `${fdResources}/images/icons/open_primary.svg`,
  CASE: `${fdResources}/images/icons/ticket_secondary.svg`,
  CASE_PRIMARY: `${fdResources}/images/icons/ticket_primary.svg`,
  CHAT: `${fdResources}/images/icons/ticket_secondary.svg`,
  CHAT_PRIMARY: `${fdResources}/images/icons/ticket_primary.svg`,
  PHONE: `${fdResources}/images/icons/call_secondary.svg`,
  PHONE_PRIMARY: `${fdResources}/images/icons/call_primary.svg`,
  GO_TO_SLACK: `${fdResources}/images/icons/open_secondary.svg`,
  GO_TO_SLACK_PRIMARY: `${fdResources}/images/icons/open_primary.svg`,
};

export default class FdEmpKnowledgeActions extends NavigationMixin(LightningElement) {
  @api knowledgeId;
  knowledgeArticle;
  conciergeBaseURL;
  knowledgeMetadata;
  actions;
  @track updatedActions = [];

  @wire(getKnowledgeActions, { knowledgeId: '$knowledgeId' })
  wiredKnowledgeActions({ error, data }) {
    if (data) {
      this.actions = data.map((value, index) => {
        return {
          ...value,
          preference: index === 0 ? 'primary' : 'secondary',
          icon: ICONS[value.actionType.toUpperCase() + (index === 0 ? '_PRIMARY' : '')],
          actionLabel: this.getLabelByType(value.actionType.toUpperCase()),
        };
      });
    } else {
      this.error = error;
    }
  }

  // eslint-disable-next-line no-undef
  @wire(getKnowledgeArticle, { recordId: '$knowledgeId' })
  wiredKnowledgeArticle({ error, data }) {
    if (data) {
      this.knowledgeArticle = data;
    } else {
      // Add error log
      this.error = error;
    }
  }

  // eslint-disable-next-line no-undef
  @wire(getKnowledgeMetadata, { knowledgeId: '$knowledgeId' })
  wiredKnowledgeMetadata({ error, data }) {
    if (data) {
      this.knowledgeMetadata = data;
    } else {
      // Add error log
      this.error = error;
    }
  }

  @wire(getConfigurationValue, { configName: 'ConciergeWebURL' })
  getConfigurationValue({ error, data }) {
    if (data) {
      this.conciergeBaseURL = data;
    } else if (error) {
      // Add error log
      this.error = error;
    }
  }

  async sendToLink(event) {
    let action;
    await getActionById({ actionId: event.target.dataset.actionId })
      .then(async (result) => {
        action = result;
        const actionAttributes = {};
        const factory = new FdShActionHandlerFactory(this);
        const _this = this;
        const wrapperFn = function (...args) {
          return _this[NavigationMixin.Navigate].bind(_this, ...args);
        };
        const boundFunction = wrapperFn();
        actionAttributes.navigationFunction = boundFunction;
        actionAttributes.actionType = action.actionType;
        actionAttributes.formId = action.formId;
        actionAttributes.target = action.actionTarget;
        actionAttributes.source = this.knowledgeMetadata.Front_Desk_Data_Source__c;
        actionAttributes.kavId = this.knowledgeMetadata.Source_ArticleVersionId__c;
        await factory.createHandlerAndHandleAction(actionAttributes);
      })
      .catch((error) => {
        console.error(
          `Error occurred while getting action by Id: ${event.target.dataset.actionId}. Caused by: ${error}`
        );
      });
  }
  /* Following action types exist but are not supported yet in front desk
   URL: 'TRAILHEAD','GO_TO_SLACK','FORM'
   CASE: 'CUSTOM_CASE','CASE'
   CALL: 'PHONE'
   EMAIL: 'EMAIL'
   CHAT: 'CHAT'
   ONSITE: 'ONSITE'
  */
  getLabelByType(actionType) {
    switch (actionType) {
      case 'URL':
        return urlLabel;
      case 'CONFIGURABLE_FORM':
        return caseLabel;
      default:
        return '';
    }
  }
}