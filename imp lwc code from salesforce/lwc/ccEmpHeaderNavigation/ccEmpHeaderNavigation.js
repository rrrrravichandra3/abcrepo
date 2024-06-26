import { LightningElement, api } from 'lwc';
import { subscribeNavigation, publishNavigation } from 'c/ccEmpLmsUtil';

export default class CcEmpHeaderNavigation extends LightningElement {
  @api headerNavigation;
  activeNav = 'Career_Connect';
  activeSubNav = 'onboarding';
  dropdownVisible = '';

  navigate(event) {
    event.preventDefault();

    this.activeNav = event.currentTarget.dataset.parentId;
    this.activeSubNav = event.currentTarget.dataset.pageId;
    const message = {
      parentId: this.activeNav,
      pageId: this.activeSubNav,
      navigationType: 'headerNavigation',
    };
    publishNavigation(message);
    console.log('message published');
  }

  toggleDropdown(event) {
    event.stopPropagation(); // Stop click event from propagating to outer elements
    const clickedKey = event.target.dataset.key;
    this.dropdownVisible = this.dropdownVisible === clickedKey ? '' : clickedKey;
  }

  get updatedHeaderNavigation() {
    return this.headerNavigation.map((item) => ({
      ...item,
      className: item.DeveloperName === this.activeNav ? 'active' : '',
      isVisible: item.DeveloperName === this.dropdownVisible,
      subnavigationItems:
        item.subnavigationItems?.map((subItem) => ({
          ...subItem,
          className: subItem.pageId === this.activeSubNav ? 'active-sub' : '',
        })) || [],
    }));
  }

  connectedCallback() {
    document.addEventListener('click', this.handleOutsideClick.bind(this));
  }

  disconnectedCallback() {
    document.removeEventListener('click', this.handleOutsideClick.bind(this));
  }

  handleOutsideClick(event) {
    if (!this.template.querySelector('.navigation-menu').contains(event.target)) {
      this.dropdownVisible = ''; // Close all dropdowns
    }
  }

  renderedCallback() {
    subscribeNavigation(this.handleNavigation.bind(this));
  }

  handleNavigation(message) {
    if (message.navigationType && message.navigationType === 'headerNavigation') {
      this.activeNav = message.parentId ? message.parentId : this.activeNav;
      this.activeSubNav = message.pageId ? message.pageId : this.activeSubNav;
    }
  }
}