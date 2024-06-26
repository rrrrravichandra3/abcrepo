import { LightningElement, api, track } from "lwc";

import SelectAnOptionLabel from "@salesforce/label/c.search_select_an_option";
import OptionsSelectedLabel from "@salesforce/label/c.search_options_selected";

import standardPicklist from "./filterCategory.html";
import treePicklist from "./filterCategoryTree.html";

export default class FilterCategory extends LightningElement {
  @api category;
  @api startFilters;
  @api disabled = false;
  @api multiSelect = false;
  @api minChar = 0;

  @track searchTerm;
  @track searchFilters;
  @track filterTooSpecific = false;
  @track searchString;
  @track message;
  @track showDropdown = false;
  @track filterData;
  @track listStart=-1;
  @api isTree = false;
  @api value;
  @api values = [];
  @api isCombobox = false;

  label = {
    SelectAnOptionLabel,
  };

  render() {
    return this.category.tree ? treePicklist : standardPicklist;
  }

  connectedCallback() {
    this.proccessFilters();
    this.blurEvent();      
  }

  @api resetFilters() {
    this.searchString = null;
  }

  // Handlers filter selected & sends updated filter array to parent
  handleFilterClick = (event) => {
    const selectedId = event.detail;
    
    this.dispatchEvent(
      new CustomEvent("toggle", {
        detail: selectedId,
      })
    );
  };

  handleKeyUp = (event) => {
    this.searchTerm = event.target.value;

    let newFilters = JSON.parse(JSON.stringify(this.category.filters));
    let showMessage = true;

    for (let filter of newFilters) {
      filter.searchDisplay = false;
      if (filter.name.startsWith(this.searchTerm)) {
        filter.searchDisplay = true;
      }
      if (filter.searchDisplay) {
        showMessage = false;
      }
    }
    this.filterTooSpecific = showMessage;

    let newCategory = {
      name: this.category.name,
      fieldApiName: this.category.fieldApiName,
      filters: [...newFilters],
    };

    this.category = newCategory;
  };

  get filterTooLarge() {
    return this.category.filters.length > 20;
  }

  showFilters() {
    if (this.disabled == false && this.category.filters) {
      this.message = "";
      this.searchString = "";

      this.proccessFilters();

      if (this.filterData.length > 0) {
        this.showDropdown = true;
      }
    }
  }

  proccessFilters() {
    var filters = JSON.parse(JSON.stringify(this.category.filters));
    for (var i = 0; i < filters.length; i++) {
      filters[i].isVisible = true;
      if (this.startFilters){
        if(this.startFilters.has(filters[i].id)){
          filters[i].isActive = true;
        } 
      }     
    }
    this.filterData = filters;
  }

  blurEvent() {
    var previousLabel;
    var count = 0;

    for (var i = 0; i < this.category.filters.length; i++) {
      if (this.category.filters[i].id === this.id) {
        previousLabel = this.category.filters[i].name;
      }
    }

    if (this.startFilters) {
      for (let j = 0; j < this.filterData.length; j += 1) {
        if (this.category.tree) {
          this.filterData[j].children.forEach((child) => {
            if (this.startFilters.has(child.id)) {
              count++;
            }
          });
        } else {
          if (this.startFilters.has(this.filterData[j].id)) {
            count++;
          }
        }
      }
    }
    if (this.multiSelect) this.searchString = count > 0 ? count + " " + OptionsSelectedLabel : "";
    else this.searchString = previousLabel;

    this.showDropdown = false;
  }

  filterFilters(event) { 
    if(event.keyCode!=9){
    this.searchString = event.target.value;
    if ((this.searchString && this.searchString.length > 0) || (event.key == "Enter") ) {
      this.message = "";
      if (this.searchString.length >= this.minChar) {
        var flag = true;
        for (var i = 0; i < this.filterData.length; i++) {
          if (this.filterData[i].name.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
            this.filterData[i].isVisible = true;
            flag = false;
          } else {
            this.filterData[i].isVisible = false;
          }
        }
        if (flag) {
          this.message = noResultsFoundForLabel + " '" + this.searchString + "'";
        }
      }
      this.showDropdown = true;
    } else {
      this.showDropdown = false;
    } }
    if(event.keyCode == 40|| event.keyCode == 38){
      this.showDropdown = true;
      this.listStart=-1;
      for (var i = 0; i < this.filterData.length; i++) { 
        this.listStart=this.listStart+1;
        if(this.filterData[i].isVisible){          
          break;                     
        }
      }
      this.removeSelectedListClass();
      this.template.querySelector(`li[data-id="${this.filterData[this.listStart].id}"]`).classList.add("selectedList");
      this.template.querySelector(`li[data-id="${this.filterData[this.listStart].id}"]`).focus();
      this.showDropdown=true;
    }
  }

  removeSelectedListClass(){
    for (var i = 0; i < this.filterData.length; i++) {  
      if(this.filterData[i].isVisible){
        this.template.querySelector(`li[data-id="${this.filterData[i].id}"]`).classList.remove("selectedList"); 
      }
    }
  }

  handleKeyUpEvent(event){
    if(event.keyCode == 40){
      this.showDropdown = true;
      if(this.listStart==this.filterData.length-1||this.listStart>this.filterData.length-1) 
      this.listStart=0;
      else
      this.listStart=this.listStart+1;
      this.removeSelectedListClass();
      this.template.querySelector(`li[data-id="${this.filterData[this.listStart].id}"]`).classList.add("selectedList");
      this.template.querySelector(`li[data-id="${this.filterData[this.listStart].id}"]`).focus();
      this.showDropdown=true;
    }
    if(event.keyCode == 38){
      this.showDropdown = true;
      if(this.listStart<=0)this.listStart=this.filterData.length-1;
      else
      this.listStart=this.listStart-1;
      console.log("Nyra"+this.filterData[this.listStart].id);
      this.removeSelectedListClass();
      this.template.querySelector(`li[data-id="${this.filterData[this.listStart].id}"]`).classList.add("selectedList");
      this.template.querySelector(`li[data-id="${this.filterData[this.listStart].id}"]`).focus();
      this.showDropdown=true;
    }
      if(event.keyCode == 13||event.keyCode == 32){
        var event = new Event('mousedown');
        this.template.querySelector(`li[data-id="${this.filterData[this.listStart].id}"]`).dispatchEvent(event);
      }
      if(event.keyCode == 27)
      this.showDropdown=false;
    }
    handleBlurEventOnList(){
      this.showDropdown = false;
    }

    selectItem(event) {
      console.log("SELECT");
      event.stopPropagation();
      event.preventDefault();
      var selectedVal = event.currentTarget.dataset.id;
      var parentId = event.currentTarget.dataset.parent;
      if (this.isCombobox) {
        if (!this.multiSelect) {
          this.template.querySelectorAll("lightning-button-stateful").forEach((element) => {
            element.selected = false;
            element.variant = "neutral";
          });
        }
        event.target.selected = !event.target.selected;
        event.target.variant = event.target.variant === "brand" ? "neutral" : "brand";
      }
      if (selectedVal) {
        var count = 0;
        var options = this.isTree ? JSON.parse(JSON.stringify(this.filterData.find((el) => el.Id === parentId).children)) : JSON.parse(JSON.stringify(this.filterData));
        for (var i = 0; i < options.length; i++) {
          
          if (options[i].id === selectedVal) {            
            if (this.multiSelect) {
              if (this.values.includes(options[i].id)) {
                this.values.splice(this.values.indexOf(options[i].id), 1);
              } else {
                this.values.push(options[i].id);
              }
              options[i].isActive = options[i].isActive ? false : true;
              this.dispatchEvent(
                new CustomEvent("toggle", {
                  detail: selectedVal,
                })
              );
            } else {
              this.value = options[i].id;
              this.searchString = options[i].name;
              options[i].isActive = options[i].isActive ? false : true;
            }
          }
          if (options[i].isActive) {
            count++;
          }
        }
        if (this.isTree) {
          this.filterData.find((el) => el.Id === parentId).children = options;
        } else this.filterData = options;
        
        if (this.multiSelect) this.searchString = count + " " + OptionsSelectedLabel;
        if (this.multiSelect) event.preventDefault();
        else this.showDropdown = false;
      }
    }

  toggleChildren(event) {
    const unorderedList = this.template.querySelector('ul [data-filter="' + event.currentTarget.dataset.id + '"]');
    const liIcon = this.template.querySelector('[data-icon="' + event.currentTarget.dataset.id + '"]');

    if (unorderedList.style.display == "none") {
      unorderedList.style.display = "block";
      liIcon.iconName = "utility:down";
    } else {
      unorderedList.style.display = "none";
      liIcon.iconName = "utility:right";
    }

    event.preventDefault();
  }

}