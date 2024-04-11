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
  
  const e=Symbol("defaultState"),t=Symbol("delegatesFocus"),n=Symbol("firstRender"),o=Symbol("focusTarget"),r=Symbol("hasDynamicTemplate"),i=Symbol("ids"),s=Symbol("nativeInternals"),a=Symbol("raiseChangeEvents"),l=Symbol("render"),c=Symbol("renderChanges"),d=Symbol("rendered"),u=Symbol("rendering"),h=Symbol("setState"),b=Symbol("shadowRoot"),g=Symbol("shadowRootMode"),p=Symbol("state"),m=Symbol("stateEffects"),f=Symbol("template"),v={tabindex:"tabIndex"},w={tabIndex:"tabindex"};function y(e){if(e===HTMLElement||Object.getPrototypeOf(e.prototype)===null)return[];const t=Object.getPrototypeOf(e.prototype).constructor;let n=t.observedAttributes;n||(n=y(t));const o=Object.getOwnPropertyNames(e.prototype).filter((t=>{const n=Object.getOwnPropertyDescriptor(e.prototype,t);return n&&"function"==typeof n.set})).map((e=>function(e){let t=w[e];if(!t){const n=/([A-Z])/g;t=e.replace(n,"-$1").toLowerCase(),w[e]=t}return t}(e))).filter((e=>n.indexOf(e)<0));return n.concat(o)}const S={checked:!0,defer:!0,disabled:!0,hidden:!0,ismap:!0,multiple:!0,noresize:!0,readonly:!0,selected:!0},x=Symbol("state"),C=Symbol("raiseChangeEventsInNextRender"),A=Symbol("changedSinceLastRender");function E(e,t){const n={};for(const i in t)o=t[i],r=e[i],(o instanceof Date&&r instanceof Date?o.getTime()===r.getTime():o===r)||(n[i]=!0);var o,r;return n}const k=new Map,R=Symbol("shadowIdProxy"),T=Symbol("proxyElement"),z={get(e,t){const n=e[T][b];return n&&"string"==typeof t?n.getElementById(t):null}};const O=function(e){return class extends e{attributeChangedCallback(e,t,n){if(super.attributeChangedCallback&&super.attributeChangedCallback(e,t,n),n!==t&&!this[u]){const t=function(e){let t=v[e];if(!t){const n=/-([a-z])/g;t=e.replace(n,(e=>e[1].toUpperCase())),v[e]=t}return t}(e);if(t in this){const i=S[e]?(o=e,"boolean"==typeof(r=n)?r:"string"==typeof r&&(""===r||o.toLowerCase()===r.toLowerCase())):n;this[t]=i}}var o,r}static get observedAttributes(){return y(this)}}}(function(t){class o extends t{constructor(){super(),this[n]=void 0,this[a]=!1,this[A]=null,this[h](this[e])}connectedCallback(){super.connectedCallback&&super.connectedCallback(),this[c]()}get[e](){return super[e]||{}}[l](e){super[l]&&super[l](e)}[c](){void 0===this[n]&&(this[n]=!0);const e=this[A];if(this[n]||e){const t=this[a];this[a]=this[C],this[C]=!1,this[u]=!0,this[l](e),this[u]=!1,this[A]=null,this[d](e),this[n]=!1,this[a]=t}}[d](e){super[d]&&super[d](e)}async[h](e){this[u]&&console.warn(`${this.constructor.name} called [setState] during rendering, which you should avoid.\nSee https://elix.org/documentation/ReactiveMixin.`);const{state:t,changed:o}=function(e,t){const n=Object.assign({},e[x]),o={};let r=t;for(;;){const t=E(n,r);if(0===Object.keys(t).length)break;Object.assign(n,r),Object.assign(o,t),r=e[m](n,t)}return{state:n,changed:o}}(this,e);if(this[x]&&0===Object.keys(o).length)return;Object.freeze(t),this[x]=t,this[a]&&(this[C]=!0);const r=void 0===this[n]||null!==this[A];this[A]=Object.assign(this[A]||{},o);this.isConnected&&!r&&(await Promise.resolve(),this[c]())}get[p](){return this[x]}[m](e,t){return super[m]?super[m](e,t):{}}}return"true"===new URLSearchParams("").get("elixdebug")&&Object.defineProperty(o.prototype,"state",{get(){return this[p]}}),o}((L=HTMLElement,class extends L{get[i](){if(!this[R]){const e={[T]:this};this[R]=new Proxy(e,z)}return this[R]}[l](e){if(super[l]&&super[l](e),void 0===this[b]){const e=function(e){let t=e[r]?void 0:k.get(e.constructor);if(void 0===t){if(t=e[f],t&&!(t instanceof HTMLTemplateElement))throw`Warning: the [template] property for ${e.constructor.name} must return an HTMLTemplateElement.`;e[r]||k.set(e.constructor,t||null)}return t}(this);if(e){const n=this.attachShadow({delegatesFocus:this[t],mode:this[g]}),o=document.importNode(e.content,!0);n.append(o),this[b]=n}else this[b]=null;const p = this[b].querySelector('[part="container"]');p.insertAdjacentHTML('beforeend', '<wes-icon part="icon" symbol="chevrondown"></wes-icon>')}}get[g](){return"closed"}})));var L;const j=Symbol("checkSize"),I=Symbol("closestAvailableItemIndex"),q=Symbol("contentSlot"),P=e,N=Symbol("defaultTabIndex"),D=t,M=Symbol("effectEndTarget"),F=n,$=o,U=Symbol("getItemText"),B=Symbol("goDown"),H=Symbol("goEnd"),W=Symbol("goFirst"),_=Symbol("goLast"),X=Symbol("goLeft"),G=Symbol("goNext"),Z=Symbol("goPrevious"),J=Symbol("goRight"),K=Symbol("goStart"),Q=Symbol("goToItemWithPrefix"),V=Symbol("goUp"),Y=r,ee=i,te=Symbol("inputDelegate"),ne=Symbol("itemsDelegate"),oe=Symbol("keydown"),re=Symbol("mouseenter"),ie=Symbol("mouseleave"),se=s,ae=a,le=l,ce=c,de=Symbol("renderDataToElement"),ue=d,he=u,be=Symbol("scrollTarget"),ge=h,pe=b,me=g,fe=Symbol("startEffect"),ve=p,we=m,ye=Symbol("swipeDown"),Se=Symbol("swipeDownComplete"),xe=Symbol("swipeLeft"),Ce=Symbol("swipeLeftTransitionEnd"),Ae=Symbol("swipeRight"),Ee=Symbol("swipeRightTransitionEnd"),ke=Symbol("swipeUp"),Re=Symbol("swipeUpComplete"),Te=Symbol("swipeStart"),ze=Symbol("swipeTarget"),Oe=Symbol("tap"),Le=f,je=Symbol("toggleSelectedFlag");"true"===new URLSearchParams("").get("elixdebug")&&(window.elix={internal:{checkSize:j,closestAvailableItemIndex:I,contentSlot:q,defaultState:P,defaultTabIndex:N,delegatesFocus:D,effectEndTarget:M,firstRender:F,focusTarget:$,getItemText:U,goDown:B,goEnd:H,goFirst:W,goLast:_,goLeft:X,goNext:G,goPrevious:Z,goRight:J,goStart:K,goToItemWithPrefix:Q,goUp:V,hasDynamicTemplate:Y,ids:ee,inputDelegate:te,itemsDelegate:ne,keydown:oe,mouseenter:re,mouseleave:ie,nativeInternals:se,event:event,raiseChangeEvents:ae,render:le,renderChanges:ce,renderDataToElement:de,rendered:ue,rendering:he,scrollTarget:be,setState:ge,shadowRoot:pe,shadowRootMode:me,startEffect:fe,state:ve,stateEffects:we,swipeDown:ye,swipeDownComplete:Se,swipeLeft:xe,swipeLeftTransitionEnd:Ce,swipeRight:Ae,swipeRightTransitionEnd:Ee,swipeUp:ke,swipeUpComplete:Re,swipeStart:Te,swipeTarget:ze,tap:Oe,template:Le,toggleSelectedFlag:je}});const Ie={html(markup, ...t) { return createTemplateFromHtml(markup + t.join('')); }};var qe=[],Pe=[];function Ne(e,t){if(e&&"undefined"!=typeof document){var n,o=!0===t.prepend?"prepend":"append",r=!0===t.singleTag,i="string"==typeof t.container?document.querySelector(t.container):document.getElementsByTagName("head")[0];if(r){var s=qe.indexOf(i);-1===s&&(s=qe.push(i)-1,Pe[s]={}),n=Pe[s]&&Pe[s][o]?Pe[s][o]:Pe[s][o]=a()}else n=a();65279===e.charCodeAt(0)&&(e=e.substring(1)),n.styleSheet?n.styleSheet.cssText+=e:n.appendChild(document.createTextNode(e))}function a(){var e=document.createElement("style");if(e.setAttribute("type","text/css"),t.attributes)for(var n=Object.keys(t.attributes),r=0;r<n.length;r++)e.setAttribute(n[r],t.attributes[n[r]]);var s="prepend"===o?"afterbegin":"beforeend";return i.insertAdjacentElement(s,e),e}}var De="/***************************************\n * This file is automatically generated.\n * Please do not edit this file. Source file is common.css\n ***************************************/\n\n/* Copyright (c) 2015-present, salesforce.com, inc. All rights reserved\nLicensed under BSD 3-Clause - see LICENSE.txt or git.io/sfdc-license */\n\n/* Document\n * --------------------- */\n\n/**\n * Normalize box sizing to border box for all browsers.\n */\n\n*,\n::before,\n::after {\n  box-sizing: border-box;\n}\n\n/* Grouping Content\n * --------------------- */\n\n/**\n * Add the correct display in IE.\n */\n\nmain {\n  display: block;\n}\n\n/**\n * 1. Remove the margin in all browsers.\n * 2. Remove the padding in all browsers.\n * 3. Normalize font sizes in all browsers.\n * 4. Normalize font weight in all browsers.\n */\n\nh1,\nh2,\nh3,\nh4,\nh5,\nh6 {\n  font-size: 0.875rem; /* 3 */\n  font-weight: normal; /* 4 */\n  margin: 0; /* 1 */\n  padding: 0; /* 2 */\n}\n\n/**\n * Remove the margin in all browsers.\n */\n\np {\n  margin: 0;\n}\n\n/**\n * 1. Remove the margin in all browsers.\n * 2. Normalize border styles in all browsers.\n */\n\nhr {\n  margin: 0; /* 1 */\n  border: 0; /* 2 */\n  border-top-width: 1px; /* 2 */\n  border-style: solid; /* 2 */\n  border-color: inherit; /* 2 */\n}\n\n/**\n * 1. Remove the margin in all browsers.\n * 2. Remove the padding in all browsers.\n * 3. Remove the list-style in all browsers, sub-system dependant.\n */\n\nol,\nul {\n  list-style: none; /* 3 */\n  padding: 0; /* 2 */\n  margin: 0; /* 1 */\n}\n\n/**\n * Remove the margin in all browsers.\n */\n\ndl,\ndt,\ndd {\n  margin: 0;\n}\n\n/* Form Controls\n * --------------------- */\n\n/**\n * Remove the margin in all browsers.\n */\n\nform {\n  margin: 0;\n}\n\n/**\n * 1. Correct font properties not being inherited.\n * 2. Remove the margin in Firefox and Safari.\n * 3. Fix correct color not being inherited.\n */\n\nbutton,\ninput,\noptgroup,\nselect,\ntextarea {\n  font: inherit; /* 1 */\n  margin: 0; /* 2 */\n  color: inherit; /* 3 */\n}\n\n/**\n * Address inconsistent `text-transform` inheritance for `button` and `select`.\n */\n\nbutton,\nselect {\n  text-transform: none;\n}\n\n/**\n * 1. Correct inability to style clickable `input` types in iOS.\n * 2. Normalizes cursor indicator on clickable elements.\n */\n\nbutton,\n[type='button'],\n[type='reset'],\n[type='submit'] {\n  -webkit-appearance: button; /* 1 */\n  appearance: button; /* 1 */\n  cursor: pointer; /* 2 */\n}\n\n/**\n * Prevent option or optgroup to increase the width of a select.\n */\n\nselect {\n  max-width: 100%;\n}\n\n/**\n * Correct the outline style in Safari.\n */\n\ninput:focus,\nbutton:focus,\nselect:focus,\ntextarea:focus {\n  outline-offset: 0;\n}\n\n/**\n * Remove the inner border and padding in Firefox.\n */\n\n::-moz-focus-inner {\n  border-style: none;\n  padding: 0;\n}\n\n/**\n * 1. Correct the text wrapping in Edge 18- and IE.\n * 2. Correct the color inheritance from `fieldset` elements in IE.\n * 3. Remove the padding so developers are not caught out when they zero out 'fieldset' elements in all browsers.\n */\n\nlegend {\n  color: inherit; /* 2 */\n  display: table; /* 1 */\n  max-width: 100%; /* 1 */\n  white-space: normal; /* 1 */\n  padding: 0; /* 3 */\n}\n\n/**\n * Add the correct vertical alignment in Chrome and Firefox.\n */\n\nprogress {\n  vertical-align: baseline;\n}\n\n/**\n * Correct the cursor style of increment and decrement buttons in Safari.\n */\n\n::-webkit-inner-spin-button,\n::-webkit-outer-spin-button {\n  height: auto;\n}\n\n/**\n * 1. Correct the odd appearance in Chrome and Safari.\n * 2. Correct the outline style in Safari.\n */\n\n[type='search'] {\n  -webkit-appearance: textfield; /* 1 */\n  outline-offset: -2px; /* 2 */\n}\n\n/**\n * Remove the inner padding in Chrome and Safari on macOS.\n */\n\n::-webkit-search-decoration {\n  -webkit-appearance: none;\n}\n\n/**\n * 1. Correct the inability to style clickable types in iOS and Safari.\n * 2. Change font properties to 'inherit' in Safari.\n */\n\n::-webkit-file-upload-button {\n  -webkit-appearance: button; /* 1 */\n  font: inherit; /* 2 */\n}\n\n/**\n * Restore the focus styles unset by the previous rule.\n */\n\n:-moz-focusring {\n  outline: 1px dotted ButtonText;\n}\n\n/**\n * Remove the additional ':invalid' styles in Firefox.\n * See: https://github.com/mozilla/gecko-dev/blob/2f9eacd9d3d995c937b4251a5557d95d494c9be1/layout/style/res/forms.css#L728-L737\n */\n\n:-moz-ui-invalid {\n  box-shadow: none;\n}\n\n/* Text-level semantics\n * --------------------- */\n\n/**\n * Normalizes cursor indicator on clickable elements.\n */\n\na {\n  cursor: pointer;\n}\n\n/**\n * Add the correct text decoration in Chrome, Edge, and Safari.\n */\n\nabbr[title] {\n  text-decoration: underline dotted;\n  cursor: help;\n}\n\n/**\n * Add the correct font weight in Edge and Safari.\n */\n\nb,\nstrong {\n  font-weight: bolder;\n}\n\n/**\n * 1. Improve consistency of default fonts in all browsers. (https://github.com/sindresorhus/modern-normalize/issues/3)\n * 2. Correct the odd 'em' font sizing in all browsers.\n * 3. Remove the margin in all browsers.\n */\n\ncode,\nkbd,\nsamp,\npre {\n  font-family: ui-monospace, SFMono-Regular, Consolas, 'Liberation Mono', Menlo, monospace; /* 1 */\n  font-size: 1em; /* 2 */\n  margin: 0; /* 3 */\n}\n\n/**\n * Prevent overflow of the container in all browsers\n */\n\npre {\n  overflow: auto;\n  -ms-overflow-style: scrollbar;\n}\n\n/**\n * Add the correct font size in all browsers.\n */\n\nsmall {\n  font-size: 80%;\n}\n\n/**\n * Prevent 'sub' and 'sup' elements from affecting the line height in all browsers.\n */\n\nsub,\nsup {\n  font-size: 75%;\n  line-height: 0;\n  position: relative;\n  vertical-align: baseline;\n}\n\nsub {\n  bottom: -0.25em;\n}\n\nsup {\n  top: -0.5em;\n}\n\n/* Embedded content\n * --------------------- */\n\n/**\n * Change the alignment on media elements in all browsers.\n */\n\naudio,\ncanvas,\niframe,\nimg,\nsvg,\nvideo {\n  vertical-align: middle;\n}\n\n/**\n * Make images responsive by default.\n */\n\nimg,\n[type='image'] {\n  max-width: 100%;\n  height: auto;\n}\n\n/**\n * Remove the border on iframes in all browsers.\n */\n\niframe {\n  border-style: none;\n}\n\n/**\n * Change the fill color to match the text color in all browsers.\n */\n\nsvg:not([fill]) {\n  fill: currentColor;\n}\n\n/* Tabular data\n * --------------------- */\n\n/**\n * 1. Remove text indentation from table contents in Chrome and Safari. [Chromium Bug 999088](https://bugs.chromium.org/p/chromium/issues/detail?id=999088), [Webkit Bug 201297](https://bugs.webkit.org/show_bug.cgi?id=201297)\n * 2. Correct table border color inheritance in all Chrome and Safari. [Chromium Bug 935729](https://bugs.chromium.org/p/chromium/issues/detail?id=935729), [Webkit Bug 195016](https://bugs.webkit.org/show_bug.cgi?id=195016)\n * 3. Collapse border spacing in all browsers\n */\n\ntable {\n  text-indent: 0; /* 1 */\n  border-color: inherit; /* 2 */\n  border-collapse: collapse; /* 3 */\n}\n\n/* Shadow host\n * --------------------- */\n\n/**\n * 1. Change the line height in all browsers\n * 2. Change the base font size in all browsers, inherit 100% from `html`\n * 3. Prevent adjustments of font size after orientation changes in IE on Windows Phone and in iOS\n * 4. Remove the grey highlight on links in iOS\n * 5. Font Stack:\n *   a. Safari for OS X and iOS (San Francisco)\n *   b. Chrome < 56 for OS X (San Francisco)\n *   c. Windows\n *   d. Android\n *   e. Web Fallback\n *   f. Emoji font stack [Mac, Windows, Linux]\n */\n\n:host {\n  line-height: 1.5;\n  font-size: 0.875rem;\n  -webkit-tap-highlight-color: transparent;\n  -ms-text-size-adjust: 100%;\n  -webkit-text-size-adjust: 100%;\n  font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, 'Helvetica Neue', Arial, sans-serif,\n    'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol';\n}\n";function Me(e){if(e.__esModule)return e;var t=Object.defineProperty({},"__esModule",{value:!0});return Object.keys(e).forEach((function(n){var o=Object.getOwnPropertyDescriptor(e,n);Object.defineProperty(t,n,o.get?o:{enumerable:!0,get:function(){return e[n]}})})),t}Ne(De,{});var Fe=Me(Object.freeze({__proto__:null,reflectAttribute:(e,t,n)=>{n?e.setAttribute(t,"boolean"==typeof n?"":n):e.removeAttribute(t)},delegateAttribute:(e,t,n,o)=>{o?(t.setAttribute(n,"boolean"==typeof o?"":o),e.removeAttribute(n)):t.removeAttribute(n)},replaceDefaultSlot:(e,t)=>{const n=e.querySelector("slot:not([name])");n&&n.replaceWith(t)},removeSlot:(e,t)=>{const n=e.querySelector(`slot[name="${t}"]`);n&&n.remove()},dispatchCustomEvent:(e,t,n)=>{const o=e.tagName.split("-")[0].toLowerCase(),r=new CustomEvent(o+"-"+t,n);return e.dispatchEvent(r),r}})),$e="/* Copyright (c) 2015-present, salesforce.com, inc. All rights reserved\n  Licensed under BSD 3-Clause - see LICENSE.txt or git.io/sfdc-license */\n\n[part~='base'] {\n  font-family: var(--wes-g-font-family-sans);\n  font-weight: 400;\n  font-size: var(--wes-g-font-size-3);\n}\n\n[part~='container'] {\n  --sds-c-icon-sizing-width: var(--wes-g-font-size-3);\n  --sds-c-icon-sizing-border: 0;\n  --sds-c-icon-color-foreground: var(--wes-g-color-palette-neutral-50);\n\n  display: flex;\n  align-items: center;\n  justify-content: end;\n  position: relative;\n  min-height: 2.75rem;\n  background-color: var(--wes-g-color-neutral-base-1);\n  border-width: var(--wes-g-sizing-border-1);\n  border-style: solid;\n  border-color: var(--wes-g-color-palette-neutral-50);\n  border-radius: var(--wes-g-radius-border-2);\n  color: var(--wes-g-color-palette-neutral-10);\n}\n\n:host([disabled]) [part~='container'] {\n  background-color: var(--wes-g-color-palette-neutral-95);\n  border-color: var(--wes-g-color-palette-neutral-80);\n}\n\n:host(:not([disabled]):not([invalidated])) [part~='container']:hover {\n  --sds-c-icon-color-foreground: var(--wes-g-color-palette-blue-20);\n\n  border-color: var(--wes-g-color-palette-blue-20);\n  border-width: var(--wes-g-sizing-border-2);\n  background: var(--wes-g-color-palette-cloud-blue-95);\n  color: var(--wes-g-color-palette-blue-20);\n}\n\n:host(:not([disabled]):not([invalidated])) [part~='container']:hover [part~='select'] {\n  padding-inline-start: calc(var(--wes-g-spacing-4) - 1px);\n  padding-inline-end: calc(var(--wes-g-spacing-7) - 1px);\n}\n\n:host(:focus-within) [part~='container'] {\n  box-shadow: 0 0 0 5px var(--wes-g-color-palette-blue-60);\n}\n\n[part~='select'] {\n  width: 100%;\n  height: 100%;\n  padding-inline-start: var(--wes-g-spacing-4);\n  padding-inline-end: var(--wes-g-spacing-7);\n  padding-block: var(--wes-g-spacing-2);\n  font-size: var(--wes-g-font-size-3);\n  line-height: 1.5;\n  border: none;\n  background: transparent;\n  appearance: none;\n}\n\n[part~='select']:focus {\n  outline: none;\n}\n\n[part~='label'] {\n  display: inline-flex;\n  margin-block-end: var(--wes-g-spacing-1);\n  color: var(--wes-g-color-palette-neutral-10);\n  font-size: var(--wes-g-font-size-3);\n}\n\n:host([required]) [part~='label']::before {\n  content: '*';\n  color: var(--wes-g-color-palette-red-50);\n  margin-inline-end: 2px;\n}\n\n[part~='icon'] {\n  position: absolute;\n  padding-inline-end: var(--wes-g-spacing-4);\n  pointer-events: none;\n}\n\n:host(:not([disabled])) [part~='select']:hover {\n  cursor: pointer;\n}\n\n:host(:not([value])) [part~='container'] {\n  color: var(--wes-g-color-palette-neutral-50);\n}\n\n:host(:not([value])) [part~='container']:hover {\n  color: var(--wes-g-color-palette-blue-20);\n}\n\n::slotted([slot='help-text']),\n::slotted([slot='validation-text']) {\n  margin-block-start: var(--wes-g-spacing-1);\n  font-size: var(--wes-g-font-size-1);\n  color: var(--wes-g-color-palette-neutral-50);\n  font-family: var(--wes-g-font-family-sans);\n  font-weight: 400;\n}\n\n::slotted([slot='validation-text']) {\n  display: none;\n}\n\n:host([invalidated]) [part~='container'] {\n  border-width: var(--wes-g-sizing-border-2);\n  border-color: var(--wes-g-color-palette-red-50);\n}\n\n:host([invalidated]) ::slotted([slot='validation-text']) {\n  display: block;\n  color: var(--wes-g-color-palette-red-50);\n}\n\n:host([invalidated]) [part~='container']:hover {\n  --sds-c-icon-color-foreground: var(--wes-g-color-palette-red-20);\n\n  border-color: var(--wes-g-color-palette-red-20);\n  border-width: var(--wes-g-sizing-border-2);\n  background: var(--wes-g-color-palette-red-95);\n  color: var(--wes-g-color-palette-pink-20);\n}\n";function Ue(e){return Math.random().toString(16).slice(2)}Ne($e,{}),Object.assign(S,{required:!0,invalidated:!0});class Be extends(function(e){return class extends e{get[q](){const e=this[pe]&&this[pe].querySelector("slot:not([name])");return this[pe]&&e||console.warn(`SlotContentMixin expects ${this.constructor.name} to define a shadow tree that includes a default (unnamed) slot.\nSee https://elix.org/documentation/SlotContentMixin.`),e}get[P](){return Object.assign(super[P]||{},{content:null})}[ue](e){if(super[ue]&&super[ue](e),this[F]){const e=this[q];e&&e.addEventListener("slotchange",(async()=>{this[ae]=!0;const t=e.assignedNodes({flatten:!0});Object.freeze(t),this[ge]({content:t}),await Promise.resolve(),this[ae]=!1}))}}}}(O)){get[P](){return Object.assign(super[P],{id:`select-${Ue()}`,value:""})}get autocomplete(){return this[ve].autocomplete}set autocomplete(e){return this[ge]({autocomplete:e})}get name(){return this[ve].name}set name(e){return this[ge]({name:e})}get id(){return this[ve].id}set id(e){return this[ge]({id:e})}get required(){return this[ve].required}set required(e){return this[ge]({required:e})}get disabled(){return this[ve].disabled}set disabled(e){return this[ge]({disabled:e})}get value(){return this[ve].value}set value(e){return this[ge]({value:e})}get ariaLabel(){return this[ve].ariaLabel}set ariaLabel(e){return this[ge]({ariaLabel:e})}get invalidated(){return this[ve].invalidated}set invalidated(e){this[ge]({invalidated:e})}get validationText(){return this[ve].validationText}set validationText(e){this[ge]({validationText:e})}[le](e){super[le](e);const t=this[b].querySelector("select"),n=this[b].querySelector('[part~="label"]'),{ariaLabel:o,autocomplete:r,id:i,name:s,value:a,content:l,required:c,disabled:d}=this[ve];if(e.ariaLabel&&Fe.delegateAttribute(this,t,"aria-label",o),e.autocomplete&&Fe.delegateAttribute(this,t,"autocomplete",r),e.id&&(this.setAttribute("id",i),o||(Fe.delegateAttribute(this,t,"id",i),Fe.delegateAttribute(this,n,"for",i))),e.name&&Fe.delegateAttribute(this,t,"name",s),e.content&&l&&this.constructOptions(l),e.validationText){let{validationText:e}=this[ve];if(e){const t=this.querySelector('[slot="validation-text"]');t?e=t.innerText:this.insertAdjacentHTML("beforeend",`<span slot="validation-text">${e}</span>`),Fe.reflectAttribute(this,"validation-text",e)}}e.value&&(Fe.reflectAttribute(this,"value",a),this.configureSelectedOption()),e.required&&(c?Fe.reflectAttribute(t,"required",!0):Fe.reflectAttribute(t,"required")),e.disabled&&(d?Fe.reflectAttribute(t,"disabled",!0):Fe.reflectAttribute(t,"disabled"))}[ue](e){super[ue](e);const t=this[b].querySelector("select");if(this[F]&&(this.onFirstRender(),this.bindEventListeners(t)),e.content&&this.configureSelectedOption(),e.invalidated)if(this[ve].invalidated){const e=this[b].querySelector("slot[name='validation-text']");e&&Fe.reflectAttribute(t,"aria-errormessage",e.id),Fe.reflectAttribute(t,"aria-invalid","true")}else Fe.reflectAttribute(t,"aria-errormessage"),Fe.reflectAttribute(this,"invalidated"),Fe.reflectAttribute(t,"aria-invalid")}onFirstRender(){const e=this[b].querySelector("slot[name='help-text']");e.insertAdjacentHTML("beforebegin",`<slot name="validation-text" role="alert" id="validation-text-message-${Ue()}"></slot>`),this.setHelpTextAriaRelation(e),this.validateSelectLabel()}setHelpTextAriaRelation(e){if(e.assignedElements().length>0){const t=this[b].querySelector("select"),n=`help-text-message-${Ue()}`;Fe.delegateAttribute(this,t,"aria-describedby",n),Fe.delegateAttribute(this,e,"id",n)}}validateSelectLabel(){const e=this[b].querySelector('slot[name="label"]'),{ariaLabel:t,id:n}=this[ve];!t&&e.assignedNodes().length<1&&console.warn(`<wes-select id="${n}"> does not have an associated label. Please provide a label for this input or use aria-label.`)}bindEventListeners(e){e.addEventListener("change",(()=>{const t=e.value;Fe.dispatchCustomEvent(this,"change",{detail:{content:t}}),Fe.reflectAttribute(this,"value",t),this[ve].required&&this.validateRequiredSelect(t)}))}validateRequiredSelect(e){""===e?Fe.reflectAttribute(this,"invalidated",!0):Fe.reflectAttribute(this,"invalidated")}constructOptions(e){const t=this[b].querySelector('[part~="select"]');let n=null;n=e.filter((e=>"OPTION"===e.tagName)),n.length>0&&[...n].forEach((e=>{t.appendChild(e)}))}configureSelectedOption(){const{value:e}=this[ve],t=this[b].querySelector('[part~="select"]'),n=t.children;if(n.length>0){let o=!0;[...n].forEach((n=>{"OPTION"===n.tagName&&n.value===e?(Fe.reflectAttribute(n,"selected",!0),t.value=e,o=!1):Fe.reflectAttribute(n,"selected")})),o&&(t.value="")}}get[Le](){return Ie.html(`
      <style>
        ${escapeXml(De)}
        ${escapeXml($e)}
      </style>
      ${'<div part="base">\n    <label part="label">\n      <slot name="label"></slot>\n    </label>\n    <div part="container">\n      <select part="select"></select>\n      <slot></slot>\n    </div>\n</div>\n<slot name="help-text"></slot>'}
    `)}}return Be;
 
})();