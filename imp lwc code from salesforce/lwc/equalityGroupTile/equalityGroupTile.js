import { LightningElement, api } from "lwc";

export default class EqualityGroupTile extends LightningElement {
  @api equalityGroup;

  selectHandler(event) {
    this.dispatchEvent(
      new CustomEvent("select", { detail: event.detail.id })
    );
  }

  get tileClasses() {
    if (this.equalityGroup.selected) {
      return "tile tile-selected slds-p-horizontal_x-small slds-p-vertical_medium slds-grid slds-grid_vertical-align-center slds-is-relative";
    }
    return "tile slds-p-horizontal_x-small slds-p-vertical_medium slds-grid slds-grid_vertical-align-center";
  }
}