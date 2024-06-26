import { LightningElement, api } from "lwc";

export default class BackButton extends LightningElement {
  @api heading;

  backClickedHandler() {
    window.history.back();
  }

  get isMobile() {
    return screen.width <= 768;
  }

  get classes() {
    return this.isMobile
      ? "slds-p-horizontal_small slds-p-vertical_x-small slds-theme_default slds-grid slds-grid_vertical-align-center"
      : "slds-p-horizontal_small slds-p-vertical_x-small slds-grid slds-grid_vertical-align-center";
  }
}