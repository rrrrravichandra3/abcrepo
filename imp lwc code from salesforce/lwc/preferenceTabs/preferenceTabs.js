import { LightningElement, api } from 'lwc';

export default class preferenceTabs extends LightningElement {
  @api activeTab;

  @api label1;
  @api label2;

  changeTabHandler(event) {
    this.activeTab = event.target.dataset.tab;
  }

  get showTab1() {
    return this.activeTab === "tab1" || !this.activeTab;
  }

  get tab1Classes() {
    return this.activeTab === "tab1"
      ? "slds-tabs_default__item slds-is-active slds-size_1-of-2"
      : "slds-tabs_default__item slds-size_1-of-2";
  }

  get tab2Classes() {
    return this.activeTab === "tab2"
      ? "slds-tabs_default__item slds-is-active slds-size_1-of-2"
      : "slds-tabs_default__item slds-size_1-of-2";
  }

}