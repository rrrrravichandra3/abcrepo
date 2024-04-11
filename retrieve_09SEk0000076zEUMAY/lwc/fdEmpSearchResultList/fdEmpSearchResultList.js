import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { format } from 'c/fdEmpStringUtils';
import { KnowledgeSearchObjectsParser } from './searchObjectsParser';

import ARIA_SEARCH_RESULTS from '@salesforce/label/c.FdEmp_Aria_Search_Results';
import RESULT_COUNT_SINGULAR from '@salesforce/label/c.FdEmp_Search_Result_Count_Singular';
import RESULT_COUNT_PLURAL from '@salesforce/label/c.FdEmp_Search_Result_Count_Plural';

export function getResultCount(searchObjects) {
  const searchResults = new KnowledgeSearchObjectsParser().getResults(searchObjects);
  return !searchResults ? 0 : searchResults.length;
}

export default class FdEmpSearchResultList extends NavigationMixin(LightningElement) {
  label = {
    ARIA_SEARCH_RESULTS,
  };

  error;

  _searchObjects;

  searchResults = [];
  searchResultTitle = '';

  @api
  get searchObjects() {
    return this._searchObjects;
  }

  set searchObjects(searchObjects) {
    if (searchObjects === this._searchObjects) {
      return;
    }

    this.searchResults = this.parseSearchObjects(searchObjects) || [];

    const count = this.searchResults.length;
    const pattern = count === 1 ? RESULT_COUNT_SINGULAR : RESULT_COUNT_PLURAL;
    this.searchResultTitle = format(pattern, count);

    this._searchObjects = searchObjects;
  }

  handleNavigate(event) {
    if (event.type !== 'click' && !(event.type === 'keyup' && event.keyCode === 13)) {
      return;
    }

    const urlName = event.target?.getAttribute('data-result-url-name');
    if (!urlName) {
      return;
    }

    event.preventDefault();

    try {
      this[NavigationMixin.Navigate]({
        type: 'standard__knowledgeArticlePage',
        attributes: {
          urlName: urlName,
        },
      });
    } catch (error) {
      console.error(`Failed to navigate to ${urlName}`, error);
    }
  }

  parseSearchObjects(searchObjects) {
    try {
      return new KnowledgeSearchObjectsParser().parse(searchObjects);
    } catch (e) {
      this.error = e;
      return [];
    }
  }
}