/*
This REST service serves to surface/Manage Individual Development Plan (IDP) for a requesting User.
IDP is shared only with a given user and their immediate manager.
This runs in User context and necessary access checks are done to ensure the same.
This service class have methods 
  - to retrieve IDP data for User and their manager.
  - update IDP data for User.
*/
@RestResource(urlMapping = '/IDP/*')
global with sharing class IDPWebService {
    public DateTime lastmodifiedDate;
    public static Boolean isLastSavedDateUpdated = false;


/*This get method 
   - for given WorkerId,
   		- If existing IDP data exists , it returns data
		- else creates IDP with placeholder values and returns the same
   - Is invoked by Requestor is peopleforce user who can be self or Manager.
     - If new IDP created, it creates apex share for the manager via platform event.

   - Input URI EmpID
   - Returns IDPWrapper response object

   - Performs authorization checks
	 - runs in with Sharing so ONLY user and manager can access IDP record.
	 - access error message returned
	 	- if current user worker id is not same as requested worker id  and NOT user manager.
		- if manager lacks access to IDP
   - currently invoked on load from  IDP subtab of V2MOM app.	
*/
@HttpGet
global static IDPWrapper getIDPData() {

	// create and return IDPWrapper with all the data
	IDPWrapper idpResponseWrapper = new IDPWrapper();
	try{
		
		RestRequest request = RestContext.request;
		// grab the employeeNum from the end of the URL
		String employeeNumber = request.requestURI.substring(
		request.requestURI.lastIndexOf('/')+1);
		String IDPRecId ;

		//get the latest IDP - security enforced ensures that 
		//if User does not have access to any of these fields exception is thrown.
		List<IDP__c> IDPRec = [SELECT id,
									  Career_Interest__c,
									  Key_Strengths__c, 
									  createdDate,
									  Last_Saved_Date__c 
								FROM IDP__c 
								WHERE Employee_Number__c  = : employeeNumber 
								WITH SECURITY_ENFORCED
								ORDER BY Lastmodifieddate Desc 
								LIMIT 1];
		
	
		//If No IDP found,
		if(IDPRec.size()==0){
			//Check if this is Employee requesting their IDP data,
			//If yes, and IDP data null, create a new IDP
			if(IDP_AccessUtil.currentUserDetail.EmployeeNumber == employeeNumber){ 
				IDP__c newIDP = new IDP__c();
				newIDP.Key_Strengths__c = '';
				newIDP.Career_Interest__c = '';
				newIDP.Employee_Number__c = employeeNumber;  
				newIDP.Last_Saved_Date__c = System.now();
				isLastSavedDateUpdated = true;
				try{
					SObjectAccessDecision insertSecurityDecision = Security.stripInaccessible(AccessType.CREATABLE, new List<IDP__c> {newIDP});
                	IDP__c securityEnforcedIdp = (IDP__c) insertSecurityDecision.getRecords()[0];
					insert securityEnforcedIdp; 
					IDPRec = [SELECT id,Career_Interest__c,Key_Strengths__c, createdDate,Last_Saved_Date__c  FROM IDP__c
					           WHERE id=:securityEnforcedIdp.Id WITH SECURITY_ENFORCED];

				}catch (exception ex){

					String ErrContext = 'Error on creating new IDP for User with Id '+ UserInfo.getUserId() + 'and Emp num ' +employeeNumber;
					system.debug(ErrContext + ex.getMessage());
					PF_Logger.log('IDP','ERROR',ex.getMessage(),ErrContext,ex.getStackTraceString(),'IDPWebService');
					idpResponseWrapper.errorMessage = IDP_AccessUtil.ON_CREATE_ERROR_MESSAGE;
					 
				}
				//Share New IDP to Manager
				//Get Manager Id ;
				if(IDPRec.size()>0){
					String ManagerId = IDP_AccessUtil.currentUserDetail.Manager__c;

					if(ManagerId != null){
						sobjectShare__e IDPShareEvt =  new sobjectShare__e(ParentId__c=IDPRec[0].Id, 
																			UserOrGroupId__c=ManagerId,
																			sObjectShareAPIName__c='IDP__Share'
																		);
						// Call method to publish events
						Database.SaveResult sr = EventBus.publish(IDPShareEvt);
						if (sr.isSuccess()) {
							System.debug('Successfully published event.');
						} else {
							for(Database.Error err : sr.getErrors()) {
								String ErrContext = 'Unable to share IDP with manager for User with Id  '+ UserInfo.getUserId() + ' and Emp num ' +employeeNumber;
								String ExceptionMessage = ' sobjectShare__e platform event failed with '+ err.getStatusCode()  + ' - ' + err.getMessage();
								system.debug(ErrContext+ExceptionMessage);
								PF_Logger.log('IDP','ERROR',err.getMessage(),ErrContext,ExceptionMessage,'IDPWebService');
							}
						}
					}else{
						String ErrContext = 'Unable to share IDP with manager as PF user manager__c details are unavailable for UserId -'+UserInfo.getUserId();
						system.debug(ErrContext);
						PF_Logger.log('IDP','ERROR',null,ErrContext,null,'IDPWebService');
					}
				}


			}//If no, it could be manager 
			else if(IDP_AccessUtil.checkIfCurrentUserIsManagerForEmployee(employeeNumber)){ 

				String ErrContext = 'Your direct report does not have an IDP. Please ask them to create an IDP via the tab next to their V2MOM.';
				system.debug(ErrContext);
				PF_Logger.log('IDP','ERROR',null,ErrContext,null,'IDPWebService');
				idpResponseWrapper.errorMessage = IDP_AccessUtil.NO_ACCESS_MANAGER_ERROR_MESSAGE;

			}else
			{
				String ErrContext = 'Unauthorized IDP Access by User with Id -'+UserInfo.getUserId() + ' for Emp num ' +employeeNumber;
				system.debug(ErrContext);
				PF_Logger.log('IDP','ERROR',null,ErrContext,null,'IDPWebService');
				idpResponseWrapper.errorMessage = IDP_AccessUtil.NO_ACCESS_ERROR_MESSAGE;
			}
		}

		if(IDPRec.size() > 0) {
			idpResponseWrapper.keyStrengths = IDPRec[0].Key_Strengths__c;
			idpResponseWrapper.careerInterest = IDPRec[0].Career_Interest__c;
			idpResponseWrapper.recordId = IDPRec[0].Id;
			idpResponseWrapper.lastModifiedDate = IDPRec[0].Last_Saved_Date__c;
			idpResponseWrapper.objectives = buildObjectiveWrapper(employeeNumber,IDPRec[0],idpResponseWrapper);
		}

	}catch(exception ex){
		String ErrContext = 'Exception occured when retrieving IDP for User with Id '+ UserInfo.getUserId() ;
		system.debug(ErrContext + ex.getMessage());
		PF_Logger.log('IDP','ERROR',ex.getMessage(),ErrContext,ex.getStackTraceString(),'IDPWebService');
		idpResponseWrapper.errorMessage = IDP_AccessUtil.GENERAL_ERROR_MESSAGE;	
	}

	if( PF_Logger.logs.size()>0){
		PF_Logger.createLogs(PF_Logger.logs);
	}
	return idpResponseWrapper;

}
// helper method to used to build response wrappers for getIDPData
public static List<IDPObjectiveWrapper> buildObjectiveWrapper(String employeeNumber,IDP__c latestIDP,IDPWrapper idp){
	//query action, objectives and IDP to build the wrapper
	List<IDP_Action__c> result =  [ Select
	                                Id,
	                                Action__c,
	                                Status__c,
	                                Completed_Date__c,
	                                EmployeeNumber__c,
                                    Support__c,
	                                IDP_Objective__r.IDP_Objective_Name__c,
	                                IDP_Objective__c,
	                                IDP_Objective__r.IDP__c,
	                                IDP_Objective__r.lastmodifieddate,
	                                IDP_Objective__r.IDP__r.Key_Strengths__c,
	                                IDP_Objective__r.IDP__r.Career_Interest__c,
	                                lastmodifieddate
	                                FROM IDP_Action__c
	                                WHERE
	                                EmployeeNumber__c = : employeeNumber
	                                                    AND
	                                                    IDP_Objective__r.IDP__c =: latestIDP.Id
	                                                                              AND
	                                                                              IsDeleted__c = false
	                                                                                             AND
	                                                                                             IDP_Objective__r.IsDeleted__c = false
	];


	Map<Id,List<IDPActionWrapper> > objectiveToActions = new Map<Id,List<IDPActionWrapper> >();
	Map<Id,String> objNameToID = new Map<Id,String>();
	//Build Objectives to ActionsMap
	//if Actions and Objectives Exist
	if(result.size()>0) {
		for(IDP_Action__c action : result) {
			IDPActionWrapper idpActionWrapper = new IDPActionWrapper();
			idpActionWrapper.recordId = action.Id;
			idpActionWrapper.Action = action.Action__c;
			idpActionWrapper.Status = action.Status__c;
			idpActionWrapper.completionDate = action.Completed_Date__c;
            idpActionWrapper.Comments = action.Support__c;
			
			// Build a Map of Objectives to Actions
			if(objectiveToActions.get(action.IDP_Objective__c)!=null) {
				List<IDPActionWrapper> actionsFromMap = objectiveToActions.get(action.IDP_Objective__c);
				actionsFromMap.add(idpActionWrapper);
				objectiveToActions.put(action.IDP_Objective__c,actionsFromMap);
			}
			else {
				List<IDPActionWrapper> actions = new List<IDPActionWrapper>();
				actions.add(idpActionWrapper);
				objectiveToActions.put(action.IDP_Objective__c,actions);
				objNameToID.put(action.IDP_Objective__c,action.IDP_Objective__r.IDP_Objective_Name__c);
			}

		}

	}
	//Query objectives without actions Exist
   
	Map<Id, IDP_Objective__c> objectivesMap;
		objectivesMap = new Map<Id, IDP_Objective__c>([SELECT id,
		                                               IDP_Objective_Name__c,
		                                               IDP__c,IDP__r.Key_Strengths__c,
		                                               IDP__r.Career_Interest__c,
		                                               IDP__r.lastmodifieddate, 
                                                       lastmodifieddate
		                                               FROM
		                                               IDP_Objective__c
		                                               WHERE
		                                               IDP__c =: latestIDP.Id
		                                                        AND IsDeleted__c = false
                                                      			AND Id NOT IN :objectiveToActions.keySet()]);
	
	
	if(!objectivesMap.isEmpty()) {
		for(IDP_Objective__c obj : objectivesMap.values()) {
			objectiveToActions.put(obj.id,null);
			objNameToID.put(obj.Id,obj.IDP_Objective_Name__c);
		}
	}
	List<IDPObjectiveWrapper> objectiveWrappersList= new List<IDPObjectiveWrapper>();
	// Build a IDPObjectiveWrapper for each entry in the objectiveToActions map
	for(Id objId:objectiveToActions.keySet()) {
		IDPObjectiveWrapper objectiveWrapper = new IDPObjectiveWrapper();
		objectiveWrapper.recordId = objId;
		objectiveWrapper.objectiveName = objNameToID.get(objId);
		if(objectiveToActions.get(objId)!=null) objectiveWrapper.actions = objectiveToActions.get(objId);
		objectiveWrappersList.add(objectiveWrapper);
	}
	return objectiveWrappersList;
}

// Method to handle update/Insert objective and Actions
@HttpPatch
global static IDPObjectiveWrapper updateObjectives(){
	RestRequest req = RestContext.request;
	IDPObjectiveWrapper wrap = new IDPObjectiveWrapper();
	try{
		Map<String, Object> params=(Map<String, Object>)JSON.deserializeUntyped(req.requestbody.tostring());
		List<Object> acts = (List<Object>)params.get('actions');
		Id objId;
		String idpId = (String)params.get('idpRecordId');
		if(params.get('recordId')!=null) {
			objId = (Id)params.get('recordId');
		}
		if(objId!=null) {
			try{
				// Update objective if name is updated
				List<IDP_Objective__c> queriedObj = [Select
											ID,
											IDP_Objective_Name__c
											FROM IDP_Objective__c
											WHERE
											ID = : objId
											WITH SECURITY_ENFORCED];
				if(queriedObj.size()>0) {
					IDP_Objective__c objtoUpdate =  queriedObj[0];
					//Update objective if Objective Name is changed
					if(objtoupdate.IDP_Objective_Name__c != (String)params.get('objectiveName')) {
						objtoupdate.IDP_Objective_Name__c = (String)params.get('objectiveName');
						update objToUpdate;
					}
				}
			}catch(exception ex){
				String ErrContext = 'Error on updating Objective for User with Id '+ UserInfo.getUserId() + 'and IDP Id ' +idpId;
				system.debug(ErrContext + ex.getMessage());
				PF_Logger.log('IDP','ERROR',ex.getMessage(),ErrContext,ex.getStackTraceString(),'IDPWebService');
				wrap.errorMessage = IDP_AccessUtil.ON_UPDATE_OBJ_ERROR_MESSAGE;	
			}
	
		}
		//create Objective
		else{
			IDP_Objective__c objtoInsert =  new IDP_Objective__c();
			try{
				objtoInsert.IDP_Objective_Name__c = (String)params.get('objectiveName');
				objtoInsert.IDP__c = idpId;
				insert objtoInsert;
				if(objId==null) {
					objId = objtoInsert.Id;
				}
			}catch(exception ex){
				String ErrContext = 'Error on creating new Objective for User with Id '+ UserInfo.getUserId() + 'and IDP Id ' +idpId;
				system.debug(ErrContext + ex.getMessage());
				PF_Logger.log('IDP','ERROR',ex.getMessage(),ErrContext,ex.getStackTraceString(),'IDPWebService');
				wrap.errorMessage = IDP_AccessUtil.ON_CREATE_OBJ_ERROR_MESSAGE;		
			}
	
		}
		if(objId != null){
			wrap.objectiveName = (String)params.get('objectiveName');
			wrap.recordId = objId;
			try{
				if(!acts.isEmpty()){
					wrap.actions = insertAndUpdateActions(acts,objId);
				}
				IDP__c idp = [SELECT Id, Last_Saved_Date__c
								FROM IDP__c
                               WHERE Id = :idpId
                                WITH SECURITY_ENFORCED ];
				wrap.objLastModifiedDate = idp.Last_Saved_Date__c;
			}catch(exception ex){
				String ErrContext = 'Error on upserting actions  for User with Id '+ UserInfo.getUserId() + 'and Obj Id ' +objId;
				system.debug(ErrContext + ex.getMessage());
				PF_Logger.log('IDP','ERROR',ex.getMessage(),ErrContext,ex.getStackTraceString(),'IDPWebService');
				wrap.errorMessage = IDP_AccessUtil.ON_UPSERT_ACTIONS_ERROR_MESSAGE;	
			}
	
		}
	
	}catch(exception ex){
		String ErrContext = 'Exception occured when upserting IDP Objective and actions for User with Id '+ UserInfo.getUserId() ;
		system.debug(ErrContext + ex.getMessage());
		PF_Logger.log('IDP','ERROR',ex.getMessage(),ErrContext,ex.getStackTraceString(),'IDPWebService');
		wrap.errorMessage = IDP_AccessUtil.GENERAL_ERROR_MESSAGE;	
	}

	if( PF_Logger.logs.size()>0){
		PF_Logger.createLogs(PF_Logger.logs);
	}	
    return wrap;

}

// helper method to insert and update actions corresponding to an objective
global static List<IDPActionWrapper> insertAndUpdateActions(List<Object> actions,Id objId){

	Map<ID,Map<String,Object> > actionsMap = new Map<ID,Map<String,Object> >();
	List<IDP_Action__c> actionsToInsert = new List<IDP_Action__c>();
	List<IDP_Action__c> actionsToUpdate = new List<IDP_Action__c>();
	
	for(Object actObject:actions) {
		Map<String,Object> act = (Map<String,Object>)actObject;
		Id actId;
		if(act.get('recordId')!=null) {
            actId = (id)act.get('recordId');
			actionsMap.put(actId,act);
		}

		//new Action
		if(actId==null) {
            IDP_Action__c action = new IDP_Action__c();
			action.Action__c = (String)act.get('Action');
			action.Status__c = (String)act.get('Status');
            action.Support__c = (String)act.get('Comments');
            if(!String.isBlank((String)act.get('completionDate'))){
            action.Completed_Date__c = date.valueOf((String)act.get('completionDate'));
            } 
			action.IDP_Objective__c = objId;
			actionsToInsert.add(action);
		}
	}

	List<IDP_Action__c> queriedActs = [SELECT id, Action__c,Status__c,Completed_Date__c,Support__c FROM IDP_Action__C WHERE id=: actionsMap.keyset() AND isdeleted=false];
	List<IDPActionWrapper> actionsWrapper = new List<IDPActionWrapper>();
	set<Id> actionsIdsToUpdate= new set<Id>();
	/*Build Action updates List  if Action,Status or Completed Date is changed
	For others, directly build the wrapper from the queryresult.*/
	for(IDP_Action__c action:queriedActs) {

		if(action.Action__c!=(String)actionsMap.get(action.id).get('Action')) {
			action.Action__c=(String)actionsMap.get(action.id).get('Action');
            action.Synced__c  = false;
			actionsToUpdate.add(action);
			actionsIdsToUpdate.add(action.Id);
		}
		if(action.Status__c!=(String)actionsMap.get(action.id).get('Status')) {
			action.Status__c=(String)actionsMap.get(action.id).get('Status');
			if(!actionsToUpdate.contains(action)) {
                action.Synced__c  = false;
				actionsToUpdate.add(action);
				actionsIdsToUpdate.add(action.Id);
			}
		}
        if(action.Support__c!=(String)actionsMap.get(action.id).get('Comments')) {
			action.Support__c=(String)actionsMap.get(action.id).get('Comments');
			if(!actionsToUpdate.contains(action)) {
                action.Synced__c  = false;
				actionsToUpdate.add(action);
				actionsIdsToUpdate.add(action.Id);
			}
		}
        if(!String.isBlank((String)actionsMap.get(action.id).get('completionDate'))){
			if(action.Completed_Date__c!=date.valueOf((String)actionsMap.get(action.id).get('completionDate'))) {
				action.Completed_Date__c=Date.valueOf((String)actionsMap.get(action.id).get('completionDate'));
				if(!actionsToUpdate.contains(action)) {
                    action.Synced__c  = false;
					actionsToUpdate.add(action);
					actionsIdsToUpdate.add(action.Id);
				}
			}

        }
		//Actions without any updates,just build the wrapper from our query source.
		if(!actionsIdsToUpdate.contains(action.Id)){
			IDPActionWrapper actionWrapper = new IDPActionWrapper();
			actionWrapper.Action = action.Action__c;
			actionWrapper.Status = action.Status__c;
			actionWrapper.completionDate = action.Completed_Date__c;
            actionWrapper.Comments = action.Support__c;
			actionWrapper.recordId = action.Id;
			actionsWrapper.add(actionWrapper);
		}

	}
	
	if(!actionsToUpdate.isEmpty()) {
			update actionsToUpdate;
			for(IDP_Action__c action:actionsToUpdate){
				IDPActionWrapper actionWrapper = new IDPActionWrapper();
				actionWrapper.Action = action.Action__c;
				actionWrapper.Status = action.Status__c;
				actionWrapper.completionDate = action.Completed_Date__c;
                actionWrapper.Comments = action.Support__c;
				actionWrapper.recordId = action.Id;
				actionsWrapper.add(actionWrapper);
			}  

    }
	if(!actionsToInsert.isEmpty()) {
		insert actionsToInsert;
		for(IDP_Action__c action:actionsToInsert){
			IDPActionWrapper actionWrapper = new IDPActionWrapper();
			actionWrapper.Action = action.Action__c;
			actionWrapper.Status = action.Status__c;
			actionWrapper.completionDate = action.Completed_Date__c;
            actionWrapper.Comments = action.Support__c;
			actionWrapper.recordId = action.Id;
			actionsWrapper.add(actionWrapper);
		} 
    }
    return actionsWrapper;

}

global class IDPWrapper {
	Id recordId;
	String keyStrengths;
	String careerInterest;
	List<IDPObjectiveWrapper> objectives;
	DateTime lastModifiedDate;
	String errorMessage;
}
global class IDPObjectiveWrapper {
	Id recordId;
	String objectiveName;
	List<IDPActionWrapper> actions;
	String errorMessage;
	DateTime objLastModifiedDate;
}
global class IDPActionWrapper {
	Id recordId;
	String Action;
	String Status;
    String Comments;
	Date completionDate;
}
    
}