import { LightningElement,api,track } from 'lwc';


export default class TmSpaPages extends LightningElement {

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


}