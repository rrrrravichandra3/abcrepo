import { LightningElement, api } from 'lwc';
import { publishNavigation } from 'c/ccEmpLmsUtil';

export default class CcEmpDemo1 extends LightningElement {
  @api stepName = 'My Skills';

  handleSave(event) {
    console.log('publish a msg from demo component');
    const payload = { stepName: this.stepName, navigationType: 'onBoarding' };
    publishNavigation(payload);
    event.preventDefault();
    console.log('stopped event prop');
  }
}