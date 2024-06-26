import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getNavigationItem from '@salesforce/apex/CcEmp_PagesConfiguration.getNavigationItem';
import { subscribeNavigation } from 'c/ccEmpLmsUtil';
import TeTopBanner from '@salesforce/resourceUrl/TE_Top_Banner';

export default class CcEmpContainer extends LightningElement {
  @api currentPageReference;
  @api currentPageId;
  @api headerNavigation = {};
  @api bannerNavigation = [];
  headerImgUrl = TeTopBanner;
  isCurrentPageReferenceLoaded = false;
  isPagesConfigLoaded = false;

  handleNavigation(message) {
    console.log('container', message);
    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    if (message.navigationType && message.navigationType === 'headerNavigation') {
      // eslint-disable-next-line @lwc/lwc/no-api-reassignments
      this.currentPageId = message.pageId;
    }
  }

  renderedCallback() {
    subscribeNavigation(this.handleNavigation.bind(this));
  }

  @wire(CurrentPageReference)
  wiredCurrentPageReference(currentPageReference) {
    if (!currentPageReference) {
      return;
    }

    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.currentPageReference = currentPageReference;
    this.isCurrentPageReferenceLoaded = true;
  }

  @wire(getNavigationItem)
  wiredNavItems({ data }) {
    if (!data) {
      return;
    }
    // console.log('data nav ',data);
    this.transformJSON(data);
    this.setLandingPage();
    this.isPagesConfigLoaded = true;
  }

  transformJSON(links) {
    const data = links.filter(
      (item) => item.Navigation_Type__c !== 'Profile Navigation' && item.Navigation_Type__c !== 'Onboarding Navigation'
    );
    // Iterate through JSON data
    data.forEach((item) => {
      const currentHeaderNavItem = {
        Label: item.Label,
        DeveloperName: item.DeveloperName,
        parentId: item.ParentId__c,
        isLandingPage: item.IsLandingPage__c,
        isActive: item.IsActive__c,
        pageId: item.PageId__c,
        isVisible: false,
        className: '',
        subnavigationItems: [],
      };
      if (item.Navigation_Type__c === 'Header Navigation' && !item.ParentId__c) {
        if (!Object.prototype.hasOwnProperty.call(this.headerNavigation, item.DeveloperName)) {
          this.headerNavigation[item.DeveloperName] = {};
        }

        if (
          this.headerNavigation[item.DeveloperName].subnavigationItems &&
          this.headerNavigation[item.DeveloperName].subnavigationItems.length > 0
        ) {
          currentHeaderNavItem.subnavigationItems = this.headerNavigation[item.DeveloperName].subnavigationItems;
        }
        this.headerNavigation[item.DeveloperName] = currentHeaderNavItem;
      } else if (item.Navigation_Type__c === 'Banner Navigation' && !item.ParentId__c) {
        this.bannerNavigation.push(currentHeaderNavItem);
      } else {
        if (!Object.prototype.hasOwnProperty.call(this.headerNavigation, item.ParentId__c)) {
          this.headerNavigation[item.ParentId__c] = { subnavigationItems: [] };
        }
        if (item.ParentId__c && Object.prototype.hasOwnProperty.call(this.headerNavigation, item.ParentId__c)) {
          this.headerNavigation[item.ParentId__c].subnavigationItems.push(currentHeaderNavItem);
        }
      }
    });
    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.headerNavigation = Object.values(this.headerNavigation);
  }

  get isLoaded() {
    return this.isCurrentPageReferenceLoaded && this.isPagesConfigLoaded;
  }

  setLandingPage() {
    let landingPage = null;
    for (const navItem of this.headerNavigation) {
      if (navItem.subnavigationItems) {
        // Search for the landing page in subnavigationItems
        landingPage = navItem.subnavigationItems.find((subPage) => subPage.isLandingPage);
        if (landingPage) {
          // If a landing page is found in subnavigation, stop searching
          break; // Exit the loop since we've found our landing page
        }
      }
    }

    this.landingPage = landingPage;
  }

  get showBanner() {
    return this.currentPageId !== 'profile' && this.currentPageId !== 'onboarding';
  }
}