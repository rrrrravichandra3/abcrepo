import { LightningElement } from 'lwc';
import einsteinImage from '@salesforce/resourceUrl/TE_Einstein3D';
import { publishNavigation } from 'c/ccEmpLmsUtil';

export default class CcEmpProfileCompletionScreen extends LightningElement {
  einsteinImage = einsteinImage;
  allc;

  checklistItems = [
    {
      id: 'acknowledgeAI',
      label: 'I acknowledge this platform uses AI that can sometimes produce inaccurate or harmful content.',
      checked: false,
    },
    {
      id: 'authorizeAI',
      label: 'I authorize the use of AI to serve me Jobs, Mentors, Learnings and Gigs suggestions.',
      checked: false,
    },
    {
      id: 'consentData',
      label: 'I consent for the platform to track anonymized data (not reported individually).',
      checked: false,
    },
  ];

  handleCheckboxChange(event) {
    const itemId = event.target.dataset.id;
    const isChecked = event.target.checked;

    this.checklistItems = this.checklistItems.map((item) => {
      if (item.id === itemId) {
        return { ...item, checked: isChecked };
      }
      return item;
    });
    console.log('publish a msg from demo component');
    const payload = { getStartedDisabled: this.isGetStartedDisabled, navigationType: 'profileCompletion' };
    publishNavigation(payload);
    event.preventDefault();
    console.log('stopped event prop');
  }

  get isGetStartedDisabled() {
    return this.checklistItems.some((item) => !item.checked);
  }
}