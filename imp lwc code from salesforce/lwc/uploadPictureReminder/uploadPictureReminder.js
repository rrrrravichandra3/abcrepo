import { LightningElement, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import IMAGE_FIELD from "@salesforce/schema/User.MediumPhotoUrl";
import Id from "@salesforce/user/Id";

import MyProfileLabel from '@salesforce/label/c.photo_my_profile';
import ReminderLabel from '@salesforce/label/c.photo_reminder';

export default class UploadPictureReminder extends NavigationMixin(LightningElement) {
  userId = Id;

  @track currentUser;

  label = {
    MyProfileLabel,
    ReminderLabel,
  };

  @wire(getRecord, {
    recordId: "$userId",
    fields: [
      IMAGE_FIELD,
    ]
  })
  wiredCurrentUser({ error, data }) {
    if (error) {
      this.showErrorMessage(error);
    } else if (data) {
      this.currentUser = data;
    }
  }

  navigateToProfile() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.userId,
        objectApiName: "User",
        actionName: "view"
      }
    });
  }

  get showReminder() {
    if (!this.currentUser) {
      return false;
    }
    const photoUrl = getFieldValue(this.currentUser, IMAGE_FIELD);
    return !photoUrl ||  photoUrl.includes("/profilephoto/005/M");
  }

  get profilePhotoBg() {
    return `background-image: url(${getFieldValue(this.currentUser, IMAGE_FIELD)})`;
  }
}