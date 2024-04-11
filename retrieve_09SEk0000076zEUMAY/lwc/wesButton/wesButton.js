import { api } from 'lwc';
import WesButtonNative from 'c/wesButtonNative';
import WesComponentWrapper from 'c/wesComponentWrapper';

// this is required or the object throws an exception if instantiation is attempted
customElements.define('wes-button', WesButtonNative);

export default class WesButton extends WesComponentWrapper {
  @api size;
  @api variant;
  @api fluid;

  _wesButtonNative;
  
  _rendered = false;

  renderedCallback() {
    if (!this._rendered) {
      this._wesButtonNative = new WesButtonNative();
    }
    this.reparentWesComponent(this._wesButtonNative, {
      size: this.size,
      variant: this.variant,
      fluid: this.fluid
    });
    this._rendered = true;
  }
}