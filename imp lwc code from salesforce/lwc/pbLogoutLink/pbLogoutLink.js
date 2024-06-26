/**
 * @description       : This LWC is a custom logout component for the preboarding 
 *                      LWR Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 10-11-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement, api } from "lwc";
import isGuest from "@salesforce/user/isGuest";
import basePath from "@salesforce/community/basePath";

export default class PbLogoutLink extends LightningElement {
    @api logoutText;

    get isGuest() {
        return isGuest;
    }

    get logoutLink() {
        const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the community basePath without the trailing "/s"
        return sitePrefix + "/secur/logout.jsp";
    }

}