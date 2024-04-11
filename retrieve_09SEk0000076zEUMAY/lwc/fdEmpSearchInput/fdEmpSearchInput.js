import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import placeholder from '@salesforce/label/c.FdEmp_Search_Input_Placeholder';

export const SEARCH_MAX_LENGTH = 1000;

const className = 'fd-nav__search';

export default class FdEmpSearchInput extends NavigationMixin(LightningElement) {
  _term = '';

  maxlength = SEARCH_MAX_LENGTH;

  label = {
    placeholder,
  };

  @api type = 'default';

  @api
  get term() {
    return this._term;
  }

  get classList() {
    return `${className} ${className}--${this.type}`;
  }

  @wire(CurrentPageReference)
  routeSubHandler(pageRef) {
    // Only the search page will have a term in the state. Clear the search box everywhere else.
    this._term = this.cleanString(pageRef.state ? pageRef.state.term : '');
  }

  handleSearch(event) {
    event.preventDefault();

    const cleanedTerm = this.cleanString(this.template.querySelector('input')?.value);
    if (cleanedTerm) {
      try {
        this[NavigationMixin.Navigate]({
          type: 'standard__search',
          state: {
            term: cleanedTerm,
          },
        });
      } catch (error) {
        console.error('Failed to navigate to search page', error);
      }
    }
  }

  cleanString(value) {
    return (value || '').trim().replaceAll(/[<>&"]/g, '');
  }
}