import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";

import mentoringPreferencesLabel from "@salesforce/label/c.mentoring_preferences";
import locationLabel from "@salesforce/label/c.Label_location";
import professionalSkillsLabel from "@salesforce/label/c.Label_Professional_Skills";
import interestsLabel from "@salesforce/label/c.Label_Interests";
import thingsToLearnLabel from "@salesforce/label/c.preference_Things_to_Learn";	
import equalityGroupsLabel from "@salesforce/label/c.equality_groups";		

export default class preferencesMenu extends NavigationMixin(LightningElement) {
  @track modal;

  labels = {mentoringPreferencesLabel};

  @track preferences = [
    {
      id: "location",
      url: "location-preferences",
      iconName: "action:map",
      label: locationLabel
    },
    {
      id: "skills",
      url: "skills-preferences",
      iconName: "action:manage_perm_sets",
      label: professionalSkillsLabel
    },
    {
      id: "interests",
      url: "interests",
      iconName: "action:description",
      label: interestsLabel
    },
    {
      id: "causes",
      url: "causes-preferences",
      iconName: "action:priority",
      label: thingsToLearnLabel
    },
    {
      id: "groups",
      url: "equality-groups",
      iconName: "action:edit_groups",
      label: equalityGroupsLabel
    }
  ];

  goToUrl(event) {
    if (this.isMobile) {
      this[NavigationMixin.Navigate]({
        type: "standard__namedPage",
        attributes: {
          pageName: event.currentTarget.dataset.nav
        }
      });
    } else {
      this.modal = event.currentTarget.dataset.nav;
    } 
  }

  closeModal() {
    this.modal = undefined;
  }

  get isMobile() {
    return screen.width <= 768;
  }

  get preferenceClasses() {
    return this.isMobile
      ? "cursor slds-grid slds-grid_vertical-align-center slds-p-around_small slds-theme_default slds-border_bottom"
      : "cursor slds-grid slds-grid_vertical-align-center slds-p-around_small";
  }

  get showLocationModal() {
    return this.modal === "location-preferences";
  }

  get showSkillsModal() {
    return this.modal === "skills-preferences";
  }

  get showInterestModal() {
    return this.modal === "interests";
  }

  get showGroupModal() {
    return this.modal === "equality-groups";
  }

  get showCausesModal() {
    return this.modal === "causes-preferences";
  }
}