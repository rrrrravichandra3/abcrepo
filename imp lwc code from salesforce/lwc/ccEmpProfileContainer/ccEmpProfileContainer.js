import { LightningElement, wire } from 'lwc';
import getNavigationItem from '@salesforce/apex/CcEmp_PagesConfiguration.getNavigationItem';
import ccEmpViewAsHeading from '@salesforce/label/c.Cc_Emp_View_As_Heading';
import ccEmpMyProfileHeading from '@salesforce/label/c.Cc_Emp_My_Profile_Heading';
import ccEmpProfileCompletion from '@salesforce/label/c.Cc_Emp_Profile_Completion_Heading';
import ccEmpadd20Skills from '@salesforce/label/c.Cc_Emp_Add_20_Skill_Heading';
import ccEmpAddCerts from '@salesforce/label/c.Cc_Emp_Add_Cert_Heading';
import ccEmpCompleteCerts from '@salesforce/label/c.Cc_Emp_Complete_Exp_Heading';
import ccEmpFindMentor from '@salesforce/label/c.Cc_Emp_Find_Mentor_Heading';
import ccEmpAddProjects from '@salesforce/label/c.Cc_Emp_Add_Projects_Heading';

export default class CcEmpProfileContainer extends LightningElement {
  hasRendered = false;
  sectionLinks = [];
  viewAsValue = 'Everyone';
  selectedSectionId;
  componentConstructor;
  hasLoaded = false;
  componentInstances = [];

  label = {
    ccEmpViewAsHeading,
    ccEmpMyProfileHeading,
    ccEmpProfileCompletion,
    ccEmpadd20Skills,
    ccEmpAddCerts,
    ccEmpCompleteCerts,
    ccEmpFindMentor,
    ccEmpAddProjects,
  };

  get viewAsoptions() {
    return [
      { label: 'Everyone', value: '' },
      { label: 'Salesforce Employee', value: 'Salesforce Employee' },
      { label: 'Hiring Manager', value: 'Hiring Manager' },
    ];
  }

  @wire(getNavigationItem)
  wiredNavItems({ error, data }) {
    console.log('data', data);
    if (data) {
      this.sectionLinks = data.filter((item) => item.Navigation_Type__c === 'Profile Navigation');
      this.sectionLinks = JSON.parse(JSON.stringify(this.sectionLinks));
      this.loadComponent();
    } else if (error) {
      console.log(error, 'error message');
    }
  }

  renderedCallback() {
    if (!this.hasRendered) {
      this.hasRendered = true;
      const style = document.createElement('style');
      style.innerText = '@keyframes html-progress {to {--progress-value: 90;}';
      this.template.querySelector('.scriptContainer').appendChild(style);
    }
  }

  handleViewAsChange(event) {
    this.viewAsValue = event.detail.value;
  }

  async loadComponent() {
    let instance;
    /* eslint-disable no-await-in-loop */
    for (let i = 0; i < this.sectionLinks.length; i++) {
      this.sectionLinks[i].key = 'c_' + this.sectionLinks[i].DeveloperName;
      if (this.sectionLinks[i].LWC_Component_Name__c) {
        instance = await import('c/' + this.sectionLinks[i].LWC_Component_Name__c);
        this.componentInstances.push({
          instance: instance.default,
          key: this.sectionLinks[i].key,
        });
      }
    }
    /* eslint-enable no-await-in-loop */
    this.hasLoaded = true;
  }

  scrollToSction(event) {
    const key = event.target.dataset.key;
    const sideNavLinks = this.template.querySelectorAll('.sideNavLinks');
    sideNavLinks.forEach((item) => {
      if (item.getAttribute('data-key') !== key) {
        item.classList.remove('active');
      } else {
        item.classList.add('active');
      }
    });

    const targetDiv = this.template.querySelector('.' + key);
    if (targetDiv) {
      const targetRect = targetDiv.getBoundingClientRect();
      const offset = -100;

      window.scrollTo({
        top: targetRect.top + window.pageYOffset + offset,
        behavior: 'smooth',
      });
    }
  }
}