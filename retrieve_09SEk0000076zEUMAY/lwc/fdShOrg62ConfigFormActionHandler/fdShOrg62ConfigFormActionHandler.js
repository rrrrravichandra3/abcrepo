import getConfigurationValue from '@salesforce/apex/FdSh_ConfigurationValue.getEnvConfigurationValue';
/**
 * Handles the specified action by performing navigation.
 * @param {Object} [actionAttributes] - Additional parameters specific to the action.
 * @throws {Error} Throws an error if navigation fails.
 */
export class FdShOrg62ConfigFormActionHandler {
  async handleAction(actionAttributes) {
    try {
      let url = '';
      await getConfigurationValue({ configName: 'Org62BaseURL' })
        .then((data) => {
          url = data;
        })
        .catch((error) => {
          console.error(
            `Error occurred while getting configuration with config name FeedbackSlackURL. Caused by: ${error}`
          );
        });
      let navigationAttributes = {};
      if (actionAttributes.target === 'URL') {
        navigationAttributes = {
          type: 'standard__webPage',
          attributes: {
            url: url + '/c/ngssLogATicket.app?configId=' + actionAttributes.formId + '&kavId=' + actionAttributes.kavId,
          },
        };
      } else {
        navigationAttributes = {
          type: 'comm__namedPage',
          attributes: {
            name: 'ticketintake__c',
          },
          state: {
            source: actionAttributes.source,
            formId: actionAttributes.formId,
          },
        };
      }
      const navigateFunction = actionAttributes.navigationFunction;
      await navigateFunction(navigationAttributes);
    } catch (error) {
      console.error(`Error occurred during navigation:`, error);
      throw error;
    }
  }
}