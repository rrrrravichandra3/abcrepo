/**
 * @description       : This LWC is a section for the "Helpful Resources" cards
 *                      for the "MySalesforce" Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 09-24-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement } from 'lwc';
import CLOUDS from '@salesforce/resourceUrl/ms_pinkClouds';

export default class PbResourcesSection extends LightningElement {
    clouds = CLOUDS;
    enabledFeatures = ["card"];

    get getBackgroundImage(){
        return `background-image:url("${this.clouds}")`;
    }


    resourcesList = [
        {
            subheader: "Benefits",
            title: "Know Your Benefits",
            paragraph: "Access information regarding coverage and health plans.",
            link: "https://salesforcebenefits.com/index.html"
        },
        {
            subheader: "HR",
            title: "Accessibility & Medical Accommodation",
            paragraph: "We strive to create an accessible and inclusive experience for all employees.",
            link: ""
        },
        {
            subheader: "Trailhead",
            title: "Trailhead is the Fun Way to Learn!",
            paragraph: "Join the global Trailblazer Community to connect to Trailblazers.",
            link: "https://trailhead.salesforce.com/"
        }
    ];


}