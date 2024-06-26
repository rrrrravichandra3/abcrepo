import {
    LightningElement,
    api
} from 'lwc';

import searchMentorsLabel from '@salesforce/label/c.search_mentors';
import myMentorsLabel from "@salesforce/label/c.menu_My_Mentors";
import myMeetingsLabel	from "@salesforce/label/c.menu_My_Meetings";
import showMoreLabel from "@salesforce/label/c.Show_More";

export default class Cs_mobileNavBar extends LightningElement {

    @api navType;
    @api myMentorsURL;
    @api searchMentorsURL;
    @api meetingsURL;
    @api showMoreURL;

    labels = {
        searchMentorsLabel,
        myMentorsLabel,
        myMeetingsLabel,
        showMoreLabel
    };


}