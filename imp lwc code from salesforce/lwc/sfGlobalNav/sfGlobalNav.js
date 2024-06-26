import { LightningElement, api, track } from 'lwc';

export default class SfGlobalNav extends LightningElement {

    globalNavReady = false;

    connectedCallback() {
        this.fireGlobalNavEvent();
    }

    renderedCallback() {
        this.fireGlobalNavEvent();
    }

    fireGlobalNavEvent(){
        const evt = new CustomEvent('add_global_nav', {
            detail: {
                origin: 'https://wp.salesforce.com/en-us/wp-json'
            },
            bubbles: true,
            composed: false
        });
        window.dispatchEvent(evt);
        this.globalNavReady = true;
    }
}