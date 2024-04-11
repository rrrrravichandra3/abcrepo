import { api } from 'lwc';
import WesDividerNative from 'c/wesDividerNative';
import WesComponentWrapper from 'c/wesComponentWrapper';

// this is required or the object throws an exception if instantiation is attempted
customElements.define('wes-divider', WesDividerNative);

export default class WesDivider extends WesComponentWrapper {
  @api color;
  @api direction;
  @api variant;
  @api role;

  _wesDividerNative;
  
  _rendered = false;

  renderedCallback() {
    if (!this._rendered) {
      this._wesDividerNative = new WesDividerNative();
    }
    this.reparentWesComponent(this._wesDividerNative, {
      color: this.color,
      direction: this.direction,
      variant: this.variant,
      role: this.role
    });
    this._rendered = true;
  }
}