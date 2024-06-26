/**
 * @description       : This LWC is a section for the "Values" cards
 *                      for the "MySalesforce" Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 09-23-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement } from 'lwc';
import BRANDY from '@salesforce/resourceUrl/ms_brandyImage';

export default class PbValuesSection extends LightningElement {
    brandyImg = BRANDY;
    enabledFeatures = ["card"];
    
    valuesList = [
        {
            title: "Trust",
            paragraph: "Trust is our #1 value. It means we act with transparency and lead with our ethics.",
            link: "https://trust.salesforce.com/?_ga=2.190864234.1793531575.1694805634-714980719.1694526233"
        },
        {
            title: "Customer Success",
            paragraph: "We prioritize our customers’ success and the success of the customers they serve.",
            link: "https://www.salesforce.com/services/overview/"
        },
        {
            title: "Innovation",
            paragraph: "We want our products to be the most relevant, easy-to-use, integrated, scalable, and global products out there, delivering fast time to value for our customers.",
            link: "https://www.salesforce.com/products/innovation/summer-21-release/"
        },
        {
            title: "Equality",
            paragraph: "We are committed to creating a more equal world and believe we are more powerful working together.",
            link: "https://www.salesforce.com/company/equality/"
        },
        {
            title: "Sustainability",
            paragraph: "Everything rests on a stable climate, so we’re helping every organization achieve net zero carbon emissions and lead by example as a net zero company.",
            link: "https://www.salesforce.com/company/sustainability/"
        }
    ];


}