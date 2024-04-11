import { LightningElement, api } from 'lwc';

import { createSnippet } from './snippet';
import { isArray } from 'c/fdEmpObjectUtils';

import MANAGER_ONLY from '@salesforce/label/c.FdEmp_Manager_Only';

export default class FdEmpSearchResultTile extends LightningElement {
  label = {
    MANAGER_ONLY,
  };

  _result;

  urlName;
  title;
  body;
  hasBadges;
  regions;
  countries;
  isManagerOnly;

  @api
  get result() {
    return this._result;
  }

  set result(result) {
    if (this._result === result) {
      return;
    }

    // Input is immutable so we have to make a copy
    const sortArray = (array) => (isArray(array) ? Array.from(array).sort() : []);
    const hasBadges = (record) => record.isManagerOnly || record.regions?.length > 0 || record.countries?.length > 0;

    this._result = {
      ...result,
      body: createSnippet(result.body),
      countries: sortArray(result.countries),
      regions: sortArray(result.regions),
      hasBadges: hasBadges(result),
    };

    this.title = this._result.title;
    this.urlName = this._result.urlName;
    this.body = this._result.body;
    this.hasBadges = this._result.hasBadges;
    this.regions = this._result.regions;
    this.countries = this._result.countries;
    this.isManagerOnly = this._result.isManagerOnly;
  }
}