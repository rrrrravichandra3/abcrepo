import { publish, subscribe, createMessageContext } from 'lightning/messageService';
import NAVIGATION_MESSAGE_CHANNEL from '@salesforce/messageChannel/careeConnectNavigation__c';
import TOAST_MESSAGE_CHANNEL from '@salesforce/messageChannel/ccEmpToast__c';

const context = createMessageContext();
const subscribeNavigation = (callback) => {
  subscribe(context, NAVIGATION_MESSAGE_CHANNEL, (message) => {
    callback(message);
  });
};

const publishNavigation = (message) => {
  publish(context, NAVIGATION_MESSAGE_CHANNEL, message);
};

const showToast = (message) => {
  publish(context, TOAST_MESSAGE_CHANNEL, message);
};
const subscribeToast = (callback) => {
  subscribe(context, TOAST_MESSAGE_CHANNEL, (message) => {
    callback(message);
  });
};

export { subscribeNavigation, publishNavigation, showToast, subscribeToast };