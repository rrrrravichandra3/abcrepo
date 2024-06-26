import { LightningElement, track, wire } from "lwc";
import { getRecord, updateRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import GROUP_LOGOS from "@salesforce/resourceUrl/EqualityGroupLogos";
import GROUP_FIELD from "@salesforce/schema/User.Equality_Group_Member__c";
import Id from "@salesforce/user/Id";

export default class EqualityGroupPicker extends LightningElement {
  userId = Id;

  @track equalityGroups = [
    {
      name: "Abilityforce",
      logo: `${GROUP_LOGOS}/abilityforce.png`,
      selected: false
    },
    {
      name: "Asiapacforce",
      logo: `${GROUP_LOGOS}/asiapacforce.png`,
      selected: false
    },
    {
      name: "BOLDforce",
      logo: `${GROUP_LOGOS}/boldforce.png`,
      selected: false
    },
    {
      name: "Earthforce",
      logo: `${GROUP_LOGOS}/earthforce.png`,
      selected: false
    },
    {
      name: "Faithforce",
      logo: `${GROUP_LOGOS}/faithforce.png`,
      selected: false
    },
    {
      name: "Genforce",
      logo: `${GROUP_LOGOS}/genforce.png`,
      selected: false
    },
    {
      name: "Latinoforce",
      logo: `${GROUP_LOGOS}/latinoforce.png`,
      selected: false
    },
    {
      name: "Outforce",
      logo: `${GROUP_LOGOS}/outforce.png`,
      selected: false
    },
    {
      name: "ParentsandFamilies",
      logo: `${GROUP_LOGOS}/parentsandfamilies.png`,
      selected: false
    },
    {
      name: "Southasiaforce",
      logo: `${GROUP_LOGOS}/southasiaforce.png`,
      selected: false
    },
    
    {
      name: "Vetforce",
      logo: `${GROUP_LOGOS}/vetforce.png`,
      selected: false
    },
    {
      name: "WINDforce",
      logo: `${GROUP_LOGOS}/windforce.png`,
      selected: false
    },
    {
      name: "Womens Network",
      logo: `${GROUP_LOGOS}/women.png`,
      selected: false
    }
  ];
  @track loading = false;

  connectedCallback() {
    this.loading = true;
  }

  @wire(getRecord, { recordId: "$userId", fields: [GROUP_FIELD] })
  wiredRecord({ error, data }) {
    if (error) {
      //eslint-disable-next-line
      console.error(error);
      this.loading = false;
    } else if (data) {
      this.initializePicklistValues(getFieldValue(data, GROUP_FIELD));
      this.loading = false;
    }
  }

  initializePicklistValues(picklistValue) {
    let values = [];
    if (picklistValue) {
      values = picklistValue.split(";");
    }
    let picklistValues = this.equalityGroups.map(value => {
      let selected = value.selected;
      if (values.includes(value.name)) {
        selected = true;
      }
      return { ...value, selected };
    });

    this.equalityGroups = picklistValues;
  }

  async saveRecord(value) {
    const fields = {};
    fields[GROUP_FIELD.fieldApiName] = value;
    console.log('----this value'+value);
    fields.Id = this.userId;
    const recordInput = { fields };
    console.log('-----recordInput'+JSON.stringify(recordInput));
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

  groupSelectHandler(event) {
    const updatedGroups = this.equalityGroups.map(group => {
      if (group.name === event.detail) {
        return { ...group, selected: !group.selected };
      }
      return { ...group };
    });
    this.equalityGroups = updatedGroups;
    const selectedValues = [];
    updatedGroups.forEach(group => {
      if (group.selected) {
        selectedValues.push(group.name);
      }
    });
    this.saveRecord(selectedValues.join(";"));
  }
}