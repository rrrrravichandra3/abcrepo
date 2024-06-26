import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { CurrentPageReference } from "lightning/navigation";
export default class CsNavItem extends NavigationMixin(LightningElement) {
  @api iconName;
  @api theURL;
  @api title;

  @wire(CurrentPageReference)
  pageRef;

  goToUrl = () => {
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: this.theURL
      }
    });
  };

  get color() {
    const pageName = this.pageRef.attributes.pageName;
    if (pageName === this.theURL) {
      return "#006BC8";
    }
    return "#706e6b";
  }

  get textClasses() {
    const pageName = this.pageRef.attributes.pageName;
    if (pageName === this.theURL) {
      return "text-holder blue";
    }
    return "text-holder";
  }
}