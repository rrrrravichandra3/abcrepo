import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getPagesConfig from '@salesforce/apex/CcEmp_PagesConfiguration.getPagesConfig';
import TeTopBanner from '@salesforce/resourceUrl/TE_Top_Banner';

export default class CcEmpContainer extends LightningElement {
  currentPageReference;
  pagesConfig;
  menuItems;

  currentPageId;
  headerImgUrl = TeTopBanner;

  isCurrentPageReferenceLoaded = false;
  isPagesConfigLoaded = false;

  @wire(CurrentPageReference)
  wiredCurrentPageReference(currentPageReference) {
    if (!currentPageReference) {
      return;
    }

    this.currentPageReference = currentPageReference;
    this.isCurrentPageReferenceLoaded = true;

    this.setCurrentPage();
  }

  @wire(getPagesConfig)
  wiredPagesConfig({ data }) {
    if (!data) {
      return;
    }

    this.pagesConfig = data;

    this.setNavigationMenu();
    this.setLandingPage();

    this.isPagesConfigLoaded = true;

    this.setCurrentPage();
  }

  get isLoaded() {
    return this.isCurrentPageReferenceLoaded && this.isPagesConfigLoaded;
  }

  setNavigationMenu() {
    this.menuItems = [...this.pagesConfig]
      .sort((a, b) => (a.menuOrder > b.menuOrder ? 1 : -1))
      .map((page) => ({
        label: page.name,
        pageId: page.pageId,
        icon: page.icon,
      }));
  }

  setLandingPage() {
    this.landingPage = this.pagesConfig.find((page) => page.isLandingPage);
  }

  setCurrentPage() {
    if (!this.isLoaded) {
      return;
    }
    this.currentPageId = this.currentPageReference?.state?.c__page || this.landingPage?.pageId;
  }
}