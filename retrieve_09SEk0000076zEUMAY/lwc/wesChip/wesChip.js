import WesChipNative from 'c/wesChipNative';
import WesComponentWrapper from 'c/wesComponentWrapper';

// this is required or the object throws an exception if instantiation is attempted
customElements.define('wes-chip', WesChipNative);

export default class WesChip extends WesComponentWrapper {

  _wesChipNative;
  
  _rendered = false;

  renderedCallback() {
    if (!this._rendered) {
      this._wesChipNative = new WesChipNative();
    }
    this.reparentWesComponent(this._wesChipNative, {

    });
    this._rendered = true;
  }
}