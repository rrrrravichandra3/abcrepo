import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import fdResources from '@salesforce/resourceUrl/FrontDeskCustom';
import home from '@salesforce/label/c.FdEmp_Front_Desk_Home';
import tickets from '@salesforce/label/c.FdEmp_Tickets_Header';
import saved from '@salesforce/label/c.FdEmp_Saved_Header';
import title from '@salesforce/label/c.FdEmp_Front_Desk_Header';
import getConfigurationValue from '@salesforce/apex/FdEmp_ConfigurationValue.getConfigurationValue';
import isSavedButtonDisplayEnabled from '@salesforce/apex/FdEmp_FeatureFlags.isSavedButtonDisplayEnabled';

const LOGO = {
  logo: `${fdResources}/images/Logo.svg`,
};

const ENTER = 13;
const HOME_PAGE_NAME = 'Home';

const className = 'fd-nav';

export default class FdEmpHeader extends NavigationMixin(LightningElement) {
  label = {
    home,
    tickets,
    saved,
    title,
  };

  logo = LOGO.logo;
  enabledFeatures = [];
  isSavedEnabled;
  ticketLink;
  error;

  @track notHomePage = true;

  get classList() {
    return `${className}__wrap${this.notHomePage ? '' : ` ${className}__wrap--home`}`;
  }

  handleHome(event) {
    if (event.type !== 'click' && !(event.type === 'keyup' && event.keyCode === ENTER)) {
      return;
    }

    event.preventDefault();

    try {
      this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
          name: HOME_PAGE_NAME,
        },
      });
    } catch (error) {
      console.error('Failed to navigate to home', error);
    }
  }

  @wire(getConfigurationValue, { configName: 'MyTicketLink' })
  getConfigurationValue({ error, data }) {
    if (data) {
      this.ticketLink = data;
    } else if (error) {
      this.error = error;
    }
  }

  @wire(isSavedButtonDisplayEnabled)
  isSavedButtonDisplayEnabled({ error, data }) {
    if (data) {
      this.isSavedEnabled = data;
    } else if (error) {
      this.error = error;
    }
  }

  @wire(CurrentPageReference)
  setNotHomePage({ attributes: { name } }) {
    this.notHomePage = name !== HOME_PAGE_NAME;
  }

  handleTicketClick() {
    if (this.ticketLink) {
      window.open(this.ticketLink, '_blank');
    }
  }
}