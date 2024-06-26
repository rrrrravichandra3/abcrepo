/**
 * @author Anchana Rajamathe
 * @date 07/07/2021
 *
 * @description This Implements IA_ErrorHandlerInterface to notify support 
 * specific to  Peopleforce
 */
public without sharing class IA_ErrorHandlerImpl implements IA_ErrorHandlerInterface {
    public static FINAL  String[] ADMINSUPPORT_DL = IA_Util.InsiderConfigDefaultRec.Email_Addresses_for_Exceptions__c.split(',');

  /*******************************************************************************************************
   * @description : Defines method to notify appropriate support channel of exceptions or errors which happened.
   * @params : errorMessages List<String>
   * @example
   * IA_ErrorHandlerImpl.notifyErrors( {'User with email 'Jane@example.com' had Null point exception while booking.','Validation error for user'}})
   */
  public static void notifyErrors(List<String> errorMessages) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //Email_Addresses_for_Exceptions__c should house - Eops email to Case DL for PROD and Slack channel email for lower envs.
        String[] toAddresses = IA_ErrorHandlerImpl.ADMINSUPPORT_DL;


            mail.setToAddresses(toAddresses);
            mail.setSubject('Error from ' + UserInfo.getOrganizationName() + ' with Org Id ' + UserInfo.getOrganizationId());
            String emailBody = String.join(errorMessages, '\n');
            mail.setPlainTextBody(emailBody);
            if (!test.isRunningTest()){
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
            }
         
  }

  
}