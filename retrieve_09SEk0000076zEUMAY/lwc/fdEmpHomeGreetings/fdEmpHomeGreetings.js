import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import FIRST_NAME from '@salesforce/schema/User.FirstName';

export default class FdEmpHomeGreetings extends LightningElement {
  userId = USER_ID;
  firstName;

  textClass;

  @wire(getRecord, { recordId: '$userId', fields: [FIRST_NAME] })
  setName({ data }) {
    this.firstName = getFieldValue(data, FIRST_NAME);
  }

  get greetingsTextClass() {
    return (this.textClass =
      this.currentTime.toLowerCase() === 'night'
        ? 'fd-home__greetings_text_night'
        : 'fd-home__greetings_text_morning_afternoon_evening');
  }

  get currentTime() {
    const hours = new Date().getHours();
    if (hours < 4 || hours > 20) {
      return 'Night';
    } else if (hours < 12) {
      return 'Morning';
    } else if (hours < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }
}