import { LightningElement, track, api,wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import SEARCH_FILTERS_UPDATED_CHANNEL from '@salesforce/messageChannel/Job_Seach_Filters_Update__c';

export default class TalentMp_searchJobsPagination extends LightningElement {
    @api totalCount;
    @track pageNumbersList;
    @track currentPageNumber = 1;
    startJobIndex = 1;
    endJobIndex = 10;
    totalPages = 0;
    pageId = 1;
    @wire(MessageContext)
    messageContext;
    filtersUpdated = false;
    filterValues;


    connectedCallback(){
        this.subscribeToMessageChannel();
        this.calculatePaginationData();
        this.updateActivePageStyle();
    }

    renderPagination(filterValues){        
        this.filtersUpdated = true;
        this.currentPageNumber = 1;
        this.filterValues = filterValues;
        setTimeout(() => {
            if(this.filtersUpdated) {
                this.calculatePaginationData();
                this.updateActivePageStyle();
                this.updateSeriesOfJobOnPageChange();
            }
            this.filtersUpdated = false;
    
        }, 500)
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
          this.messageContext,
          SEARCH_FILTERS_UPDATED_CHANNEL,
          (filterValues) => this.renderPagination(filterValues)
        );
      }

    calculatePaginationData(){
        this.pageNumbersList = [];
        this.totalPages = this.totalCount % 10 === 0 ? this.totalCount/10 : Math.ceil(this.totalCount/10);
        if(this.totalPages <= 5){
            for(let i=1;i<=this.totalPages;i++){
                this.pageNumbersList.push(i);
            }
        }
        else{
            this.pageNumbersList.push(1,2,3,'...',this.totalPages);
        }
    }

    handlePageChange(event){
        this.pageId = event.target.dataset.id;
        if(this.pageId == '...'){
            return false;
        }
        else if(this.pageId === 'previous'){
            this.currentPageNumber = this.currentPageNumber - 1;
        }
        else if(this.pageId === 'next'){
            this.currentPageNumber = this.currentPageNumber + 1;
        }
        else{
            this.currentPageNumber = parseInt(this.pageId);
        }

        this.updatePaginationList();

        this.updateActivePageStyle();

        this.updateSeriesOfJobOnPageChange();

        this.fireEventToGetPaginatedJobsFromParent();
    }

    updateSeriesOfJobOnPageChange(){
        this.startJobIndex = ((this.currentPageNumber - 1) * 10) + 1;
        if(this.totalCount < 10){
            this.endJobIndex = this.totalCount;
        }
        else if(this.currentPageNumber === this.totalPages && this.totalCount%10 !== 0){
            this.endJobIndex = (this.totalPages - 1) * 10  + (this.totalCount % 10);
        }
        else{
            this.endJobIndex = this.currentPageNumber * 10;
        }
    }

    updateActivePageStyle(){
        this.pageNumbersList = this.pageNumbersList
        .map(page => {
            return {
                    pageNumber: page,
                    style: page == this.currentPageNumber ? 'font-weight:bold;cursor:pointer' : 'cursor:pointer'
            }
        });
    }

    fireEventToGetPaginatedJobsFromParent(){
        const event = new CustomEvent('callparentgetjobs', {
            detail: {
                pageNumber: this.currentPageNumber,
                filterValues: this.filterValues
            }
        });
        this.dispatchEvent(event);
    }

    updatePaginationList(){
        let updatedPageNumbersList;
        if(this.totalPages > 5){
            if(this.currentPageNumber == this.totalPages){
                updatedPageNumbersList =  [1, '...', this.currentPageNumber - 2, this.currentPageNumber - 1, this.totalPages];
                this.pageNumbersList = [...updatedPageNumbersList];
            }
            else if(this.currentPageNumber < 3){
                updatedPageNumbersList =  [1,2,3, '...', this.totalPages];
                this.pageNumbersList = [...updatedPageNumbersList];
            }
            else if(this.currentPageNumber == 3){
                updatedPageNumbersList =  [1,2,3,4, '...', this.totalPages];
                this.pageNumbersList = [...updatedPageNumbersList];
            }
            else if(this.currentPageNumber > 3 && this.totalPages >= this.currentPageNumber + 3){
                updatedPageNumbersList =  [1,'...',this.currentPageNumber - 1, this.currentPageNumber, this.currentPageNumber+1, '...', this.totalPages];
                this.pageNumbersList = [...updatedPageNumbersList];
            }
            else if(this.currentPageNumber == this.totalPages - 1){
                updatedPageNumbersList =  [1,'...',this.totalPages - 2, this.totalPages - 1, this.totalPages];
                this.pageNumbersList = [...updatedPageNumbersList];
            }
            else if(this.currentPageNumber == this.totalPages - 2){
                updatedPageNumbersList =  [1,'...',this.totalPages - 3,this.totalPages - 2, this.totalPages - 1, this.totalPages];
                this.pageNumbersList = [...updatedPageNumbersList];
            }
        }
        else{
            updatedPageNumbersList = [];
            for(let i=1;i<=this.totalPages;i++){
                updatedPageNumbersList.push(i);
            }
            this.pageNumbersList = [...updatedPageNumbersList];
        }
    }

    get isPreviousVisible(){
        return this.totalPages > 5 && this.currentPageNumber > 1 ? true : false;
    }

    get isNextVisible(){
        return this.totalPages > 5 && this.currentPageNumber != this.totalPages ? true : false;
    }

    get isPaginationRequired(){
        return this.totalCount > 10 ? true : false;
    }
}