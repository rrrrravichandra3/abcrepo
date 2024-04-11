import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { format } from 'c/fdEmpStringUtils';

import { QnaAnswerEntityParser } from './qnaAnswerEntityParser';

import ARIA_EINSTEIN_RESULT from '@salesforce/label/c.FdEmp_Aria_Einstein_Result';
import DISCLAIMER from '@salesforce/label/c.FdEmp_Einstein_Generative_AI_Disclaimer';
import SOURCE_ARTICLE_SINGULAR from '@salesforce/label/c.FdEmp_Einstein_Generative_AI_Source_Article_Singular';
import SOURCE_ARTICLE_PLURAL from '@salesforce/label/c.FdEmp_Einstein_Generative_AI_Source_Article_Plural';

export default class FdEmpSearchGeneratedAnswer extends NavigationMixin(LightningElement) {
  label = {
    ARIA_EINSTEIN_RESULT,
    DISCLAIMER,
  };

  _entity;

  answerHtml = null;
  answerSources = [];

  get sourceCountTitle() {
    if (!this.answerSources) {
      return null;
    }

    const count = this.answerSources.length;
    const pattern = count === 1 ? SOURCE_ARTICLE_SINGULAR : SOURCE_ARTICLE_PLURAL;
    return format(pattern, count);
  }

  @api
  get entity() {
    return this._entity;
  }

  set entity(entity) {
    if (this._entity === entity) {
      return;
    }

    const parser = new QnaAnswerEntityParser();

    try {
      this.answerHtml = parser.parseAnswerHtml(entity);
      this.answerSources = parser.parseAnswerSources(entity);
    } catch (e) {
      console.error(e.message);
      this.answerHtml = null;
      this.answerSources = null;
    }

    this._entity = entity;
  }

  handleNavigate(event) {
    if (event.type !== 'click' && !(event.type === 'keyup' && event.keyCode === 13)) {
      return;
    }

    const urlName = event.target?.getAttribute('data-generated-source-url-name');
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
}