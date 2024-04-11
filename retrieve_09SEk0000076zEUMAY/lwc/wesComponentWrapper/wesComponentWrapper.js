import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import wesResource from '@salesforce/resourceUrl/wes';

export default class WesComponentWrapper extends LightningElement {
  connectedCallback() {
    // load global stylesheets for all components
    loadStyle(this, wesResource + '/hooks.custom-props.css');
    loadStyle(this, wesResource + '/foundation.css');
  }

  /**
   * Assigns attributes from this component to native wes component, then reparents the slotted elements
   * to a native wes component, and then native wes component gets assigned to lwc:dom='manual' div
   *
   * @param {*} nativeComponent - manually defined wes component
   * @param {*} attributes - object containing api attribute names and values
   */
  reparentWesComponent(nativeComponent, attributes) {
    // we need to pass attributes from the LWC component to the child native web component
    for (const attribute in attributes) {
      if (attributes[attribute]) {
        nativeComponent.setAttribute(attribute, attributes[attribute]);
      }
    }

    /**
     * It's important to add the slot elements to the component before adding it to the DOM, or else
     * the component may throw errors if it doesn't find expected content in the slot on render
     * (i.e., when added to the DOM).
     *
     * Also, we can't simply pass the entire slot over, since then the children won't be visible
     * since they're used a closed shadow dom. Note that we need to access the children of this
     * and not the children of this.template, since the children of this.template are not accessible
     * in the shadow dom.
     */
    while (this.childNodes.length > 0) {
      if (this.childNodes[0].nodeType === 3) {
        // text node
        nativeComponent.appendChild(document.createTextNode(this.childNodes[0].textContent));

        // this needs to be removed, since we created a copy
        this.childNodes[0].remove();
      } else if (this.childNodes[0].nodeType === 1) {
        // element node (it's moved, so removal is implied)
        nativeComponent.appendChild(this.childNodes[0]);
      }
    }

    // move the new component to the desired spot in the DOM
    const cmpTarget = this.template.querySelector('.component');
    cmpTarget.append(nativeComponent);
  }
}