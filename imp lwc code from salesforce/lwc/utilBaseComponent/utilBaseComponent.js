import { LightningElement, wire } from 'lwc';
import {publish, MessageContext} from 'lightning/messageService'
import GAChannel from '@salesforce/messageChannel/ES_Google_Analytics_Tracking_Channel__c';

export default class UtilBaseComponent extends LightningElement {
    @wire(MessageContext)
    messageContext;

    publishUserEventToGoogleAnalytics(eventLabel, eventCategory){
        let GoogleAnalyticsEventInfo = {'event_label':eventLabel,'event_category': eventCategory};
        publish(this.messageContext, GAChannel, GoogleAnalyticsEventInfo);
    }
}