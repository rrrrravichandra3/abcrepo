import { LightningElement } from 'lwc';

import equalityGroupsLabel from '@salesforce/label/c.equality_groups';  
import whatEqualityGroupsAreYouAMemberOfLabel from '@salesforce/label/c.equality_What_Equality_Groups_are_you_a_member_of';

export default class equalityGroupPreferences extends LightningElement {
    labels = {
        equalityGroupsLabel,
        whatEqualityGroupsAreYouAMemberOfLabel
    };
}