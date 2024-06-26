/**
 * @description       : This LWC is a logo that navigates to the home page
 *                      for the preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 10-16-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class PbLogo extends NavigationMixin(LightningElement) {
    @api logo;


    /**
     * @description navigateHome method uses the NavigationMixin
     *              from lightning/nvaigation to navigate Home
     */
    navigateHome() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: "Home"
            }
        });
    }
}