import { FdEmpKnowledgeParser } from 'c/fdEmpKnowledgeParser';
import { isObject } from 'c/fdEmpObjectUtils';

export class FdEmpSearchResultParser {
  parse(record) {
    if (record === null || record === undefined) {
      throw new Error('Record was not provided to parse()');
    }

    if (!isObject(record.fields)) {
      throw new Error(
        `Record expected to have fields (apiName="${record.apiName}", fields="${JSON.stringify(record.fields)}")`
      );
    }

    const normalized = {};

    for (const [fieldApiName, field] of Object.entries(record.fields || {})) {
      if (Object.prototype.hasOwnProperty.call(field, 'value')) {
        normalized[fieldApiName] = field.value;
      }
    }

    const parsed = new FdEmpKnowledgeParser().parse(normalized);

    return parsed;
  }
}