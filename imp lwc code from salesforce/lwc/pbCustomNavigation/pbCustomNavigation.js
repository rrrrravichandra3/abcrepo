/**
 * @description       : This LWC is a custom navigation header for the preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 10-16-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/
import { LightningElement, api, wire } from 'lwc';
import USERID from "@salesforce/user/Id";
import { getRecord } from "lightning/uiRecordApi";

export default class PbCustomNavigation extends LightningElement {
    enabledFeatures = ["popover","text-input","card","button"];
    userId = USERID;
    contactId;
    firstName;
    lastName;
    firstInitial;
    lastInitial;
    employeeId;

    @api workdayLinkText;
    @api logoutText;
    @api profileMenuImage;
    @api myTicketsLabel;
    @api helpLabel;
    @api employeeIdLabel;
    @api searchPlaceholder;

    _logoUrl;
    @api
    get logoId() {
        return this._logoUrl;
    }
    set logoId(value) {
        this._logoUrl = 'sfsites/c/cms/delivery/media/' + value;
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
            console.log("ContactId ", data.fields.ContactId.value);
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
         "Contact.LastName",
         "Contact.EmployeeNumber__c"
      ] 
   }) getContactRecord({ data, error }){
      if (data) {
        if(data.fields.FirstName) {
            this.firstName = data.fields.FirstName.value;
            this.firstInitial = this.firstName.charAt(0).toUpperCase();
        }
        if(data.fields.FirstName) {
            this.lastName = data.fields.LastName.value;
            this.lastInitial = this.lastName.charAt(0).toUpperCase();
            }
        if(data.fields.EmployeeNumber__c) {
            this.employeeId = data.fields.EmployeeNumber__c.value;
        }
         
      } else if (error) {
         this.error = error;
         console.log("error: ", error);
      } 
   }

}