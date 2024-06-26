import { LightningElement, track, api } from 'lwc';
import TE_Top_Banner from "@salesforce/resourceUrl/TE_Top_Banner"
import getEmployeeContactData from '@salesforce/apex/te_GrowthAppService.getEmployeeContactData';
import getPreferences from '@salesforce/apex/te_PreferencesController.getPreferences';
import getWorkLocations from '@salesforce/apex/te_PreferencesController.getWorkLocations';
import updatePreferences from '@salesforce/apex/te_PreferencesController.updatePreferences';
import getRelocationOptions from '@salesforce/apex/te_PreferencesController.getRelocationOptions';

export default class Growth extends LightningElement {
    @api contact;
    @api preferences;
    @api skillList;
    @api usr;
    @track locationOptions;
    @track relocationOptions;
    @track isLoading = false;
    headerImgUrl = TE_Top_Banner;
    isOpenToRelocate;

    connectedCallback(){
      getEmployeeContactData()
        .then((result) => {
          this.contact = result.contact;
          this.skillList = result.skillList;
          this.usr = result.usr;
        })
        .catch((error) => {
          console.log(error);
        });
      this.getPreferenceData();
      this.getPathwayPicklistVals();
      this.getRelocationOptions();
    }

    getPreferenceData(){
      getPreferences()
        .then(result => {
            this.isOpenToRelocate = result.Open_to_Relocation__c;
            console.log(result);
            this.preferences = result;
        })
        .catch(error => {
            console.error('Error:', error);
        });
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

  getRelocationOptions(){
    getRelocationOptions()
    .then(result => {
        let options = [];
        if (result) {
        result.forEach((r) => {
            options.push({ label: r, value: r });
        });
        }
        this.relocationOptions = options;
    })
    .catch(error => {
        console.error('Error:', error);
    });
}

  handleClick(){
    this.isLoading = true;
    updatePreferences({preferences: this.preferences})
    .then((result) => {
      this.preferences = result;
      console.log('this.preferences'+JSON.stringify(this.preferences));
      this.isLoading = false;
      this.template.querySelector("c-te-career-path-cmp").reRunJobRecommendations();
    })
    .catch((error) => {
      this.isLoading = false;
      console.log(error);
    });
  }

  handleRelocationChange(event){
    console.log(event.detail);
    this.isOpenToRelocate = event.detail.checked;
    this.preferences.Open_to_Relocation__c = event.detail.checked;
  }

  handleLocationChange(event){
    console.log(event.detail);
    this.preferences.Preferred_Work_Location__c = event.detail.value;
  }

  handleRelocationCountryChange(event){
    this.preferences.Relocation_Country__c = event.detail.value;
  }
}