import { api } from 'lwc';
import WesCardNative from 'c/wesCardNative';
import WesComponentWrapper from 'c/wesComponentWrapper';

// this is required or the object throws an exception if instantiation is attempted
customElements.define('wes-card', WesCardNative);

export default class WesCard extends WesComponentWrapper {
  @api direction;
  @api media;
  @api depth;

  _wesCardNative;
  
  _rendered = false;

  renderedCallback() {
    if (!this._rendered) {
      this._wesCardNative = new WesCardNative();
    }
    this.reparentWesComponent(this._wesCardNative, {
      direction: this.direction,
      media: this.media,
      depth: this.depth
    });
    this._rendered = true;
  }
}