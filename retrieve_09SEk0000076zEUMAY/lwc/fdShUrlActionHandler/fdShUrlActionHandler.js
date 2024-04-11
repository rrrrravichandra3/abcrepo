export class FdShUrlActionHandler {
  async handleAction(actionAttributes) {
    try {
      const navigationAttributes = {
        type: 'standard__webPage',
        attributes: {
          url: actionAttributes.target,
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