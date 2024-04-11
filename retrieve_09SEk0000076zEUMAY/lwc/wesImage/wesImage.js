import { api } from 'lwc';
import WesImageNative from 'c/wesImageNative';
import WesComponentWrapper from 'c/wesComponentWrapper';

// this is required or the object throws an exception if instantiation is attempted
customElements.define('wes-image', WesImageNative);

export default class WesImage extends WesComponentWrapper {
  @api src;
  @api alt;
  @api width;
  @api radius;
  @api ariaDescribedby;

  _wesImageNative;
  
  _rendered = false;

  renderedCallback() {
    if (!this._rendered) {
      this._wesImageNative = new WesImageNative();
    }
    this.reparentWesComponent(this._wesImageNative, {
      src: this.src,
      alt: this.alt,
      width: this.width,
      radius: this.radius,
      ariaDescribedby: this.ariaDescribedby
    });
    this._rendered = true;
  }
}