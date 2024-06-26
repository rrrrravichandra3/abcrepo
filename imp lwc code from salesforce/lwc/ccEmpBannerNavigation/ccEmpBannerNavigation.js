import { LightningElement, api } from 'lwc';
import TeTopBanner from '@salesforce/resourceUrl/TE_SubHeader_Banner';
import BANNERNAVIGATION_TITLLE from '@salesforce/label/c.ccEmp_BannerNavigationTitle';
import { subscribeNavigation, publishNavigation } from 'c/ccEmpLmsUtil';

export default class CcEmpBannerNavigation extends LightningElement {
  headerImgUrl = TeTopBanner;
  bannerNavigationTitle = BANNERNAVIGATION_TITLLE;
  @api bannerNavigation;
  pageId;

  connectedCallback() {
    subscribeNavigation(this.handleNavigation.bind(this));
  }

  navigate(event) {
    const message = { pageId: event.target.dataset.page };
    publishNavigation(message);
  }

  handleNavigation(message) {
    if (message.navigationType && message.navigationType === 'headerNavigation') {
      this.pageId = message.pageId;
      const navigationItems = this.template.querySelectorAll('a');

      navigationItems.forEach((item) => {
        if (item.getAttribute('data-id') !== this.pageId) {
          item.classList.remove('active');
        } else {
          item.classList.add('active');
        }
      });
    }
  }
}