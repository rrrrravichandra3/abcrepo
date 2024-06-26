import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import FUNCTIONAL_COMPETENCIES_FIELD from "@salesforce/schema/User.Functional_Competencies__c";
import FUNCTIONAL_COMPETENCIES_TO_IMPROVE_FIELD from "@salesforce/schema/User.Functional_Competencies_to_Improve__c";
import GREAT_COMPETENCIES_FIELD from "@salesforce/schema/User.Great_Competencies__c";
import GREAT_COMPETENCIES_TO_IMPROVE_FIELD from "@salesforce/schema/User.Great_Competencies_to_Improve__c";
import MENTOR_LOCATION_FIELD from "@salesforce/schema/User.Mentor_Location_Preference__c";
import COUNTRY_FIELD from "@salesforce/schema/User.Country";
import MENTOR_TYPE_FIELD from "@salesforce/schema/User.Mentor_Type_Preference__c";
import MENTEE_TYPE_FIELD from "@salesforce/schema/User.Mentee_Type_Preference__c";
import SKILLS_FIELD from "@salesforce/schema/User.Skills__c";
import SKILLS_TO_IMPROVE_FIELD from "@salesforce/schema/User.Skills_to_Improve__c";
import EQUALITY_GROUP_MEMBER_FIELD from "@salesforce/schema/User.Equality_Group_Member__c";
import EXPERIENCES_FIELD from "@salesforce/schema/User.Experiences__c";
import EXPERIENCES_TO_IMPROVE_FIELD from "@salesforce/schema/User.Experiences_to_Improve__c";
import LANGUAGES_FIELD from "@salesforce/schema/User.Mentoring_Language__c";
import CERTIFICATIONS_FIELD from "@salesforce/schema/User.Certifications__c";
import Id from "@salesforce/user/Id";
//import cacheData from "@salesforce/apex/MainMentoringController.cacheData";

import getRolesAndCompetencies from "@salesforce/apex/MainMentoringController.retrieveRolesAndCompetencies";

import YearOfExperienceLabel from "@salesforce/label/c.search_year_of_experience";
import YearsOfExperienceLabel from "@salesforce/label/c.search_years_of_experience";
import TypeOfMentoringLabel from "@salesforce/label/c.Label_type_of_mentoring";
import RoleCompetenciesLabel from "@salesforce/label/c.Label_role_competencies";
import LocationsLabel from "@salesforce/label/c.Label_locations";
import SkillsLabel from "@salesforce/label/c.Label_skills";
import EqualityGroupLabel from "@salesforce/label/c.Label_Equality_Group_Member";

import GreatCompetenciesLabel from "@salesforce/label/c.Label_great_competencies";
import ExperiencesLabel from "@salesforce/label/c.Label_experiences";
import CertificationsLabel from "@salesforce/label/c.Label_certifications";
import LanguagesLabel from "@salesforce/label/c.Label_languages";

export default class FilterPanel extends LightningElement {
  userId = Id;
  @api showFilters = false;
  @api filterCategories = [];
  @api activeFilters = [];
  @api startFilters = [];
  @api firstCall = false;

  @api resetFilters() {
    this.activeFilters = [];
    this.template.querySelectorAll("c-filter-category").forEach((element) => {
      element.resetFilters();
    });
  }

  get filterMap() {
    console.log(JSON.stringify(' $$ this.startFilters '+this.startFilters));
   if (this.startFilters) {
     const set = new Set();
     this.startFilters.filter((o) => {
       if (set.has(o.id)) return false;
       set.add(o.id);
       return true;
     });
     return set;
   }
   return null;
 }

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: EQUALITY_GROUP_MEMBER_FIELD,
  })
  mentorInterestsWire({ error, data }) {
    if (data) {
      let interestsValues = {
        name: EqualityGroupLabel,
        fieldApiName: EQUALITY_GROUP_MEMBER_FIELD,
        order: 6,
        filters: data.values.map(function (picklistValue) {
          let tempPicklistValue = {
            name: picklistValue.label,
            id: picklistValue.value,
            fieldApiName: EQUALITY_GROUP_MEMBER_FIELD.fieldApiName,
            filterField: EQUALITY_GROUP_MEMBER_FIELD.fieldApiName,
            searchDisplay: true,
          };
          return tempPicklistValue;
        }),
      };
      let newFilters = [...this.filterCategories];
      newFilters.push(interestsValues);
      this.filterCategories = newFilters;
    } else if (error) {
      //eslint-disable-next-line
      console.error("Error: ", error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error: ",
          message: error.body.message,
          variant: "error",
        })
      );
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: MENTOR_TYPE_FIELD,
  })
  mentorTypeWire({ error, data }) {
    if (data) {
      let mentorTypeValues = {
        name: TypeOfMentoringLabel,
        fieldApiName: MENTOR_TYPE_FIELD,
        order: 4,
        filters: data.values.map(function (picklistValue) {
          let tempPicklistValue = {
            name: picklistValue.label,
            id: picklistValue.value,
            fieldApiName: MENTOR_TYPE_FIELD.fieldApiName,
            filterField: MENTEE_TYPE_FIELD.fieldApiName,
            searchDisplay: true,
          };
          return tempPicklistValue;
        }),
      };
      let newFilters = [...this.filterCategories];
      newFilters.push(mentorTypeValues);
      this.filterCategories = newFilters;
    } else if (error) {
      //eslint-disable-next-line
      console.error("Error: ", error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error: ",
          message: error.body.message,
          variant: "error",
        })
      );
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: MENTOR_LOCATION_FIELD,
  })
  mentorLocationWire({ error, data }) {
    if (data) {
      console.log("D2: ", data);
      let locationValues = {
        name: LocationsLabel,
        fieldApiName: MENTOR_LOCATION_FIELD,
        order: 7,
        filters: data.values.map(function (picklistValue) {
          let tempPicklistValue = {
            name: picklistValue.label,
            id: picklistValue.value,
            fieldApiName: MENTOR_LOCATION_FIELD.fieldApiName,
            filterField: COUNTRY_FIELD.fieldApiName,
            searchDisplay: true,
          };
          return tempPicklistValue;
        }),
      };
      let newFilters = [...this.filterCategories];
      newFilters.push(locationValues);
      this.filterCategories = newFilters;
    } else if (error) {
      //eslint-disable-next-line
      console.error("Error: ", error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error: ",
          message: error.body.message,
          variant: "error",
        })
      );
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: GREAT_COMPETENCIES_FIELD,
  })
  greatCompetenciesWire({ error, data }) {
    if (data) {
      let interestsValues = {
        name: GreatCompetenciesLabel,
        fieldApiName: GREAT_COMPETENCIES_FIELD,
        order: 1,
        filters: data.values.map(function (picklistValue) {
          let tempPicklistValue = {
            name: picklistValue.label,
            id: picklistValue.value,
            fieldApiName: GREAT_COMPETENCIES_TO_IMPROVE_FIELD.fieldApiName,
            filterField: GREAT_COMPETENCIES_FIELD.fieldApiName,
            searchDisplay: true,
          };
          return tempPicklistValue;
        }),
      };
      let newFilters = [...this.filterCategories];
      newFilters.push(interestsValues);
      this.filterCategories = newFilters;
    } else if (error) {
      //eslint-disable-next-line
      console.error("Error: ", error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({//72968304
          title: "Error: ",
          message: error.body.message,
          variant: "error",
        })
      );
    }
  }

  @wire(getRolesAndCompetencies)
  wiredApexMethod({ error, data }) {
    if (error) {
      console.log("Error: ", error);
      this.loading = false;
      this.showUnsupportedBanner = true;
    } else if (data) {
      console.log("data: ", data);
      let tempFilterData=[];
      for(let i=0; i<data.length; i++){
        tempFilterData.push(...data[i].values);
      }
      let newRoleCompetencyValues = {
        name: RoleCompetenciesLabel,
        fieldApiName: "roleCompetencies",
        tree: false,
        order: 5,
        filters: tempFilterData.map(function (child) {
          var tempPicklistValue = {
              name: child.label,
              id: child.value,
              key: child.value,
              fieldApiName: FUNCTIONAL_COMPETENCIES_TO_IMPROVE_FIELD.fieldApiName,
              filterField: FUNCTIONAL_COMPETENCIES_FIELD.fieldApiName,
              searchDisplay: true,
            };
          //console.log('TWO:',tempPicklistValue); 
          return tempPicklistValue;
        }),
      };

      // let roleCompetencyValues = {
      //   name: RoleCompetenciesLabel,
      //   fieldApiName: "roleCompetencies",
      //   tree: true,
      //   order: 5,
      //   filters: data.map(function (picklistValue) {
      //     let tempPicklistValue = {
      //       name: picklistValue.Name,
      //       id: picklistValue.Id,
      //       searchDisplay: true,
      //       children: picklistValue.Functional_Competencies__c.split(";").map(function (child) {
      //         return {
      //           name: child,
      //           id: child,
      //           key: picklistValue.Name + "-" + child,
      //           fieldApiName: FUNCTIONAL_COMPETENCIES_TO_IMPROVE_FIELD.fieldApiName,
      //           filterField: FUNCTIONAL_COMPETENCIES_FIELD.fieldApiName,
      //           tree: true,
      //         };
      //       }),
      //     };
      //     return tempPicklistValue;
      //   }),
      // };

      let newFilters = [...this.filterCategories];
      newFilters.push(newRoleCompetencyValues);
      this.filterCategories = newFilters;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: EXPERIENCES_FIELD,
  })
  experiencesWire({ error, data }) {
    if (data) {
      let interestsValues = {
        name: ExperiencesLabel,
        fieldApiName: EXPERIENCES_FIELD,
        order: 2,
        filters: data.values.map(function (picklistValue) {
          let tempPicklistValue = {
            name: picklistValue.label,
            id: picklistValue.value,
            fieldApiName: EXPERIENCES_TO_IMPROVE_FIELD.fieldApiName,
            filterField: EXPERIENCES_FIELD.fieldApiName,
            searchDisplay: true,
          };
          return tempPicklistValue;
        }),
      };
      let newFilters = [...this.filterCategories];
      newFilters.push(interestsValues);
      this.filterCategories = newFilters;
    } else if (error) {
      //eslint-disable-next-line
      console.error("Error: ", error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error: ",
          message: error.body.message,
          variant: "error",
        })
      );
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: LANGUAGES_FIELD,
  })
  languagesWire({ error, data }) {
    if (data) {
      let interestsValues = {
        name: LanguagesLabel,
        fieldApiName: LANGUAGES_FIELD,
        order: 3,
        filters: data.values.map(function (picklistValue) {
          let tempPicklistValue = {
            name: picklistValue.label,
            id: picklistValue.value,
            fieldApiName: LANGUAGES_FIELD.fieldApiName,
            filterField: LANGUAGES_FIELD.fieldApiName,
            searchDisplay: true,
          };
          return tempPicklistValue;
        }),
      };
      let newFilters = [...this.filterCategories];
      newFilters.push(interestsValues);
      this.filterCategories = newFilters;
    } else if (error) {
      //eslint-disable-next-line
      console.error("Error: ", error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error: ",
          message: error.body.message,
          variant: "error",
        })
      );
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: CERTIFICATIONS_FIELD,
  })
  certificationsWire({ error, data }) {
    if (data) {
      let interestsValues = {
        name: CertificationsLabel,
        fieldApiName: CERTIFICATIONS_FIELD,
        order: 8,
        filters: data.values.map(function (picklistValue) {
          let tempPicklistValue = {
            name: picklistValue.label,
            id: picklistValue.value,
            fieldApiName: CERTIFICATIONS_FIELD.fieldApiName,
            filterField: CERTIFICATIONS_FIELD.fieldApiName,
            searchDisplay: true,
          };
          return tempPicklistValue;
        }),
      };
      let newFilters = [...this.filterCategories];
      newFilters.push(interestsValues);
      this.filterCategories = newFilters;
    } else if (error) {
      //eslint-disable-next-line
      console.error("Error: ", error.body.message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error: ",
          message: error.body.message,
          variant: "error",
        })
      );
    }
  }

  @wire(getRecord, {
    recordId: "$userId",
    fields: [
      SKILLS_TO_IMPROVE_FIELD,
      SKILLS_FIELD,
      MENTOR_LOCATION_FIELD,
      COUNTRY_FIELD,
      MENTOR_TYPE_FIELD,
      MENTEE_TYPE_FIELD,
      EQUALITY_GROUP_MEMBER_FIELD,
      GREAT_COMPETENCIES_FIELD,
      GREAT_COMPETENCIES_TO_IMPROVE_FIELD,
      EXPERIENCES_FIELD,
      EXPERIENCES_TO_IMPROVE_FIELD,
      LANGUAGES_FIELD,
      CERTIFICATIONS_FIELD,
    ],
  })
  wiredCurrentUser({ error, data }) {
    if (error) {
      this.showErrorMessage(error);
    } else if (data) {
      this.currentUser = data;
    }
  }

  connectedCallback(){
    
  }
  preselectFilters() {
    // This functions creates a default filterCategories array of filters, based on the user's preferences
    // Filters to consider: Interests, Mentor Location, Mentor Skills, Type of Mentoring

    // Get selected values from user Record
    /*const equalityGroupMembers = getFieldValue(this.currentUser, EQUALITY_GROUP_MEMBER_FIELD);
    const countries = getFieldValue(this.currentUser, MENTOR_LOCATION_FIELD);
    const skills = getFieldValue(this.currentUser, SKILLS_TO_IMPROVE_FIELD);
    const typeOfMentoring = getFieldValue(this.currentUser, MENTOR_TYPE_FIELD);

    const filters = [
      ...(equalityGroupMembers && equalityGroupMembers !== "" ? equalityGroupMembers.split(";") : []),
      ...(countries && countries !== "" ? countries.split(";") : []),
      ...(skills && skills !== "" ? skills.split(";") : []),
      ...(typeOfMentoring && typeOfMentoring !== "" ? typeOfMentoring.split(";") : []),
    ];*/
    
    //this.filterCategories = newFilters; // Completely reassigns new array to trigger re-render of filters
    this.dispatchEvent(
      new CustomEvent("filter", {
        detail: this.activeFilters,
      })
    );
  }

  showErrorMessage(error) {
    //eslint-disable-next-line
    console.error(error);
    let message = "Unknown error";
    if (Array.isArray(error.body)) {
      message = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      message = error.body.message;
    }
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Error loading user",
        message,
        variant: "error",
      })
    );
  }

  // Loops through filter array toggles filter with given id
  toggleFilter(id) {
   
      console.log('toggleFilter');
      let newFilters = JSON.parse(JSON.stringify([...this.filterCategories]));
      console.log("toggele json: "+ newFilters)
      for (let i = 0; i < newFilters.length; i += 1) {
        var filterToggled = false;
  
        for (let j = 0; j < newFilters[i].filters.length; j += 1) {
          if (newFilters[i].filters[j].children) {
            // Logic for toggling nested filters (tree)
            for (let k = 0; k < newFilters[i].filters[j].children.length; k += 1) {
              if (newFilters[i].filters[j].children[k].id === id && !filterToggled) {
                filterToggled = true;
                if (!this.checkIfAlreadyActive(newFilters[i].filters[j].children[k])) {
                  console.log("adding to active filters");
                  this.addToActiveFilters(newFilters[i].filters[j].children[k]);
                } else {
                  console.log("removing");
                  this.removeFromActiveFilters(newFilters[i].filters[j].children[k]);
                }
              }
            }
          } else {
            if (id === newFilters[i].filters[j].id) {
              if (!this.checkIfAlreadyActive(newFilters[i].filters[j])) {
                this.addToActiveFilters(newFilters[i].filters[j]);
              } else {
                this.removeFromActiveFilters(newFilters[i].filters[j]);
              }
            }
          }
        }
      }
      this.filterCategories = newFilters; // Completely reassigns new array to trigger re-render of filters
    
  }

  handleSearchKeyChange(searchKey) {
    this.searchKey = searchKey;
  }
  
  checkIfAlreadyActive(filter) {
    //console.log('checkIfAlreadyActive');
    let theActiveFilters = JSON.parse(JSON.stringify([...this.activeFilters]));
      
    if (this.startFilters) {
      this.startFilters.filter((o) => {
        theActiveFilters.push(o);
      });
    }

    for (let i = 0; i < theActiveFilters.length; i += 1) {
      if (theActiveFilters[i].id === filter.id) {
        return true;
      }
    }
    console.log('checkIfAlreadyActive'+JSON.stringify());
    this.firstCall = true;
        
    return false;
  }

  addToActiveFilters(filter) {
    let theActiveFilters = JSON.parse(JSON.stringify([...this.activeFilters]));
    theActiveFilters.push(filter);
    
    this.activeFilters = theActiveFilters;
    this.dispatchEvent(
      new CustomEvent("filter", {
        detail: this.activeFilters,
      })
    );
  }

  removeFromActiveFilters(filter) {
    let theActiveFilters = JSON.parse(JSON.stringify([...this.activeFilters]));
    for (let i = 0; i < theActiveFilters.length; i += 1) {
      if (theActiveFilters[i].id === filter.id) {
        theActiveFilters.splice(i, 1);
      }
    }
    this.activeFilters = theActiveFilters;
    this.dispatchEvent(
      new CustomEvent("filter", {
        detail: {add: null, remove: filter},
      })
    );
  }

  // Handlers filter selected & sends updated filter array to parent
  handleFilterClick(event) {
    //console.log('handleFilterClick');
    const selectedId = event.detail;
    this.toggleFilter(selectedId);
  }

  handleParentClick(event) {
    console.log('handleParentClick');
    console.log(event.detail);
    this.toggleFilter(event.detail);
  }

  closeClickedHandler() {
    this.dispatchEvent(new CustomEvent("close"));
  }

  get sortedCategories() {
    //console.log(JSON.stringify([...this.filterCategories]));
    let theSortedCategories = JSON.parse(JSON.stringify([...this.filterCategories]));
    return theSortedCategories.sort(function (a, b) {
      return a.order - b.order;
    });
  }
}