import { FdEmpSearchResultParser } from 'c/fdEmpSearchResultParser';
import { isArray } from 'c/fdEmpObjectUtils';

/**
 * Parses the searchObjects from Knowledge search results.
 */
export class KnowledgeSearchObjectsParser {
  getResults(searchObjects) {
    if (!isArray(searchObjects) || !searchObjects[0] || !isArray(searchObjects[0]?.searchResults)) {
      return null;
    }
    return searchObjects[0].searchResults;
  }

  parse(searchObjects) {
    const searchResults = this.getResults(searchObjects);
    if (!searchResults) {
      throw new Error(`Expected an array containing searchResults`);
    }

    const errors = [];
    const list = searchResults.filter((result) => !!result?.record).map((result) => result.record);

    const parser = new FdEmpSearchResultParser();
    const parsed = list
      .map((record) => {
        try {
          return parser.parse(record);
        } catch (e) {
          errors.push(e);
          return null;
        }
      })
      .filter((record) => !!record);

    if (errors.length > 0) {
      console.error(`Errors occurred parsing search results: ${JSON.stringify(errors)}`);
      if (parsed.length === 0) {
        throw new Error('No results to display due to parsing errors');
      }
    }

    return parsed;
  }
}