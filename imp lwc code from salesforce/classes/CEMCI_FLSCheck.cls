/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 08-18-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
global class CEMCI_FLSCheck implements CEMCI_FLSCheckInterface {
  public static Boolean canReadObject(String objectName) {
    Schema.DescribeSObjectResult sObjResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
    return sObjResult.isAccessible();
  }
  public static Boolean canReadField(String objectName, String fieldName) {
    Schema.DescribeFieldResult sObjFieldResult = Schema.getGlobalDescribe()
      .get(objectName)
      .getDescribe()
      .fields.getMap()
      .get(fieldName)
      .getDescribe();
    return sObjFieldResult.isAccessible();
  }
  public static Boolean canUpdateObject(String objectName) {
    Schema.DescribeSObjectResult sObjResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
    return sObjResult.isUpdateable();
  }
  public static Boolean canUpdateField(String objectName, String fieldName) {
    Schema.DescribeFieldResult sObjFieldResult = Schema.getGlobalDescribe()
      .get(objectName)
      .getDescribe()
      .fields.getMap()
      .get(fieldName)
      .getDescribe();
    return sObjFieldResult.isUpdateable();
  }
  public static Boolean canCreateField(String objectName, String fieldName) {
    Schema.DescribeFieldResult sObjFieldResult = Schema.getGlobalDescribe()
      .get(objectName)
      .getDescribe()
      .fields.getMap()
      .get(fieldName)
      .getDescribe();
    return sObjFieldResult.isCreateable();
  }

  public static Boolean canCreateObject(String objectName) {
    Schema.DescribeSObjectResult sObjResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
    return sObjResult.isCreateable();
  }

  public static Boolean canDeleteObject(String objectName) {
    Schema.DescribeSObjectResult sObjResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
    return sObjResult.isDeletable();
  }
}