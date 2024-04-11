export class FdShConfigFormActionHandler {
  async handleAction(actionAttributes) {
    try {
      const navigationAttributes = {
        type: 'comm__namedPage',
        attributes: {
          name: 'ticketintake__c',
        },
        state: {
          source: actionAttributes.source,
          formId: actionAttributes.formId,
        },
      };
      const navigateFunction = actionAttributes.navigationFunction;
      await navigateFunction(navigationAttributes);
    } catch (error) {
      console.error('Error occurred during navigation:', error);
      throw error;
    }
  }
}