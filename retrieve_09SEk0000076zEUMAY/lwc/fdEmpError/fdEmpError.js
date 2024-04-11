import { LightningElement, api } from 'lwc';
import fdResources from '@salesforce/resourceUrl/FrontDeskCustom';
import GENERIC_ERROR_TITLE from '@salesforce/label/c.FdEmp_Generic_Error_Title';
import GENERIC_ERROR_MESSAGE from '@salesforce/label/c.FdEmp_Generic_Error_Text';
import ACCESS_ERROR_TITLE from '@salesforce/label/c.FdEmp_Access_Error_Title';
import ACCESS_ERROR_MESSAGE from '@salesforce/label/c.FdEmp_Access_Error_Text';

/** Error type enum */
const ErrorType = {
  genericError: 'genericError',
  accessError: 'accessError',
};

const ERROR_MESSAGES = {
  [ErrorType.genericError]: {
    title: GENERIC_ERROR_TITLE,
    message: GENERIC_ERROR_MESSAGE,
    image: `${fdResources}/images/something_went_wrong_bear.png`,
  },
  [ErrorType.accessError]: {
    title: ACCESS_ERROR_TITLE,
    message: ACCESS_ERROR_MESSAGE,
    image: `${fdResources}/images/no_data_illustration.svg#noDataIllustration`,
  },
};

const NOT_FOUND_OR_ACCESS_ERROR = 'List has no rows for assignment to SObject';

export default class FdEmpError extends LightningElement {
  /** Single or array of LDS errors */
  @api errors;

  /** Error template type */
  type = ErrorType.genericError;

  get errorDetails() {
    let errorArray = this.errors;
    if (!Array.isArray(this.errors)) {
      errorArray = [this.errors];
    }
    this.reduceErrors(errorArray);
    return ERROR_MESSAGES[this.type];
  }

  /**
   * Reduces one or more LDS errors into a string[] of error messages.
   * @param {FetchResponse|FetchResponse[]} errors
   * @return {String[]} Error messages
   */
  reduceErrors(errors) {
    return (
      errors
        // Remove null/undefined items
        .filter((error) => !!error)
        // Extract an error message
        .map((error) => {
          // log error trace to the console
          console.error(error);
          // UI API read errors
          if (Array.isArray(error.body)) {
            return error.body.map((e) => e.message);
          }
          // Page level errors
          else if (error?.body?.pageErrors && error.body.pageErrors.length > 0) {
            return error.body.pageErrors.map((e) => e.message);
          }
          // Field level errors
          else if (error?.body?.fieldErrors && Object.keys(error.body.fieldErrors).length > 0) {
            const fieldErrors = [];
            Object.values(error.body.fieldErrors).forEach((errorArray) => {
              fieldErrors.push(...errorArray.map((e) => e.message));
            });
            return fieldErrors;
          }
          // UI API DML page level errors
          else if (error?.body?.output?.errors && error.body.output.errors.length > 0) {
            return error.body.output.errors.map((e) => e.message);
          }
          // UI API DML field level errors
          else if (error?.body?.output?.fieldErrors && Object.keys(error.body.output.fieldErrors).length > 0) {
            const fieldErrors = [];
            Object.values(error.body.output.fieldErrors).forEach((errorArray) => {
              fieldErrors.push(...errorArray.map((e) => e.message));
            });
            return fieldErrors;
          }
          // UI API DML, Apex and network errors
          else if (error.body && typeof error.body.message === 'string') {
            return error.body.message;
          }
          // JS errors
          else if (typeof error.message === 'string') {
            return error.message;
          }
          // Unknown error shape so try HTTP status text
          return error.statusText;
        })
        .map((message) => {
          if (message === NOT_FOUND_OR_ACCESS_ERROR) {
            this.type = ErrorType.accessError;
          }
          return message;
        })
        // Flatten
        .reduce((prev, curr) => prev.concat(curr), [])
        // Remove empty strings
        .filter((message) => !!message)
    );
  }
}