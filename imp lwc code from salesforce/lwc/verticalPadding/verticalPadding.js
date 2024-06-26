import { LightningElement, api } from 'lwc';

export default class VerticalPadding extends LightningElement {
    @api heightpx;
    @api heightMobile;

    get containerStyle() {
        return `--vp-height: ${this.heightpx};
            --vp-height-mobile: ${this.mobileHeight}`;
      }    

    get mobileHeight() {
        return this.heightMobile ? this.heightMobile : this.heightpx;
    }
}