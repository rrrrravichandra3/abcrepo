import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//apex methods to fetch case comments and post a new comment
import getCaseCommentList from '@salesforce/apex/MA_MyCasesController.getCaseCommentWrapperList';
import postNewCaseCommentServer from '@salesforce/apex/MA_MyCasesController.postNewCaseComment';
//Labels
import CommentsListFetchError from '@salesforce/label/c.MA_MyCases_CommentListLoadError';
import PostNewCommentError from '@salesforce/label/c.MA_MyCases_CommentPostError';
import InvalidCommentError from '@salesforce/label/c.MA_MyCases_InvalidCommentError';
import SuccessfullCommentPost from '@salesforce/label/c.MA_MyCases_CommentPostSuccess';

export default class MaMyCasesComment extends LightningElement {
    //labels are stored here
    label = {
        CommentsListFetchError,
        PostNewCommentError,
        InvalidCommentError,
        SuccessfullCommentPost
    };
    //Id of the case selected
    @track localSelectedCaseId
    //List of case comments in a wrapper
    @track casesCommentWrapper;
    //Variables for controlling fetch case comments functionality
    @track fetchCommentsError;
    @track fetchCommentsServerCallInprogress;
    //variables for controlling post a new comment functionality
    @track postNewCaseComment;
    @track postCommentError;
    @track postCommentServerCallInProgress;
    @track disablePostCommentButton

    _caseclosedstatus;
    @api 
    get caseclosedstatus() {
        return this._caseclosedstatus;
    }
    set caseclosedstatus(value) {
        this.setAttribute('caseclosedstatus', value);
        this._caseclosedstatus = value;
    }

    //parent component passes selected case id to api selectedcaseid
    //which in turn gets/sets the trackable variable localSelectedCaseId
    @api 
    get selectedcaseid() {
        return this.localSelectedCaseId;
    }
    set selectedcaseid(value) {
        this.setAttribute('selectedcaseid',value);
        this.localSelectedCaseId = value;
        //get the comments for the selected case
        this.getCaseCommentsFromServer();
    }

    //constructor
    constructor(){
        super();
        this.disablePostCommentButton = false;
    }

    //function to make server call to get case coments
    getCaseCommentsFromServer(){
        if(this.localSelectedCaseId){
            this.fetchCommentsServerCallInprogress = true;
            getCaseCommentList({caseId : this.localSelectedCaseId})
            .then(result =>{
                this.casesCommentWrapper = result;
                this.fetchCommentsError = undefined;
                this.fetchCommentsServerCallInprogress = false;
                const element = this.template.querySelector('[data-id="overview"]');
                element.scrollTop = element.scrollHeight;
            })
            .catch(error => {
                this.fetchCommentsError = error;
                this.casesCommentWrapper = undefined;
                this.fetchCommentsServerCallInprogress = false;
                this.showCommentFetchErrorToast();
            })
        }
        
    }

    //function to call apex to post a new comment stored in variable postNewCaseComment
    //this method is called when "Add a Comment" button is clicked
    postNewComment(){
        if(this.disablePostCommentButton === true){
            return;
        }
        //if there is no data or empty string, show error toast
        if(!this.postNewCaseComment || this.postNewCaseComment==="" || !this.localSelectedCaseId){
            this.showInvalidCommentPostError();
        }else{
            //disable the button
            this.disablePostCommentButton = true;
            //call server to post the comment
            this.postCommentServerCallInProgress = true;
            postNewCaseCommentServer({caseId : this.localSelectedCaseId, newCaseComment : this.postNewCaseComment})
            .then(result =>{
                this.postNewCaseComment = undefined;
                this.postCommentError = undefined;
                this.postCommentServerCallInProgress = false;
                this.disablePostCommentButton = false;
                //show success toast
                this.showCommentPostSuccessMessage();
                //after successfully inserting new comment, get updated list of case comments from server
                this.getCaseCommentsFromServer();
                this.sendCaseUpdatedDetails(result.Id, result.Status);
            })
            .catch(error => {
                this.postCommentError = error;
                this.postCommentServerCallInProgress = false;
                this.disablePostCommentButton = false;
                //is there was error encountered while posting case comment, throw an error toast
                this.showCommentPostServerError();
            })
        }
    }

    sendCaseUpdatedDetails(caseId, caseStatus) {
        const commentEvent = new CustomEvent('comment', {detail: {id: caseId, status: caseStatus}});
        this.dispatchEvent(commentEvent);
    }

    //function to keep html input text box and variable postNewCaseComment in sync
    updateCommentValue(event){
        let userComment = event.target.value;
        userComment = userComment.trim();
        this.postNewCaseComment = userComment;
    }
    
    //-----Error and success toasts------

    //function to throw error toast when fetching case comments encounters error
    showCommentFetchErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: this.label.CommentsListFetchError,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    //function to throw error toast when user tries to post invalid comment
    showInvalidCommentPostError() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: this.label.InvalidCommentError,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    //function to throw error when inserting new comment encounters error
    showCommentPostServerError(){
        const evt = new ShowToastEvent({
            title: 'Error',
            message: this.label.PostNewCommentError,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    //function to show success toast after posting a new case comment
    showCommentPostSuccessMessage(){
        const evt = new ShowToastEvent({
            title: 'Success',
            message: this.label.SuccessfullCommentPost,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    /*keycheck(event) {
        if(event.which == 13) {
            this.postNewComment();
        }
    }*/
    
    
}