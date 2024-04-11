import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { FdShActionHandlerFactory } from 'c/fdShActionHandlerFactory';

export default class fdBndlBundle extends NavigationMixin(LightningElement) {
  @track isDropdownOpen = false;
  @api categoryTitle;
  @api categoryButtons = [];
  @api categoryLinks = [];
  @track mappedCategoryButtons;
  @track mappedCategoryLinks;

  connectedCallback() {
    this.mappedCategoryButtons = this.categoryButtons.map((value, index) => {
      return {
        ...value,
        index: index,
        variant: index % 2 === 0 ? 'primary' : 'secondary',
        style: index % 2 === 0 ? '--sds-c-icon-color-foreground:white' : '',
      };
    });
    this.mappedCategoryLinks = this.categoryLinks.map((value, index) => {
      return {
        ...value,
        index: index,
        isLastItem: index === this.categoryLinks.length - 1,
      };
    });
  }

  handleDropdownClick() {
    this.isDropdownOpen = !this.isDropdownOpen;
  }

  handleBlur() {
    this.isDropdownOpen = false;
  }

  async sendToLink(event) {
    let link;
    event.preventDefault();
    try {
      const index = event.target.dataset.index;
      if (event.target.dataset.link) {
        link = this.mappedCategoryLinks[index];
      } else {
        link = this.mappedCategoryButtons[index];
      }
      const actionAttributes = {};
      const factory = new FdShActionHandlerFactory(this);
      const _this = this;
      const wrapperFn = function (...args) {
        return _this[NavigationMixin.Navigate].bind(_this, ...args);
      };
      const boundFunction = wrapperFn();
      actionAttributes.navigationFunction = boundFunction;
      actionAttributes.actionType = link.type === 'SEARCH' ? 'URL' : link.type;
      actionAttributes.formId = link.formId;
      actionAttributes.target = link.type === 'SEARCH' ? '/search/' + link.searchterm : link.URL;
      actionAttributes.source = link.org;
      await factory.createHandlerAndHandleAction(actionAttributes);
    } catch (error) {
      console.error(`Error occurred while getting action by Id: ${event.target.dataset.index}. Caused by: ${error}`);
    }
  }
}