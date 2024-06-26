/**
 * @description       : This LWC displays the welcome video
 *                      for the preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 10-11-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement, api } from 'lwc';

export default class PbVideoContainer extends LightningElement {

   baseUrl = 'sfsites/c/cms/delivery/media/';

   _videoUrl;
   @api
   get videoId() {
      return this._videoUrl;
   }
   set videoId(value) {
      this._videoUrl = this.baseUrl + value;
   }

    _astroUrl;
   @api
   get contentId() {
      return this._astroUrl;
   }
   set contentId(value) {
      this._astroUrl = this.baseUrl + value;
   }

   _branchUrl;
   @api
   get contentId2() {
      return this._branchUrl;
   }
   set contentId2(value) {
      this._branchUrl = this.baseUrl + value;
   }

   _birdUrl;
   @api
   get contentId3() {
      return this._birdUrl;
   }
   set contentId3(value) {
      this._birdUrl = this.baseUrl + value;
   }

   _bushUrl;
   @api
   get contentId4() {
      return this._bushUrl;
   }
   set contentId4(value) {
      this._bushUrl = this.baseUrl + value;
   }


}