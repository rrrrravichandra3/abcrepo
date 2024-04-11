import { api } from 'lwc';
import WesButtonToggleNative from 'c/wesButtonToggleNative';
import WesIconNative from 'c/wesIconNative';
import WesComponentWrapper from 'c/wesComponentWrapper';

// this is required or the object throws an exception if instantiation is attempted
customElements.define('wes-button-toggle', WesButtonToggleNative);
// needed to display icons within button
// wes-icon should only be defined once within customElements
if (!customElements.get('wes-icon')) {
  customElements.define('wes-icon', WesIconNative);
}

export default class WesButtonToggle extends WesComponentWrapper {
  @api pressed;

  _wesButtonToggleNative;

  _rendered = false;

  renderedCallback() {
    if (!this._rendered) {
      this._wesButtonToggleNative = new WesButtonToggleNative();
    }
    this.reparentWesComponent(this._wesButtonToggleNative, {
      pressed: this.pressed
    });
    this._rendered = true;
  }
}