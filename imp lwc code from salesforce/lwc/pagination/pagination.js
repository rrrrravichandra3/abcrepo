import { LightningElement, api, track } from "lwc";

export default class Pagination extends LightningElement {
  @track currentPage = 0;
  totalRecords;
  totalPage = 0;
  visibleRecords = [];
  recordSize = 6;
  cardsPerPage = [
    { label: 3, value: 3 },
    { label: 6, value: 6 },
    { label: 9, value: 9 }
  ];
  totalRecordsSize;
  @api rowLimit;
  @api lessThanLimitReturned;
  @api maxNumberOfRecords;

  @api
  get records() {
    return this.visibleRecords;
  }

  set records(data) {
    if (data.length) {
      this.totalRecords = data;
      this.totalRecordsSize = this.totalRecords.length;
      if (this.currentPage === 0) {
        this.currentPage = 1;
      }
      this.recordSize = Number(this.recordSize);
      this.totalPage = Math.ceil(data.length / this.recordSize);
      this.updateRecords();
    }
  }

  get disablePrevious() {
    return this.currentPage <= 1;
  }

  get disableNext() {
    let disable = false;
    if (
      (this.totalRecordsSize >= this.maxNumberOfRecords || this.lessThanLimitReturned) &&
      this.currentPage === this.totalPage
    ) {
      disable = true;
    }

    this.dispatchEvent(
      new CustomEvent("resultsexhausted", {
        detail: {
          maximumResults: disable
        }
      })
    );
    return disable;
  }

  previousHandler() {
    let isValid = this.template.querySelector("lightning-input").checkValidity();
    if (!isValid) return;
    if (this.currentPage > 1) {
      this.currentPage = this.currentPage - 1;
      this.template.querySelector("lightning-input").value = this.currentPage - 1;
      this.updateRecords();
    }
  }

  nextHandler() {
    let isValid = this.template.querySelector("lightning-input").reportValidity();
    if (!isValid) return;
    if (this.currentPage < this.totalPage) {
      this.currentPage = Number(this.currentPage) + 1;
      this.updateRecords();
    } else {
      this.loadMore();
    }
  }

  updateRecords() {
    this.totalPage = Math.ceil(this.totalRecords.length / this.recordSize);
    if (this.currentPage > this.totalPage) {
      this.currentPage = this.totalPage;
    }
    const start = (this.currentPage - 1) * this.recordSize;
    const end = this.recordSize * this.currentPage;
    this.visibleRecords = this.totalRecords.slice(start, end);
    this.dispatchEvent(
      new CustomEvent("update", {
        detail: {
          records: this.visibleRecords
        }
      })
    );
  }

  loadMore() {
    this.dispatchEvent(
      new CustomEvent("load", {
        detail: {
          loadMore: true
        }
      })
    );
    this.currentPage = Number(this.currentPage) + 1;
  }

  @api
  setData(contactResults) {
    this.records = contactResults;
  }

  handleNumberOfCardsPerPage(event) {
    this.recordSize = parseInt(event.detail.value);
    this.updateRecords();
  }

  handlePageNumberBlur(event) {
    this.updatePageNumber(event.target.value);
  }

  handlePageNumberKeyUp(event) {
    let restrictedkeys = ["+", "-", ".", "Shift"];

    if (restrictedkeys.includes(event.key)) {
      this.template.querySelectorAll("lightning-input").forEach((element) => {
        if (element.name === "currentPageNumber") {
          element.value = this.currentPage;
        }
      });
    }
    if (event.key === "Enter") this.updatePageNumber(event.target.value);
  }

  updatePageNumber(pageNumber) {
    if (pageNumber == "") {
      this.template.querySelector("lightning-input").reportValidity();
      return;
    }
    if (pageNumber < 1) {
      this.currentPage = this.currentPage;
      this.template.querySelector("lightning-input").value = this.currentPage;
      this.updateRecords();
    } else if (pageNumber >= this.totalPage) {
      this.template.querySelector("lightning-input").value = this.totalPage;
      this.currentPage = this.totalPage;
      this.updateRecords();
    } else {
      this.currentPage = pageNumber;
      this.updateRecords();
    }
    this.template.querySelector("lightning-input").reportValidity();
  }
}