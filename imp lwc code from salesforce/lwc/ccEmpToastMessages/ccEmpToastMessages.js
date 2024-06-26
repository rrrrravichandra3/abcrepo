import { LightningElement, track } from 'lwc';
import { subscribeToast } from 'c/ccEmpLmsUtil';
export default class CcEmpToastMessages extends LightningElement {
  @track isErrorToast;
  @track isInfoToast;
  @track isSuccessToast;
  @track isWarningToast;
  @track message;
  @track title;
  connectedCallback() {
    subscribeToast(this.handleToast.bind(this));
  }

  async handleToast(event) {
    console.log('toastMessage Received', event);
    this.isErrorToast = event.variant === 'error';
    this.isInfoToast = event.variant === 'info';
    this.isSuccessToast = event.variant === 'success';
    this.isWarningToast = event.variant === 'warning';
    this.message = event.message;
    this.title = event.title;
    console.log('this.isErrorToast', this.isErrorToast);
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    // await setTimeout(this.close(), 20000);
  }

  close() {
    this.isErrorToast = false;
    this.isInfoToast = false;
    this.isSuccessToast = false;
    this.isWarningToast = false;
    this.message = '';
    this.title = '';
  }
}