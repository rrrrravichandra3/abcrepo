import { LightningElement,api} from 'lwc';

export default class PbToastMessage extends LightningElement {
    _success;
    @api _toastMsg;

    @api showToast(msg,success) {
        this._success=success;
        const ele = this.template.querySelector('.message');
        ele.className = (success) ? 'message success show' : 'message error show';
        this._toastMsg = msg;
        // After 3 seconds, remove the show class from DIV
        setTimeout(function(){ ele.className = ele.className.replace("show", "hide"); ele.msg='';}, 5000);
    }
}