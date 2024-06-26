import { LightningElement, api } from "lwc";

export default class LightningModal extends LightningElement {
  @api cancelLabel = "Cancel";
  @api saveLabel = "Save";
  @api hideFooter = false;
  @api saveDisabled = false;
  @api footerCentered = false;

  get filterModalActive() {
    return this.filterModal && this.filtersChanged;
  }

  get buttonClass() {
    return this.footerCentered ? "slds-align_absolute-center" : "";
  }

  // renderedCallback() {
  //   this.activateTabTrap();
  // }

  // Focus Trap Code => Call when opening a modal
  // activateTabTrap() {
  //   let focusableEls = this.querySelectorAll(
  //     'section.slds-modal a[href]:not([disabled]), section.slds-modal button:not([disabled]), section.slds-modal textarea:not([disabled]), section.slds-modal input[type="text"]:not([disabled]), section.slds-modal input[type="radio"]:not([disabled]), section.slds-modal input[type="checkbox"]:not([disabled]), section.slds-modal select:not([disabled])'
  //   );
  //   let firstFocusableEl = focusableEls[0];
  //   let lastFocusableEl = focusableEls[focusableEls.length - 1];

  //   // Focus on first focuseable element of the modal
  //   // this.querySelector(".slds-modal__header .slds-modal__close").focus();
  //   // console.log("Close Button" + this.template.querySelector(".slds-modal__header .slds-modal__close"))

  //   // Custom Tab key event on the last focuseable element
  //   lastFocusableEl.addEventListener(
  //     "keydown",
  //     function (e) {
  //       let isTabPressed = e.key === "Tab" || e.keyCode === KEYCODE_TAB;
  //       let KEYCODE_TAB = 9;

  //       if (isTabPressed && e.target === lastFocusableEl) {
  //         if (!e.shiftKey) {
  //           firstFocusableEl.focus();
  //           e.preventDefault();
  //         }
  //       } else {
  //         return;
  //       }
  //     },
  //     false
  //   );

  //   // Custom Tab key event on the first focuseable element
  //   firstFocusableEl.addEventListener(
  //     "keydown",
  //     function (e) {
  //       let isTabPressed = e.key === "Tab" || e.keyCode === KEYCODE_TAB;
  //       let KEYCODE_TAB = 9;

  //       if (isTabPressed && e.shiftKey && e.target === firstFocusableEl) {
  //         /* shift + tab */
  //         lastFocusableEl.focus();
  //         e.preventDefault();
  //       } else {
  //         return;
  //       }
  //     },
  //     false
  //   );
  // }

  cancelClickedHandler() {
    this.dispatchEvent(new CustomEvent("cancel"));
  }

  saveClickedHandler() {
    this.dispatchEvent(new CustomEvent("save"));
  }

  closeClickedHandler() {
    this.dispatchEvent(new CustomEvent("close"));
  }
}