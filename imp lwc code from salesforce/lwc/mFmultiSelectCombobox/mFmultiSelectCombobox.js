/* Code by CafeForce || www.cafeforce.com || support@cafeforce.com || Mandatory Header */
import { LightningElement, track, api } from "lwc";
import templateOne from "./mFmultiSelectCombobox.html";
import templateTwo from "./mFmultiSelectStatefulButtons.html";

import SelectAnOptionLabel from "@salesforce/label/c.search_select_an_option";
import OptionsSelectedLabel from "@salesforce/label/c.search_options_selected";
import noResultsFoundForLabel from "@salesforce/label/c.search_no_results_found";
import PleaseselectanoptionLabel from "@salesforce/label/c.Please_select_an_option_Label";

export default class MultiSelectCombobox extends LightningElement {
  @api options;
  @api selectedValue;
  @api selectedValues = [];
  @api label; // It looks not in use
  @api minChar = 2;
  @api disabled = false;
  @api multiSelect = false;
  @api value;
  @api values = [];
  @track optionData;
  @track searchString;
  @track message;
  @api showDropdown = false;
   @track listStart=-1;
  @api isCombobox = false;
  @api isTree = false;
  @api customLabel;
  @api invalid;

  labels = { SelectAnOptionLabel, PleaseselectanoptionLabel};

  render() {
    return !this.isCombobox ? templateOne : templateTwo;
  }
  
  isDDopen(){
    //console.log('this.showDropdown '+this.showDropdown);
    //return this.showDropdown;
  }

  connectedCallback() {
    this.showDropdown = false;
    var optionData = this.options ? JSON.parse(JSON.stringify(this.options)) : [];
    var value = this.selectedValue ? JSON.parse(JSON.stringify(this.selectedValue)) : [];
    var values = this.selectedValues ? JSON.parse(JSON.stringify(this.selectedValues)) : [];
    // console.log(value);
    // console.log(values);
    //console.log("data - "+optionData);
    if (value || values) {
      var searchString;
      var count = 0;
      for (var i = 0; i < optionData.length; i++) {
        if (this.multiSelect) {
          // console.log(this.multiSelect);
          if (!this.isTree) {
            // console.log(optionData[i].value);
            optionData[i].selectedLabel = optionData[i].label+" is Selected";
            optionData[i].unselectLabel = "Unselect "+ optionData[i].label;
            if (values.includes(optionData[i].value)) {
              optionData[i].selected = true;
              optionData[i].variant = "brand";              
              //optionData[i].selectedLabel = optionData[i].label+"is Selected";
              //optionData[i].unselectLabel = "Unselect "+ optionData[i].label;
              count++;
            }
          } else {
            optionData[i].children.forEach((element) => {
              console.log("tree", element.value);
              if (values.includes(element.value)) {
                element.selected = true;
                element.variant = "brand";
                count++;
              }
            });
          }
        } else {
          if (optionData[i].value == value) {
            searchString = optionData[i].label;
            optionData[i].selected = true;
            optionData[i].variant = "brand";
          }
        }
      }
      if (this.multiSelect) this.searchString = count + " " + OptionsSelectedLabel;
      else this.searchString = searchString;
    }
    this.value = value;
    this.values = values;
    this.optionData = optionData;
  }

  filterOptions(event) {
    if(event.keyCode!=9){
    this.searchString = event.target.value;
    if (this.searchString && this.searchString.length > 0) {
      this.message = "";
      if (this.searchString.length >= this.minChar) {
        var flag = true;
        for (var i = 0; i < this.optionData.length; i++) {
          if (this.optionData[i].label.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
            this.optionData[i].isVisible = true;
            flag = false;
          } else {
            this.optionData[i].isVisible = false;
          }
        }
        if (flag) {
          this.message = noResultsFoundForLabel + " '" + this.searchString + "'";
        }
      }
      this.showDropdown = true;
    } else {
      this.showDropdown = false;
    }
  }
  if(event.keyCode == 40|| event.keyCode == 38){
    this.showDropdown = true;
    this.listStart=0;
    this.removeSelectedListClass();
    this.template.querySelector(`li[data-id="${this.optionData[this.listStart].value}"]`).classList.add("selectedList");
    this.template.querySelector(`li[data-id="${this.optionData[this.listStart].value}"]`).focus();
    this.showDropdown=true;
  }
  }
removeSelectedListClass(){
  for (var i = 0; i < this.optionData.length; i++) {  this.template.querySelector(`li[data-id="${this.optionData[i].value}"]`).classList.remove("selectedList"); }
}
handleKeyUp(event){
  if(event.keyCode == 40){
    console.log('down arrow key pressed..!!');
    this.showDropdown = true;
    if(this.listStart==this.optionData.length-1||this.listStart>this.optionData.length-1) 
    this.listStart=0;
    else
    this.listStart=this.listStart+1;
    this.removeSelectedListClass();
    this.template.querySelector(`li[data-id="${this.optionData[this.listStart].value}"]`).classList.add("selectedList");
    this.template.querySelector(`li[data-id="${this.optionData[this.listStart].value}"]`).focus();
    this.showDropdown=true;
  }
  if(event.keyCode == 38){
    this.showDropdown = true;
    if(this.listStart<=0)this.listStart=this.optionData.length-1;
    else
    this.listStart=this.listStart-1;
    console.log("Nyra"+this.optionData[this.listStart].value);
    this.removeSelectedListClass();
    this.template.querySelector(`li[data-id="${this.optionData[this.listStart].value}"]`).classList.add("selectedList");
    this.template.querySelector(`li[data-id="${this.optionData[this.listStart].value}"]`).focus();
    this.showDropdown=true;
  }
  if(event.keyCode == 13||event.keyCode == 32){
      var event = new Event('mousedown');
      this.template.querySelector(`li[data-id="${this.optionData[this.listStart].value}"]`).dispatchEvent(event);
    }
  if(event.keyCode == 27){
    console.log("Escape button pressed");
    this.showDropdown=false;
    event.preventDefault();
    event.stopPropagation();
  }

  
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
      var options = this.isTree ? JSON.parse(JSON.stringify(this.optionData.find((el) => el.Id === parentId).children)) : JSON.parse(JSON.stringify(this.optionData));
      for (var i = 0; i < options.length; i++) {
        if (options[i].value === selectedVal) {
          if (this.multiSelect) {
            if (this.values.includes(options[i].value)) {
              this.values.splice(this.values.indexOf(options[i].value), 1);
            } else {
              this.values.push(options[i].value);
            }
            options[i].selected = options[i].selected ? false : true;
            options[i].selectedLabel = options[i].label+" is Selected";
            options[i].unselectLabel = "Unselect "+ options[i].label;
          } else {
            this.value = options[i].value;
            this.searchString = options[i].label;
          }
        }
        if (options[i].selected) {
          //options[i].selectedLabel = options[i].label+" is Selected";
          //options[i].unselectLabel = "Unselect "+ options[i].label;
          count++;
        }
      }
      if (this.isTree) {
        this.optionData.find((el) => el.Id === parentId).children = options;
      } else this.optionData = options;

      if (this.multiSelect) this.searchString = count + " " + OptionsSelectedLabel;
      if (this.multiSelect) event.preventDefault();
      else this.showDropdown = false;
    }
    console.log("values", this.values);
    console.log("value", this.value);
  }

  showOptions() {
    if (this.disabled == false && this.options) {
      this.message = "";
      this.searchString = "";
      var options = JSON.parse(JSON.stringify(this.optionData));
      for (var i = 0; i < options.length; i++) {
        options[i].isVisible = true;
      }
      if (options.length > 0) {
        this.showDropdown = true;
      }
      this.optionData = options;
    }
  }

  removePill(event) {
    var value = event.currentTarget.name;
    var count = 0;
    var options = JSON.parse(JSON.stringify(this.optionData));
    for (var i = 0; i < options.length; i++) {
      if (options[i].value === value) {
        options[i].selected = false;
        this.values.splice(this.values.indexOf(options[i].value), 1);
      }
      if (options[i].selected) {
        count++;
      }
    }
    this.optionData = options;
    if (this.multiSelect) this.searchString = count + " " + OptionsSelectedLabel;
  }

  blurEvent() {
    var previousLabel;
    var count = 0;
    for (var i = 0; i < this.optionData.length; i++) {
      //console.log(JSON.parse(JSON.stringify(this.optionData[i])));

      if (!this.isTree) {
        if (this.optionData[i].value === this.value) {
          previousLabel = this.optionData[i].label;
        }
        if (this.optionData[i].selected) {
          count++;
        }
      } else {
        console.log("this.isTree: ", this.isTree);
        for (var z = 0; z < this.optionData[i].children.length; z++) {
          if (this.optionData[i].children[z]?.selected) {
            count++;
          }
        }
      }
    }
    if (this.multiSelect) this.searchString = count + " " + OptionsSelectedLabel;
    else this.searchString = previousLabel;
   
    this.showDropdown = false;

    this.dispatchEvent(
      new CustomEvent("select", {
        detail: {
          payloadType: "multi-select",
          payload: {
            value: this.value,
            values: this.values,
          },
        },
      })
    );
  }
 
  toggleChildren(event) {
    console.log("TOGGLE");
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
    event.stopPropagation();
  }

  get hasInputError() {
    return this.invalid ? "slds-form-element slds-has-error" : "slds-form-element";
 }
}
/* 
    Code by CafeForce 
    Website: http://www.cafeforce.com 
    DO NOT REMOVE THIS HEADER/FOOTER FOR FREE CODE USAGE 
*/