import { LightningElement, track, wire, api } from "lwc";
import { refreshApex } from "@salesforce/apex";
import retrieveMentors from "@salesforce/apex/MainMentoringController.retrieveMentors";
//import cacheData from "@salesforce/apex/MainMentoringController.cacheData";
//import retrieveUsers from "@salesforce/apex/MainMentoringController.retrieveUsers";
import { NavigationMixin } from "lightning/navigation";
import FUNCTIONAL_COMPETENCIES_FIELD from "@salesforce/schema/User.Functional_Competencies__c";
import FUNCTIONAL_COMPETENCIES_TO_IMPROVE_FIELD from "@salesforce/schema/User.Functional_Competencies_to_Improve__c";
import GREAT_COMPETENCIES_FIELD from "@salesforce/schema/User.Great_Competencies__c";
import GREAT_COMPETENCIES_TO_IMPROVE_FIELD from "@salesforce/schema/User.Great_Competencies_to_Improve__c";
import AVAILABLE_FIELD from "@salesforce/schema/User.Available__c";
import BUSINESS_UNIT_FIELD from "@salesforce/schema/User.Business_Unit__c";
import COST_CENTER_FIELD from "@salesforce/schema/User.Cost_Center__c";
import COUNTRY_FIELD from "@salesforce/schema/User.Country";
import MENTEE_TYPE_FIELD from "@salesforce/schema/User.Mentee_Type_Preference__c";
import MENTOR_TYPE_FIELD from "@salesforce/schema/User.Mentor_Type_Preference__c";
import MENTOR_LOCATION_FIELD from "@salesforce/schema/User.Mentor_Location_Preference__c";
import SKILLS_FIELD from "@salesforce/schema/User.Skills__c";
import SKILLS_TO_IMPROVE_FIELD from "@salesforce/schema/User.Skills_to_Improve__c";
import HIRE_DATE_FIELD from "@salesforce/schema/User.Hire_Date__c";
import EGC_FIELD from "@salesforce/schema/User.Equality_Group_Member__c";
import EXPERIENCES_FIELD from "@salesforce/schema/User.Experiences__c";
import EXPERIENCES_TO_IMPROVE_FIELD from "@salesforce/schema/User.Experiences_to_Improve__c";
import LANGUAGES_FIELD from "@salesforce/schema/User.Mentoring_Language__c";
import CERTIFICATIONS_FIELD from "@salesforce/schema/User.Certifications__c";

import AdvancedFiltersLabel from "@salesforce/label/c.search_advanced_filters";
import areYouAContractorLabel from "@salesforce/label/c.search_are_you_a_contractor";
import weArePilotingLabel from "@salesforce/label/c.search_we_are_piloting";
import searchMentorsLabel from "@salesforce/label/c.search_mentors";

import couldntFindMentorsCriteriaLabel from "@salesforce/label/c.search_Oops_We_couldn_t_find_any_mentors_for_your_specified_criteria";
import mentorSuggestionsForYouLabel from "@salesforce/label/c.search_mentor_suggestions_for_you";
import noAvailableMentorsForYouLabel from "@salesforce/label/c.search_There_are_no_available_mentors_for_your_specified_criteria";
import weShortlistedGreatMentorsForYouLabel from "@salesforce/label/c.search_we_shortlisted_great_mentors_for_you";
import filterCardTitle from "@salesforce/label/c.search_Filter_card_title";
import searchBasedOnYourBackgroundLabel from "@salesforce/label/c.search_Based_on_your_background";

export default class SearchMentors extends NavigationMixin(LightningElement) {
  @api showFilteringOptions = false;
  @api filtersAlwaysOn = false;
  @api showSearchBar = false;

  @track mentorsRaw;
  @track filteredMentors;
  @track showFilters = false;
  @track filterCategories;
  @track loading = false;
  @track showUnsupportedBanner = false;
  @track searchTerm;
  @track currentUser;

  @track certifications = [];
  @track typeOfMentoring = [];
  @track functionalCompetencies = [];
  @track languages = [];
  @track experiences = [];
  @track egcs = [];
  @track greatCompetencies = [];
  @track locations = [];

  wiredMentors;
  @track mentorData;

  labels = {
    AdvancedFiltersLabel,
    areYouAContractorLabel,
    weArePilotingLabel,
    searchMentorsLabel,
    couldntFindMentorsCriteriaLabel,
    mentorSuggestionsForYouLabel,
    noAvailableMentorsForYouLabel,
    weShortlistedGreatMentorsForYouLabel,
    searchBasedOnYourBackgroundLabel,
    filterCardTitle,
  };

  connectedCallback() {
    this.handleRetrieveFromCache();
    console.log('in Connected call back');
    if (this.filtersAlwaysOn) {
      this.showFilters = true;
    }
    this.loading = true;
    this.handleRetrieveMentors();
  }
  handleRetrieveFromCache(){
    
    if(localStorage.getItem('activeFilters')){
      try {
        this.filterCategories = JSON.parse(localStorage.getItem('activeFilters'));

        let certificationsList = [];
        let typeOfMentoringList = [];
        let functionalCompetenciesList = [];
        let languagesList = [];
        let experiencesList = [];
        let egcsList = [];
        let greatCompetenciesList = [];
        let locationsList = [];

        this.filterCategories.forEach((filter) => {
          if (filter.filterField == CERTIFICATIONS_FIELD.fieldApiName) {
            certificationsList.push(filter.id);
          }
          if (filter.filterField == MENTEE_TYPE_FIELD.fieldApiName) {
            typeOfMentoringList.push(filter.id);
          }
          if (filter.filterField == FUNCTIONAL_COMPETENCIES_FIELD.fieldApiName) {
            functionalCompetenciesList.push(filter.id);
          }
          if (filter.filterField == LANGUAGES_FIELD.fieldApiName) {
            languagesList.push(filter.id);
          }
          if (filter.filterField == EXPERIENCES_FIELD.fieldApiName) {
            experiencesList.push(filter.id);
          }
          if (filter.filterField == EGC_FIELD.fieldApiName) {
            egcsList.push(filter.id);
          }
          if (filter.filterField == GREAT_COMPETENCIES_FIELD.fieldApiName) {
            greatCompetenciesList.push(filter.id);
          }
          if (filter.fieldApiName == MENTOR_LOCATION_FIELD.fieldApiName) {
            locationsList.push(filter.id);
          }
        });
        this.certifications = certificationsList;
        this.typeOfMentoring = typeOfMentoringList;
        this.functionalCompetencies = functionalCompetenciesList;
        this.languages = languagesList;
        this.experiences = experiencesList;
        this.egcs = egcsList;
        this.greatCompetencies = greatCompetenciesList;
        this.locations = locationsList;
      }
      catch (e) {
        console.log('Failed to Parse');
      }
    }
  }

  loadData() {
    //Called when a request is sent in order to refresh the apex to filter out that person
    refreshApex(this.wiredMentors);
  }
/*
  @wire(retrieveMentors, {
    certifications: "$certifications",
    typeOfMentoring: "$typeOfMentoring",
    functionalCompetencies: "$functionalCompetencies",
    languages: "$languages",
    experiences: "$experiences",
    egcs: "$egcs",
    greatCompetencies: "$greatCompetencies",
    locations: "$locations",
  })
  wiredApexMethod(value) {
    this.wiredMentors = value;

    const { data, error } = value;
    if (error) {
      console.log("Error: ", error);
      this.loading = false;
      this.showUnsupportedBanner = true;
    } else if (data) {
      console.log("data: ", data);

      const scoredUsers = data.map((user) => {
        return {
          ...user,
          topMentor: false,
          topCareerMentor: false,
          topValueMentor: false,
          salesLeader: false,
        };
      });
      console.log("scoredUsers: ", scoredUsers);
      this.mentorsRaw = scoredUsers;
      this.processMentors(scoredUsers);
    }
  }
*/
  handleRetrieveMentors() {
    console.log(' $$ handleRetrieveMentors '+this.filterCategories);
    if(this.filterCategories){
      localStorage.setItem("activeFilters",JSON.stringify([...this.filterCategories]));
    }
          
    retrieveMentors({
      certifications: this.certifications,
      typeOfMentoring: this.typeOfMentoring,
      functionalCompetencies: this.functionalCompetencies,
      languages: this.languages,
      experiences: this.experiences,
      egcs: this.egcs,
      greatCompetencies: this.greatCompetencies,
      locations: this.locations
    })
      .then(response => {
        console.log("data: ", response);
        const scoredUsers = response.map((user) => {
          return {
            ...user,
            topMentor: false,
            topCareerMentor: false,
            topValueMentor: false,
            salesLeader: false,
          };
        });
        console.log("scoredUsers: ", scoredUsers);
        this.mentorsRaw = scoredUsers;
        this.processMentors(scoredUsers);
      })
      .catch(error => {
          this.error = error;
          console.log("Error: ", error);
          this.loading = false;
          this.showUnsupportedBanner = true;
      });  
  }


  async processMentors(mentorResponse) {
    console.log("processMentors", mentorResponse.length);
    const parsedMentors = mentorResponse;

    for (let i = 0; i < parsedMentors.length; i++) {
      if (parsedMentors[i][CERTIFICATIONS_FIELD.fieldApiName]?.split(";")?.includes("Sales Leader Excellence Coach")) {
        parsedMentors[i].salesLeader = true;
      }
    }
    this.mentorData = parsedMentors;
    this.filterResults();
    this.loading = false;
  }

  filterResults() {
    this.filteredMentors = this.mentorData;
    // Filter results based on search term
    if (this.searchTerm) {
      const lowerCaseSearchTerm = this.searchTerm.toLowerCase();
      this.filteredMentors = this.filteredMentors.filter((mentor) => {
        const nameMatch = mentor.Name ? mentor.Name.toLowerCase().includes(lowerCaseSearchTerm) : false;
        const titleMatch = mentor.Title ? mentor.Title.toLowerCase().includes(lowerCaseSearchTerm) : false;
        const cityMatch = mentor.City ? mentor.City.toLowerCase().includes(lowerCaseSearchTerm) : false;
        const businessUnitMatch = mentor[BUSINESS_UNIT_FIELD.fieldApiName] ? mentor[BUSINESS_UNIT_FIELD.fieldApiName].toLowerCase().includes(lowerCaseSearchTerm) : false;
        const costCenterMatch = mentor[COST_CENTER_FIELD.fieldApiName] ? mentor[COST_CENTER_FIELD.fieldApiName].toLowerCase().includes(lowerCaseSearchTerm) : false;
        return nameMatch || titleMatch || cityMatch || businessUnitMatch || costCenterMatch;
      });
    } else {
      this.filteredMentors = this.mentorData;
    }
  }

  searchHandler(event) {
    this.searchTerm = event.detail;
    this.filterResults();
  }
  
  
  filterChangedHandler(event) {
    console.log(' $$ C '+event.detail);

    if(event.detail.remove){
      console.log(' $ In remove');
      let theActiveFilters = JSON.parse(JSON.stringify([...this.filterCategories]));
      for (let i = 0; i < theActiveFilters.length; i += 1) {
        if (theActiveFilters[i].id === event.detail.remove.id) {
          theActiveFilters.splice(i, 1);
        }
      }
      this.filterCategories = theActiveFilters;
    }else{
      console.log(' $ In Add');
      if(this.filterCategories){
        let theActiveFilters = JSON.parse(JSON.stringify([...this.filterCategories]));
        for (const elem of event.detail) {
          
          var exists = false;
          for (let i = 0; i < theActiveFilters.length; i += 1) {
            console.log(' $ In Add'+elem.id);
            console.log(' $ In Add'+theActiveFilters[i].id);
            try{
              if (theActiveFilters[i].id == elem.id) {
                exists = true;
                //theActiveFilters.splice(elem);
              }
            } catch (e) {
              console.log('Failed to Parse'+e);
            }
            
          }
          if(!exists){
            theActiveFilters.push(elem);
          }
          
        }
        this.filterCategories = theActiveFilters;
      }else{
        this.filterCategories = event.detail;
      }
    }
    console.log(' $$ this.filterCategories '+this.filterCategories);
    
    let certificationsList = [];
    let typeOfMentoringList = [];
    let functionalCompetenciesList = [];
    let languagesList = [];
    let experiencesList = [];
    let egcsList = [];
    let greatCompetenciesList = [];
    let locationsList = [];

    this.filterCategories.forEach((filter) => {
      if (filter.filterField == CERTIFICATIONS_FIELD.fieldApiName) {
        certificationsList.push(filter.id);
      }
      if (filter.filterField == MENTEE_TYPE_FIELD.fieldApiName) {
        typeOfMentoringList.push(filter.id);
      }
      if (filter.filterField == FUNCTIONAL_COMPETENCIES_FIELD.fieldApiName) {
        functionalCompetenciesList.push(filter.id);
      }
      if (filter.filterField == LANGUAGES_FIELD.fieldApiName) {
        languagesList.push(filter.id);
      }
      if (filter.filterField == EXPERIENCES_FIELD.fieldApiName) {
        experiencesList.push(filter.id);
      }
      if (filter.filterField == EGC_FIELD.fieldApiName) {
        egcsList.push(filter.id);
      }
      if (filter.filterField == GREAT_COMPETENCIES_FIELD.fieldApiName) {
        greatCompetenciesList.push(filter.id);
      }
      if (filter.fieldApiName == MENTOR_LOCATION_FIELD.fieldApiName) {
        locationsList.push(filter.id);
      }
    });
    this.certifications = certificationsList;
    this.typeOfMentoring = typeOfMentoringList;
    this.functionalCompetencies = functionalCompetenciesList;
    this.languages = languagesList;
    this.experiences = experiencesList;
    this.egcs = egcsList;
    this.greatCompetencies = greatCompetenciesList;
    this.locations = locationsList;
  }

  resetFilters() {
    this.filterCategories = '';
    localStorage.clear();
    localStorage.setItem("activeFilters",'');
    
    this.certifications = [];
    this.typeOfMentoring = [];
    this.functionalCompetencies = [];
    this.languages = [];
    this.experiences = [];
    this.egcs = [];
    this.greatCompetencies = [];
    this.locations = [];
    
    this.filterChangedHandler({ detail: [] });
    this.filterResults();
    this.template.querySelector("c-filter-panel").resetFilters();
    this.handleRetrieveMentors();    
  }

  calculateYears(hireDate) {
    const yearDifMs = Date.now() - hireDate;
    const yearDate = new Date(yearDifMs);
    return Math.abs(yearDate.getUTCFullYear() - 1970);
  }

  toggleFilters() {
    this.showFilters = !this.showFilters;
  }

  toggleUserView() {
    this.showUser = !this.showUser;
  }

  userSelectedHandler(event) {
    // View a custom object record.
    // this[NavigationMixin.Navigate]({
    //   type: "comm__namedPage",
    //   attributes: {
    //     pageName: "mentoring-profile",
    //   },
    //   state: {
    //     score: event.detail.user.score,
    //     showRequestButtons: true,
    //     userId: event.detail.user.Id,
    //   },
    // });

    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: event.detail.user.Id,
        actionName: "view",
      },
    });
  }
  handleOpenRecordClick(event) {
    console.log("Click Open ");
    console.log(event.detail);
    console.log(event.target.value);
    //this[NavigationMixin.Navigate]({
    //  type: 'standard__recordPage',
    //attributes: {
    //    recordId: event.target.,
    //    actionName: 'view',
    //},
    //});
  }

  // GETTERS
  get noMentorsFound() {
    if (!this.filteredMentors) {
      return true;
    }
    if (!this.filteredMentors.length > 0) {
      return true;
    }
    return false;
  }

  get isMobile() {
    return screen.width <= 768;
  }

  get availableMentors() {
    let theSortedMentors = JSON.parse(JSON.stringify([...this.filteredMentors]));

    for (let i = 0; i < theSortedMentors.length; i++) {
      if (theSortedMentors[i][CERTIFICATIONS_FIELD.fieldApiName]?.split(";")?.includes("Sales Leader Excellence Coach")) {
        theSortedMentors[i].salesLeader = true;
      }
    }
    return theSortedMentors;
  }

  get noAvailableMentors() {
    return this.availableMentors ? this.availableMentors.length === 0 : true;
  }

  get getContainerClass() {
    if (this.isMobile) {
      return "slds-is-relative container";
    }
    return "slds-is-relative container searchbar-edit";
  }
}