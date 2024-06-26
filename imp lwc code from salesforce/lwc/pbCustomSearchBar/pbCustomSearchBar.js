/**
 * @description       : This LWC is a custom search component to search Knowledge Articles
 *                      for the preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 10-16-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class PbCustomSearchBar extends NavigationMixin(LightningElement) {
    @api searchPlaceholder;

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            const queryTerm = evt.target.value;
            this.navigateToSearch(queryTerm);
        }
    }

    navigateToSearch(queryTerm) {
        // Navigate to search page using lightning/navigation API: https://developer.salesforce.com/docs/component-library/bundle/lightning:navigation/documentation
        this[NavigationMixin.Navigate]({
            type: 'standard__search',
            attributes: {},
            state: {
                term: queryTerm
            }
        });
    }

}