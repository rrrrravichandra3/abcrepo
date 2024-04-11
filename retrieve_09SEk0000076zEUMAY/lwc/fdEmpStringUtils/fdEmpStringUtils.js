import { isString, isObject, isArray, isNull, isUndefined } from 'c/fdEmpObjectUtils';

/**
 * Returns a formatted string using the given pattern and arguments.
 * The pattern string should use bracket notation for argument substitution.
 * For example, the string "{1}" will be substituted for the argument at
 * position 1, with a zero-based index. If the argument is undefined, the
 * "{1}" will be left in the string.
 *
 * @example
 * format("{0} {m}", "Hello", "World"); // "Hello World"
 * format("{0} {1}", "Hello", undefined); // "Hello {1}"
 * format("{0} {1}", "Hello"); // "Hello {1}"
 *
 *
 * @param {*} pattern a pattern string containing "{N}" for argument substitution
 * @param {*} args an array of arguments (or varargs or an object) to substitute into the pattern
 * @return {string} a formatted string
 * @throws if pattern is not a string or args is not an array or varargs
 */
export const format = (pattern, ...args) => {
  if (!isString(pattern)) {
    throw new Error('pattern must be a string');
  }
  if (isNull(args) || !isArray(args) || args.length === 0) {
    throw new Error('args must be an array or varargs');
  }

  // Unroll the array if it's a single-element array.
  // Support both varargs and a single array
  const params = args.length === 1 && isObject(args[0]) ? args[0] : args;

  return pattern.replace(/{(\d+)}/g, (match, i) => {
    if (i < 0 || i >= params.length) {
      return match;
    }
    const value = params[i];
    return isNull(value) || isUndefined(value) ? match : value;
  });
};