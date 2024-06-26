import { LightningElement, api } from 'lwc';

import viewYourProfileLabel from '@salesforce/label/c.profile_view_your_profile';

export default class ViewProfile extends LightningElement {
  @api user;
  
  labels = {viewYourProfileLabel};

  viewProfileClickedHandler() {
    this.dispatchEvent(new CustomEvent('profile'));
  }

  // GETTERS
  get backgroundImage() {
    return `background-image: url(${this.user.fields.MediumPhotoUrl.value})`;
  }
}