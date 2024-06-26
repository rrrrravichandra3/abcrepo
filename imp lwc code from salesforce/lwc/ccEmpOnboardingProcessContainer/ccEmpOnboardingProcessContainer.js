import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import FIRST_NAME_FIELD from '@salesforce/schema/User.FirstName';
import LAST_NAME_FIELD from '@salesforce/schema/User.LastName';
import getNavigationItem from '@salesforce/apex/CcEmp_PagesConfiguration.getNavigationItem';
import getPreferences from '@salesforce/apex/CcEmp_PagesConfiguration.getPreferences';
import savePreference from '@salesforce/apex/CcEmp_PagesConfiguration.savePreference';
import { subscribeNavigation } from 'c/ccEmpLmsUtil';

export default class CcEmpOnboardingProcessContainer extends LightningElement {
  userId = USER_ID;
  userName;
  sectionLinks = [];
  componentInstances;
  @api currentStepIndex = 0;
  steps = [];
  index = 0;
  isGetStartedDisabled = true;

  connectedCallback() {
    this.updateStepClasses();
    this.loadPreferences();
    subscribeNavigation(this.handleMessageService.bind(this));
  }

  handleMessageService(message) {
    console.log('received message ' + JSON.stringify(message));
    // Find the completed step by name and mark it as complete
    const stepIndex = this.steps.findIndex((step) => step.Label === message.stepName);
    console.log('stepIndex***' + stepIndex);
    if (message.navigationType && message.navigationType === 'onBoarding' && stepIndex !== -1) {
      this.steps[stepIndex].isComplete = true;
      this.saveCompletedSteps(); // Save the new state
      this.updateStepClasses();
      // Optional: Navigate to the next step automatically
      // this.currentStepIndex = stepIndex + 1;
      this.loadComponent();
    }
    if (message.navigationType && message.navigationType === 'profileCompletion') {
      this.isGetStartedDisabled = message.getStartedDisabled;
    }
  }

  @wire(getRecord, { recordId: '$userId', fields: [FIRST_NAME_FIELD, LAST_NAME_FIELD] })
  wiredUser({ error, data }) {
    if (data) {
      this.userName = `${data.fields.FirstName.value} ${data.fields.LastName.value}`;
    } else if (error) {
      console.error('Error retrieving user information:', error);
    }
  }

  /* @wire(getPreferences, { userId: '$userId' })
  preferences;*/

  updateStepClasses() {
    let allPreviousCompleted = true;

    this.steps = this.steps.map((step, index) => {
      let progressClass = 'slds-progress__item';
      let iconContainerClass = 'slds-icon_container ';
      let title = '';
      let status = '';
      let iconHref = '/assets/icons/utility-sprite/svg/symbols.svg#';
      let clickable = false;

      if (step.isComplete) {
        progressClass += ' slds-is-completed';
        iconContainerClass +=
          // eslint-disable-next-line max-len
          ' slds-progress__marker slds-icon-utility-success slds-progress__marker_icon slds-progress__marker_icon-success';
        title = 'Complete';
        status = 'Complete';
        iconHref += 'success';
        clickable = true;
      } else if (index === this.currentStepIndex) {
        progressClass += ' slds-is-active';
        iconContainerClass += ' icon-style-class';
        title = 'Active';
        status = 'Active';
        iconHref += 'choice'; // You can use any icon that represents an active state
        clickable = true;
      } else {
        iconContainerClass += ' icon-style-class';
        iconHref += 'routing_offline'; // Placeholder, use an appropriate icon
        clickable = false;
      }
      // If the step is not clickable, add the 'step-disabled' class
      if (!clickable) {
        progressClass += ' step-disabled';
      }
      // If any previous step is not complete, future steps should not be clickable
      allPreviousCompleted = allPreviousCompleted && step.isComplete;
      return { ...step, progressClass, iconContainerClass, title, status, iconHref, clickable };
    });
  }

  handleStepSelection(event) {
    // Logic to update the current step based on the selection
    // Reset all steps to inactive and not complete
    const stepName = event.currentTarget.dataset.name;
    const stepIndex = this.steps.findIndex((step) => step.Label === stepName);

    // Only allow the step to be set as the current step if it's clickable
    if (this.steps[stepIndex].clickable) {
      // eslint-disable-next-line @lwc/lwc/no-api-reassignments
      this.currentStepIndex = stepIndex;
      this.updateStepClasses();
      this.loadComponent();
    }
  }

  @wire(getNavigationItem)
  wiredNavItems({ error, data }) {
    if (data) {
      this.steps = data.filter((item) => item.Navigation_Type__c === 'Onboarding Navigation');
      this.steps = JSON.parse(JSON.stringify(this.steps));
      this.loadComponent();
    } else if (error) {
      console.log(error, 'error message');
    }
  }

  async loadComponent() {
    const step = this.currentStep;
    if (step && step.LWC_Component_Name__c) {
      try {
        const module = await import(`c/${step.LWC_Component_Name__c}`);
        this.componentInstances = module.default;
      } catch (error) {
        console.error(`Error loading component for step ${step.Label}:`, error);
      }
    } else {
      this.componentInstances = null;
    }
  }

  loadPreferences() {
    getPreferences({ userId: this.userId })
      .then((data) => {
        if (data && data.length > 0) {
          const preferenceRecord = data[0];
          const completedSteps = preferenceRecord.Onboarding_Completed_Steps__c
            ? preferenceRecord.Onboarding_Completed_Steps__c.split(';')
            : [];
          this.steps = this.steps.map((step) => {
            // Check if the step is complete and log it
            const isStepComplete = completedSteps.includes(step.Label);

            return {
              ...step,
              isComplete: isStepComplete,
            };
          });

          // Find the index of the first uncompleted step
          const firstUncompletedIndex = this.steps.findIndex((step) => !step.isComplete);
          // If all steps are complete, it will return -1, so check before setting
          // eslint-disable-next-line @lwc/lwc/no-api-reassignments
          this.currentStepIndex = firstUncompletedIndex !== -1 ? firstUncompletedIndex : this.steps.length - 1;
          this.updateStepClasses();
          this.loadComponent();
        } else {
          console.log('No preference data found');
          // No completed steps found, set the first step as active
          // eslint-disable-next-line @lwc/lwc/no-api-reassignments
          this.currentStepIndex = 0;
          this.updateStepClasses();
          this.loadComponent();
        }
      })
      .catch((error) => {
        console.error('Error loading preferences', error);
      });
  }

  handleNext() {
    // Check if current step is completed
    const step = this.currentStep;
    if (step) {
      // Ensure your component has an isCompleted method
      this.steps[this.currentStepIndex].isComplete = true;
      this.saveCompletedSteps();
      this.currentStepIndex++;
      this.updateStepClasses();
      this.loadComponent();
    }
  }

  saveCompletedSteps() {
    const completedSteps = this.steps
      .filter((step) => step.isComplete)
      .map((step) => step.Label)
      .join(';');
    savePreference({ userId: this.userId, completedSteps: completedSteps })
      .then(() => console.log('Preferences saved'))
      .catch((error) => console.error('Error saving preferences', error));
  }

  handlePrevious() {
    if (!this.isFirstStep) {
      this.currentStepIndex--;
      this.updateStepClasses();
      this.loadComponent();
    }
  }

  handleSkip() {
    this.currentStepIndex++;
    this.updateStepClasses();
    this.loadComponent();
  }

  get currentStep() {
    return this.steps[this.currentStepIndex] || {};
  }

  get isFirstStep() {
    return this.currentStepIndex === 0;
  }

  get isLastStep() {
    return this.currentStepIndex === this.steps.length - 1;
  }

  get isNotFirstStep() {
    return this.currentStepIndex !== 0;
  }

  get isSkipDisabled() {
    // "Skip Section" is disabled if the current step is required and not complete
    const currentStep = this.currentStep;
    return currentStep.isRequired__c && !currentStep.isComplete;
  }

  get allStepsCompleted() {
    // This getter checks if all steps are marked as complete
    return this.steps.every((step) => step.isComplete);
  }

  handleGetStartedClick() {
    // Logic to proceed with the Get Started action
    this.dispatchEvent(new CustomEvent('getstarted'));
    // You could also navigate to a different page or perform another action
  }
}