import { LightningElement, api } from 'lwc';
// import getEmployeeContactData from '@salesforce/apex/te_GrowthAppService.getEmployeeContactData';

export default class CcEmpGeneralPageDetail extends LightningElement {
  @api contact;
  @api usr;

  connectedCallback() {
    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.contact = {
      Department: '7435-IT Applications Hyderabad',
      Email: 'pkanani@salesforce.dev',
      ES_DJC_Work_Location__c: 'India - Hyderabad',
      EmployeeNumber__c: '812955',
      Job_Code__c: '1239',
      FirstName: 'Priyanka',
      Job_Family__c: 'Core Software Engineering',
      Title: 'Software Engineering MTS',
      ES_DJC_Grade__c: 'COMP_GRADE_06',
      Id: '003AE0000016q3RYAQ',
      LastName: 'Kanani',
      Segment__c: 'Software Engineering',
    };
    // business-innovation-1305.scratch.file.force.com/profilephoto/729O1000000TzBN/F
    // https://business-innovation-1305.scratch.file.force.com/profilephoto/729O1000000TzBN/F
    // https://dreamjobcentral--pfdev16.sandbox.file.force.com/profilephoto/729AE0000001IKf/F
    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.usr = {
      FullPhotoUrl: '/sfsites/c/profilephoto/729O1000000VWYH/F',
      Id: '0054u000007fGPOAA2',
    };
    /*  getEmployeeContactData()
        .then((result) => {
          this.contact = result.contact;
        //  this.skillList = result.skillList;
          this.usr = result.usr;
        })
        .catch((error) => {
          console.log(error);
        });
    }*/
  }
}