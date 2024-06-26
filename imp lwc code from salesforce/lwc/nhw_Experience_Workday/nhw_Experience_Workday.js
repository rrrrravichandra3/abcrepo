import { LightningElement,track } from 'lwc';
import NHW_workday from '@salesforce/resourceUrl/NHW_workday';
import NHW_workday2 from '@salesforce/resourceUrl/NHW_workday2';
import NHW_workday3 from '@salesforce/resourceUrl/NHW_workday3';

export default class Nhw_Experience_Workday extends LightningElement {
    _image1 = NHW_workday;
    _image2 = NHW_workday2;
    _image3 = NHW_workday3;
    @track _containerText = 'Complete your tasks in Workday';
    @track _containerHeader = 'Workday Inbox Tasks';
    @track _containerBodyText = 'There are a few tasks that you need to complete in Workday. After you are done, please return to this site to continue';
    @track _text1 = 'Login to ';
    @track _text2 = 'Workday';
    @track _text3 = 'Click the inbox icon';
    @track _text4 = 'Complete tasks';
    @track _labelConfirmation = ' I confirm I have completed my tasks in Workday';
    @track _isNextEnabled = false;
    @track _backBtnLabel = 'Back to home'
    
    get disableButton(){
        return !this._isNextEnabled;
    }
    connectedCallback() {
        this.updateCmp();
     }
    

}