import { api } from 'lwc';
import WesInputCheckboxNative from 'c/wesInputCheckboxNative';
// eslint-disable-next-line no-unused-vars
import WesChipNative from 'c/wesChipNative'; // needed for checkbox to appear
import WesComponentWrapper from 'c/wesComponentWrapper';

// this is required or the object throws an exception if instantiation is attempted
customElements.define('wes-input-checkbox', WesInputCheckboxNative);

export default class WesInputCheckbox extends WesComponentWrapper {
  @api checked;
  @api indeterminate;
  @api value;
  @api disabled;
  @api required;
  @api name;
  @api id;
  @api error;
  @api size;

  _wesInputCheckboxNative;

  _rendered = false;

  renderedCallback() {
    if (!this._rendered) {
      this._wesInputCheckboxNative = new WesInputCheckboxNative();
    }
    this.reparentWesComponent(this._wesInputCheckboxNative, {
      checked: this.checked,
      indeterminate: this.indeterminate,
      value: this.value,
      disabled: this.disabled,
      required: this.required,
      name: this.name,
      id: this.id,
      error: this.error,
      size: this.size
    });
    this._rendered = true;
  }
}