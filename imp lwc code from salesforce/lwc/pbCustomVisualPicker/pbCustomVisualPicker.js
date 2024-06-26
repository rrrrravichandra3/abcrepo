import { LightningElement,api,track } from 'lwc';
import preboardingResources from '@salesforce/resourceUrl/preboardingResources';
export default class PbCustomVisualPicker extends LightningElement {

    _imgsrc;
    @api isselected;
    @api imgsrc;
    @api name;
    @api sId;

    @track _cls = 'container';

    @api select() {
        this.isselected=true;
        this.updateStyle();
    }

    @api deselect() {
        console.log('deeselect');
        this.isselected=false;
        this.updateStyle();
    }

    updateStyle() {
        if(this.isselected===true) {
            this._cls='container selected';
        } else {
            this._cls='container default';
        }
    }

    connectedCallback() {
        this.isselected=false;
        this._imgsrc= preboardingResources + '/preboardingResources/' + this.imgsrc;
        this.updateStyle();
    }
}