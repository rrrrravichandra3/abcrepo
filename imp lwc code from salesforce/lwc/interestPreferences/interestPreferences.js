import { LightningElement } from 'lwc';
import INTEREST_FIELD from '@salesforce/schema/User.Interests__c';
import Id from '@salesforce/user/Id';

import interestsLabel from '@salesforce/label/c.Label_Interests';
import whatAreSomeOfYourInterestsLabel from '@salesforce/label/c.interests_What_are_some_of_your_interests';

export default class interestPreferences extends LightningElement {
  interestField = INTEREST_FIELD;
  userId = Id;

  labels = {
    interestsLabel,
    whatAreSomeOfYourInterestsLabel
  };
}