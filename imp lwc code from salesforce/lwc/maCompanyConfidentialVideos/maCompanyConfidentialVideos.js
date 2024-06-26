import {LightningElement, track, wire, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getContentVersionList from '@salesforce/apex/MA_CompanyConfidentialVideoController.getContentVersionList';
import basePath from '@salesforce/community/basePath';
import { reduceErrors } from 'c/maErrorHandlingUtility';

export default class MaCompanyConfidentialVideos extends LightningElement {

    @track videolists =[];
    @track currentItems = 2;   
    @track contentVersions;
    @track selectedVideo;
    @track filteredList;
    @api recordId;

    previewVideo = false;
    videoLink = ''
    hasVideos = false
    isModalOpen = false;
    showLoadMore = false;
    hasRendered = false;

    
    renderedCallback(){
        console.log('recordId',this.recordId)
        if(!this.hasRendered){
            getContentVersionList({recordId: this.recordId})
            .then(data =>{
                
                if(data){

                    let communityUrl = window.location.origin+''+basePath
                    communityUrl = communityUrl.replace('/s','');   
                    this.contentVersions = JSON.parse(JSON.stringify(data))
                    this.contentVersions.forEach(element => element.videoUrl = communityUrl+'/sfsites/c/sfc/servlet.shepherd/version/download/'+ element.Id+'?operationContext=S1');
                    this.hasVideos = this.contentVersions.length > 0;
                    this.showLoadMore = this.contentVersions.length > 2
                    this.filteredList = this.contentVersions.slice(0, 2);
                }
            }).catch(error => this.showError(error));
            this.hasRendered = true;
        }
    }
   

    openModal(event) {
        const index = event.currentTarget.dataset.index;
        this.selectedVideo = this.contentVersions[index];
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }
   

    loadmoreData(event){
       
       this.filteredList = this.contentVersions.slice(0, this.filteredList.length+2);
       this.showLoadMore =  !(this.filteredList.length >= this.contentVersions.length)
       
    }

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }

   
    showError(error) {
        console.log(error);
        this.showSpinner = false;
        
        this.showToast('Error', 'error', reduceErrors(error));
    }

}