/**
 * @description       : This LWC is a card to show the user's title
 *                      for the preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 10-11-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement, api } from 'lwc';

export default class PbTitleCard extends LightningElement {
    @api title;
    @api titleText;
}