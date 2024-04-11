/**
 * A mapping function that converts a picklist string to an array.
 *
 * @param {string} value the picklist string
 * @return {Array<string>} the array of picklist values
 */
const picklistToArray = (value) =>
  typeof value === 'string'
    ? value
        .split(';')
        .map((item) => item.trim())
        .filter((item) => !!item)
    : [];

/**
 * Generates a mapping function that returns true if the field value contains the given value.
 *
 * @param {string} containsValue the value to check for in the picklist string
 * @return {Function} the mapping function that returns true if the picklist contains the given value
 */
const picklistContainsToBoolean = (containsValue) => (fieldValue) =>
  picklistToArray(fieldValue)?.includes(containsValue) || false;

/**
 * Mappings for the values in the Front_Desk_Permissions__c picklist field.
 */
const PERMISSIONS = {
  Manager: 'Manager',
};

/**
 * Knowledge Article Version Schema.
 *
 * Unfortunately, LWC Schema doesn't allow you to use imports for Knowledge objects.
 *
 * Each field definition can have the following attributes:
 *
 * - fieldApiName - the API name of the field
 * - mapper - a function that takes the field value and returns a transformed value
 * - required - true if the field is required and an exception should be thrown if it is missing
 * - default - the default value for the field if a value is not otherwise present (or required)
 *
 * @see https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_knowledgearticleversion.htm
 */
const FIELDS = {
  /**
   * Standard fields
   */
  id: {
    fieldApiName: 'Id',
    required: true,
  },
  language: {
    fieldApiName: 'Language',
  },
  lastModifiedDate: {
    fieldApiName: 'LastModifiedDate',
  },
  publishStatus: {
    fieldApiName: 'PublishStatus',
  },
  title: {
    fieldApiName: 'Title',
  },
  urlName: {
    fieldApiName: 'UrlName',
  },

  /**
   * Custom fields
   */
  body: {
    fieldApiName: 'Body__c',
    default: '',
  },
  countries: {
    fieldApiName: 'Front_Desk_Countries__c',
    mapper: picklistToArray,
    default: [],
  },
  isManagerOnly: {
    fieldApiName: 'Front_Desk_Permissions__c',
    mapper: picklistContainsToBoolean(PERMISSIONS.Manager),
    default: false,
  },
  regions: {
    fieldApiName: 'Front_Desk_Regions__c',
    mapper: picklistToArray,
    default: [],
  },
};

/**
 * A parser that converts a Knowledge Article Version record from the platform into a
 * normalized form of an article.
 */
export class FdEmpKnowledgeParser {
  /**
   * Parses and normalizes a Knowledge Article Version record.
   *
   * @param {object} record the record data as returned from the platfrom
   * @return {object} the parsed and normalized Knowledge data
   */
  parse(record) {
    if (record === null || record === undefined) {
      throw new Error('Record was not provided to parse()');
    }

    const normalized = {};
    for (const [fieldName, definition] of Object.entries(FIELDS)) {
      const value = record[definition.fieldApiName];
      if (value) {
        normalized[fieldName] = definition.mapper ? definition.mapper(value) : value;
      } else if (Object.prototype.hasOwnProperty.call(definition, 'default')) {
        normalized[fieldName] = definition.default;
      } else if (definition.required) {
        throw new Error(`Record is missing a required field: ${fieldName}`);
      }
    }

    return normalized;
  }
}