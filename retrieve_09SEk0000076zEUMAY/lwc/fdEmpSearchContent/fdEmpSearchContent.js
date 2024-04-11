import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import lang from '@salesforce/i18n/lang';

import { isString, isNumber, isObject } from 'c/fdEmpObjectUtils';

import fdResources from '@salesforce/resourceUrl/FrontDeskCustom';
import LOADING from '@salesforce/label/c.FdEmp_Search_Loading';
import NO_RESULT_TITLE from '@salesforce/label/c.FdEmp_Search_No_Result_Title';
import NO_RESULT_INFO from '@salesforce/label/c.FdEmp_Search_No_Result_Info';

// searchByKeyword is not using the Continuation search because we want to return the articles list as fast as possible,
// whereas generated answer results may come back a bit later
import searchByKeyword from '@salesforce/apex/FdEmp_KnowledgeSearchController.performSearch';
import searchGeneratedAnswer from '@salesforce/apexContinuation/FdEmp_KnowledgeSearchController.performSearchAsync';

import { SEARCH_MAX_LENGTH } from 'c/fdEmpSearchInput';
import { getResultCount } from 'c/fdEmpSearchResultList';

const OFFSET_DEFAULT = 0;
const PAGE_SIZE_DEFAULT = 15;

const SEARCH_MIN_LENGTH = 2;

export default class FdEmpSearchContent extends NavigationMixin(LightningElement) {
  _term;
  _lang = lang;
  _offset = OFFSET_DEFAULT;
  _pageSize = PAGE_SIZE_DEFAULT;
  _searchType = {
    KW: 'KW',
    QA: 'QA',
  };

  label = {
    LOADING,
    NO_RESULT_TITLE,
    NO_RESULT_INFO,
  };

  noResultsImage = `${fdResources}/images/rocks.png`;

  errors = null;
  @track generatedAnswerEntity = null;
  @track keywordSearchObjects = null;

  get isLoading() {
    // generatedAnswerEntity is optional
    return this.keywordSearchObjects === null && this.errors === null;
  }

  get hasNoResults() {
    return this.keywordSearchObjects !== null && this.keywordSearchObjects.length === 0 && this.errors === null;
  }

  @wire(CurrentPageReference)
  setCurrentPageReference(pageRef) {
    const term = (pageRef?.state?.term || '').trim();

    // Only re-execute search when the term has changed
    if (term !== this._term) {
      this._term = term;

      this.reset();
      this.updateSearch();
    }
  }

  async updateSearch() {
    const params = {
      query: this._term,
      lang: this._lang,
      offset: this._offset,
      pageSize: this._pageSize,
    };
    if (!isString(params.query) || !isString(params.lang) || !isNumber(params.offset) || !isNumber(params.pageSize)) {
      console.error(`Invalid params: ${JSON.stringify(params)}`);
      this.handleNoResults();
      return;
    }
    if (params.query.length < SEARCH_MIN_LENGTH || params.query.length > SEARCH_MAX_LENGTH) {
      this.handleNoResults();
      return;
    }

    searchByKeyword({ ...params, searchType: this._searchType.KW })
      .then((data) => this.handleSearchData(data))
      .catch((error) => this.handleError(error));

    searchGeneratedAnswer({ ...params, searchType: this._searchType.QA })
      .then((data) => this.handleQnaAnswer(data))
      .catch((error) => {
        console.log(JSON.stringify(error));
      });
  }

  handleQnaAnswer(data) {
    const result = JSON.parse(data);
    this.generatedAnswerEntity = result?.qnaAnswer?.entity;
  }

  handleSearchData(data) {
    if (!data) {
      this.handleError(new Error('No data returned from search'));
      return;
    }

    if (!isObject(data)) {
      this.handleError(new Error('Invalid data returned from search'));
      return;
    }

    if (data.error) {
      this.handleError(data.error);
      return;
    }

    this.keywordSearchObjects =
      getResultCount(data.keywordBasedAnswer?.searchObjects) > 0 ? data.keywordBasedAnswer.searchObjects : [];
    this.generatedAnswerEntity = data.qnaAnswer?.entity;
    this.errors = null;
  }

  handleNoResults() {
    this.errors = null;
    this.keywordSearchObjects = [];
    this.generatedAnswerEntity = null;
  }

  handleError(error) {
    this.errors = [error];
    this.keywordSearchObjects = null;
    this.generatedAnswerEntity = null;
  }

  reset() {
    this.errors = null;
    this.keywordSearchObjects = null;
    this.generatedAnswerEntity = null;
  }
}