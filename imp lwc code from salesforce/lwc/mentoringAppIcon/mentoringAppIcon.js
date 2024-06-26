import { LightningElement, api } from 'lwc';

export default class MentoringAppIcon extends LightningElement {
  @api iconName;
  @api color;
  @api styles;

  // GETTERS
  get isMentor() {
    return this.iconName === 'mentor';
  }
  get isCalendar() {
    return this.iconName === 'calendar';
  }
  get isNotes() {
    return this.iconName === 'notes';
  }
  get isThumbsUp() {
    return this.iconName === 'thumbs-up';
  }
  get isSwitch() {
    return this.iconName === 'switch';
  }
  get isSearch() {
    return this.iconName === 'search';
  }
  get isMore() {
    return this.iconName === 'more';
  }
  get isBell() {
    return this.iconName === 'bell';
  }
}