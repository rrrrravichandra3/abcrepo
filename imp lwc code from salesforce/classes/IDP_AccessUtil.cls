/*
This is Util class which has methods related to Access Management for IDP records.
- Apex sharing
- CRUD checks.
*/
public with sharing class IDP_AccessUtil {
    public static final  string NO_ACCESS_ERROR_MESSAGE =System.Label.IDP_NO_ACCESS_ERROR_MESSAGE;
    public static final  string ON_CREATE_ERROR_MESSAGE =System.Label.IDP_ON_CREATE_ERROR_MESSAGE;
    public static final  string GENERAL_ERROR_MESSAGE =System.Label.IDP_GENERAL_ERROR_MESSAGE;
    public static final  string NO_ACCESS_MANAGER_ERROR_MESSAGE =System.Label.IDP_NO_ACCESS_MANAGER_ERROR_MESSAGE;
    public static final  string ON_CREATE_OBJ_ERROR_MESSAGE =System.Label.IDP_ON_CREATE_OBJ_ERROR_MESSAGE;
    public static final  string ON_UPDATE_OBJ_ERROR_MESSAGE =System.Label.IDP_ON_UPDATE_OBJ_ERROR_MESSAGE;
    public static final  string ON_UPSERT_ACTIONS_ERROR_MESSAGE =System.Label.IDP_ON_UPSERT_ACTIONS_ERROR_MESSAGE;
    public static user currentUserDetail{
        get {
            if(currentUserDetail == null){
                List<user> currentUserDetails = [SELECT id,EmployeeNumber,Manager__c,Manager__r.EmployeeNumber 
                                                    FROM User
                                                    WHERE Id=:UserInfo.getUserId()];
                User currentUserDetailInit=  currentUserDetails.size() > 0 ?currentUserDetails[0] : null;
                return currentUserDetailInit;

            }
            return currentUserDetail;


        } 
        set;
    }
    public static string currentUserManagerEmpId;

    public static boolean checkIfManagerHasAccess(String IDPRecId){
        String currentUserId = UserInfo.getUserId();
        List<IDP__share> IDPShareRecs = [SELECT Id, UserOrGroupId, AccessLevel, 
                                        RowCause 
                                        FROM IDP__share 
                                        WHERE ParentId = :IDPRecId AND UserOrGroupId= :currentUserId];
        If(IDPShareRecs.size()>0){
            return true ;//TODO :Maybe we check for rowCause too?
        }else{
            return false;
        }
    }
    public static map<String,Boolean>  shareIDPWithManager(map<string,string> mMgerIdByIDPRecId) 
    {
        List<IDP__Share> IDPShareWithMgerRecs = new List<IDP__Share>();
        map<String,Boolean> mIsShareSuccessByIDPRecId = new map<String,Boolean>();
        for(String IDPRecId: mMgerIdByIDPRecId.keySet()){
            // Create new sharing rec for IDP.
            IDP__Share IDPShrWithMgrRec  = new IDP__Share();
            IDPShrWithMgrRec.ParentId = IDPRecId;
            IDPShrWithMgrRec.UserOrGroupId = mMgerIdByIDPRecId.get(IDPRecId);
            IDPShrWithMgrRec.RowCause = Schema.IDP__Share.RowCause.Manual;

            IDPShrWithMgrRec.AccessLevel = 'Read';
            IDPShareWithMgerRecs.add(IDPShrWithMgrRec);
        }

        List<Database.SaveResult> srList = Database.insert(IDPShareWithMgerRecs,false);
        // As each element in SaveResult Array corresponds input sobject array,
        // we can update incoming map accordingly
        Integer i = 0;
        for(Database.SaveResult sr: srList){
            String IDPRecId = IDPShareWithMgerRecs[i].ParentId;
            // Process the save results.
            if(sr.isSuccess()){
                // Indicates success
                mIsShareSuccessByIDPRecId.put(IDPRecId, true);
            }
            else {
                // Get first save result error.
                Database.Error err = sr.getErrors()[0];
                
                // Check if the error is related to trival access level.
                // Access level must be more permissive than the object's default.
                // These sharing records are not required and thus an insert exception is acceptable. 
                if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                        err.getMessage().contains('AccessLevel')){
                    // Indicates success.
                    mIsShareSuccessByIDPRecId.put(IDPRecId, true);

                }
                else{
                        // Indicates failure.
                    mIsShareSuccessByIDPRecId.put(IDPRecId, false);

                }
            } 
            i++;       
        }
        return  mIsShareSuccessByIDPRecId;
 
    }
    public static boolean checkIfCurrentUserIsManagerForEmployee(string employeeId){
        //TODO: filter for standard user.
        List<User> PF_Employee_User = [SELECT id,EmployeeNumber,Manager__r.EmployeeNumber 
                                        FROM User
                                        WHERE EmployeeNumber=:employeeId
                                        Limit 1
                                       ];
        if(PF_Employee_User.size()>0){
            User PF_Current_User = [SELECT id,EmployeeNumber,Manager__r.EmployeeNumber 
                                    FROM User
                                    WHERE Id=:UserInfo.getUserId()
            ];
            String EmployeeManagerEmpId = PF_Employee_User[0].Manager__r.EmployeeNumber;
            String currentUserEmpId = PF_Current_User.EmployeeNumber;
            if(   EmployeeManagerEmpId != null 
            && EmployeeManagerEmpId == currentUserEmpId
            ){
            return true;

            }else{
            return false;
            }
        }
        else{ //PF user does not exist for this employee number.
            String ErrContext = 'PF user does not exist for requested employee number - '+employeeId;
            system.debug(ErrContext);
            PF_Logger.log('IDP','ERROR',null,ErrContext,null,'IDP_AccessUtil');        
            return false;
        }

        
    }




}