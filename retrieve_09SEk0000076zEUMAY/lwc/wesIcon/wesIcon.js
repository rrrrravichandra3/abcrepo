import { api } from 'lwc';
import WesIconNative from 'c/wesIconNative';
import WesComponentWrapper from 'c/wesComponentWrapper';

// this is required or the object throws an exception if instantiation is attempted
if (!customElements.get('wes-icon')) {
  customElements.define('wes-icon', WesIconNative);
}

export default class WesIcon extends WesComponentWrapper {
  @api symbol;

  _wesIconNative;

  _rendered = false;

  renderedCallback() {
    if (!this._rendered) {
      this._wesIconNative = new WesIconNative();
    }
    this.reparentWesComponent(this._wesIconNative, {
      symbol: this.symbol
    });
    this._rendered = true;
  }
}