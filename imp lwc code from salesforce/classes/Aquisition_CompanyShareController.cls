public without sharing class Aquisition_CompanyShareController{

    public final Acquisition_Company__c company{get; set;}
    
    public Aquisition_CompanyShareController(ApexPages.StandardController stdController) {
        this.company = (Acquisition_Company__c)stdController.getRecord();
        Acquisition_Company__c companyQueried = [SELECT Id, Name, Status__c FROM Acquisition_Company__c WHERE Id=: company.Id];
        company.Name = companyQueried.Name;
        company.Status__c = companyQueried.Status__c;
    }

    private List<M_A_Preboarding_Setting__mdt> settings{
        get{
            if(settings == null) settings = [SELECT Access_Level__c, Compensation_Access__c, DeveloperName, Label, 
                                                Rank__c, Type__c, Can_Share__c FROM M_A_Preboarding_Setting__mdt 
                                                WHERE Type__c = 'Access' ORDER BY Rank__c ASC];
            return settings;
        }
        set;
    }

    @TestVisible
    private Map<String, Id> maPremSets{
        get{
            if(maPremSets == null){
                maPremSets = new Map<String, Id>();
                List<String> permsetDevNames = new List<String>();
                for(M_A_Preboarding_Setting__mdt setting : settings){
                    permsetDevNames.add(setting.DeveloperName);
                }
                List<PermissionSet> permsets = [SELECT Id, Name FROM PermissionSet WHERE Name IN : permsetDevNames];
                for(PermissionSet permset: permsets){
                    maPremSets.put(permset.Name, permset.Id);
                }
            }
            return maPremSets;
            
        }
        set;
    }

    // ONLY Uset with Sharable Permset Assigned AND Has access to current company can share the record.
    public Boolean canUserShareCompany{
        get{
            if(canUserShareCompany == null){
                canUserShareCompany = false;
                //Collect all permset developer names to 
                List<String> sharablePermSets = new List<String>();
                for(M_A_Preboarding_Setting__mdt setting: settings){
                    if(setting.Can_Share__c == true){
                        sharablePermSets.add(setting.DeveloperName);
                    }
                }
                // User need at least one sharable Permission set assigned. Sharable Permission Sets are in Custom Metadata
                List<PermissionSetAssignment> currentUserPermissionsSets = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment 
                                                                                WHERE AssigneeId=:UserInfo.getUserId() AND  PermissionSet.Name IN : sharablePermSets];
                if(currentUserPermissionsSets.size() > 0 ){
                    // Current user has access to current company?
                    List<Acquisition_Company__Share> currentUsersAccessToThisCompany = [SELECT ID, RowCause, AccessLevel, UserOrGroupId FROM Acquisition_Company__Share
                                                                                            WHERE UserOrGroupId =: UserInfo.getUserId() AND ParentId =: company.Id];
                    if(currentUsersAccessToThisCompany.size() > 0){
                        canUserShareCompany = true;
                    }
                }
            }
            return canUserShareCompany;
        }
        set;
    }

    public Boolean showSharingWarning{
        get{
            M_A_Preboarding_Setting__mdt warningStatuses = [SELECT value__c FROM M_A_Preboarding_Setting__mdt WHERE DeveloperName = 'WarningStatuses'];
            List<String> statuses = warningStatuses.value__c.split(',');
            for(String status : statuses){
                if(company.Status__c == status){
                    return true;
                }
            }
            return false;
        }
        set;
    }

    public String searchString{
        get{
            if(searchString == null) searchString = '';
            return searchString;
        }
        set{
            availableUsersOptions = null;
            searchString = String.escapeSingleQuotes(value);
        }
    }
    @TestVisible
    private Set<Id> alreadySharedUsersIds{
        get{
            if(alreadySharedUsersIds == null){
                alreadySharedUsersIds = new Set<Id>();
                List<UserSharingToDisplay> sharedWith = alreadySharedWith;
            }
            return alreadySharedUsersIds;
        }
        set;
    }
    
    public List<SelectOption> selectedUsersOptions{
        get{
            if(selectedUsersOptions == null) selectedUsersOptions = new List<SelectOption>();
            return selectedUsersOptions;
        }
        set;
    }

    public List<SelectOption> availableUsersOptions{
        get{
            if(availableUsersOptions == null) {
                List<PermissionSetAssignment> availableUsers = null;
                availableUsersOptions = new List<SelectOption>();
                if(searchString != null && searchString !=''){
                    String searchStringLike = '%'+searchString+'%';
                    availableUsers = [SELECT AssigneeId, Assignee.Name, Assignee.Email, Id, PermissionSetId FROM PermissionSetAssignment 
                                        WHERE Assignee.IsActive = true AND PermissionSetId IN :  maPremSets.values()
                                                AND AssigneeId not in : alreadySharedUsersIds AND Assignee.Name LIKE :searchStringLike limit 100];
                }else{
                    availableUsers = [SELECT AssigneeId, Assignee.Name, Assignee.Email, Id, PermissionSetId FROM PermissionSetAssignment 
                                        WHERE Assignee.IsActive = true AND PermissionSetId IN :  maPremSets.values()
                                                AND AssigneeId not in : alreadySharedUsersIds limit 300];
                }
                //User can have multiple  M&A permsets, we only need unique users
                Set<Id> uniqueUsers = new Set<Id>();
                Set<Id> selectedUserIds = new Set<Id>();
                for(SelectOption selectedUserOption: selectedUsersOptions){
                    selectedUserIds.add(selectedUserOption.getValue());
                    System.debug('selectedUserOption****. '+selectedUserOption);
                }
                for(PermissionSetAssignment usrPermset: availableUsers){
                    if(uniqueUsers.add(usrPermset.AssigneeId) && !selectedUserIds.contains(usrPermset.AssigneeId)){ //if you can add to a set means unique
                        availableUsersOptions.add(new SelectOption(usrPermset.AssigneeId, usrPermset.Assignee.Name +' ('+usrPermset.Assignee.Email+')'));
                        System.debug('availableUsersOptions****. '+availableUsersOptions);
                    }
                }
            }
            return availableUsersOptions;
        }
        set;
    }

    public List<UserSharingToDisplay> alreadySharedWith{
        get{
            if(alreadySharedWith == null) {
                Map<Id, UserSharingToDisplay> sharingRecordsMap = new Map<Id, UserSharingToDisplay>();
                List<Acquisition_Company__Share> shares = [SELECT Id, ParentId, RowCause, UserOrGroupId, AccessLevel FROM Acquisition_Company__Share WHERE ParentId =:  company.Id];
                for(Acquisition_Company__Share share : shares){
                    String tempIdString = share.UserOrGroupId;
                    if(tempIdString.startsWith('005')){
                        sharingRecordsMap.put(share.UserOrGroupId, new UserSharingToDisplay(share));
                    }
                }
                List<User> users = [SELECT Id, Name, Email FROM User WHERE Id in : sharingRecordsMap.keySet()];
                for(User usr: users){
                    UserSharingToDisplay userForDisplay = sharingRecordsMap.get(usr.Id);
                    userForDisplay.name = usr.Name;
                    userForDisplay.email = usr.Email;
                }
                alreadySharedUsersIds =  sharingRecordsMap.keySet();
                alreadySharedWith = sharingRecordsMap.values();
            }
            return alreadySharedWith;
        }
        set;
    }
    public String deleteShareUserId{get; set;}
    /***************************************
        Variable Declaration done 
    ****************************************/

    public PageReference deleteShae(){
        try{
             //Calling batch class to process acquisition compensation records for processing
             MA_AcquisitionCompensationShareBatch compensationBatch = new MA_AcquisitionCompensationShareBatch(company.Id,null,null,null,deleteShareUserId,'DELETE'); 
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.PF_MA_Compensation_Deletion_Info));              
             if(PF_MA_Settings__c.getInstance().MA_AcquisitionCompensationShare_Size__c != null){
             if(Integer.valueof(PF_MA_Settings__c.getInstance().MA_AcquisitionCompensationShare_Size__c) < 9001){
             database.executeBatch(compensationBatch,Integer.valueof(PF_MA_Settings__c.getInstance().MA_AcquisitionCompensationShare_Size__c));
             }else{
             database.executeBatch(compensationBatch,9000);
             } 
             }
             List<Acquisition_Company__Share> companyShares = [SELECT Id FROM Acquisition_Company__Share WHERE UserOrGroupId=:deleteShareUserId AND ParentId=:company.Id];
             if(companyShares!=null && !companyShares.isEmpty()){
             Delete companyShares;
             }             
             alreadySharedWith= null;
             deleteShareUserId = null;
             availableUsersOptions = null;            
        }catch (Exception ex){
            ApexPages.Message exceptionMessage = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            ApexPages.addMessage(exceptionMessage);
            PF_Logger.log('M&A','ERROR',ex.getMessage(),' Error occured while sending Acquisition Compensation Share records to batch class',' UserId '
                    + UserInfo.getUserId(), 'Aquisition_CompanyShareController');
        }
        return null;
    }

    public PageReference searchUsers(){
        availableUsersOptions = null;
        return null;
    }

    public PageReference createSharing(){
		Savepoint sp = Database.setSavepoint();
        try{
            List<Acquisition_Company__Share> comapnyShares = new List<Acquisition_Company__Share>();
            Map<Id, String> selectedUserIdsMap = new Map<Id, String>();
            for(SelectOption selectedOption: selectedUsersOptions){
                selectedUserIdsMap.put(selectedOption.getValue(), selectedOption.getLabel());
            }

            //Query user with M&A Permissions, To make sure users has M&A permsets assigned
            List<PermissionSetAssignment> userPermSetsAssignements = [SELECT AssigneeId, PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment 
                                                                        WHERE PermissionSetId IN : maPremSets.values() AND AssigneeId IN : selectedUserIdsMap.keySet()];
            Map<Id, Set<String>> userToPermSets = new Map<Id, Set<String>>();
            for(PermissionSetAssignment userPermSet : userPermSetsAssignements){
                if(userToPermSets.get(userPermSet.AssigneeId) == null){
                    Set<String> permsets = new Set<String>(); 
                    permsets.add(userPermSet.PermissionSet.Name);
                    userToPermSets.put(userPermSet.AssigneeId, permsets);
                }else{
                    Set<String> permsets = userToPermSets.get(userPermSet.AssigneeId);
                    permsets.add(userPermSet.PermissionSet.Name);
                }
            }
            Set<Id> usersNeedCompensationAccess = new Set<Id>();
            for(Id userRecordId : userToPermSets.keySet()){
                Set<String> permSets = userToPermSets.get(userRecordId);
                for(M_A_Preboarding_Setting__mdt setting: settings){
                    if(permSets.contains(setting.DeveloperName)){
                        if(setting.Can_Share__c){
                            comapnyShares.add(new Acquisition_Company__Share(ParentId = company.Id, UserOrGroupId=userRecordId, AccessLevel=setting.Access_Level__c, RowCause='Can_Share__c'));
                        }else{
                            comapnyShares.add(new Acquisition_Company__Share(ParentId = company.Id, UserOrGroupId=userRecordId, AccessLevel=setting.Access_Level__c, RowCause='Can_t_Share__c'));
                        }
                        system.debug('comapnyShares***. '+comapnyShares);
                        if(setting.Compensation_Access__c) usersNeedCompensationAccess.add(userRecordId);
                        break;
                    }
                }
            }

            Database.SaveResult[] companySharesSaveResult =  Database.insert(comapnyShares, false);
            for( Integer idx = 0; idx < companySharesSaveResult.size(); idx++){
                if(!companySharesSaveResult[idx].isSuccess()){
                    Id erroredUserId = comapnyShares[idx].UserOrGroupId;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,  'Company Sharing Failed for User : '+ 
                                                                                            selectedUserIdsMap.get(erroredUserId)+ 
                                                                                            ' with message :' + companySharesSaveResult[idx].getErrors()[0].getMessage() +
                                                                                            ' Company sharing AND Compensation sharing is canceled for this user.'));
                    //Remove user FROM the set of users who needed Compensation Sharing 
                    usersNeedCompensationAccess.remove(erroredUserId);
                    selectedUserIdsMap.remove(erroredUserId);
                }
            }
            
            //Calling batch class to process acquisition compensation records for processing
            if(usersNeedCompensationAccess.size() > 0){
                 system.debug('usersNeedCompensationAccess***. '+usersNeedCompensationAccess);
                MA_AcquisitionCompensationShareBatch compensationBatch = new MA_AcquisitionCompensationShareBatch(company.Id,usersNeedCompensationAccess,comapnyShares,selectedUserIdsMap,null,'SAVE'); 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.PF_MA_Compensation_Share_Info)); 
                 //Default scope should be set to 9000 in custom setting 
                 system.debug('PF_MA_Settings__c.getInstance().MA_AcquisitionCompensationShare_Size__c** '+PF_MA_Settings__c.getInstance().MA_AcquisitionCompensationShare_Size__c);
                 if(PF_MA_Settings__c.getInstance().MA_AcquisitionCompensationShare_Size__c != null){
                 if(Integer.valueof(PF_MA_Settings__c.getInstance().MA_AcquisitionCompensationShare_Size__c) < 9001 && usersNeedCompensationAccess.size() > 1){
                 Decimal dynamicScope = PF_MA_Settings__c.getInstance().MA_AcquisitionCompensationShare_Size__c/usersNeedCompensationAccess.size();
                 database.executeBatch(compensationBatch,Integer.valueof(dynamicScope));
                 }else{
                 database.executeBatch(compensationBatch,9000);
                 } 
                 } 
             } 
            selectedUsersOptions = null;
            availableUsersOptions = null;
            alreadySharedWith= null;
            
        }catch (Exception ex){
            ApexPages.Message exceptionMessage = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            ApexPages.addMessage(exceptionMessage);
			Database.rollback(sp);
            PF_Logger.log('M&A','ERROR',ex.getMessage(),' Error occured while sending Acquisition Compensation Share records to batch class',' UserId '
                    + UserInfo.getUserId(), 'Aquisition_CompanyShareController');
        }
        return null;
    }

    public PageReference returnToCompanyDetails(){
        return new PageReference('/'+company.Id);
    }

	public static void sendEmail(Set<Id> userIds, Id compId) {
    
        Id companyId = compId;		
		EmailTemplate maNotificationEmailTemplate=[SELECT id FROM EmailTemplate WHERE DeveloperName = 'M_A_Company_Sharing_Notifications' LIMIT 1];
		
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage ();
		email.setTemplateId(maNotificationEmailTemplate.Id);
		email.setSaveAsActivity(false);
		List<User> users = [SELECT Id, Name, Email FROM User WHERE Id IN :  userIds];
		Contact userContact = [SELECT Id FROM Contact WHERE Email like : UserInfo.getUserEmail()+'%' limit 1];
		if(userContact == null) userContact = [SELECT Id FROM Contact limit 1];
		
		email.setTargetObjectId(userContact.Id);
		List<String> emailAddresses = new List<String>();
		for(User usr: users){
			emailAddresses.add(usr.Email);
		}
		email.setToAddresses(emailAddresses);
		email.setWhatId(companyId);
		emails.add(email);
		if(!Test.isRunningTest()){
			List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
		}
	}

    public class UserSharingToDisplay{
        public UserSharingToDisplay(Acquisition_Company__Share share){
            this.userId = share.UserOrGroupId;
            if(share.AccessLevel == 'All') this.accessLevel = 'Full Access';
            else if(share.AccessLevel == 'Edit') this.accessLevel = 'Read/Write';
            else this.accessLevel = share.AccessLevel;

            if(share.RowCause == 'Can_t_Share__c') this.rowCause = 'Can not share';
            else if(share.RowCause == 'Can_Share__c') this.rowCause = 'Can share';
            else if(share.AccessLevel == 'All') this.rowCause = 'Can share';
            else if(share.AccessLevel == 'Read' && share.RowCause == 'Manual') this.rowCause = 'Can not share';
            else this.rowCause = share.RowCause;

            if(share.RowCause == 'Owner') canNotDelete = true;
        }
        public Id userId{get; set;}
        public String name{get; set;}
        public String accessLevel{get; set;}
        public String rowCause{get; set;}
        public String email{get; set;}
        public Boolean canNotDelete{get; set;}
    }
}