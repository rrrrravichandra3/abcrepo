import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTrendingArticles from '@salesforce/apex/FdEmp_TrendingArticlesController.getTrendingArticles';
import lang from '@salesforce/i18n/lang';

export default class FdEmpTrendingArticles extends NavigationMixin(LightningElement) {
  articles;
  isDataLoaded = false;

  @wire(getTrendingArticles, { language: lang })
  wiredArticles({ error, data }) {
    if (data) {
      this.articles = data;
      this.isDataLoaded = true;
    } else if (error) {
      this.isDataLoaded = false;
    }
  }

  handleTrendingArticleLinkClick(event) {
    this[NavigationMixin.Navigate]({
      type: 'standard__knowledgeArticlePage',
      attributes: {
        urlName: event.currentTarget.dataset.url,
      },
    });
  }
}