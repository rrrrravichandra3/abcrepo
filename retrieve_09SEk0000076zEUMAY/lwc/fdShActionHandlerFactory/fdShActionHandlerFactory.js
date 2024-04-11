import getActionHandler from '@salesforce/apex/FdSh_ActionConfiguration.getActionHandler';
import { FdShConfigFormActionHandler } from 'c/fdShConfigFormActionHandler';
import { FdShOrg62ConfigFormActionHandler } from 'c/fdShOrg62ConfigFormActionHandler';
import { FdShOrg62FlowActionHandler } from 'c/fdShOrg62FlowActionHandler';
import { FdShUrlActionHandler } from 'c/fdShUrlActionHandler';
export class FdShActionHandlerFactory {
  async createHandlerAndHandleAction(actionAttributes) {
    let handlerClassName;
    let handler;
    getActionHandler({
      actionName: actionAttributes.actionType,
      orgType: actionAttributes.source,
    })
      .then(async (result) => {
        handlerClassName = result;
        if (handlerClassName === 'FdShConfigFormActionHandler') {
          handler = new FdShConfigFormActionHandler();
        } else if (handlerClassName === 'FdShUrlActionHandler') {
          handler = new FdShUrlActionHandler();
        } else if (handlerClassName === 'FdShOrg62ConfigFormActionHandler') {
          handler = new FdShOrg62ConfigFormActionHandler();
        } else if (handlerClassName === 'FdShOrg62FlowActionHandler') {
          handler = new FdShOrg62FlowActionHandler();
        } else {
          throw new Error('Invalid component type');
        }
        await handler.handleAction(actionAttributes);
      })
      .catch((error) => {
        console.error('An error occurred while creating handler', error);
      });
  }
}