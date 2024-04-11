import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import wesResource from '@salesforce/resourceUrl/wes';

export default class WesScope extends LightningElement {
  /**
   * @description Deprecated. To be removed.
   * See known 'idea': https://ideas.salesforce.com/s/idea/a0B8W00000GdknvUAB
   */
  @api enabledFeatures;

  /**
   * @description Deprecated. To be removed.
   * See known 'idea': https://ideas.salesforce.com/s/idea/a0B8W00000GdknvUAB
   */
  @api supportedComponents;

  /**
   * Load WES styles and scripts once the scope element is inserted into the document
   *
   * Please see the following document for context on why loadStyle and loadScript is used:
   * https://salesforce.quip.com/bpn7AkJlDqoj#temp:C:CIDe1acb9aa1a8a4e55aa409d9af
   */
  connectedCallback() {
    // load global stylesheets for all components
    loadStyle(this, wesResource + '/hooks.custom-props.css');
    loadStyle(this, wesResource + '/foundation.css');

    // TODO: consider if this should be a separate component
    loadStyle(this, wesResource + '/grid.css');
  }
}