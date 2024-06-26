import { LightningElement, api, track, wire } from "lwc";
import { getListUi } from "lightning/uiListApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class recordPicker extends LightningElement {
  @api object;
  @api listViewApiName;
  @api
  get selectedRecordIds() {
    return this._selectedRecordIds;
  }

  set selectedRecordIds(value) {
    this._selectedRecordIds = value;
    this.preselectItems();
  }

  @track records;
  @track loading = false;

  @wire(getListUi, {
    objectApiName: "$object",
    listViewApiName: "$listViewApiName"
  })
  wiredRecords({ error, data }) {
    if (error) {
      // eslint-disable-next-line
      console.error("records Error: ", error);
      this.showErrorMessage(error);
    } else if (data) {
      this.records = data.records.records.map(record => ({
        id: record.id,
        Name: record.fields.Name.value,
        selected: this.selectedRecordIds ? this.selectedRecordIds.includes(record.id) : false
      }));
    }
  }

  preselectItems() {
    if (this.records) {
      let records = this.records.map(record => {
        let selected = record.selected;
        if (this.selectedRecordIds.includes(record.id)) {
          selected = true;
        }
        return { ...record, selected };
      });
      this.records = records;
    }
  }

  // toggles selected value of clicked item
  handleSelected(event) {
    let records = this.records.map(record => {
      let selected = record.selected;
      if (record.id === event.target.dataset.id) {
        selected = !record.selected;
      }
      return { ...record, selected };
    });
    this.records = records;
    const recordIds = [];
    records.forEach(record => {
      if (record.selected) {
        recordIds.push(record.id);
      }
    });
    this.dispatchEvent(
      new CustomEvent("select", {
        detail: recordIds
      })
    );
  }

  showErrorMessage(error) {
    // eslint-disable-next-line no-console
    console.error(error);
    let message = "Unknown error";
    if (Array.isArray(error.body)) {
      message = error.body.map(e => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      message = error.body.message;
    } else {
      message = error;
    }
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Error loading records",
        message,
        variant: "error"
      })
    );
  }
}