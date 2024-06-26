import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getWorkLocations from '@salesforce/apex/te_PreferencesController.getWorkLocations'


export default class Te_profileCard extends NavigationMixin(LightningElement) {
    @api contact;
    @api usr;
    @api skills;
    @api preferences;
    @track locationOptions;
    certList = ['cert1','cert2','cert3','cert4'];
    
    get options() {
        return [
            { label: 'Progress on my Role', value: 'Progress on my Role' },
            { label: 'Explore New Roles', value: 'Explore New Roles' },
        ];
    }
    connectedCallback(){
        this.getPathwayPicklistVals();
    }

    handleSaveSkills(event){
        console.log(event.detail.skillsListUpdated);
    }

    goToMentors(){
        window.open("https://dreamjobcentral.my.site.com/mentorfinder/s/");
    }

    navigateToProfile(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'p__c'
            }
        });
    }

    updatePathway(){

    }
    getPathwayPicklistVals(){
        getWorkLocations()
        .then(result => {
            let options = [];
            if (result) {
            result.forEach((r) => {
                options.push({ label: r, value: r });
            });
            }
            this.locationOptions = options;
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }
}