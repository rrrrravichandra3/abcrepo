import { api } from 'lwc';
import WesInputRadioGroupNative from 'c/wesInputRadioGroupNative';
import WesComponentWrapper from 'c/wesComponentWrapper';

// this is required or the object throws an exception if instantiation is attempted
customElements.define('wes-input-radio-group', WesInputRadioGroupNative);

export default class WesInputRadioGroup extends WesComponentWrapper {
  @api legend;
  @api direction;
  @api disabled;
  @api name;
  @api selected;
  @api size;

  _wesInputRadioGroupNative;
  
  _rendered = false;

  renderedCallback() {
    if (!this._rendered) {
      this._wesInputRadioGroupNative = new WesInputRadioGroupNative();
    }
    this.reparentWesComponent(this._wesInputRadioGroupNative, {
      legend: this.legend,
      direction: this.direction,
      disabled: this.disabled,
      name: this.name,
      selected: this.selected,
      size: this.size
    });
    this._rendered = true;
  }
}