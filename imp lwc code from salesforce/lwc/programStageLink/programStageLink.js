import { LightningElement, api } from "lwc";

export default class ProgramStageLink extends LightningElement {
  @api link;
  @api label;

  goToClick = (event) => {
    if(event.which == 1 || event.which == 13 || event.which == 32){
      
    window.open(this.link, "_blank").focus();
    }

  };
};