import { LightningElement, api } from 'lwc';

export default class CircleLogo extends LightningElement {
  @api imageUrl;

  get backgroundImage() {
    return `background-image: url(${this.imageUrl})`;
  }
}