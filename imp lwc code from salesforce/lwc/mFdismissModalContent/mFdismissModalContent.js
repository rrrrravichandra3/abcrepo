import { LightningElement, api } from 'lwc';

import tellUsALittleMoreThisHelpsLabel from '@salesforce/label/c.mentor_Please_tell_us_a_little_more_This_helps_us_improve_our_algorithm';
import whyAreYouNotInterestedLabel from '@salesforce/label/c.mentor_Why_are_you_not_interested_in_this_person_as_a_mentor';
import pleaseTellUsMoreLabel from '@salesforce/label/c.mentor_Please_tell_us_more';
import anyAdditionalInformationLabel from '@salesforce/label/c.mentor_Any_additional_information_is_appreciated';

export default class MFdismissModalContent extends LightningElement {

    labels = {
        tellUsALittleMoreThisHelpsLabel,
        whyAreYouNotInterestedLabel,
        pleaseTellUsMoreLabel,
        anyAdditionalInformationLabel
    }
    @api dismissalReason= '';
    @api reasonvalues;

    handleReasonChange(event){
        this.dispatchEvent(
            new CustomEvent("reasonchange", {
                bubbles: true, 
                composed: true,
                detail: event.detail
            })
        );
    }

    handleDismissalInformationChange(event){
        this.dispatchEvent(
            new CustomEvent("informationchange", {
                bubbles: true, 
                composed: true,
                detail: event.detail
            })
        );
    }
}