import { LightningElement, api } from 'lwc';
import returnGPTResponse from '@salesforce/apex/CcEmp_EinsteinGPTService.returnGPTResponse';

export default class CcEmpResumeParser extends LightningElement {
  @api textValue;

  @api suggestedSkills = [];

  async callEinsteinGPTToGetSkillSuggestions() {
    const skillsSuggestionPrompt =
      'Provide a response with only comma separated values of skills a ' +
      'professional would or can have closely related the following existing skills: ' +
      this.textValue +
      '. Only comma separated values of suggested skills so we can ' +
      'process suggestions without scanning any unwanted response. ' +
      'Do not provide any skills back that are provided in the existing skills list. ';
    let resultGpt;
    await returnGPTResponse({ textPrompt: skillsSuggestionPrompt })
      .then((result) => {
        resultGpt = result;
      })
      .catch((error) => {
        console.log(error);
      });
    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.suggestedSkills = resultGpt.split(',').slice(0, 10);
  }

  handleInputChange(event) {
    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.textValue = event.detail.value;
  }
}