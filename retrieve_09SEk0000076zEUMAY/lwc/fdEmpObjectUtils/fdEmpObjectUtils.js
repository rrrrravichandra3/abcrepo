/**
 * A set of utility methods meant to align to Underscore.js Object.
 *
 * @see https://underscorejs.org/#objects
 */

/**
 * Returns true if object is a string.
 * @param {*} object the object to test
 * @return {boolean} true if object is a string
 */
export const isString = (object) => {
  return typeof object === 'string';
};

/**
 * Returns true if object is a number.
 * @param {*} object the object to test
 * @return {boolean} true if object is a number
 */
export const isNumber = (object) => {
  return typeof object === 'number';
};

/**
 * Returns true if object is an array.
 * @param {*} object the object to test
 * @return {boolean} true if object is an array
 */
export const isArray = (object) => {
  return Array.isArray(object);
};

/**
 * Returns true if object is a function.
 * @param {*} object the object to test
 * @return {boolean} true if object is a function
 */
export const isFunction = (object) => {
  return typeof object === 'function';
};

/**
 * Returns true if object is an object (which includes functions and arrays).
 * @param {*} object the object to test
 * @return {boolean} true if object is an object, function, or array
 */
export const isObject = (object) => {
  return !!object && (isFunction(object) || typeof object === 'object');
};

/**
 * Returns true if object is undefined.
 * @param {*} object the object to test
 * @return {boolean} true if object is undefined
 */
export const isUndefined = (object) => {
  return typeof object === 'undefined';
};

/**
 * Returns true if object is null.
 * @param {*} object the object to test
 * @return {boolean} true if object is null
 */
export const isNull = (object) => {
  return object === null;
};