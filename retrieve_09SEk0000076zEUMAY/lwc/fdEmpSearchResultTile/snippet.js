const MAX_LENGTH = 500;
const ELLIPSES = '&hellip;';

const removeAllElementsBySelector = (parent, selector) => {
  const elements = parent.querySelectorAll(selector);
  if (elements) {
    Array.from(elements).forEach((el) => el.parentElement.removeChild(el));
  }
};

/**
 * Creates a snippet, sanitized of HTML and possibly truncated,
 * of the given body string.
 *
 * @param {string} body the HTML string to convert to a snippet
 * @param {number} maxLength a maximum string length to return
 * @return {string} a snippet sanitized of HTML and possibly truncated
 */
export const createSnippet = (body, maxLength = MAX_LENGTH) => {
  if (!body) {
    return '';
  }

  // Remove tags that load resources
  body = body.replace(/\<(?:\\)??(img|frame|iframe|script|style).*?\>/gi, '');

  const temp = document.createElement('div');
  // eslint-disable-next-line @lwc/lwc/no-inner-html
  temp.innerHTML = `${body}`;
  removeAllElementsBySelector(temp, 'table');
  removeAllElementsBySelector(temp, 'br');

  const cleaned = (temp.textContent || temp.innerText || '').replace(/\s+/g, ' ').trim();

  // Trim and ellipsize
  return cleaned.length > maxLength - 1 ? cleaned.slice(0, maxLength - 1).trim() + ELLIPSES : cleaned;
};