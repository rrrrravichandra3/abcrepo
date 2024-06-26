import { LightningElement, api } from "lwc";

export default class Ia_ControlAsButton extends LightningElement {
  @api label;
  @api url;
  @api asLink;
  @api containerAlignment;
  @api containerPadding;
  @api buttonWidth;

  // GETTERS/SETTERS:
  get getContainerAlignment() {
    return `text-align:${this.containerAlignment};`;
  }
  get getContainerPadding() {
    return `padding:${this.containerPadding}px;`;
  }
  get getButtonWidth() {
    return `width:${this.buttonWidth}px;`;
  }
  get getContainerStyles() {
    const align = this.getContainerAlignment;
    const padding = this.getContainerPadding;
    console.log("getContainerStyles:", align, padding);
    return `${align} ${padding}`;
  }
  get getButtonStyles() {
    const width = this.getButtonWidth;
    console.log("getButtonStyles:", width);
    return `${width}`;
  }
}