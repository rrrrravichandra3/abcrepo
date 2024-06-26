/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 08-18-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public interface CEMCI_FLSCheckInterface {
  Boolean canReadObject(String objectName);
  Boolean canReadField(String objectName, String fieldName);
  Boolean canUpdateObject(String objectName);
  Boolean canUpdateField(String objectName, String fieldName);
  Boolean canCreateField(String objectName, String fieldName);
  Boolean canCreateObject(String objectName);
  Boolean canDeleteObject(String objectName);
}