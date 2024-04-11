import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FdEmpSupportTile extends NavigationMixin(LightningElement) {
  @api link;
  @api icon;
  @api label;
  @api internal;

  handleSupportTileClick() {
    const isInternalArticle = this.internal;
    const articleUrl = this.link;

    const navigationAttributes = {};
    if (isInternalArticle) {
      navigationAttributes.type = 'standard__knowledgeArticlePage';
      navigationAttributes.attributes = {
        urlName: this.link,
      };
    } else {
      navigationAttributes.type = 'standard__webPage';
      navigationAttributes.attributes = {
        url: articleUrl,
      };
    }
    this[NavigationMixin.Navigate](navigationAttributes);
  }
}