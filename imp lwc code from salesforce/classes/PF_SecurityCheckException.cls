/*
 * Throw this exception to indicate any security check failed. E.g. User doesn't
 * have the access to perform that operation on the field or object
 * See: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_exception_custom.htm
 */
public class PF_SecurityCheckException extends Exception { }