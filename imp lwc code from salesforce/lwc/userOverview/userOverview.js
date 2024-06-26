import { LightningElement, api, track } from "lwc";
import { getFieldValue } from "lightning/uiRecordApi";
import CITY_FIELD from "@salesforce/schema/User.City";
import HIRE_FIELD from "@salesforce/schema/User.Hire_Date__c";
import GROUP_LOGOS from "@salesforce/resourceUrl/EqualityGroupLogos";
import GROUPS_FIELD from "@salesforce/schema/User.Equality_Group_Member__c";

import yearShortLabel from "@salesforce/label/c.overview_year_short";
import atSalesforceLabel from "@salesforce/label/c.overview_AT_SALESFORCE";
import equalityGroupsLabel from "@salesforce/label/c.equality_groups";
import locationLabel from "@salesforce/label/c.Label_location";
import noLabel from "@salesforce/label/c.no";

const equalityGroups = [
  {
    name: "Abilityforce",
    logo: `${GROUP_LOGOS}/abilityforce.png`,
  },
  {
    name: "BOLDforce",
    logo: `${GROUP_LOGOS}/boldforce.png`,
  },
  {
    name: "Earthforce",
    logo: `${GROUP_LOGOS}/earthforce.png`,
  },
  {
    name: "Faithforce",
    logo: `${GROUP_LOGOS}/faithforce.png`,
  },
  {
    name: "Latinoforce",
    logo: `${GROUP_LOGOS}/latinoforce.png`,
  },
  {
    name: "Outforce",
    logo: `${GROUP_LOGOS}/outforce.png`,
  },
  {
    name: "Vetforce",
    logo: `${GROUP_LOGOS}/vetforce.png`,
  },
  {
    name: "Women's Network",
    logo: `${GROUP_LOGOS}/women.png`,
  },
];

export default class UserOverview extends LightningElement {
  @api user;

  @track equalityGroups;

  labels = {
    yearShortLabel,
    atSalesforceLabel,
    noLabel,
  };

  connectedCallback() {
    const groups = getFieldValue(this.user, GROUPS_FIELD) ? getFieldValue(this.user, GROUPS_FIELD).split(";") : [];
    const filteredGroups = equalityGroups.filter((group) => groups.includes(group.name));
    this.equalityGroups = filteredGroups;
  }

  get locationAllCapsLabel() {
    return locationLabel.toUpperCase();
  }

  get equalityGroupsAlLCapsLabel() {
    return equalityGroupsLabel.toUpperCase();
  }

  calculateYears(hireDate) {
    const yearDifMs = Date.now() - hireDate;
    const yearDate = new Date(yearDifMs);
    return Math.abs(yearDate.getUTCFullYear() - 1970);
  }

  get equalityGroupsFound() {
    return this.equalityGroups.length > 0;
  }

  get experience() {
    let hireDate = new Date(getFieldValue(this.user, HIRE_FIELD));
    let experience = this.calculateYears(hireDate) > 0 ? this.calculateYears(hireDate) : "< 1";
    return experience;
  }

  get city() {
    return getFieldValue(this.user, CITY_FIELD);
  }
}