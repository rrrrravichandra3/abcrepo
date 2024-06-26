import { LightningElement,api,track} from 'lwc';
import getEmployeeContactData from '@salesforce/apex/te_GrowthAppService.getEmployeeContactData';
import getPreferences from '@salesforce/apex/te_PreferencesController.getPreferences';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'c/resourceLoader';

import getCareerPaths from '@salesforce/apex/talentMP_CareerPathing.getCareerPaths';

import getTradiationalCareerPath from '@salesforce/apex/talentMP_CareerPathing.getTradiationalCareerPath';

import getContactJobProfile from '@salesforce/apex/talentMP_CareerPathing.getContactJobProfile';

import careerPathCardModal from 'c/talentMp_careerPathCard';


export default class TeCareerPathing extends LightningElement {
  
    d3Initialized = false;

    @api contactId;
    @api contact;
    @api preferences;
    @api skillList;
    @api usr;
    @track showSpinner = false;

    @api futureJobsList;


    @api currentJob;

    @track likeState1 = false;

    @track futureJobs =[];

    futureJobCodeSelected = '';

    async renderedCallback() {

      if (this.d3Initialized) {
        return;
      }
      this.d3Initialized = true;
      try {
          await Promise.all([
              loadScript('https://d3js.org/d3.v7.min.js'),
              loadScript('https://cdn.jsdelivr.net/npm/d3-org-chart@3'),
              loadScript('https://cdn.jsdelivr.net/npm/d3-flextree@2.1.2/build/d3-flextree.js')
          ]);
        
      } catch (error) {
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error loading D3',
                  message: error.message,
                  variant: 'error'
              })
          );
      }
  }

  handleJobClick(event){
    console.log("Event Entered")
    let jobId = event.target.value;
    this.futureJobCodeSelected = '';
    for(let jobs of this.futureJobs){
      if(jobId == jobs.value){
        jobs.isJobSelected = true;
        this.futureJobCodeSelected = jobId;
      }else{
        jobs.isJobSelected = false;
      }
    }
    
    this.initializeD3();

  }

  async initializeD3() {

    var chart = null;

    this.showSpinner = true;
    console.log('calling d3');
    getTradiationalCareerPath().then((data) => {
    //getCareerPaths({currentJobCode:this.currentJob.Job_Code__c,futureLateralJobCode:this.futureJobCodeSelected}).then((data) => {
      console.log("D3 Org inside org fecth")
      console.log(data);
     
      chart = new d3.OrgChart()
      .nodeHeight((d) => 85 + 25)
      .nodeWidth((d) => 220 + 2)
      .childrenMargin((d) => 50)
      .compactMarginBetween((d) => 35)
      .compactMarginPair((d) => 30)
      .neighbourMargin((a, b) => 20)
      .nodeContent(function (d, i, arr, state) {
      
        if(d.data.parentId == null){
          return `
          <div style='width:${
            d.width
              }px;height:${d.height}px;'>
  
              <article class="slds-card">
              <div>
                <span class="slds-text-body_small slds-badge slds-theme_success" style="margin:-20px 50px -10px 50px;">Current Job</span>
              </div>
              <div class="slds-card__body slds-card__body_inner slds-text-title_bold">${
                d.data.jobName
              }</div>

              <div class="slds-card__body slds-card__body_inner slds-text-title_bold">${
                d.data.frequency
              }</div>
                <footer class="slds-card__footer"></footer>
              </article>
            </div>
        `;
        }else{
          return `
        <div style='width:${
          d.width
            }px;height:${d.height}px;'>

            <article class="slds-card">
            <div style="padding:5px 10px">
                
              </div>
            <div class="slds-card__body slds-card__body_inner slds-text-title_bold">${
              d.data.jobName
            }</div>

            <div class="slds-card__body slds-card__body_inner slds-text-title_bold">${
              d.data.frequency
            }</div>
              
              <footer class="slds-card__footer"></footer>
            </article>
          </div>
        `;
        }
        
      })
      .container(this.template.querySelector('.chart-container'))
      .data(data)
      .layout('left')
      .compact(true) 
      .render().fit();

      chart.expandAll().fit();

      chart.compact(true).render().fit();

      this.showSpinner = false;

    });

}

  

connectedCallback(){

  getContactJobProfile({contactId: this.contactId}).then((result) => {

    console.log(result['CurrentJob'][0]);

    this.currentJob = result['CurrentJob'][0];

    let futureJobsFromMap = result['FutureJob'];

    console.log('current jobs');
    console.log(this.currentJob);
    console.log(futureJobsFromMap);

    for(let job of futureJobsFromMap){
      
      if((job.Job_Category__c != this.currentJob.Job_Category__c) && (Number(job.Job_Grade__c) == Number(this.currentJob.Job_Grade__c) || Number(job.Job_Grade__c) == Number(this.currentJob.Job_Grade__c)+1)){
        if(job.Job_Category__c  == 'C'){
          this.futureJobs= [...this.futureJobs,{'label':job.Name,'value':job.Job_Code__c,'grade':job.Job_Grade__c,'level':'Profressional','isManager':false,'isJobSelected':false}];
        }else if(job.Job_Category__c  == 'P'){
          this.futureJobs= [...this.futureJobs,{'label':job.Name,'value':job.Job_Code__c,'grade':job.Job_Grade__c,'level':'Management','isManager':true,'isJobSelected':false}];
        }
        
      }
    }

    console.log('Future Jobs'+this.futureJobs);

    this.initializeD3();

  }).catch((error) => {
    console.log(error);
  });
  

  




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
      }
  
      getPreferenceData(){
        getPreferences()
          .then(result => {
              console.log(result);
              this.preferences = result;
          })
          .catch(error => {
              console.error('Error:', error);
          });
      }

      setCurrentJob(event){
        this.futureJobCodeSelected = '';

        this.futureJobCodeSelected = event.detail.value[0];

        this.initializeD3();

      }

      async handleClick() {
        const result = await careerPathCardModal.open({
            // `label` is not included here in this example.
            // it is set on lightning-modal-header instead
            size: 'large'

        });
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log(result);
      }


    get rootNodes() {
        // Identify root nodes by checking for nodes with no parents
        console.log('roots ------> ' +Object.keys(this.graph).filter(nodeId => !this.graph[nodeId].parents || this.graph[nodeId].parents.length === 0))
        return Object.keys(this.graph).filter(nodeId => !this.graph[nodeId].parents || this.graph[nodeId].parents.length === 0);
    }
}