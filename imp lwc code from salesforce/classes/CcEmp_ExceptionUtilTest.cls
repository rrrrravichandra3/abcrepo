@isTest
private class CcEmp_ExceptionUtilTest {
    private static final String ERROR_MESSAGE = 'Fields should match';
    @isTest
    static void testAccessibleFieldsException() {
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
            Account.Name, Account.Industry
        };
        CcEmp_ExceptionUtil.AccessibleFieldsException ex = new CcEmp_ExceptionUtil.AccessibleFieldsException(fields);
        System.assertEquals(fields, ex.getFields(), ERROR_MESSAGE);
    }

    @isTest
    static void testCreateableFieldsException() {
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
            Account.Name, Account.Industry
        };
        CcEmp_ExceptionUtil.CreateableFieldsException ex = new CcEmp_ExceptionUtil.CreateableFieldsException(fields);
        System.assertEquals(fields, ex.getFields(), ERROR_MESSAGE);
    }

    @isTest
    static void testUpdateableFieldsException() {
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
            Account.Name, Account.Industry
        };
        CcEmp_ExceptionUtil.UpdateableFieldsException ex = new CcEmp_ExceptionUtil.UpdateableFieldsException(fields);
        System.assertEquals(fields, ex.getFields(), ERROR_MESSAGE);
    }

    @isTest
    static void testDeleteableCrudException() {
        List<Schema.SObjectType> types = new List<Schema.SObjectType>{
            Account.SObjectType, Contact.SObjectType
        };
        CcEmp_ExceptionUtil.DeleteableCrudException ex = new CcEmp_ExceptionUtil.DeleteableCrudException(types);
        System.assertEquals(types, ex.getTypes(), ERROR_MESSAGE);
    }

}