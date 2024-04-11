import { api } from 'lwc';
import WesInputRadioNative from 'c/wesInputRadioNative';
import WesComponentWrapper from 'c/wesComponentWrapper';

// this is required or the object throws an exception if instantiation is attempted
customElements.define('wes-input-radio', WesInputRadioNative);

export default class WesInputRadio extends WesComponentWrapper {
  @api role;
  @api size;
  @api checked;
  @api value;
  @api disabled;
  @api required;
  @api name;
  @api id;
  @api error;

  _wesInputRadioNative;
  
  _rendered = false;

  renderedCallback() {
    if (!this._rendered) {
      this._wesInputRadioNative = new WesInputRadioNative();
    }
    this.reparentWesComponent(this._wesInputRadioNative, {
      role: this.role,
      size: this.size,
      checked: this.checked,
      value: this.value,
      disabled: this.disabled,
      required: this.required,
      name: this.name,
      id: this.id,
      error: this.error
    });
    this._rendered = true;
  }
}