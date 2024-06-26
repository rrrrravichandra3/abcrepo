/**
 * @description       : This child LWC is a reusable card for the "Values" section
 *                      for the "MySalesforce" Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 09-23-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement, api } from 'lwc';

export default class PbValueCard extends LightningElement {
    @api title;
    @api paragraph;
    @api link;
}