import { LightningElement,api } from 'lwc';

export default class CareerConnectSpaPages extends LightningElement {

    @api currentPageId;

    get isJobsPage() {
        if(this.currentPageId == 'growApp'){
            return true;
        }else{
            return false;
        }
    }

    get isCareerPage(){
        if(this.currentPageId == 'careerPath'){
            return true;
        }else{
            return false;
        }
    }

    get isJobSearchPage(){
        if(this.currentPageId == 'jobsSearch'){
            return true;
        }else{
            return false;
        }
    }

}