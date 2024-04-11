export default (function () { 
  function escapeXml(unsafe) {
    return unsafe.replace(/[<>&'"]/g, function (c) {
      switch (c) {
        case "<":
          return "&lt;";
        case ">":
          return "&gt;";
        case "&":
          return "&amp;";
        case "'":
          return "&apos;";
        case '"':
          return "&quot;";
      }
    });
  }

  function createTemplateFromHtmlNode(el) {
    let node;

    if (el.tagName === "style") {
      node = document.createElement("style");
      const styleText = el.innerHTML;
      node.append(document.createTextNode(styleText));
    } else {
      // createElement is needed since importNode doesn't transfer special properties
      node = document.createElement(el.tagName);

      el.getAttributeNames().forEach((name) => {
        node.setAttribute(name, el.getAttribute(name));
      });
    } 

    for (let i = 0; i < el.children.length; i++) {
      node.appendChild(createTemplateFromHtmlNode(el.children[i]));
    }

    return node;
  }

  function createTemplateFromHtml(html) {
    const parser = new DOMParser();
    parser.async = false;
    const xml = "<root>" + html + "</root>";
    let element;

    const template = document.createElement("template");
    element = parser.parseFromString(xml, "text/xml").documentElement;

    for (let i = 0; i < element.children.length; i++) {
      template.content.appendChild(createTemplateFromHtmlNode(element.children[i]));
    }

    return template;
  }
  
  const e={html:(e,...n)=>t.html(e,...n).content},t={html(markup, ...t) { return createTemplateFromHtml(markup + t.join('')); }},n=Symbol("defaultState"),s=Symbol("delegatesFocus"),o=Symbol("firstRender"),r=Symbol("focusTarget"),a=Symbol("hasDynamicTemplate"),i=Symbol("ids"),c=Symbol("nativeInternals"),l=Symbol("raiseChangeEvents"),d=Symbol("render"),u=Symbol("renderChanges"),b=Symbol("rendered"),p=Symbol("rendering"),g=Symbol("setState"),h=Symbol("shadowRoot"),v=Symbol("shadowRootMode"),m=Symbol("state"),f=Symbol("stateEffects"),y=Symbol("template"),w=Symbol("checkSize"),S=Symbol("closestAvailableItemIndex"),x=Symbol("contentSlot"),k=n,E=Symbol("defaultTabIndex"),C=s,L=Symbol("effectEndTarget"),T=o,A=r,P=Symbol("getItemText"),O=Symbol("goDown"),D=Symbol("goEnd"),j=Symbol("goFirst"),I=Symbol("goLast"),z=Symbol("goLeft"),R=Symbol("goNext"),H=Symbol("goPrevious"),M=Symbol("goRight"),N=Symbol("goStart"),_=Symbol("goToItemWithPrefix"),U=Symbol("goUp"),$=a,B=i,F=Symbol("inputDelegate"),q=Symbol("itemsDelegate"),W=Symbol("keydown"),K=Symbol("mouseenter"),Z=Symbol("mouseleave"),G=c,J=l,Q=d,V=u,X=Symbol("renderDataToElement"),Y=b,ee=p,te=Symbol("scrollTarget"),ne=g,se=h,oe=v,re=Symbol("startEffect"),ae=m,ie=f,ce=Symbol("swipeDown"),le=Symbol("swipeDownComplete"),de=Symbol("swipeLeft"),ue=Symbol("swipeLeftTransitionEnd"),be=Symbol("swipeRight"),pe=Symbol("swipeRightTransitionEnd"),ge=Symbol("swipeUp"),he=Symbol("swipeUpComplete"),ve=Symbol("swipeStart"),me=Symbol("swipeTarget"),fe=Symbol("tap"),ye=y,we=Symbol("toggleSelectedFlag");function Se(e){if(e.__esModule)return e;var t=Object.defineProperty({},"__esModule",{value:!0});return Object.keys(e).forEach((function(n){var s=Object.getOwnPropertyDescriptor(e,n);Object.defineProperty(t,n,s.get?s:{enumerable:!0,get:function(){return e[n]}})})),t}"true"===new URLSearchParams("").get("elixdebug")&&(window.elix={internal:{checkSize:w,closestAvailableItemIndex:S,contentSlot:x,defaultState:k,defaultTabIndex:E,delegatesFocus:C,effectEndTarget:L,firstRender:T,focusTarget:A,getItemText:P,goDown:O,goEnd:D,goFirst:j,goLast:I,goLeft:z,goNext:R,goPrevious:H,goRight:M,goStart:N,goToItemWithPrefix:_,goUp:U,hasDynamicTemplate:$,ids:B,inputDelegate:F,itemsDelegate:q,keydown:W,mouseenter:K,mouseleave:Z,nativeInternals:G,event:event,raiseChangeEvents:J,render:Q,renderChanges:V,renderDataToElement:X,rendered:Y,rendering:ee,scrollTarget:te,setState:ne,shadowRoot:se,shadowRootMode:oe,startEffect:re,state:ae,stateEffects:ie,swipeDown:ce,swipeDownComplete:le,swipeLeft:de,swipeLeftTransitionEnd:ue,swipeRight:be,swipeRightTransitionEnd:pe,swipeUp:ge,swipeUpComplete:he,swipeStart:ve,swipeTarget:me,tap:fe,template:ye,toggleSelectedFlag:we}});var xe=Se(Object.freeze({__proto__:null,reflectAttribute:(e,t,n)=>{n?e.setAttribute(t,"boolean"==typeof n?"":n):e.removeAttribute(t)},delegateAttribute:(e,t,n,s)=>{s?(t.setAttribute(n,"boolean"==typeof s?"":s),e.removeAttribute(n)):t.removeAttribute(n)},replaceDefaultSlot:(e,t)=>{const n=e.querySelector("slot:not([name])");n&&n.replaceWith(t)},removeSlot:(e,t)=>{const n=e.querySelector(`slot[name="${t}"]`);n&&n.remove()},dispatchCustomEvent:(e,t,n)=>{const s=e.tagName.split("-")[0].toLowerCase(),o=new CustomEvent(s+"-"+t,n);return e.dispatchEvent(o),o}}));const ke={tabindex:"tabIndex"},Ee={tabIndex:"tabindex"};function Ce(e){if(e===HTMLElement||Object.getPrototypeOf(e.prototype)===null)return[];const t=Object.getPrototypeOf(e.prototype).constructor;let n=t.observedAttributes;n||(n=Ce(t));const s=Object.getOwnPropertyNames(e.prototype).filter((t=>{const n=Object.getOwnPropertyDescriptor(e.prototype,t);return n&&"function"==typeof n.set})).map((e=>function(e){let t=Ee[e];if(!t){const n=/([A-Z])/g;t=e.replace(n,"-$1").toLowerCase(),Ee[e]=t}return t}(e))).filter((e=>n.indexOf(e)<0));return n.concat(s)}const Le={checked:!0,defer:!0,disabled:!0,hidden:!0,ismap:!0,multiple:!0,noresize:!0,readonly:!0,selected:!0},Te=Symbol("state"),Ae=Symbol("raiseChangeEventsInNextRender"),Pe=Symbol("changedSinceLastRender");function Oe(e,t){const n={};for(const r in t)s=t[r],o=e[r],(s instanceof Date&&o instanceof Date?s.getTime()===o.getTime():s===o)||(n[r]=!0);var s,o;return n}const De=new Map,je=Symbol("shadowIdProxy"),Ie=Symbol("proxyElement"),ze={get(e,t){const n=e[Ie][h];return n&&"string"==typeof t?n.getElementById(t):null}};const Re=function(e){return class extends e{attributeChangedCallback(e,t,n){if(super.attributeChangedCallback&&super.attributeChangedCallback(e,t,n),n!==t&&!this[p]){const t=function(e){let t=ke[e];if(!t){const n=/-([a-z])/g;t=e.replace(n,(e=>e[1].toUpperCase())),ke[e]=t}return t}(e);if(t in this){const r=Le[e]?(s=e,"boolean"==typeof(o=n)?o:"string"==typeof o&&(""===o||s.toLowerCase()===o.toLowerCase())):n;this[t]=r}}var s,o}static get observedAttributes(){return Ce(this)}}}(function(e){class t extends e{constructor(){super(),this[o]=void 0,this[l]=!1,this[Pe]=null,this[g](this[n])}connectedCallback(){super.connectedCallback&&super.connectedCallback(),this[u]()}get[n](){return super[n]||{}}[d](e){super[d]&&super[d](e)}[u](){void 0===this[o]&&(this[o]=!0);const e=this[Pe];if(this[o]||e){const t=this[l];this[l]=this[Ae],this[Ae]=!1,this[p]=!0,this[d](e),this[p]=!1,this[Pe]=null,this[b](e),this[o]=!1,this[l]=t}}[b](e){super[b]&&super[b](e)}async[g](e){this[p]&&console.warn(`${this.constructor.name} called [setState] during rendering, which you should avoid.\nSee https://elix.org/documentation/ReactiveMixin.`);const{state:t,changed:n}=function(e,t){const n=Object.assign({},e[Te]),s={};let o=t;for(;;){const t=Oe(n,o);if(0===Object.keys(t).length)break;Object.assign(n,o),Object.assign(s,t),o=e[f](n,t)}return{state:n,changed:s}}(this,e);if(this[Te]&&0===Object.keys(n).length)return;Object.freeze(t),this[Te]=t,this[l]&&(this[Ae]=!0);const s=void 0===this[o]||null!==this[Pe];this[Pe]=Object.assign(this[Pe]||{},n);this.isConnected&&!s&&(await Promise.resolve(),this[u]())}get[m](){return this[Te]}[f](e,t){return super[f]?super[f](e,t):{}}}return"true"===new URLSearchParams("").get("elixdebug")&&Object.defineProperty(t.prototype,"state",{get(){return this[m]}}),t}((He=HTMLElement,class extends He{get[i](){if(!this[je]){const e={[Ie]:this};this[je]=new Proxy(e,ze)}return this[je]}[d](e){if(super[d]&&super[d](e),void 0===this[h]){const e=function(e){let t=e[a]?void 0:De.get(e.constructor);if(void 0===t){if(t=e[y],t&&!(t instanceof HTMLTemplateElement))throw`Warning: the [template] property for ${e.constructor.name} must return an HTMLTemplateElement.`;e[a]||De.set(e.constructor,t||null)}return t}(this);if(e){const t=this.attachShadow({delegatesFocus:this[s],mode:this[v]}),n=document.importNode(e.content,!0);t.append(n),this[h]=t}else this[h]=null}}get[v](){return"closed"}})));var He;var Me=[],Ne=[];function _e(e,t){if(e&&"undefined"!=typeof document){var n,s=!0===t.prepend?"prepend":"append",o=!0===t.singleTag,r="string"==typeof t.container?document.querySelector(t.container):document.getElementsByTagName("head")[0];if(o){var a=Me.indexOf(r);-1===a&&(a=Me.push(r)-1,Ne[a]={}),n=Ne[a]&&Ne[a][s]?Ne[a][s]:Ne[a][s]=i()}else n=i();65279===e.charCodeAt(0)&&(e=e.substring(1)),n.styleSheet?n.styleSheet.cssText+=e:n.appendChild(document.createTextNode(e))}function i(){var e=document.createElement("style");if(e.setAttribute("type","text/css"),t.attributes)for(var n=Object.keys(t.attributes),o=0;o<n.length;o++)e.setAttribute(n[o],t.attributes[n[o]]);var a="prepend"===s?"afterbegin":"beforeend";return r.insertAdjacentElement(a,e),e}}var Ue="/***************************************\n * This file is automatically generated.\n * Please do not edit this file. Source file is common.css\n ***************************************/\n\n/* Copyright (c) 2015-present, salesforce.com, inc. All rights reserved\nLicensed under BSD 3-Clause - see LICENSE.txt or git.io/sfdc-license */\n\n/**\n * Normalize box sizing to border box for all browsers.\n */\n\n*,\n::before,\n::after {\n  box-sizing: border-box;\n}\n\nh1,\nh2,\nh3,\nh4,\nh5,\nh6 {\n  font-weight: var(--sds-s-heading-font-weight);\n  margin-block-start: var(--sds-s-heading-spacing-block-start, var(--sds-s-heading-spacing-block));\n  margin-block-end: var(--sds-s-heading-spacing-block-end, var(--sds-s-heading-spacing-block));\n}\n\np {\n  margin-block-start: var(--sds-s-content-spacing-block-start, var(--sds-s-content-spacing-block));\n  margin-block-end: var(--sds-s-content-spacing-block-end, var(--sds-s-content-spacing-block));\n}\n\nol,\nul {\n  list-style: none;\n  padding: 0;\n  margin-block-start: var(--sds-s-content-spacing-block-start, var(--sds-s-content-spacing-block));\n  margin-block-end: var(--sds-s-content-spacing-block-end, var(--sds-s-content-spacing-block));\n}\n\nbutton,\n[type='button'],\n[type='reset'],\n[type='submit'] {\n  -webkit-appearance: button;\n  appearance: button;\n  cursor: pointer;\n}\n\n[type='search'] {\n  -webkit-appearance: textfield;\n  outline-offset: -2px;\n}\n\ninput:focus,\nbutton:focus,\nselect:focus,\ntextarea:focus {\n  outline-offset: 0;\n}\n\n::-moz-focus-inner {\n  border-style: none;\n  padding: 0;\n}\n\n::-webkit-search-decoration {\n  -webkit-appearance: none;\n}\n\n::-webkit-file-upload-button {\n  -webkit-appearance: button;\n  font: inherit;\n}\n\n:-moz-focusring {\n  outline: 1px dotted ButtonText;\n}\n\n:-moz-ui-invalid {\n  box-shadow: none;\n}\n\ncode,\nkbd,\nsamp,\npre {\n  font-family: var(--sds-g-font-family-monospace);\n}\n\nimg,\n[type='image'] {\n  max-width: 100%;\n  height: auto;\n}\n\niframe {\n  border-style: none;\n}\n";_e(Ue,{});var $e="/***************************************\n * This file is automatically generated.\n * Please do not edit this file. Source file is button.css\n ***************************************/\n\n/* Copyright (c) 2015-present, salesforce.com, inc. All rights reserved\nLicensed under BSD 3-Clause - see LICENSE.txt or git.io/sfdc-license */\n\n:host(:focus) {\n  outline: 0;\n}\n\n[part~='button'] {\n  display: var(--sds-c-button-display, inline-flex);\n  position: relative;\n  background: none;\n  background-color: var(--sds-c-button-color-background, var(--sds-s-button-color-background, transparent));\n  background-clip: border-box;\n  color: var(--sds-c-button-text-color, var(--sds-s-button-text-color, inherit));\n  padding-left: var(\n    --sds-c-button-spacing-inline-start,\n    var(--sds-c-button-spacing-inline, var(--sds-s-button-spacing-inline))\n  );\n  padding-right: var(\n    --sds-c-button-spacing-inline-end,\n    var(--sds-c-button-spacing-inline, var(--sds-s-button-spacing-inline))\n  );\n  padding-top: var(\n    --sds-c-button-spacing-block-start,\n    var(--sds-c-button-spacing-block, var(--sds-s-button-spacing-block))\n  );\n  padding-bottom: var(\n    --sds-c-button-spacing-block-start,\n    var(--sds-c-button-spacing-block, var(--sds-s-button-spacing-block))\n  );\n  border-width: var(--sds-c-button-sizing-border, var(--sds-s-button-sizing-border, 1px));\n  border-style: solid;\n  border-color: var(--sds-c-button-color-border, var(--sds-s-button-color-border, transparent));\n  border-radius: var(--sds-c-button-radius-border, var(--sds-c-button-radius-border, 0.25rem));\n  box-shadow: var(--sds-c-button-shadow, var(--sds-s-button-shadow));\n  width: var(--sds-c-button-width);\n  line-height: var(--sds-c-button-line-height);\n  white-space: normal;\n  user-select: none;\n  align-items: center;\n  text-decoration: var(--sds-c-button-text-decoration, none);\n  appearance: none;\n}\n\n[part~='button']:hover {\n  --sds-c-button-text-color: var(\n    --sds-c-button-text-color-hover,\n    var(--sds-s-button-text-color-hover, #0176d3)\n  );\n  --sds-c-button-color-background: var(\n    --sds-c-button-color-background-hover,\n    var(--sds-s-button-color-background-hover)\n  );\n  --sds-c-button-color-border: var(--sds-c-button-color-border-hover, var(--sds-s-button-color-border-hover));\n\n  cursor: pointer;\n}\n\n[part~='button']:focus {\n  --sds-c-button-color-background: var(\n    --sds-c-button-color-background-focus,\n    var(--sds-s-button-color-background-focus)\n  );\n  --sds-c-button-color-border: var(\n    --sds-c-button-color-border-focus,\n    var(--sds-s-button-color-border-focus, #0176d3)\n  );\n  --sds-c-button-text-color: var(\n    --sds-c-button-text-color-focus,\n    var(--sds-s-button-text-color-focus, #0176d3)\n  );\n  --sds-c-button-shadow: var(--sds-c-button-shadow-focus, var(--sds-s-button-shadow-focus, #0176d3 0 0 3px));\n\n  outline: 0;\n}\n\n[part~='button']:active {\n  --sds-c-button-text-color: var(\n    --sds-c-button-text-color-active,\n    var(--sds-s-button-text-color-active, currentColor)\n  );\n  --sds-c-button-color-background: var(\n    --sds-c-button-color-background-active,\n    var(--sds-s-button-color-background-active)\n  );\n  --sds-c-button-color-border: var(\n    --sds-c-button-color-border-active,\n    var(--sds-s-button-color-border-active, #0176d3)\n  );\n}\n\n[part~='button']:disabled {\n  --sds-c-button-text-color: var(--sds-c-button-text-color-disabled, #939393);\n  --sds-c-button-color-background: var(--sds-c-button-color-background-disabled);\n  --sds-c-button-color-border: var(--sds-c-button-color-border-disabled);\n\n  pointer-events: none;\n}\n\n[part~='button']:disabled * {\n  pointer-events: none;\n}\n";_e($e,{});class Be extends(function(e){return class extends e{constructor(){super(),this.addEventListener("mouseenter",(async e=>{this[J]=!0,this[K](e),await Promise.resolve(),this[J]=!1})),this.addEventListener("mouseleave",(async e=>{this[J]=!0,this[Z](e),await Promise.resolve(),this[J]=!1}))}get[k](){return Object.assign(super[k]||{},{hover:!1})}[K](e){super[K]&&super[K](e),this[ne]({hover:!0})}[Z](e){super[Z]&&super[Z](e),this[ne]({hover:!1})}}}(Re)){get[k](){return Object.assign(super[k],{ariaLabel:null,ariaControls:null,ariaExpanded:null,ariaHaspopup:null,ariaLive:null,ariaPressed:!1,variant:null,role:null,id:"",name:"",value:null,type:null,disabled:!1})}get variant(){return this[ae].variant}set variant(e){this[ne]({variant:e})}get disabled(){return this[ae].disabled}set disabled(e){this[ne]({disabled:e})}get ariaPressed(){return this[ae].ariaPressed}set ariaPressed(e){this[ne]({ariaPressed:e})}get ariaLabel(){return this[ae].ariaLabel}set ariaLabel(e){this[ne]({ariaLabel:e})}get ariaLive(){return this[ae].ariaLive}set ariaLive(e){this[ne]({ariaLive:e})}get ariaControls(){return this[ae].ariaControls}set ariaControls(e){this[ne]({ariaControls:e})}get ariaExpanded(){return this[ae].ariaExpanded}set ariaExpanded(e){this[ne]({ariaExpanded:e})}get ariaHaspopup(){return this[ae].ariaHaspopup}set ariaHaspopup(e){this[ne]({ariaHaspopup:e})}get id(){return this[ae].id}set id(e){this[ne]({id:e})}get name(){return this[ae].name}set name(e){this[ne]({name:e})}get value(){return this[ae].value}set value(e){this[ne]({value:e})}get role(){return this[ae].role}set role(e){this[ne]({role:e})}[fe](){const e=new MouseEvent("click",{bubbles:!0,cancelable:!0});this.dispatchEvent(e)}[Q](e){super[Q](e);const t=this[h].querySelector('[part~="button"]');if(e.disabled){const{disabled:e}=this[ae];e&&xe.delegateAttribute(this,t,"disabled",e)}if(e.id){const{id:e}=this[ae];xe.reflectAttribute(t,"id",e)}if(e.ariaLabel){const{ariaLabel:e}=this[ae];e&&xe.delegateAttribute(this,t,"aria-label",e)}if(e.ariaPressed){const{ariaPressed:e}=this[ae];e&&xe.delegateAttribute(this,t,"aria-pressed",e)}if(e.ariaControls){const{ariaControls:e}=this[ae];e&&xe.delegateAttribute(this,t,"aria-controls",e)}if(e.ariaExpanded){const{ariaExpanded:e}=this[ae];e&&xe.delegateAttribute(this,t,"aria-expanded",e)}if(e.ariaLive){const{ariaLive:e}=this[ae];e&&xe.delegateAttribute(this,t,"aria-live",e)}if(e.ariaHaspopup){const{ariaHaspopup:e}=this[ae];e&&xe.delegateAttribute(this,t,"aria-haspopup",e)}if(e.value){const{value:e}=this[ae];e&&xe.delegateAttribute(this,t,"value",e)}if(e.name){const{name:e}=this[ae];e&&xe.delegateAttribute(this,t,"name",e)}if(e.role){const{role:e}=this[ae];e&&xe.delegateAttribute(this,t,"role",e)}}get[ye](){return t.html(`
      <style>
        ${escapeXml(Ue)}
        ${escapeXml($e)}
      </style>
      ${'\n<button part="button">\n  <slot name="start" part="start"></slot>\n  <slot></slot>\n  <slot name="end" part="end"></slot>\n</button>\n'}
    `)}}var Fe="/***************************************\n * This file is automatically generated.\n * Please do not edit this file. Source file is button-toggle.css\n ***************************************/\n\n/* Copyright (c) 2015-present, salesforce.com, inc. All rights reserved\nLicensed under BSD 3-Clause - see LICENSE.txt or git.io/sfdc-license */\n\n:host([pressed]) {\n  --sds-c-button-text-color: var(--sds-c-button-text-color-pressed);\n  --sds-c-button-color-background: var(--sds-c-button-color-background-pressed, #dee5fc);\n  --sds-c-button-color-border: var(--sds-c-button-color-border-pressed);\n  --sds-c-button-text-color-hover: var(--sds-c-button-color-border-pressed-hover);\n  --sds-c-button-color-background-hover: var(--sds-c-button-color-background-pressed-hover);\n  --sds-c-button-color-border-hover: var(--sds-c-button-color-border-pressed-hover);\n  --sds-c-button-text-color-active: var(--sds-c-button-color-border-pressed-active);\n  --sds-c-button-color-background-active: var(--sds-c-button-color-background-pressed-active);\n  --sds-c-button-color-border-active: var(--sds-c-button-color-border-pressed-active);\n}\n";_e(Fe,{});const qe=32,We=13;class Ke extends Be{get[k](){return Object.assign(super[k],{pressed:null})}get pressed(){return this[ae].pressed}set pressed(e){this[ne]({pressed:e})}_onKeyDown(e){if(!e.altKey)switch(e.keyCode){case qe:case We:e.preventDefault(),this._togglePressed()}}_togglePressed(){this.toggleAttribute("pressed")}[ie](e,t){const n=super[ie]?super[ie](e,t):{};if(t.pressed){const{pressed:t}=e,s=null!==t;Object.assign(n,{ariaPressed:s?"true":"false"})}return n}[Q](e){super[Q](e);const t=this[h].querySelector('[part="button"]');this[T]&&(this.addEventListener("keydown",this._onKeyDown),this.addEventListener("click",this._togglePressed)),e.ariaPressed&&xe.delegateAttribute(this,t,"aria-pressed",this[ae].ariaPressed)}get[ye](){const t=super[ye];return t.content.append(e.html(`
    <style>
      ${escapeXml(Fe)}
    </style>
    `)),t}}var Ze="/* Copyright (c) 2015-present, salesforce.com, inc. All rights reserved\n  Licensed under BSD 3-Clause - see LICENSE.txt or git.io/sfdc-license */\n\n:host {\n  --sds-c-button-color-background-hover: var(--wes-g-color-palette-blue-95);\n  --sds-c-button-spacing-block: 2px;\n  --sds-c-button-spacing-inline: 12px;\n  --sds-c-button-sizing-border: 2px;\n  --sds-c-button-color-border: var(--wes-g-color-palette-neutral-50);\n  --sds-c-button-color-border-hover: var(--wes-g-color-palette-blue-20);\n  --sds-c-button-text-color: var(--wes-g-color-palette-neutral-50);\n  --sds-c-button-text-color-hover: var(--wes-g-color-palette-blue-20);\n  --sds-c-button-radius-border: var(--wes-g-radius-border-2);\n  --sds-c-button-line-height: 20px;\n\n  --sds-c-button-color-background-pressed: var(--wes-g-color-palette-neutral-40);\n  --sds-c-button-color-background-pressed-hover: var(--wes-g-color-palette-blue-95);\n  --sds-c-button-color-background-pressed-active: var(--wes-g-color-neutral-base-3);\n  --sds-c-button-text-color-pressed: var(--wes-g-color-neutral-base-1);\n  --sds-c-button-text-color-pressed-hover: var(--wes-g-color-palette-blue-20);\n  --sds-c-button-text-color-pressed-active: var(--wes-g-color-palette-neutral-40);\n  --sds-c-button-color-border-pressed: var(--wes-g-color-palette-neutral-40);\n  --sds-c-button-color-border-pressed-hover: var(--wes-g-color-palette-blue-20);\n  --sds-c-button-color-border-pressed-active: var(--wes-g-color-palette-neutral-40);\n\n  --sds-c-button-text-color-disabled: var(--wes-g-color-neutral-base-1);\n  --sds-c-button-color-background-disabled: var(--wes-g-color-palette-neutral-80);\n  --sds-c-button-color-border-disabled: var(--wes-g-color-palette-neutral-80);\n\n  --sds-c-icon-sizing: 12px;\n  --sds-c-icon-sizing-border: 0;\n}\n\n[part~='button'] {\n  font-size: var(--wes-g-font-size-2);\n  font-family: var(--wes-g-font-sans);\n  font-weight: var(--wes-g-font-weight-bold);\n}\n\n[part~='button']:focus {\n  --sds-c-button-color-border: var(--wes-g-color-palette-blue-50);\n  --sds-c-button-shadow: none;\n  --sds-c-button-color-background: var(--wes-g-color-palette-blue-95);\n\n  outline: 2px solid var(--wes-g-color-brand-base-contrast-1);\n  outline-offset: 2px;\n}\n\n::slotted([slot='end']) {\n  margin-inline-start: var(--wes-g-spacing-2);\n}\n\n::slotted([symbol='check']),\n::slotted([symbol='close']),\n:host([pressed]) ::slotted([symbol='add']),\n:host([pressed]) [part~='button']:focus ::slotted([symbol='check']),\n:host([pressed]) [part~='button']:hover ::slotted([symbol='check']) {\n  display: none;\n}\n\n::slotted([symbol='add']),\n:host([pressed]) ::slotted([symbol='check']),\n:host([pressed]) [part~='button']:focus ::slotted([symbol='close']),\n:host([pressed]) [part~='button']:hover ::slotted([symbol='close']) {\n  display: flex;\n}\n";_e(Ze,{});class Ge extends Ke{[Q](e){super[Q](e),this[T]&&this.insertAdjacentHTML("beforeend",' <wes-icon symbol="add" slot="end"></wes-icon>\n          <wes-icon symbol="check" slot="end"></wes-icon>\n          <wes-icon symbol="close" slot="end"></wes-icon>\n        ')}get[ye](){const t=super[ye];return t.content.append(e.html(`
        <style>
          ${escapeXml(Ze)}
        </style>
      `)),t}}return Ge;
 
})();