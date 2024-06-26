import { LightningElement, api } from "lwc";

export default class ProgramStageNavItem extends LightningElement {
  @api stage;
  

  navItemClick = (event) => {
    //console.log("navItemClick: ", event.target.dataset.stageid);
    if(event.which == 1 || event.which == 13 || event.which == 32){
    this.dispatchEvent(
      new CustomEvent("navitemclick", {
        detail: { selected: event.target.dataset.stageid },
      })
    );
  };
};

  get listClasses() {
    if (this.stage?.programStage?.Active) {
      return "slds-nav-vertical__item slds-is-active";
    }
    return "slds-nav-vertical__item";
  }
}