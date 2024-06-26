import {
  LightningElement,
  api
} from "lwc";

export default class CurrentFilters extends LightningElement {
  @api activeFilters;

  removeFromActiveFilters(id) {
    let theActiveFilters = JSON.parse(JSON.stringify([...this.activeFilters]));

    for (let i = 0; i < theActiveFilters.length; i += 1) {
      if (theActiveFilters[i].id === id) {
        theActiveFilters.splice(i, 1);
      }
    }
    this.activeFilters = theActiveFilters
    return this.activeFilters;
  }


  // Send delete event with filter id
  removeHandler(event) {
    this.dispatchEvent(
      new CustomEvent("removefilter", {
        detail: this.removeFromActiveFilters(event.target.dataset.filterid)
      })
    );
  }

  // GETTERS
  get filtersApplied() {
    if (!this.activeFilters) {
      return false;
    }
    if (!this.activeFilters.length > 0) {
      return false;
    }
    return true;
  }
}