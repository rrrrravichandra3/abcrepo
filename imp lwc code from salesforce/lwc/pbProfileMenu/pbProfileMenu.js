/**
 * @description       : This LWC is is a profile menu for the header on the
 *                      preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 10-11-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement, api } from 'lwc';

export default class PbProfileMenu extends LightningElement {
    @api firstName;
    @api lastName;
    @api firstInitial;
    @api lastInitial;
    @api employeeId;
    @api employeeIdLabel;
    @api workdayLinkText;
    @api logoutText;
    baseUrl = 'sfsites/c/cms/delivery/media/';
    showPopover = false;

    _headerImage
    @api 
    get profileMenuImage() {
        return this._headerImage;
    }
    set profileMenuImage(value) {
        this._headerImage = this.baseUrl + value;
    }

}