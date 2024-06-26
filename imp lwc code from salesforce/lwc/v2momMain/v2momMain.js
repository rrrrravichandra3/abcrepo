import { LightningElement,api } from 'lwc';
import V2MOM_BANNER from '@salesforce/resourceUrl/V2MOMBanner';

export default class V2momMain extends LightningElement {
    @api v2MomEmployeeNumber;
    @api isManager;
    @api employeeName;
    @api managerName;

    v2momBanner = V2MOM_BANNER;
}