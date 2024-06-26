/**
 * @description       : This LWC is a custom component to display a Case record
 *                      for the preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 10-26-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/ 
import { LightningElement, api } from 'lwc';

export default class PbCaseListItem extends LightningElement {
    @api caseItem;

    // Labels for Case Item data
    @api ticketLabel;
    @api createdLabel;
    @api modifiedLabel;
    @api openStatusText;
    @api closedStatusText;

    subject;
    status;
    isClosed;
    caseNumber;
    dateCreated;
    lastModified;

    connectedCallback() {
        if(this.caseItem) {
            let rec = JSON.parse(JSON.stringify(this.caseItem));
            this.subject = rec.Subject;
            this.status = rec.Status;
            this.isClosed = rec.IsClosed;
            this.caseNumber = rec.CaseNumber;
            this.lastModified = rec.LastModifiedDate;
            this.dateCreated = rec.CreatedDate; 
        }
    }
    
}