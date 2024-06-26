import { LightningElement, api } from "lwc";
import TICK_ICON from "@salesforce/resourceUrl/tick";

export default class buttonTile extends LightningElement {
  @api buttonId;
  @api selected;
  iconSrc = TICK_ICON;
  @api ariaLabel;

  selectHandler(event) {
    if(event.which == 1 || event.which == 13 || event.which == 32){
    this.dispatchEvent(
      new CustomEvent("select", { bubbles: true, 
        composed: true,
        detail: { id: this.buttonId, selected: !this.selected }
      })
    );
    console.log('Are you bubbling?'+this.buttonId)
  }
}
  get tileClasses() {
    if (this.selected) {
      return "tile tile-selected slds-p-horizontal_x-small slds-p-vertical_medium slds-grid slds-grid_vertical-align-center slds-is-relative";
    }
    return "tile slds-p-horizontal_x-small slds-p-vertical_medium slds-grid slds-grid_vertical-align-center";
  } 
}