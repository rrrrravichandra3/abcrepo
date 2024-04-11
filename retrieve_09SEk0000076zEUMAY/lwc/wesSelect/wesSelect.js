import { api } from 'lwc';
import WesSelectNative from 'c/wesSelectNative';
import WesIconNative from 'c/wesIconNative';
import WesComponentWrapper from 'c/wesComponentWrapper';

// this is required or the object throws an exception if instantiation is attempted
customElements.define('wes-select', WesSelectNative);
// needed to display icons within button
// wes-icon should only be defined once within customElements
if (!customElements.get('wes-icon')) {
  customElements.define('wes-icon', WesIconNative);
}

export default class WesSelect extends WesComponentWrapper {
  @api autocomplete;
  @api autofocus;
  @api disabled;
  @api form;
  @api multiple;
  @api required;
  @api value;
  @api invalidated;
  @api validationText;

  _wesSelectNative;

  _rendered = false;

  renderedCallback() {
    if (!this._rendered) {
      this._wesSelectNative = new WesSelectNative();
    }
    this.reparentWesComponent(this._wesSelectNative, {
      autocomplete: this.autocomplete,
      autofocus: this.autofocus,
      disabled: this.disabled,
      form: this.form,
      multiple: this.multiple,
      required: this.required,
      value: this.value,
      invalidated: this.invalidated,
      validationText: this.validationText
    });
    this._rendered = true;
  }
}