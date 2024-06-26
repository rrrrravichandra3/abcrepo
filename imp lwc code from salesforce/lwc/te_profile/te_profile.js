import { LightningElement,api } from 'lwc';
import TE_Top_Banner from "@salesforce/resourceUrl/TE_Top_Banner"
import getEmployeeContactData from '@salesforce/apex/te_GrowthAppService.getEmployeeContactData';
import getPreferences from '@salesforce/apex/te_PreferencesController.getPreferences';

export default class Te_profile extends LightningElement {
    @api contact;
    @api preferences;
    @api skillList;
    @api usr;
    headerImgUrl = TE_Top_Banner;
    
    data = [
      {id: '1',title: 'Software Engineering LMTS', org: 'Salesforce', date: 'Feb 2022 - Present', description: 'Blah blah'},
      {id: '2',title: 'Software Engineering SMTS', org: 'Salesforce', date: 'Aug 2020 - Feb 2022', description: 'Blah blah'},
      {id: '3',title: 'Software Engineering MTS', org: 'Salesforce', date: 'Jul 2019 - Aug 2020', description: 'Blah blah'}
    ];

    columns = [
      { label: 'Title', fieldName: 'title' },
      { label: 'Organization', fieldName: 'org' },
      { label: 'Date', fieldName: 'date' }
    ];

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
      console.log(this.data);
      console.log(this.columns);
    }

    handleSaveSkills(event){
      console.log(event.detail.skillsListUpdated);
    }

    getPreferenceData(){
      getPreferences()
        .then(result => {
            this.preferences = result;
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }

    handleGeneration(){
      console.log('click');
    }
}