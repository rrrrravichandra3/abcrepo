/**
 * @description       :
 * @author            : Venkata Akash Patti (akashpatti)
 * @group             :
 * @last modified on  : 06-14-2022
 * @last modified by  : Venkata Akash Patti (akashpatti)
 **/

import { LightningElement, api } from "lwc";

export default class DragAndDropList extends LightningElement {
  @api records;
  @api stage;

  handleItemDrag(evt) {
    const event = new CustomEvent("listitemdrag", {
      detail: evt.detail
    });
    this.dispatchEvent(event);
  }

  handleDragOver(evt) {
    evt.preventDefault();
  }

  handleDrop(evt) {
    const event = new CustomEvent("itemdrop", {
      detail: this.stage
    });
    this.dispatchEvent(event);
  }

  handleRemoveFromPool(evt) {
    const event = new CustomEvent("removecard", {
      detail: evt.detail
    });
    this.dispatchEvent(event);
  }
}