import { LightningElement } from 'lwc';
import LEARN_FIELD from '@salesforce/schema/User.Things_To_Learn__c';
import Id from '@salesforce/user/Id';

import newHobbyLabel from '@salesforce/label/c.preference_Thought_about_picking_up_a_new_hobby';
import thingsToLearnLabel from '@salesforce/label/c.preference_Things_to_Learn';

export default class CausesPreferences extends LightningElement {
  learnField = LEARN_FIELD;
  userId = Id;

  labels = {
    newHobbyLabel,
    thingsToLearnLabel
  };
}