import { LightningElement, api } from 'lwc';

import matchingSkillsAndInterestsLabel from '@salesforce/label/c.matching_skills_and_interests';

export default class MatchingSkills extends LightningElement {
  @api skills;

  labels = {
    matchingSkillsAndInterestsLabel
  };
}