import { LightningElement, api, track } from 'lwc';

export default class MaCaseListItem extends LightningElement {
    @api macasewrapper;
    @api selected;
    @api mouseIsOver;
    @api firstcaseid;
    @api closedStatusSet;

    @track opencaseswrapper;
    @track closedcaseswrapper;

    isValidClosedStatus(caseStatus) {
        return this.closedStatusSet.has(caseStatus.toLowerCase());
    }

    connectedCallback() {
        if(this.macasewrapper.caseId === this.firstcaseid) {
            this.invokeSelectEvent();
        }
    }

    handleClick(event) {
        this.invokeSelectEvent();
    }

    invokeSelectEvent() {
        const selectEvent = new CustomEvent('select', {
            detail: this.macasewrapper.caseId
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }

    get divClass() {
        let cls = this.isValidClosedStatus(this.macasewrapper.Status) ? 'slds-p-top_small slds-p-bottom_small c-greyclosed' : 'slds-p-top_small slds-p-bottom_small c-default';
        
        if (this.selected) {
            cls += ' c-highlight-selected';
        } 

        if (this.mouseIsOver) {
            cls += ' c-mouseover-border'
        }

        return cls;
    }

}