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
  
  const e=Symbol("defaultState"),t=Symbol("delegatesFocus"),n=Symbol("firstRender"),i=Symbol("focusTarget"),r=Symbol("hasDynamicTemplate"),s=Symbol("ids"),o=Symbol("nativeInternals"),a=Symbol("raiseChangeEvents"),l=Symbol("render"),c=Symbol("renderChanges"),d=Symbol("rendered"),u=Symbol("rendering"),h=Symbol("setState"),b=Symbol("shadowRoot"),m=Symbol("shadowRootMode"),g=Symbol("state"),f=Symbol("stateEffects"),p=Symbol("template"),y={tabindex:"tabIndex"},w={tabIndex:"tabindex"};function v(e){if(e===HTMLElement||Object.getPrototypeOf(e.prototype)===null)return[];const t=Object.getPrototypeOf(e.prototype).constructor;let n=t.observedAttributes;n||(n=v(t));const i=Object.getOwnPropertyNames(e.prototype).filter((t=>{const n=Object.getOwnPropertyDescriptor(e.prototype,t);return n&&"function"==typeof n.set})).map((e=>function(e){let t=w[e];if(!t){const n=/([A-Z])/g;t=e.replace(n,"-$1").toLowerCase(),w[e]=t}return t}(e))).filter((e=>n.indexOf(e)<0));return n.concat(i)}const S={checked:!0,defer:!0,disabled:!0,hidden:!0,ismap:!0,multiple:!0,noresize:!0,readonly:!0,selected:!0},x=Symbol("state"),E=Symbol("raiseChangeEventsInNextRender"),A=Symbol("changedSinceLastRender");function C(e,t){const n={};for(const s in t)i=t[s],r=e[s],(i instanceof Date&&r instanceof Date?i.getTime()===r.getTime():i===r)||(n[s]=!0);var i,r;return n}const L=new Map,k=Symbol("shadowIdProxy"),T=Symbol("proxyElement"),O={get(e,t){const n=e[T][b];return n&&"string"==typeof t?n.getElementById(t):null}};const R=function(e){return class extends e{attributeChangedCallback(e,t,n){if(super.attributeChangedCallback&&super.attributeChangedCallback(e,t,n),n!==t&&!this[u]){const t=function(e){let t=y[e];if(!t){const n=/-([a-z])/g;t=e.replace(n,(e=>e[1].toUpperCase())),y[e]=t}return t}(e);if(t in this){const s=S[e]?(i=e,"boolean"==typeof(r=n)?r:"string"==typeof r&&(""===r||i.toLowerCase()===r.toLowerCase())):n;this[t]=s}}var i,r}static get observedAttributes(){return v(this)}}}(function(t){class i extends t{constructor(){super(),this[n]=void 0,this[a]=!1,this[A]=null,this[h](this[e])}connectedCallback(){super.connectedCallback&&super.connectedCallback(),this[c]()}get[e](){return super[e]||{}}[l](e){super[l]&&super[l](e)}[c](){void 0===this[n]&&(this[n]=!0);const e=this[A];if(this[n]||e){const t=this[a];this[a]=this[E],this[E]=!1,this[u]=!0,this[l](e),this[u]=!1,this[A]=null,this[d](e),this[n]=!1,this[a]=t}}[d](e){super[d]&&super[d](e)}async[h](e){this[u]&&console.warn(`${this.constructor.name} called [setState] during rendering, which you should avoid.\nSee https://elix.org/documentation/ReactiveMixin.`);const{state:t,changed:i}=function(e,t){const n=Object.assign({},e[x]),i={};let r=t;for(;;){const t=C(n,r);if(0===Object.keys(t).length)break;Object.assign(n,r),Object.assign(i,t),r=e[f](n,t)}return{state:n,changed:i}}(this,e);if(this[x]&&0===Object.keys(i).length)return;Object.freeze(t),this[x]=t,this[a]&&(this[E]=!0);const r=void 0===this[n]||null!==this[A];this[A]=Object.assign(this[A]||{},i);this.isConnected&&!r&&(await Promise.resolve(),this[c]())}get[g](){return this[x]}[f](e,t){return super[f]?super[f](e,t):{}}}return"true"===new URLSearchParams("").get("elixdebug")&&Object.defineProperty(i.prototype,"state",{get(){return this[g]}}),i}(function(e){return class extends e{get[s](){if(!this[k]){const e={[T]:this};this[k]=new Proxy(e,O)}return this[k]}[l](e){if(super[l]&&super[l](e),void 0===this[b]){const e=function(e){let t=e[r]?void 0:L.get(e.constructor);if(void 0===t){if(t=e[p],t&&!(t instanceof HTMLTemplateElement))throw`Warning: the [template] property for ${e.constructor.name} must return an HTMLTemplateElement.`;e[r]||L.set(e.constructor,t||null)}return t}(this);if(e){const n=this.attachShadow({delegatesFocus:this[t],mode:this[m]}),i=document.importNode(e.content,!0);n.append(i),this[b]=n}else this[b]=null}}get[m](){return"closed"}}}(HTMLElement))),j=Symbol("checkSize"),I=Symbol("closestAvailableItemIndex"),z=Symbol("contentSlot"),P=e,M=Symbol("defaultTabIndex"),D=t,N=Symbol("effectEndTarget"),F=n,V=i,U=Symbol("getItemText"),H=Symbol("goDown"),$=Symbol("goEnd"),W=Symbol("goFirst"),B=Symbol("goLast"),q=Symbol("goLeft"),_=Symbol("goNext"),X=Symbol("goPrevious"),G=Symbol("goRight"),Z=Symbol("goStart"),J=Symbol("goToItemWithPrefix"),K=Symbol("goUp"),Q=r,Y=s,ee=Symbol("inputDelegate"),te=Symbol("itemsDelegate"),ne=Symbol("keydown"),ie=Symbol("mouseenter"),re=Symbol("mouseleave"),se=o,oe=a,ae=l,le=c,ce=Symbol("renderDataToElement"),de=d,ue=u,he=Symbol("scrollTarget"),be=h,me=b,ge=m,fe=Symbol("startEffect"),pe=g,ye=f,we=Symbol("swipeDown"),ve=Symbol("swipeDownComplete"),Se=Symbol("swipeLeft"),xe=Symbol("swipeLeftTransitionEnd"),Ee=Symbol("swipeRight"),Ae=Symbol("swipeRightTransitionEnd"),Ce=Symbol("swipeUp"),Le=Symbol("swipeUpComplete"),ke=Symbol("swipeStart"),Te=Symbol("swipeTarget"),Oe=Symbol("tap"),Re=p,je=Symbol("toggleSelectedFlag");function Ie(e){const t=ze(e,(e=>e instanceof HTMLElement&&e.matches('a[href],area[href],button:not([disabled]),details,iframe,input:not([disabled]),select:not([disabled]),textarea:not([disabled]),[contentEditable="true"],[tabindex]')&&e.tabIndex>=0)),{value:n}=t.next();return n instanceof HTMLElement?n:null}function*ze(e,t){let n;if(t(e)&&(yield e),e instanceof HTMLElement&&e.shadowRoot)n=e.shadowRoot.children;else{const t=e instanceof HTMLSlotElement?e.assignedNodes({flatten:!0}):[];n=t.length>0?t:e.childNodes}if(n)for(let e=0;e<n.length;e++)yield*ze(n[e],t)}"true"===new URLSearchParams("").get("elixdebug")&&(window.elix={internal:{checkSize:j,closestAvailableItemIndex:I,contentSlot:z,defaultState:P,defaultTabIndex:M,delegatesFocus:D,effectEndTarget:N,firstRender:F,focusTarget:V,getItemText:U,goDown:H,goEnd:$,goFirst:W,goLast:B,goLeft:q,goNext:_,goPrevious:X,goRight:G,goStart:Z,goToItemWithPrefix:J,goUp:K,hasDynamicTemplate:Q,ids:Y,inputDelegate:ee,itemsDelegate:te,keydown:ne,mouseenter:ie,mouseleave:re,nativeInternals:se,event:event,raiseChangeEvents:oe,render:ae,renderChanges:le,renderDataToElement:ce,rendered:de,rendering:ue,scrollTarget:he,setState:be,shadowRoot:me,shadowRootMode:ge,startEffect:fe,state:pe,stateEffects:ye,swipeDown:we,swipeDownComplete:ve,swipeLeft:Se,swipeLeftTransitionEnd:xe,swipeRight:Ee,swipeRightTransitionEnd:Ae,swipeUp:Ce,swipeUpComplete:Le,swipeStart:ke,swipeTarget:Te,tap:Oe,template:Re,toggleSelectedFlag:je}});const Pe=document.createElement("div");const shadowRoot = Pe.attachShadow({mode:"closed",delegatesFocus:!0});shadowRoot.delegatesFocus;const Me=new Set;function De(e){const t=function(e){const t=/rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*[\d.]+\s*)?\)/.exec(e);if(t){return{r:t[1],g:t[2],b:t[3]}}return null}(Ne(e));if(t){const n=function(e){const t=e.r/255,n=e.g/255,i=e.b/255,r=Math.max(t,n,i),s=Math.min(t,n,i);let o=0,a=0,l=(r+s)/2;const c=r-s;if(0!==c){switch(a=l>.5?c/(2-c):c/(r+s),r){case t:o=(n-i)/c+(n<i?6:0);break;case n:o=(i-t)/c+2;break;case i:o=(t-n)/c+4}o/=6}return{h:o,s:a,l:l}}(t),i=n.l<.5;e[be]({dark:i})}}function Ne(e){const t="rgb(255,255,255)";if(e instanceof Document)return t;const n=getComputedStyle(e).backgroundColor;if(n&&("transparent"!==n&&"rgba(0, 0, 0, 0)"!==n))return n;if(e.assignedSlot)return Ne(e.assignedSlot);const i=e.parentNode;return i instanceof ShadowRoot?Ne(i.host):i instanceof Element?Ne(i):t}function Fe(e){return class extends e{get ariaLabel(){return this[pe].ariaLabel}set ariaLabel(e){this[pe].removingAriaAttribute||this[be]({ariaLabel:String(e)})}get ariaLabelledby(){return this[pe].ariaLabelledby}set ariaLabelledby(e){this[pe].removingAriaAttribute||this[be]({ariaLabelledby:String(e)})}get[P](){return Object.assign(super[P]||{},{ariaLabel:null,ariaLabelledby:null,inputLabel:null,removingAriaAttribute:!1})}[ae](e){if(super[ae]&&super[ae](e),this[F]&&this.addEventListener("focus",(()=>{this[oe]=!0;const e=Ue(this,this[pe]);this[be]({inputLabel:e}),this[oe]=!1})),e.inputLabel){const{inputLabel:e}=this[pe];e?this[ee].setAttribute("aria-label",e):this[ee].removeAttribute("aria-label")}}[de](e){if(super[de]&&super[de](e),this[F]){(window.requestIdleCallback||setTimeout)((()=>{const e=Ue(this,this[pe]);this[be]({inputLabel:e})}))}const{ariaLabel:t,ariaLabelledby:n}=this[pe];e.ariaLabel&&!this[pe].removingAriaAttribute&&this.getAttribute("aria-label")&&(this.setAttribute("delegated-label",t),this[be]({removingAriaAttribute:!0}),this.removeAttribute("aria-label")),e.ariaLabelledby&&!this[pe].removingAriaAttribute&&this.getAttribute("aria-labelledby")&&(this.setAttribute("delegated-labelledby",n),this[be]({removingAriaAttribute:!0}),this.removeAttribute("aria-labelledby")),e.removingAriaAttribute&&this[pe].removingAriaAttribute&&this[be]({removingAriaAttribute:!1})}[ye](e,t){const n=super[ye]?super[ye](e,t):{};if(t.ariaLabel&&e.ariaLabel||t.selectedText&&e.ariaLabelledby&&this.matches(":focus-within")){const t=Ue(this,e);Object.assign(n,{inputLabel:t})}return n}}}function Ve(e){if("selectedText"in e)return e.selectedText;if("value"in e&&"options"in e){const t=e.value,n=e.options.find((e=>e.value===t));return n?n.innerText:""}return"value"in e?e.value:e.innerText}function Ue(e,t){const{ariaLabel:n,ariaLabelledby:i}=t,r=e.isConnected?e.getRootNode():null;let s=null;if(i&&r){s=i.split(" ").map((n=>{const i=r.getElementById(n);return i?i===e&&null!==t.value?t.selectedText:Ve(i):""})).join(" ")}else if(n)s=n;else if(r){const t=e.id;if(t){const e=r.querySelector(`[for="${t}"]`);e instanceof HTMLElement&&(s=Ve(e))}if(null===s){const t=e.closest("label");t&&(s=Ve(t))}}return s&&(s=s.trim()),s}window.matchMedia("(prefers-color-scheme: dark)").addListener((()=>{Me.forEach((e=>{De(e)}))}));const He={html:(e,...t)=>$e.html(e,...t).content},$e={html(markup, ...t) { return createTemplateFromHtml(markup + t.join('')); }};let We=!1;const Be=Symbol("focusVisibleChangedListener");function qe(e){return class extends e{constructor(){super(),this.addEventListener("focusout",(e=>{Promise.resolve().then((()=>{const t=e.relatedTarget||document.activeElement,n=this===t,i=function(e,t){let n=t;for(;n;){const t=n.assignedSlot||n.parentNode||n.host;if(t===e)return!0;n=t}return!1}(this,t);!n&&!i&&(this[be]({focusVisible:!1}),document.removeEventListener("focusvisiblechange",this[Be]),this[Be]=null)}))})),this.addEventListener("focusin",(()=>{Promise.resolve().then((()=>{this[pe].focusVisible!==We&&this[be]({focusVisible:We}),this[Be]||(this[Be]=()=>{this[be]({focusVisible:We})},document.addEventListener("focusvisiblechange",this[Be]))}))}))}get[P](){return Object.assign(super[P]||{},{focusVisible:!1})}[ae](e){if(super[ae]&&super[ae](e),e.focusVisible){const{focusVisible:e}=this[pe];this.toggleAttribute("focus-visible",e)}}get[Re](){const e=super[Re]||$e.html``;return e.content.append(He.html(`
        <style>
          :host {
            outline: none;
          }

          :host([focus-visible]:focus-within) {
            outline-color: Highlight; /* Firefox */
            outline-color: -webkit-focus-ring-color; /* All other browsers */
            outline-style: auto;
          }
        </style>
      `)),e}}}function _e(e){if(We!==e){We=e;const t=new CustomEvent("focusvisiblechange",{detail:{focusVisible:We}});document.dispatchEvent(t)}}function Xe(e){return class extends e{constructor(){super();const e=this;!this[se]&&e.attachInternals&&(this[se]=e.attachInternals())}checkValidity(){return this[se].checkValidity()}get[P](){return Object.assign(super[P]||{},{name:"",validationMessage:"",valid:!0})}get internals(){return this[se]}static get formAssociated(){return!0}get form(){return this[se].form}get name(){return this[pe]?this[pe].name:""}set name(t){const n=String(t);"name"in e.prototype&&(super.name=n),this[be]({name:n})}[ae](e){if(super[ae]&&super[ae](e),e.name){const{name:e}=this[pe];e?this.setAttribute("name",e):this.removeAttribute("name")}if(this[se]&&this[se].setValidity&&(e.valid||e.validationMessage)){const{valid:e,validationMessage:t}=this[pe];e?this[se].setValidity({}):this[se].setValidity({customError:!0},t)}}[de](e){super[de]&&super[de](e),e.value&&this[se]&&this[se].setFormValue&&this[se].setFormValue(this[pe].value,this[pe])}reportValidity(){return this[se].reportValidity()}get type(){return super.type||this.localName}get validationMessage(){return this[pe].validationMessage}get validity(){return this[se].validity}get willValidate(){return this[se].willValidate}}}window.addEventListener("keydown",(()=>{_e(!0)}),{capture:!0}),window.addEventListener("mousedown",(()=>{_e(!1)}),{capture:!0});const Ge=Symbol("extends"),Ze=Symbol("delegatedPropertySetters"),Je={a:!0,area:!0,button:!0,details:!0,iframe:!0,input:!0,select:!0,textarea:!0},Ke={address:["scroll"],blockquote:["scroll"],caption:["scroll"],center:["scroll"],dd:["scroll"],dir:["scroll"],div:["scroll"],dl:["scroll"],dt:["scroll"],fieldset:["scroll"],form:["reset","scroll"],frame:["load"],h1:["scroll"],h2:["scroll"],h3:["scroll"],h4:["scroll"],h5:["scroll"],h6:["scroll"],iframe:["load"],img:["abort","error","load"],input:["abort","change","error","select","load"],li:["scroll"],link:["load"],menu:["scroll"],object:["error","scroll"],ol:["scroll"],p:["scroll"],script:["error","load"],select:["change","scroll"],tbody:["scroll"],tfoot:["scroll"],thead:["scroll"],textarea:["change","select","scroll"]},Qe=["click","dblclick","mousedown","mouseenter","mouseleave","mousemove","mouseout","mouseover","mouseup","wheel"],Ye={abort:!0,change:!0,reset:!0},et=["address","article","aside","blockquote","canvas","dd","div","dl","fieldset","figcaption","figure","footer","form","h1","h2","h3","h4","h5","h6","header","hgroup","hr","li","main","nav","noscript","ol","output","p","pre","section","table","tfoot","ul","video"],tt=["accept-charset","autoplay","buffered","challenge","codebase","colspan","contenteditable","controls","crossorigin","datetime","dirname","for","formaction","http-equiv","icon","ismap","itemprop","keytype","language","loop","manifest","maxlength","minlength","muted","novalidate","preload","radiogroup","readonly","referrerpolicy","rowspan","scoped","usemap"],nt=function(e){return class extends e{get[D](){return!0}focus(e){const t=this[V];t&&t.focus(e)}get[V](){return Ie(this[me])}}}(R);class it extends nt{constructor(){super();const e=this;!this[se]&&e.attachInternals&&(this[se]=e.attachInternals())}attributeChangedCallback(e,t,n){if(tt.indexOf(e)>=0){const t=Object.assign({},this[pe].innerAttributes,{[e]:n});this[be]({innerAttributes:t})}else super.attributeChangedCallback(e,t,n)}blur(){this.inner.blur()}get[P](){return Object.assign(super[P],{innerAttributes:{}})}get[M](){return Je[this.extends]?0:-1}get extends(){return this.constructor[Ge]}get inner(){const e=this[Y]&&this[Y].inner;return e||console.warn("Attempted to get an inner standard element before it was instantiated."),e}static get observedAttributes(){return[...super.observedAttributes,...tt]}[ae](e){super[ae](e);const t=this.inner;if(this[F]){(Ke[this.extends]||[]).forEach((e=>{t.addEventListener(e,(()=>{const t=new Event(e,{bubbles:Ye[e]||!1});this.dispatchEvent(t)}))})),"disabled"in t&&Qe.forEach((e=>{this.addEventListener(e,(e=>{t.disabled&&e.stopImmediatePropagation()}))}))}if(e.tabIndex&&(t.tabIndex=this[pe].tabIndex),e.innerAttributes){const{innerAttributes:e}=this[pe];for(const n in e)rt(t,n,e[n])}this.constructor[Ze].forEach((n=>{if(e[n]){const e=this[pe][n];("selectionEnd"===n||"selectionStart"===n)&&null===e||(t[n]=e)}}))}[de](e){if(super[de](e),e.disabled){const{disabled:e}=this[pe];void 0!==e&&function(e,t,n){if(e.toggleAttribute(t,n),e[o]&&e[o].states){const i=e[o].states,r=`--${t}`;n?i.add(r):i.delete(r)}}(this,"disabled",e)}}get[Re](){const e=et.includes(this.extends)?"block":"inline-block",t=this.extends;return $e.html(`
      <style>
        :host {
          display: ${escapeXml(e)}
        }
        
        [part~="inner"] {
          box-sizing: border-box;
          height: 100%;
          width: 100%;
        }
      </style>
      <${t} id="inner" part="inner ${t}">
        <slot></slot>
      </${t}>
    `)}static wrap(e){class t extends it{}t[Ge]=e;const n=document.createElement(e);return function(e,t){const n=Object.getOwnPropertyNames(t);e[Ze]=[],n.forEach((n=>{const i=Object.getOwnPropertyDescriptor(t,n);if(!i)return;const r=function(e,t){if("function"==typeof t.value){if("constructor"!==e)return function(e,t){const n=function(...t){this.inner[e](...t)};return{configurable:t.configurable,enumerable:t.enumerable,value:n,writable:t.writable}}(e,t)}else if("function"==typeof t.get||"function"==typeof t.set)return function(e,t){const n={configurable:t.configurable,enumerable:t.enumerable};t.get&&(n.get=function(){return function(e,t){return e[pe][t]||e[me]&&e.inner[t]}(this,e)});t.set&&(n.set=function(t){!function(e,t,n){e[pe][t]!==n&&e[be]({[t]:n})}(this,e,t)});t.writable&&(n.writable=t.writable);return n}(e,t);return null}(n,i);r&&(Object.defineProperty(e.prototype,n,r),r.set&&e[Ze].push(n))}))}(t,Object.getPrototypeOf(n)),t}}function rt(e,t,n){S[t]?"string"==typeof n?e.setAttribute(t,""):null===n&&e.removeAttribute(t):null!=n?e.setAttribute(t,n.toString()):e.removeAttribute(t)}function st(e){return class extends e{get[P](){return Object.assign(super[P]||{},{selectionEnd:0,selectionStart:0})}[ae](e){if(super[ae]&&super[ae](e),this[F]){const e=(()=>{setTimeout((()=>{this[oe]=!0,ot(this),this[oe]=!1}),10)}).bind(this);this.addEventListener("keydown",e),this.addEventListener("mousedown",e),this.addEventListener("touchend",e)}}[de](e){super[de](e),e.value&&ot(this)}}}function ot(e){const t=e.inner,{selectionEnd:n,selectionStart:i}=t;e[be]({selectionEnd:n,selectionStart:i})}!function(e){P,ae}(Fe(qe(it.wrap("button")))),Fe(qe(Xe(st(it.wrap("input"))))),new URLSearchParams("").get("elixdebugpopup"),new URLSearchParams("").get("elixdebugpopup"),Xe(function(e){return class extends e{get[z](){const e=this[me]&&this[me].querySelector("slot:not([name])");return this[me]&&e||console.warn(`SlotContentMixin expects ${this.constructor.name} to define a shadow tree that includes a default (unnamed) slot.\nSee https://elix.org/documentation/SlotContentMixin.`),e}get[P](){return Object.assign(super[P]||{},{content:null})}[de](e){if(super[de]&&super[de](e),this[F]){const e=this[z];e&&e.addEventListener("slotchange",(async()=>{this[oe]=!0;const t=e.assignedNodes({flatten:!0});Object.freeze(t),this[be]({content:t}),await Promise.resolve(),this[oe]=!1}))}}}}(st(it.wrap("textarea"))));const at=window.ResizeObserver;void 0!==at&&new at((e=>{e.forEach((e=>{const{target:t}=e,{clientHeight:n,clientWidth:i}=t;t[be]({clientHeight:n,clientWidth:i})}))})),new URLSearchParams("").get("elixdebugpopup");var lt=[],ct=[];function dt(e,t){if(e&&"undefined"!=typeof document){var n,i=!0===t.prepend?"prepend":"append",r=!0===t.singleTag,s="string"==typeof t.container?document.querySelector(t.container):document.getElementsByTagName("head")[0];if(r){var o=lt.indexOf(s);-1===o&&(o=lt.push(s)-1,ct[o]={}),n=ct[o]&&ct[o][i]?ct[o][i]:ct[o][i]=a()}else n=a();65279===e.charCodeAt(0)&&(e=e.substring(1)),n.styleSheet?n.styleSheet.cssText+=e:n.appendChild(document.createTextNode(e))}function a(){var e=document.createElement("style");if(e.setAttribute("type","text/css"),t.attributes)for(var n=Object.keys(t.attributes),r=0;r<n.length;r++)e.setAttribute(n[r],t.attributes[n[r]]);var o="prepend"===i?"afterbegin":"beforeend";return s.insertAdjacentElement(o,e),e}}var ut="/***************************************\n * This file is automatically generated.\n * Please do not edit this file. Source file is common.css\n ***************************************/\n\n/* Copyright (c) 2015-present, salesforce.com, inc. All rights reserved\nLicensed under BSD 3-Clause - see LICENSE.txt or git.io/sfdc-license */\n\n/* Document\n * --------------------- */\n\n/**\n * Normalize box sizing to border box for all browsers.\n */\n\n*,\n::before,\n::after {\n  box-sizing: border-box;\n}\n\n/* Grouping Content\n * --------------------- */\n\n/**\n * Add the correct display in IE.\n */\n\nmain {\n  display: block;\n}\n\n/**\n * 1. Remove the margin in all browsers.\n * 2. Remove the padding in all browsers.\n * 3. Normalize font sizes in all browsers.\n * 4. Normalize font weight in all browsers.\n */\n\nh1,\nh2,\nh3,\nh4,\nh5,\nh6 {\n  font-size: 0.875rem; /* 3 */\n  font-weight: normal; /* 4 */\n  margin: 0; /* 1 */\n  padding: 0; /* 2 */\n}\n\n/**\n * Remove the margin in all browsers.\n */\n\np {\n  margin: 0;\n}\n\n/**\n * 1. Remove the margin in all browsers.\n * 2. Normalize border styles in all browsers.\n */\n\nhr {\n  margin: 0; /* 1 */\n  border: 0; /* 2 */\n  border-top-width: 1px; /* 2 */\n  border-style: solid; /* 2 */\n  border-color: inherit; /* 2 */\n}\n\n/**\n * 1. Remove the margin in all browsers.\n * 2. Remove the padding in all browsers.\n * 3. Remove the list-style in all browsers, sub-system dependant.\n */\n\nol,\nul {\n  list-style: none; /* 3 */\n  padding: 0; /* 2 */\n  margin: 0; /* 1 */\n}\n\n/**\n * Remove the margin in all browsers.\n */\n\ndl,\ndt,\ndd {\n  margin: 0;\n}\n\n/* Form Controls\n * --------------------- */\n\n/**\n * Remove the margin in all browsers.\n */\n\nform {\n  margin: 0;\n}\n\n/**\n * 1. Correct font properties not being inherited.\n * 2. Remove the margin in Firefox and Safari.\n * 3. Fix correct color not being inherited.\n */\n\nbutton,\ninput,\noptgroup,\nselect,\ntextarea {\n  font: inherit; /* 1 */\n  margin: 0; /* 2 */\n  color: inherit; /* 3 */\n}\n\n/**\n * Address inconsistent `text-transform` inheritance for `button` and `select`.\n */\n\nbutton,\nselect {\n  text-transform: none;\n}\n\n/**\n * 1. Correct inability to style clickable `input` types in iOS.\n * 2. Normalizes cursor indicator on clickable elements.\n */\n\nbutton,\n[type='button'],\n[type='reset'],\n[type='submit'] {\n  -webkit-appearance: button; /* 1 */\n  appearance: button; /* 1 */\n  cursor: pointer; /* 2 */\n}\n\n/**\n * Prevent option or optgroup to increase the width of a select.\n */\n\nselect {\n  max-width: 100%;\n}\n\n/**\n * Correct the outline style in Safari.\n */\n\ninput:focus,\nbutton:focus,\nselect:focus,\ntextarea:focus {\n  outline-offset: 0;\n}\n\n/**\n * Remove the inner border and padding in Firefox.\n */\n\n::-moz-focus-inner {\n  border-style: none;\n  padding: 0;\n}\n\n/**\n * 1. Correct the text wrapping in Edge 18- and IE.\n * 2. Correct the color inheritance from `fieldset` elements in IE.\n * 3. Remove the padding so developers are not caught out when they zero out 'fieldset' elements in all browsers.\n */\n\nlegend {\n  color: inherit; /* 2 */\n  display: table; /* 1 */\n  max-width: 100%; /* 1 */\n  white-space: normal; /* 1 */\n  padding: 0; /* 3 */\n}\n\n/**\n * Add the correct vertical alignment in Chrome and Firefox.\n */\n\nprogress {\n  vertical-align: baseline;\n}\n\n/**\n * Correct the cursor style of increment and decrement buttons in Safari.\n */\n\n::-webkit-inner-spin-button,\n::-webkit-outer-spin-button {\n  height: auto;\n}\n\n/**\n * 1. Correct the odd appearance in Chrome and Safari.\n * 2. Correct the outline style in Safari.\n */\n\n[type='search'] {\n  -webkit-appearance: textfield; /* 1 */\n  outline-offset: -2px; /* 2 */\n}\n\n/**\n * Remove the inner padding in Chrome and Safari on macOS.\n */\n\n::-webkit-search-decoration {\n  -webkit-appearance: none;\n}\n\n/**\n * 1. Correct the inability to style clickable types in iOS and Safari.\n * 2. Change font properties to 'inherit' in Safari.\n */\n\n::-webkit-file-upload-button {\n  -webkit-appearance: button; /* 1 */\n  font: inherit; /* 2 */\n}\n\n/**\n * Restore the focus styles unset by the previous rule.\n */\n\n:-moz-focusring {\n  outline: 1px dotted ButtonText;\n}\n\n/**\n * Remove the additional ':invalid' styles in Firefox.\n * See: https://github.com/mozilla/gecko-dev/blob/2f9eacd9d3d995c937b4251a5557d95d494c9be1/layout/style/res/forms.css#L728-L737\n */\n\n:-moz-ui-invalid {\n  box-shadow: none;\n}\n\n/* Text-level semantics\n * --------------------- */\n\n/**\n * Normalizes cursor indicator on clickable elements.\n */\n\na {\n  cursor: pointer;\n}\n\n/**\n * Add the correct text decoration in Chrome, Edge, and Safari.\n */\n\nabbr[title] {\n  text-decoration: underline dotted;\n  cursor: help;\n}\n\n/**\n * Add the correct font weight in Edge and Safari.\n */\n\nb,\nstrong {\n  font-weight: bolder;\n}\n\n/**\n * 1. Improve consistency of default fonts in all browsers. (https://github.com/sindresorhus/modern-normalize/issues/3)\n * 2. Correct the odd 'em' font sizing in all browsers.\n * 3. Remove the margin in all browsers.\n */\n\ncode,\nkbd,\nsamp,\npre {\n  font-family: ui-monospace, SFMono-Regular, Consolas, 'Liberation Mono', Menlo, monospace; /* 1 */\n  font-size: 1em; /* 2 */\n  margin: 0; /* 3 */\n}\n\n/**\n * Prevent overflow of the container in all browsers\n */\n\npre {\n  overflow: auto;\n  -ms-overflow-style: scrollbar;\n}\n\n/**\n * Add the correct font size in all browsers.\n */\n\nsmall {\n  font-size: 80%;\n}\n\n/**\n * Prevent 'sub' and 'sup' elements from affecting the line height in all browsers.\n */\n\nsub,\nsup {\n  font-size: 75%;\n  line-height: 0;\n  position: relative;\n  vertical-align: baseline;\n}\n\nsub {\n  bottom: -0.25em;\n}\n\nsup {\n  top: -0.5em;\n}\n\n/* Embedded content\n * --------------------- */\n\n/**\n * Change the alignment on media elements in all browsers.\n */\n\naudio,\ncanvas,\niframe,\nimg,\nsvg,\nvideo {\n  vertical-align: middle;\n}\n\n/**\n * Make images responsive by default.\n */\n\nimg,\n[type='image'] {\n  max-width: 100%;\n  height: auto;\n}\n\n/**\n * Remove the border on iframes in all browsers.\n */\n\niframe {\n  border-style: none;\n}\n\n/**\n * Change the fill color to match the text color in all browsers.\n */\n\nsvg:not([fill]) {\n  fill: currentColor;\n}\n\n/* Tabular data\n * --------------------- */\n\n/**\n * 1. Remove text indentation from table contents in Chrome and Safari. [Chromium Bug 999088](https://bugs.chromium.org/p/chromium/issues/detail?id=999088), [Webkit Bug 201297](https://bugs.webkit.org/show_bug.cgi?id=201297)\n * 2. Correct table border color inheritance in all Chrome and Safari. [Chromium Bug 935729](https://bugs.chromium.org/p/chromium/issues/detail?id=935729), [Webkit Bug 195016](https://bugs.webkit.org/show_bug.cgi?id=195016)\n * 3. Collapse border spacing in all browsers\n */\n\ntable {\n  text-indent: 0; /* 1 */\n  border-color: inherit; /* 2 */\n  border-collapse: collapse; /* 3 */\n}\n\n/* Shadow host\n * --------------------- */\n\n/**\n * 1. Change the line height in all browsers\n * 2. Change the base font size in all browsers, inherit 100% from `html`\n * 3. Prevent adjustments of font size after orientation changes in IE on Windows Phone and in iOS\n * 4. Remove the grey highlight on links in iOS\n * 5. Font Stack:\n *   a. Safari for OS X and iOS (San Francisco)\n *   b. Chrome < 56 for OS X (San Francisco)\n *   c. Windows\n *   d. Android\n *   e. Web Fallback\n *   f. Emoji font stack [Mac, Windows, Linux]\n */\n\n:host {\n  line-height: 1.5;\n  font-size: 0.875rem;\n  -webkit-tap-highlight-color: transparent;\n  -ms-text-size-adjust: 100%;\n  -webkit-text-size-adjust: 100%;\n  font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, 'Helvetica Neue', Arial, sans-serif,\n    'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol';\n}\n";function ht(e){if(e.__esModule)return e;var t=Object.defineProperty({},"__esModule",{value:!0});return Object.keys(e).forEach((function(n){var i=Object.getOwnPropertyDescriptor(e,n);Object.defineProperty(t,n,i.get?i:{enumerable:!0,get:function(){return e[n]}})})),t}dt(ut,{});var bt=ht(Object.freeze({__proto__:null,reflectAttribute:(e,t,n)=>{n?e.setAttribute(t,"boolean"==typeof n?"":n):e.removeAttribute(t)},delegateAttribute:(e,t,n,i)=>{i?(t.setAttribute(n,"boolean"==typeof i?"":i),e.removeAttribute(n)):t.removeAttribute(n)},replaceDefaultSlot:(e,t)=>{const n=e.querySelector("slot:not([name])");n&&n.replaceWith(t)},removeSlot:(e,t)=>{const n=e.querySelector(`slot[name="${t}"]`);n&&n.remove()},dispatchCustomEvent:(e,t,n)=>{const i=e.tagName.split("-")[0].toLowerCase(),r=new CustomEvent(i+"-"+t,n);return e.dispatchEvent(r),r}})),mt="/* Copyright (c) 2015-present, salesforce.com, inc. All rights reserved\n  Licensed under BSD 3-Clause - see LICENSE.txt or git.io/sfdc-license */\n[part~='figure'] {\n  margin: 0;\n}\n\n[part~='image'] {\n  border-radius: 0;\n  object-fit: cover;\n  aspect-ratio: 1/1;\n  max-width: 100%;\n}\n\n:host([radius='1']) [part~='image'] {\n  border-radius: var(--wes-g-radius-border-3);\n}\n\n:host([radius='2']) [part~='image'] {\n  border-radius: var(--wes-g-radius-border-4);\n}\n\n:host([radius='circle']) [part~='image'] {\n  border-radius: var(--wes-g-radius-border-circle);\n}\n";dt(mt,{});class gt extends R{get src(){return this[pe].src}set src(e){this[be]({src:e})}get alt(){return this[pe].alt}set alt(e){this[be]({alt:e})}get radius(){return this[pe].radius}set radius(e){this[be]({radius:e})}get ariaDescribedby(){return this[pe].ariaDescribedby}set ariaDescribedby(e){this[be]({ariaDescribedby:e})}get width(){return this[pe].width}set width(e){this[be]({width:e})}get[Re](){return $e.html(`
      <style>
        ${escapeXml(ut)}
        ${escapeXml(mt)}
      </style>
      ${'<figure part="figure">\n  <img part="image" />\n  <figcaption part="caption">\n    <slot></slot>\n  </figcaption>\n</figure>\n'}
    `)}[ae](e){super[ae](e);const t=this[b].querySelector('[part="image"]');if(e.src){const{src:e}=this[pe];bt.delegateAttribute(this,t,"src",e)}if(e.alt){const{alt:e}=this[pe];bt.delegateAttribute(this,t,"alt",e)}if(e.width){const{width:e}=this[pe];bt.delegateAttribute(this,t,"width",e)}if(e.radius){const{radius:e}=this[pe];bt.reflectAttribute(this,"radius",e)}if(e.ariaDescribedby){const{ariaDescribedby:e}=this[pe];bt.delegateAttribute(this,t,"aria-describedby",e)}}}return gt;
 
})();