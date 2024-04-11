import { api } from 'lwc';
import WesBadgeNative from 'c/wesBadgeNative';
import WesComponentWrapper from 'c/wesComponentWrapper';

// this is required or the object throws an exception if instantiation is attempted
customElements.define('wes-badge', WesBadgeNative);

export default class WesBadge extends WesComponentWrapper {
  @api type;
  @api value;

  _wesBadgeNative;
  
  _rendered = false;

  renderedCallback() {
    if (!this._rendered) {
      this._wesBadgeNative = new WesBadgeNative();
    }
    this.reparentWesComponent(this._wesBadgeNative, {
      type: this.type,
      value: this.value
    });
    this._rendered = true;
  }
}