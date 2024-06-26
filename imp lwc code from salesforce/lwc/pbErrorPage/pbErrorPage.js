import { LightningElement,api } from 'lwc';
import pbAstroErrorPage from '@salesforce/resourceUrl/pbAstroErrorPage';
import pbWDError from '@salesforce/resourceUrl/pbWDError';
import pbTicketError from '@salesforce/resourceUrl/pbTicketError';
import pbSupportError from '@salesforce/resourceUrl/pbSupportError';
import pbSFLogo from '@salesforce/resourceUrl/pbSFLogo';
import pbbgLeft from '@salesforce/resourceUrl/pberrorBGImgLeft';
import pbbgRight from '@salesforce/resourceUrl/pberrorBGImgRight';
import pbbgCloud from '@salesforce/resourceUrl/pberrorBGImgCloud';


export default class PbErrorPage extends LightningElement {

    @api congratulationText;
    @api bodyText;
    bgLeft = pbbgLeft;
    bgRight = pbbgRight;
    bgCloud = pbbgCloud;
    AstroErrorPage = pbAstroErrorPage;
    WDError = pbWDError;
    TicketError = pbTicketError;
    SupportError = pbSupportError;
    SFLogo = pbSFLogo;
    enabledFeatures = ["button","grid"];
    link1 = "https://concierge.it.salesforce.com/tickets";
    link2 = "https://wd12.myworkday.com/salesforce/d/home.htmld";
    link3 = "https://app.moveworks.ai/bot/17094923942757200196/slack/?embed_location=kb";

    gotoConcierge(){
        window.open(this.link1, '_blank').focus();
    }

    gotoWorkDay(){
        window.open(this.link2, '_blank').focus();
    }

    gotoAskConcierge(){
        window.open(this.link3, '_blank').focus();
    }



}