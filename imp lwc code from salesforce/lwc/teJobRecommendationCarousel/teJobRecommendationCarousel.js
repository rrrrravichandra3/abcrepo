import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class TeJobRecommendationCarousel extends NavigationMixin(LightningElement) {
    @api recommendedJobs = [];
    @api contact;
    @api skills;

    activeIndex = 0;

    handlePreviousBtn() {
        if (this.activeIndex > 0) {
            this.activeIndex--;
        }
    }

    handleNextBtn() {
        if (this.activeIndex < this.recommendedJobs.length - 3) {
            this.activeIndex++;
        }
    }

    get jobsToShow() {
        return this.recommendedJobs.slice(this.activeIndex, this.activeIndex + 3);
    }

    navigateToJobPage(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'searchJobs__c'
            }
        });
    }
}