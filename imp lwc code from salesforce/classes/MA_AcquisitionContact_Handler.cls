public class MA_AcquisitionContact_Handler {


    public class ContactAqcParameter{
        @InvocableVariable(required=true)
        public Id acquistionId;
        @InvocableVariable(required=true)
        public Boolean activateUser;
    }
    

	@InvocableMethod(label='Deactivate MA Users' description='If acquisition contact status is cancelled, then updating user active field to false')
    public static void deactivateMAUsers(ContactAqcParameter[] conatctAqcParams) {        
       
        Boolean activatePortalUser = true;
        List<Id> allContactIds = new List<Id>();
        for(ContactAqcParameter contactAqc : conatctAqcParams){
            allContactIds.add(contactAqc.acquistionId);
            activatePortalUser = contactAqc.activateUser;
        }
        
        List<User> allUsers = [Select Id,IsActive From User where Contact.Acquisition_Contacts__c in :allContactIds and IsActive =: !activatePortalUser];
        
        List<User> usersToDeactivate = new List<User>();
        for(User user : allUsers) {
            user.IsActive = activatePortalUser;
            usersToDeactivate.add(user);
        }
        
        if(Schema.sObjectType.User.fields.IsActive.isUpdateable()) {
        	 update usersToDeactivate;
        }
    }
}