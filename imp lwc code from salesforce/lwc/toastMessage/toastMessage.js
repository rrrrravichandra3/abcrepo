import { LightningElement,api, track} from 'lwc';

export default class ToastMessage extends LightningElement {
    _success;
    @api _toastMsg;

    @api showToast(msg,success) {
        this._success=success;
        var ele = this.template.querySelector('.toast');
        ele.className = (success) ? 'toast success show' : 'toast error show';
        this._toastMsg = msg;
        // After 3 seconds, remove the show class from DIV
        setTimeout(function(){ ele.className = ele.className.replace("show", ""); ele.msg='';}, 3000);
    }
}