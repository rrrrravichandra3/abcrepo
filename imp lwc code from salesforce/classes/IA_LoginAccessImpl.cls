/**
 * @description This Implements IA_LoginAccessInterface to perform login checks involving additional customizations
 * @author Anchana Rajamathe
 * @date 12/27/2020
 *
 * specific to  Peopleforce
 */
public without sharing class IA_LoginAccessImpl implements IA_LoginAccessInterface {
    public static final String CANDIDATE_RECORD_TYPE_NAME = 'WDR Candidate';
    /*******************************************************************************************************
     * @description Defines method to Performs= additional login check
     * specific for the customer and returns eligible contacts.
     * @param List<Contact> : List of All contacts
     * @return  List<Contact> : List of Eligible contacts
     * @example
     * List<Contact> eligibleContacts = IA_LoginAccessImpl.additionalLoginAccessChecks(contacts);
     */
    public static List<Contact> additionalLoginAccessChecks(List<Contact> contacts) {
        List<Contact> eligibleContacts = new List<Contact>();
          List<String> externalCandidateStages = IA_Util.eligibleCandidateStages;
          Boolean loginAllowed = false;
          List<WDR_Application__c> currentAplication = additionalApplicationStageCheck(contacts[0].Email);
          
          for(WDR_Application__c wd:currentAplication){
              if(String.isNotBlank(wd.Candidate_Stage__c)){
                  if(externalCandidateStages.contains(wd.Candidate_Stage__c) && loginAllowed==false){
                      loginAllowed= true;
                      eligibleContacts.add(contacts[0]);
                  }
              }
          }
  
      return eligibleContacts;
    }
    /*******************************************************************************************************
     * @description Defines method to perform if eligible user has required access
     * specific for the customer and returns eligible contacts.
     * @param List<Contact> : List of All contacts
     * @return  List<Contact> : List of Eligible contacts
     * @example
     * List<Contact> eligibleContacts = IA_LoginAccessImpl.additionalLoginAccessChecks(contacts);
     */
    public static Boolean additionalLoginAccessCheckAndProvisioningForUser(List<User> associatedUser) {
      String PermissionsetName = IA_Util.InsiderConfigDefaultRec.Perm_Set__c;
      String PublicGroupName = IA_Util.InsiderConfigDefaultRec.Public_Group__c;
      List<PermissionSetAssignment> userCandidatePerm = new List<PermissionSetAssignment>();
      List<GroupMember> groupMember = new List<GroupMember>();
      Boolean loginAllowed = false;
      
      List<WDR_Application__c> currentAplication = additionalApplicationStageCheck(associatedUser[0].Email);//get eligible applications
          
      if (currentAplication.size()==0){
        return false;
      }
  
      if (String.isNotBlank(PermissionsetName)) {//PermissionsetName is optional and can 
           userCandidatePerm = [
            SELECT id
            FROM PermissionSetAssignment
            WHERE PermissionSet.name = :PermissionsetName AND AssigneeId = :associatedUser[0].Id
          ];
      }
      system.debug(userCandidatePerm);
      system.debug(groupMember);
      groupMember = [Select id from groupMember where UserOrGroupId=:associatedUser[0].Id and Group.developerName = :PublicGroupName];
      if (userCandidatePerm.size() == 0 || groupMember.size() == 0) {
         // IA_InternalCandidateFuture.assignGroupAndPermset(new List<Id>{associatedUser[0].Id});
        //AssignPermissionSetAndPublicGroup(associatedUser[0].Id, PermissionsetName, PublicGroupName);
      }
  
      return true;
    }
  /**
     * @description Assigns a specific PermissionSet and PublicGroup to a User.
     *
     * @param UserId 
     * The unique identifier of the User to whom the PermissionSet and PublicGroup will be assigned.
     *
     * @param PermissionSetName 
     * The name of the PermissionSet that will be assigned to the User.
     *
     * @param GroupName 
     * The name of the PublicGroup that will be assigned to the User.
     *
     * @return 
     * This method does not return any value. It initiates a Flow that handles the assignment of the PermissionSet and PublicGroup to the specified User.
     *
     * @example
     * IA_LoginAccessImpl.AssignPermissionSetAndPublicGroup(user.Id, 'PermissionSetName', 'PublicGroupName');
     */
    public static void AssignPermissionSetAndPublicGroup(Id UserId, String PermissionSetName, String GroupName) {
      system.debug('Inside assign...');
      Map<String, Object> inputVarMap = new Map<String, Object>();
      inputVarMap.put('PermissionSetName', PermissionSetName);
      inputVarMap.put('GroupName', GroupName);
      inputVarMap.put('UserId', UserId);
      Flow.Interview.IA_AutoPermAndPublicGroupAssignment provisionAccessToCandidateFlow = new Flow.Interview.IA_AutoPermAndPublicGroupAssignment(
        inputVarMap
      );
      provisionAccessToCandidateFlow.start();
    }
    /**
     * @description This method retrieves a list of WDR_Application__c records where the candidate's email matches the provided email and the candidate's stage is in the list of eligible candidate stages.
     * @param String associatedUserEmail The email of the candidate to search for.
     * @return List<WDR_Application__c> A list of WDR_Application__c records where the candidate's email matches the provided email and the candidate's stage is in the list of eligible candidate stages.
     * @example
     * List<WDR_Application__c> currentAplication = IA_LoginAccessImpl.additionalApplicationStageCheck('example@example.com');
     */
    //Return List<WDR_Application__c> with eligible candidate stage
    public static List<WDR_Application__c> additionalApplicationStageCheck(String associatedUserEmail) {
          List<WDR_Application__c> currentAplication = [Select Candidate_Stage__c from WDR_Application__c where 
                                                    Internal_Candidate__c = False 
                                                    AND Candidate_Email__c =:associatedUserEmail
                                                    AND Candidate_Stage__c IN :IA_Util.eligibleCandidateStages];
          return currentAplication;
      }
  }