import { LightningElement,track,api} from 'lwc';

export default class PbHomeNav extends LightningElement {


    @api currentpage;
    _ishome = true;
    @api buttonlabel;

    get btnVariant() {
        return (this.buttonlabel== 'Back to Home') ? 'secondary' : 'primary';
        
    }


    handleClick() {
        this.dispatchEvent(new CustomEvent('btnclick'));
    }
}