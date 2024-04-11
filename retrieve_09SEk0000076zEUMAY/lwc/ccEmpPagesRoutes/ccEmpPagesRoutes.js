import { LightningElement, api } from 'lwc';

export default class CcEmpPagesRoutes extends LightningElement {
  @api currentPageId;

  get isJobsPage() {
    return this.currentPageId === 'jobsRecom' ? true : false;
  }

  get isCareerPage() {
    return this.currentPageId === 'careerPath' ? true : false;
  }

  get isJobSearchPage() {
    return this.currentPageId === 'jobsSearch' ? true : false;
  }

  get isEinsteinGPT() {
    return this.currentPageId === 'einsteinGPT' ? true : false;
  }
}