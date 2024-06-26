import { LightningElement, api, wire, track } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, updateRecord, getFieldValue } from "lightning/uiRecordApi";

import searchLabel from "@salesforce/label/c.search";

export default class MultiPicklist extends LightningElement {
  @api field;
  @api recordId;

  @api picklistValues;

  @track record;
  @track searchTerm;

  labels = { searchLabel };

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA", // default record type id
    fieldApiName: "$field"
  })
  wiredPicklistValues({ error, data }) {
    if (error) {
      // eslint-disable-next-line
      console.error("picklistError: ", error);
    } else if (data) {
      let picklistValues = [];
      data.values.forEach(value => {
        picklistValues.push({ ...value, selected: false });
      });
      this.picklistValues = picklistValues;
      if (this.record) {
        this.initializePicklistValues(getFieldValue(this.record, this.field));
      }
    }
  }

  @wire(getRecord, { recordId: "$recordId", fields: "$field" })
  wiredRecord({ error, data }) {
    if (error) {
      //eslint-disable-next-line
      console.error(error);
    } else if (data) {
      this.record = data;
      if (this.picklistValues) {
        this.initializePicklistValues(getFieldValue(data, this.field));
      }
    }
  }

  searchChangeHandler(event) {
    this.searchTerm = event.target.value;
  }

  async saveRecord(value) {
    const fields = {};
    fields[this.field.fieldApiName] = value;
    fields.Id = this.recordId;
    const recordInput = { fields };
    try {
      await updateRecord(recordInput);
    } catch (error) {
      // eslint-disable-next-line
      console.error(error);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Couldn't save record",
          message: error.body.message,
          variant: "error"
        })
      );
    }
  }

  initializePicklistValues(picklistValue) {
    let values = [];
    if (picklistValue) {
      values = picklistValue.split(";");
    }
    let picklistValues = this.picklistValues.map(value => {
      let selected = value.selected;
      if (values.includes(value.value)) {
        selected = true;
      }
      return { ...value, selected };
    });
    this.picklistValues = picklistValues;
  }

  // toggles selected value of clicked item
  handleSelected(event) {
    let picklistValues = this.picklistValues.map(value => {
      let selected = value.selected;
      if (value.value === event.target.dataset.plvalue) {
        selected = !value.selected;
      }
      return { ...value, selected };
    });

    // Save record if record Id passed in
    if (this.recordId) {
      const selectedValues = [];
      picklistValues.forEach(value => {
        if (value.selected) {
          selectedValues.push(value.value);
        }
      });
      this.saveRecord(selectedValues.join(";"));
    }

    this.picklistValues = picklistValues;
    this.dispatchEvent(
      new CustomEvent("select", {
        detail: { field: this.field, picklistValues },
        bubbles: true
      })
    );
  }

  get filteredPlValues() {
    if (this.searchTerm) {
      return this.picklistValues.filter(plValue => plValue.value.toLowerCase().includes(this.searchTerm.toLowerCase()));
    }
    return this.picklistValues;
  }

  get showSearch() {
    if (this.picklistValues) {
      return this.picklistValues.length >= 10;
    }
    return false;
  }
}