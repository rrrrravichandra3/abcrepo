import { LightningElement } from 'lwc';

customElements.define('test-component', class MyWebComponent extends HTMLElement {
    constructor() {
      super();
  
      this.attachShadow({ mode: "closed" }).innerHTML =
        "<div>I am a third-party web component!</div>";
    }
  });

export default class ComponentTest extends LightningElement { }