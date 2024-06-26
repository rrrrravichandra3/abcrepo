/**
 * @description       : This child LWC is a reusable card for the "Helpful Resources" section
 *                      for the "MySalesforce" Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 09-24-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement, api } from 'lwc';
import ARROW from '@salesforce/resourceUrl/ms_arrowIcon';

export default class PbResourcesCard extends LightningElement {
    @api title;
    @api paragraph;
    @api link;
    @api subheader;

    arrowIcon = ARROW;
}