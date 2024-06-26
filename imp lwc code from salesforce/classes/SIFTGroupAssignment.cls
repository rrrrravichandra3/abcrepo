global class SIFTGroupAssignment {
    Public static String insertOrDeleteErrors;

    @InvocableMethod(label='Add Users to public groups')
    global static void addUsersToPublicGroups(List<UserGroupId> ugIds) {
        List<GroupMember> groupMembersToInsert = new List<GroupMember>();
        for (UserGroupId ugId : ugIds) {
            GroupMember gm= new GroupMember(); 
            gm.GroupId= ugId.groupId;
            gm.UserOrGroupId = ugId.userId;
            groupMembersToInsert.add(gm);
        }
        
        if(groupMembersToInsert.size()>0){
            Database.SaveResult[] saveResultList = Database.insert(groupMembersToInsert, false);
            for(Integer i =0; i< saveResultList.size(); i++) {
				if(saveResultList[i].isSuccess() == false) {
					for(Database.Error error : saveResultList[i].getErrors()) {
						if(String.Valueof(error.getStatusCode())!='DUPLICATE_VALUE'){
							insertOrDeleteErrors = insertOrDeleteErrors + error.getStatusCode()+':'+error.getMessage()+ '\n';
						}
						
					}
				}
			}          
        }        
    }
    
    global class UserGroupId {
        @InvocableVariable
        global Id groupId;
        
        @InvocableVariable
        global Id userId;
        
    }
    
    
    private static void mailErrors() {
        String emailIdsFromCustomSetting = IFB_SIFT_Settings_List__c.getInstance('SIFT').IFB_WD_Integration_Downstream_Err_Emails__c;
        if(String.isEmpty(emailIdsFromCustomSetting) == true) {
            return;
        }
        List<String>emailIds = emailIdsFromCustomSetting.split(',');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(emailIds);
        mail.setSenderDisplayName('SIFT - Public group assignment failures');
        mail.setSubject('Errors that occurred when inserting SIFT Permission Sets');
        mail.setPlainTextBody(insertOrDeleteErrors);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}