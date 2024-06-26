/**
 * @description       : This LWC is a custom banner for the preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 10-11-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement, api, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import UserId from "@salesforce/user/Id"; // get current user's id

export default class PbCustomBanner extends LightningElement {

   userId = UserId;
   contactId;
   firstName;
   jobTitle;
   startDate;
   location;
   boomerangFlag = false;
   error;

   _startDateDay;
   _startDateMonth;
   countdown;

   enabledFeatures = ["button","grid"];

   @api pageTitle;
   @api welcomeText;
   @api boomerangText;
   @api greetingText;
   @api buttonText;
   @api startDateText;
   @api months;
   @api titleText;
   @api tooltipText;
   @api contentId;
   @api contentId2;
   @api contentId3;
   @api contentId4;
   @api videoId;

   connectedCallback() {
      console.log("userId: ", this.userId);
   }

   /**
    * @description call getRecord wire to
    *              get current User's ContactId
    * @param   userId the current Users recordId
    */
   @wire(getRecord, { recordId: "$userId", fields: ["User.ContactId"] }) // test: userId = 005Oz000000BljZIAS
   getContactId({ data, error }){
      if (data) {
         if(data.fields.ContactId.value) {
            this.contactId = data.fields.ContactId.value;
         }
      } else if (error) {
         this.error = error;
         console.log("error: ", error);
      } 
   }

   /**
    * @description call getRecord wire to
    *              get current User's related Contact record
    * @param   userId the current Users recordId
    */
   @wire(getRecord, { 
      recordId: "$contactId", 
      fields: [
         "Contact.FirstName",
         "Contact.Title",
         "Contact.Start_Date__c",
         "Contact.ES_DJC_Work_Location__c",
         "Contact.Boomerang__c"
      ] 
   }) getContactRecord({ data, error }){
      
      if (data) {
         if(data.fields.FirstName) {
            this.firstName = data.fields.FirstName.value;
         }
         if(data.fields.Title) {
            this.jobTitle = data.fields.Title.value;
         }
         if(data.fields.Start_Date__c) {
            this.startDate = data.fields.Start_Date__c.value;
            let tempDate = new Date(this.startDate + 'T00:00');
            this._startDateDay =  tempDate.getDate();
            if(this.months) {
               const monthsArray = this.months.split(',');
               this._startDateMonth = monthsArray[tempDate.getMonth()];
            }
         }
         if(data.fields.ES_DJC_Work_Location__c) {
            this.location = data.fields.ES_DJC_Work_Location__c.value;
         }
         if(data.fields.Boomerang__c) {
            this.boomerangFlag = data.fields.Boomerang__c.value;
         }
         
      } else if (error) {
         this.error = error;
         console.log("error: ", error);
      } 
   }



}