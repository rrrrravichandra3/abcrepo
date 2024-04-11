import { FdEmpSearchResultParser } from 'c/fdEmpSearchResultParser';

const GPT_ANSWER = 'GPT_ANSWER';

const ifGptAnswer = (entity, proceedFn) => {
  if (entity.answerType !== GPT_ANSWER) {
    return null;
  }
  return proceedFn();
};

const parseSourceRecord = (record) => {
  try {
    return new FdEmpSearchResultParser().parse(record);
  } catch (e) {
    console.error(e.message);
    return null;
  }
};

export class QnaAnswerEntityParser {
  parseAnswerHtml(entity) {
    if (!entity) {
      throw new Error('entity was not provided to parseAnswerHtml()');
    }

    return ifGptAnswer(entity, () => entity.content);
  }

  parseAnswerSources(entity) {
    if (!entity) {
      throw new Error('entity was not provided to parseAnswerSources()');
    }

    return ifGptAnswer(entity, () => {
      return (
        entity.searchResults
          ?.filter((result) => !!result.record)
          .map((result) => result.record)
          .map(parseSourceRecord)
          .filter((result) => !!result) || []
      );
    });
  }
}