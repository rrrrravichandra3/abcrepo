/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 */

 
public with sharing class  V2MOMDetailController {
      
    V2MOM__c v2mom;
    public List<Attachment> attach{get;set;}
    public List<MyCarrerPlan__c> myc{get;set;}
    private String v2momSharing;
    List<ProcessInstanceCustom> processInstance = new List<ProcessInstanceCustom>();
    Id processInstanceId;   
    private Boolean isEditMode = false;
    User currentUser;
   	User v2momOwner;
   	User manager;
   	String msgError = '';
   	Boolean showError;
   	Id v2momId;
   	String pageType;
   	String errName;
   	String errEffDate;
   	String errVision;  
   	Boolean showErrorName;
   	Boolean showErrorEffDate;
   	Boolean showErrorVision;
   	public boolean lock{get;set;}
   	String methodsToPrioritize = '';
   	String valuesToPrioritize = '';
   	String obstaclesToPrioritize = '';
   	String metricsToPrioritize = '';
   	String methodsColor = '';
   	Id idPerformanceReview;
   	String xml;
   	String recordType;
   	List<SelectOption> optionsV2MOM = new List<SelectOption>();
   	
    public class CustomException extends Exception {} // This needs to be refactored into external class as soon
   	  
    public V2MOMDetailController (ApexPages.StandardController stdController)
	{   		
       			v2momId = System.currentPageReference().getParameters().get('id');
       			myc= [select id, name, createdDate, LastModifiedBy.Name, LastModifiedDate, createdById, v2mom__r.Owner.name from MyCarrerPlan__c where v2mom__c=:v2momID order by createdDate desc limit 500];
       			attach = [select 	id, 
							name, 
							CreatedDate,
							Owner.name,
							LastModifiedBy.Name,
							LastModifiedDate, 
							CreatedByID 
							from Attachment 
							where parentID =: v2momId order by Attachment.CreatedDate desc limit 500];
       			pageType = System.currentPageReference().getParameters().get('type');
       			idPerformanceReview = System.currentPageReference().getParameters().get('from');
       	
		        currentUser = [Select Id, Name, Profile.Name, PCOMM__c From User Where id =: userInfo.getUserId()];
		        List<RecordType> recordTypes = [Select Id, Name, r.SobjectType From RecordType r Where SobjectType = 'V2MOM__c' ];
		        Map<Id, RecordType> recordTypesMap = new Map<Id, RecordType>();
		        List<V2MOM__c> v2moms;
		        for (RecordType rt : recordTypes)
		        {
		        	recordTypesMap.put(rt.Id, rt);
		        }
		        
	
       			if (v2momId != null)
       			{
		        	 v2moms = [select name, Share_With__c , status__c, v2mom_Type__c, Effective_Date__c, 
		                    Owner.Name, CreatedBy.Name, CreatedById, LastModifiedBy.Name, CreatedDate,LastModifiedDate,
		                     locked__c , IsLocked, Date_Approved__c, Date_Submitted__c ,  Vision__c, RecordType.Id, RecordType.Name,
		                     (Select Id, Status,CreatedBy.Name From ProcessInstances order by CreatedDate DESC),
		                     
		                     (Select Id, ProcessInstanceId, StepStatus, CreatedDate, Comments, CreatedBy.Name, OriginalActor.Name, Actor.Name, Actor.Id From ProcessSteps 
		                                          order by StepStatus)
		                                        
		                      from V2MOM__c v where id =: v2momId
		                      
		                      
		                      
		                      ];
		       
		       
       			}
       			else
       			{
       				v2moms = new List<V2MOM__c>();
       			}

		        //It means that current logged user can't access this v2mom due to sharing rules
		        if (v2moms.size() == 0 && v2momId != null)
		        {
		        	 	
		        }
		        else
		        {
		        	if (v2moms.size() == 0)
		        	{
		        		v2mom = new V2MOM__c();	
		        	}
		        	else
		        	{
		        		if (currentUser.Profile.id != PerformanceAccessUtil.getSystem_Administrator_Id() && currentUser.Profile.Name!='systemadministrator')
		        		{
		        			v2mom = v2moms[0];
		        			
		        			if (v2mom.OwnerId != currentUser.Id)
		        			{
		        				v2momOwner = [Select Id, Profile.Name, Manager__c, ReviewManager__c, PCOMM__c from User where id =: v2mom.OwnerId ];
		        				
		        				if (v2momOwner.Manager__c != null)
		        				{
		        					manager = [Select Id, Profile.Name, Manager__c, ReviewManager__c from User where id =: v2mom.OwnerId ];
		        				}
		        				
		        				if (pageType != null )
		        				{
		        					 
		        				}
		        			}
		        		}
		        		else
		        		{
			        		v2mom = v2moms[0];
		        		}
		        	}
		        	
		        	v2mom.RecordType = recordTypesMap.get(v2mom.RecordType.Id);
		        }
		        
		    
		        if (v2moms.size() != 0)
		        {
		       		 v2momOwner = [Select Id, Profile.Name, Manager__c, ReviewManager__c, PCOMM__c from User where id =: v2mom.OwnerId ]; 	
		        }
		        else
		        {
		        	v2momOwner = new User();
		        }
		                
		        
		        if (v2mom != null)
		        {
		        
		        for (ProcessInstance pri : v2mom.ProcessInstances)
		        {
		            List<ProcessInstanceHistory> processInstanceHistory = new List<ProcessInstanceHistory>();
		        
		            ProcessInstanceCustom pic;
		            List<ProcessInstanceHistoryCustom> cphil = new List<ProcessInstanceHistoryCustom>() ;
		            ProcessInstanceHistoryCustom cphi;
		            
		            for (ProcessInstanceHistory prih : v2mom.ProcessSteps)
		            {   
		                
		                if (prih.StepStatus == 'Pending')
		                {
		                	processInstanceId = prih.ProcessInstanceId;
		                }
		                
		              
		                
		                if (prih.ProcessInstanceId == pri.Id)
		                {
		                    cphi = new ProcessInstanceHistoryCustom(prih, currentUser);
		                    cphil.add(cphi);
		                }
		                
		            }
		    
		            pic = new ProcessInstanceCustom(pri,cphil);
		            processInstance.add(pic);       
			        }
		        }
		       
		       	 if (v2moms.size() != 0)
		       	 {  
		       	 	xml = New_XML_Controller.generateXMLForV2MOM(v2momId);
		       	 }
		       	 
		       
	 
   	 		if (v2mom != null)
   	 		{
   	 			if (v2mom.RecordType.Name != null)
   	 			{
		   	 		if(v2mom.RecordType.Name == 'Scorecard V2MOM')
			   	 	{ 
			   	 		
			   	 		optionsV2MOM.add(new SelectOption('Individual Q1/Q2',Label.IndividualQ1_Q2V2MOMType));
			   	 		optionsV2MOM.add(new SelectOption('Individual Q3/Q4',Label.IndividualQ3_Q4V2MOMType));
			   	 		optionsV2MOM.add(new SelectOption('Department',Label.Department_label));
			   	 		optionsV2MOM.add(new SelectOption('Organization',Label.OrganizationV2MOMType));
			   	 		optionsV2MOM.add(new SelectOption('Onboarding',Label.OnBoarding_label));
			   	 		optionsV2MOM.add(new SelectOption('Year End Short','Year End Short'));
   	 					optionsV2MOM.add(new SelectOption('Sales','Sales'));
			   	 	}
			   	 	else
			   	 	{
			   	 		
			   	 		optionsV2MOM.add(new SelectOption('Individual',Label.IndividualV2MOMType));
			   	 		optionsV2MOM.add(new SelectOption('Department',Label.Department_label));
			   	 		optionsV2MOM.add(new SelectOption('Organization',Label.OrganizationV2MOMType));
			   	 		optionsV2MOM.add(new SelectOption('Onboarding',Label.OnBoarding_label));
			   	 		optionsV2MOM.add(new SelectOption('Year End Short','Year End Short'));
   	 					optionsV2MOM.add(new SelectOption('Sales','Sales'));
			   	 	}
		 
					if (V2MOM.V2MOM_Type__c == 'Ad Hoc')
					{
						optionsV2MOM.add(new SelectOption('Ad Hoc',Label.MyTeamController_AdHocType));
					}
   	 			}
   	 			else
   	 			{
   	 				if (currentUser.Profile.ID == PerformanceAccessUtil.getSystem_Administrator_Id() || currentUser.Profile.Name=='systemadministrator')
	   	 			{
	   	 				
		   	 			String recordTypeId = System.currentPageReference().getParameters().get('RecordType');
		   	 			RecordType recordTypeNewV2MOM = null;
		   	 			try{
		   	 				recordTypeNewV2MOM = [select Id , Name From RecordType Where id =: recordTypeId];
		   	 				
		   	 			}catch(Exception e){
		   	 				
		   	 				System.debug('Exception: ' + e.getMessage());
		   	 			}
		   	 			if(recordTypeNewV2MOM != null){
		   	 					if (recordTypeNewV2MOM.Name == 'Scorecard V2MOM')
		   	 					{
		   	 						System.debug('paso10');
		   	 						optionsV2MOM.add(new SelectOption('Individual Q1/Q2',Label.IndividualQ1_Q2V2MOMType));
				   	 				optionsV2MOM.add(new SelectOption('Individual Q3/Q4',Label.IndividualQ3_Q4V2MOMType));
				   	 				optionsV2MOM.add(new SelectOption('Department',Label.Department_label));
				   	 				optionsV2MOM.add(new SelectOption('Organization',Label.OrganizationV2MOMType));
				   	 				optionsV2MOM.add(new SelectOption('Onboarding',Label.OnBoarding_label));
				   	 				optionsV2MOM.add(new SelectOption('Year End Short','Year End Short'));
   	 								optionsV2MOM.add(new SelectOption('Sales','Sales'));
		   	 					}
		   	 						
		   	 			}else{
		   	 						optionsV2MOM.add(new SelectOption('Individual',Label.IndividualV2MOMType));
				   	 				optionsV2MOM.add(new SelectOption('Department',Label.Department_label));
				   	 				optionsV2MOM.add(new SelectOption('Organization',Label.OrganizationV2MOMType));
				   	 				optionsV2MOM.add(new SelectOption('Onboarding',Label.OnBoarding_label));
				   	 				optionsV2MOM.add(new SelectOption('Year End Short','Year End Short'));
   	 								optionsV2MOM.add(new SelectOption('Sales','Sales'));
		   	 			}	
		   	 			
		   	 			
		   	 			
	   	 			}
	   	 			else
	   	 			{
	   	 				
	   	 				if(currentUser.Profile.Name == Label.Profile_SupportManager || currentUser.Profile.Name == Label.Profile_SupportEmployee || currentUser.Profile.Name == Label.Profile_EducationManager  || currentUser.Profile.Name == Label.Profile_EducationEmployee || currentUser.Profile.Name == Label.Profile_CSMEmployee ||  currentUser.Profile.Name == Label.Profile_CSMManager)
				   	 	{
				   	 		System.debug('paso12');
				   	 		optionsV2MOM.add(new SelectOption('Individual Q1/Q2',Label.IndividualQ1_Q2V2MOMType));
				   	 		optionsV2MOM.add(new SelectOption('Individual Q3/Q4',Label.IndividualQ3_Q4V2MOMType));
				   	 		optionsV2MOM.add(new SelectOption('Department',Label.Department_label));
				   	 		optionsV2MOM.add(new SelectOption('Organization',Label.OrganizationV2MOMType));
				   	 		optionsV2MOM.add(new SelectOption('Onboarding',Label.OnBoarding_label));
				   	 		optionsV2MOM.add(new SelectOption('Year End Short','Year End Short'));
   	 						optionsV2MOM.add(new SelectOption('Sales','Sales'));
				   	 	}
				   	 	else
				   	 	{
				   	 		
				   	 		optionsV2MOM.add(new SelectOption('Individual',Label.IndividualV2MOMType));
				   	 		optionsV2MOM.add(new SelectOption('Department',Label.Department_label));
				   	 		optionsV2MOM.add(new SelectOption('Organization',Label.OrganizationV2MOMType));
				   	 		optionsV2MOM.add(new SelectOption('Onboarding',Label.OnBoarding_label));
				   	 		optionsV2MOM.add(new SelectOption('Year End Short','Year End Short'));
   	 						optionsV2MOM.add(new SelectOption('Sales','Sales'));
				   	 	}
				
						if (v2mom != null)
						{
							if (V2MOM.V2MOM_Type__c == 'Ad Hoc')
							{
								optionsV2MOM.add(new SelectOption('Ad Hoc',Label.MyTeamController_AdHocType));
							}
						}
	   	 			}
   	 			}
   	 		}
   	 		else
   	 		{
   	 			
   	 			if (currentUser.Profile.ID == PerformanceAccessUtil.getSystem_Administrator_Id() || currentUser.Profile.Name=='systemadministrator')
   	 			{
	   	 			String recordTypeId = System.currentPageReference().getParameters().get('RecordType');
	   	 			RecordType recordTypeNewV2MOM = null;
	   	 			try{
	   	 				recordTypeNewV2MOM = [select Id , Name From RecordType Where id =: recordTypeId];	
	   	 			}catch(Exception e){
	   	 				System.debug('Exception: ' + e.getMessage());
	   	 			}
	   	 			
	   	 		
	   	 			if (recordTypeNewV2MOM != null){
	   	 				if (recordTypeNewV2MOM.Name == 'Scorecard V2MOM')
	   	 				{
	   	 					optionsV2MOM.add(new SelectOption('Individual Q1/Q2',Label.IndividualQ1_Q2V2MOMType));
			   	 			optionsV2MOM.add(new SelectOption('Individual Q3/Q4',Label.IndividualQ3_Q4V2MOMType));
			   	 			optionsV2MOM.add(new SelectOption('Department',Label.Department_label));
			   	 			optionsV2MOM.add(new SelectOption('Organization',Label.OrganizationV2MOMType));
			   	 			optionsV2MOM.add(new SelectOption('Onboarding',Label.OnBoarding_label));
			   	 			optionsV2MOM.add(new SelectOption('Year End Short','Year End Short'));
   	 						optionsV2MOM.add(new SelectOption('Sales','Sales'));
	   	 				}
	   	 					
	   	 			}else{
	   	 					optionsV2MOM.add(new SelectOption('Year End Short','Year End Short'));
   	 						optionsV2MOM.add(new SelectOption('Sales','Sales'));
			   	 			optionsV2MOM.add(new SelectOption('Individual',Label.IndividualV2MOMType));
			   	 			optionsV2MOM.add(new SelectOption('Department',Label.Department_label));
			   	 			optionsV2MOM.add(new SelectOption('Organization',Label.OrganizationV2MOMType));
			   	 			optionsV2MOM.add(new SelectOption('Onboarding',Label.OnBoarding_label));
	   	 			}
	   	 			
   	 			}
   	 			else
   	 			{
   	 				
   	 				if(currentUser.Profile.Name == Label.Profile_SupportManager || currentUser.Profile.Name == Label.Profile_SupportEmployee || currentUser.Profile.Name == Label.Profile_EducationManager  || currentUser.Profile.Name == Label.Profile_EducationEmployee || currentUser.Profile.Name == Label.Profile_CSMEmployee ||  currentUser.Profile.Name == Label.Profile_CSMManager)
			   	 	{
			   	 	
			   	 		optionsV2MOM.add(new SelectOption('Individual Q1/Q2',Label.IndividualQ1_Q2V2MOMType));
			   	 		optionsV2MOM.add(new SelectOption('Individual Q3/Q4',Label.IndividualQ3_Q4V2MOMType));
			   	 		optionsV2MOM.add(new SelectOption('Department',Label.Department_label));
			   	 		optionsV2MOM.add(new SelectOption('Organization',Label.OrganizationV2MOMType));
			   	 		optionsV2MOM.add(new SelectOption('Onboarding',Label.OnBoarding_label));
			   	 		optionsV2MOM.add(new SelectOption('Year End Short','Year End Short'));
   	 					optionsV2MOM.add(new SelectOption('Sales','Sales'));
			   	 	}
			   	 	else
			   	 	{
			   	 	
			   	 		optionsV2MOM.add(new SelectOption('Year End Short','Year End Short'));
   	 					optionsV2MOM.add(new SelectOption('Sales','Sales'));
			   	 		optionsV2MOM.add(new SelectOption('Individual',Label.IndividualV2MOMType));
			   	 		optionsV2MOM.add(new SelectOption('Department',Label.Department_label));
			   	 		optionsV2MOM.add(new SelectOption('Organization',Label.OrganizationV2MOMType));
			   	 		optionsV2MOM.add(new SelectOption('Onboarding',Label.OnBoarding_label));
			   	 		
			   	 	}
			
					if (v2mom != null)
					{
				
					if (V2MOM.V2MOM_Type__c == 'Ad Hoc')
					{
						optionsV2MOM.add(new SelectOption('Ad Hoc',Label.MyTeamController_AdHocType));
						}
					}
   	 			}
   	 		}
   	 		
   	 		
    }
    
    public PageReference reassignV2MOM(){
    	String url = '/ReassignV2MOMApprove?id=' + V2MOM.Id + '&from=' + getWorkItemId();
    	System.Pagereference reassign = new System.Pagereference(url);
  		reassign.setRedirect(true);
  		return reassign; 
    }
    
    /*public void setLock(boolean value){
       	lock = value;
    }*/
    public boolean getHasAttachments(){
		return (attach.size()>0&&attach!=null);
	}
	public string getAttachmentID(){
		String result;
		if(getHasAttachments()){
			result= attach[0].Id;
		}
		return result;
	}
    
    public PageReference hasRigth()
    {
    	
    	PageReference pageRef = Page.errorMessage;
    	
    	String v2momId = System.currentPageReference().getParameters().get('id');
   		pageType = System.currentPageReference().getParameters().get('type');
   		idPerformanceReview = System.currentPageReference().getParameters().get('from');
   		/*List<ProcessInstanceWorkitem> isApproval = new List<ProcessInstanceWorkitem>();
   		try{
   			isApproval = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.ActorId, p.OriginalActorId 
   														From ProcessInstanceWorkitem p 
   														Where p.ProcessInstance.Status =: 'Pending' And p.ActorId =: userInfo.getUserId() 
   														And p.ProcessInstance.TargetObjectId =: v2momId];	
   		}catch(Exception e){
   			System.debug('Error: ' + e.getMessage());
   		}
   		
   		if ( isApproval.size() > 0 ){
   			String originalActorId = isApproval[0].OriginalActorId;
   			User originalActor = [Select Id, Name From User Where Id =: originalActorId];
   			
   			
   				V2MOM__Share newVShare = new V2MOM__Share();
   				newVShare.ParentId = v2momId;
   				newVShare.UserOrGroupId = UserInfo.getUserId();
   				newVShare.AccessLevel = 'Edit';
   				upsert newVShare;	
   			
   			 
   		}*/
   		
       	List<V2MOM__c> v2moms;
   			if (v2momId != null)
   			{
	        	 v2moms = [select name, Share_With__c , status__c, v2mom_Type__c, Effective_Date__c, 
	                    Owner.Name, CreatedBy.Name, CreatedById, LastModifiedBy.Name, CreatedDate,LastModifiedDate,
	                     locked__c , IsLocked, Date_Approved__c, Date_Submitted__c ,  Vision__c, RecordType.Id, RecordType.Name,
	                     (Select Id, Status,CreatedBy.Name From ProcessInstances order by CreatedDate DESC),
	                     (Select Id, ProcessInstanceId, StepStatus, CreatedDate, Comments, CreatedBy.Name, OriginalActor.Name, Actor.Name, Actor.Id From ProcessSteps 
	                                          order by StepStatus)
	                      from V2MOM__c v where id =: v2momId
	                      ];
   			}
   			else
   			{
   				v2moms = new List<V2MOM__c>();
   			}
		        //It means that current logged user can't access this v2mom due to sharing rules
		        if (v2moms.size() == 0 && v2momId != null)
		        {
		        	if (pageType != null)
		        	{
		        		pageRef.getParameters().put('type', System.currentPageReference().getParameters().get('type'));
		        	}
		        	
		        	return pageRef; 	
		        }
		        else
		        {
		        	if (v2moms.size() == 0)
		        	{
		        		v2mom = new V2MOM__c();	
		        	}
		        	else
		        	{
		        		if (currentUser.Profile.id != PerformanceAccessUtil.getSystem_Administrator_Id() && currentUser.Profile.Name!='systemadministrator')
		        		{
		        			v2mom = v2moms[0];
		        			if (v2mom.OwnerId != currentUser.Id)
		        			{
		        				v2momOwner = [Select Id, Profile.Name, Manager__c, ReviewManager__c, PCOMM__c from User where id =: v2mom.OwnerId ];
            														   
		        				if (v2momOwner.Manager__c != null)
		        				{
		        					manager = [Select Id, Profile.Name, Manager__c, ReviewManager__c from User where id =: v2mom.OwnerId ];
        } 
        
        if (pageType != null)
        {
        			if (pageType != null)
		        	{
		        		pageRef.getParameters().put('type', System.currentPageReference().getParameters().get('type'));
		        	}
		        	
		        	
		        					return pageRef; 
		        				}
		        			}
		        		}
		        		else
        	{
			        		v2mom = v2moms[0];
        	}
        }   	
		        }
		
    	return null;		
									   
    }
    
     public PageReference hasRigthEdit()
    {
    	PageReference pageRef = Page.errorMessage;
    	
    	Id v2momId = System.currentPageReference().getParameters().get('id');
   		pageType = System.currentPageReference().getParameters().get('type');
   		idPerformanceReview = System.currentPageReference().getParameters().get('from');
       	List<V2MOM__c> v2moms;
   			if (v2momId != null && v2momId!='')
   			{
	        	 v2moms = [select name, Share_With__c , status__c, v2mom_Type__c, Effective_Date__c, 
	                    Owner.Name, CreatedBy.Name, CreatedById, LastModifiedBy.Name, CreatedDate,LastModifiedDate,
	                     locked__c , IsLocked, Date_Approved__c, Date_Submitted__c ,  Vision__c, RecordType.Id, RecordType.Name,
	                     (Select Id, Status,CreatedBy.Name From ProcessInstances order by CreatedDate DESC),
	                     (Select Id, ProcessInstanceId, StepStatus, CreatedDate, Comments, CreatedBy.Name, OriginalActor.Name, Actor.Name, Actor.Id From ProcessSteps 
	                                          order by StepStatus)
	                      from V2MOM__c v where id =: v2momId
	                      ];
   			}
   			else
   			{
   				v2moms = new List<V2MOM__c>();
   			}
		        //It means that current logged user can't access this v2mom due to sharing rules
		        if (v2moms.size() == 0 && v2momId != null)
		        {
		        	if (pageType != null)
		        	{
		        		pageRef.getParameters().put('type', System.currentPageReference().getParameters().get('type'));
		        	}
		        	
		        	return pageRef; 	
		        }
		        else
		        {
		        	if (v2moms.size() == 0)
		        	{
		        		v2mom = new V2MOM__c();	
		        	}
		        	else
		        	{
		        		if (currentUser.Profile.id != PerformanceAccessUtil.getSystem_Administrator_Id() && currentUser.Profile.Name!='systemadministrator')
		        		{
		        			v2mom = v2moms[0];
		        			
		        			// Redirect to errorMessage Page
		        			if(v2mom.Locked__c){
		        				return new PageReference('/apex/errorMessage');
		        			}
		        			
		        			if (v2mom.OwnerId != currentUser.Id)
		        			{
		        				v2momOwner = [Select Id, Profile.Name, Manager__c, ReviewManager__c, PCOMM__c from User where id =: v2mom.OwnerId ];
            														   
		        				if (v2momOwner.Manager__c != null)
		        				{
		        					manager = [Select Id, Profile.Name, Manager__c, ReviewManager__c from User where id =: v2mom.OwnerId ];
        } 
        
        if (pageType != null)
        {
        			if (pageType != null)
		        	{
		        		pageRef.getParameters().put('type', System.currentPageReference().getParameters().get('type'));
		        	}
		        	
		        	
		        					return pageRef; 
		        				}
		        			}
		        		}
		        		else
        	{
			        		v2mom = v2moms[0];
        	}
        }   	
		        }
		
    	if (currentUser.Id != V2MOM.OwnerId && (currentUser.Profile.id != PerformanceAccessUtil.getSystem_Administrator_Id() && currentUser.Profile.Name!='systemadministrator')){return new PageReference('/apex/errorMessage');}	
		return null;		
									   
    }
    
    public Boolean getHasEditRight()
    {
    	if (currentUser.Profile.id == PerformanceAccessUtil.getSystem_Administrator_Id() || currentUser.Profile.Name=='systemadministrator') return true;
    	if (currentUser.Id == V2MOM.OwnerId) return true;
    	return false;	
    }
    
    public void setRecordType(String value)
    {
    	recordType = value;
    }
    
    public String getRecordType()
    {
    	return recordType;
    }
    
     public String getRecordTypeName()
    {
    	Id idRecrodType = System.currentPageReference().getParameters().get('RecordType');
    	
    	try{
    		RecordType rt =  [Select Id, Name from RecordType Where Id =: idRecrodType];
    		return rt.Name; 	
    	}catch(Exception e){
    		System.debug(e.getMessage());
    	}
    	
    	return null;
    }
    
    public List<SelectOption> getV2MOMRecordTypes()
    {
    	List<RecordType> recordTypes = [Select Id, Name, r.SobjectType From RecordType r Where SobjectType = 'V2MOM__c' ];
		List<SelectOption> options = new List<SelectOption>();
		 
		for (RecordType rt : recordTypes)
		{
			options.add(new SelectOption(rt.Id, rt.Name));	
		}
		
		return options;
    }
    
    public User getCurrentUser()
    {
    	return currentUser;
    }
    
    public String getV2MOMName()
    {
    	return v2mom.Name;
    }
    public void DoNothing()
    {
    	
    }
    //presentation
    
    public String getPage()
    {
    	if ( System.currentPageReference().getParameters().get('page') != null)
    	{
    		return 'step1';
    	}	
    	
    	return '';
    }
    
    public String getXml(){
       	
    	return xml;	
    }
    
    public String getV2MOMOwnerName()
    {
    	return currentUser.Name;	
    } 
    
    public Boolean getIsFromPR()
    {
    	if (idPerformanceReview != null)
    	{
    		return true;
    	}
    	
    	return false;
    }
    
    public Id getIdPerformanceReview()
    {
    	return idPerformanceReview;
    }
    public Boolean getIsPendingForApproval()
    {
    	return (v2mom.Status__c == 'Pending Approval');
    }
    
    public String getMethodsToPrioritize()
    {
    	return methodsToPrioritize;
    } 
    public void setMethodsToPrioritize(String value)
    {
    	methodsToPrioritize = value;
    }
    public String getValuesToPrioritize()
    {
    	return valuesToPrioritize ;
    } 
    public void setValuesToPrioritize(String value)
    {
    	valuesToPrioritize  = value;
    } 
    public String getObstaclesToPrioritize()
    {
    	return obstaclesToPrioritize; 	
    } 
    public void setObstaclesToPrioritize(String value)
    {
    	obstaclesToPrioritize = value;
    } 
    public String getMetricsToPrioritize()
    {
    	return metricsToPrioritize ;
    } 
    public void setMetricsToPrioritize(String value)
    {
    	metricsToPrioritize = value;
    } 
    
    public String getMethodsColor()
    {
    	return methodsColor;	
    }
    
    public void setMethodsColor(String value)
    {
    	methodsColor = value;
    }
    
    /**
	* Return true if the current user can add or remove users to v2mom's sharing.
	* @Return Boolean
	*/
    public Boolean getIsShowSharing()
    {
    	if (currentUser.Profile.Name == 'System Administrator'||currentUser.Profile.Name=='systemadministrator') return true;
    	if (currentUser.Id == v2momOwner.Id) return true;
    	if (currentUser.Id == v2momOwner.Manager__c) return true;
    	if (v2momOwner.Manager__c != null)
    		if (manager.Manager__c != null)
	    		if (currentUser.Id == manager.Manager__c) return true;
    	if (currentUser.Id == v2momOwner.PCOMM__c ) return true;
    	return false;
    }
   
    /**
    * Return Options with Effectives Dates
    */
    public List<SelectOption> getEffectiveDates() {
    	
    	List<String> allEffectiveDates = getAllEffectiveDates();
        List<SelectOption> options = new List<SelectOption>();
      	
      	for (String effectiveDate: allEffectiveDates)
      	{
      			options.add(new SelectOption(effectiveDate, effectiveDate));	
      	}
      
        return options;
    }
    
    /**
    * Return all effective Dates
    */
    public List<String> getAllEffectiveDates()
	{
		List<String> effectiveDates = new List<String>();
		Boolean showNext = false;
			
		Schema.DescribeFieldResult fieldResult = V2MOM__c.Effective_Date__c.getDescribe();

		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
	  	for( Schema.PicklistEntry f : ple)
	   	{
	     
	      	effectiveDates.add(f.getLabel());  
	   }   
	  
	  
	  return effectiveDates;
	}
	
	 /**
    * Return default effective Date
    */
	public String getDefaultEffectiveDate()
	{
		Schema.DescribeFieldResult fieldResult = V2MOM__c.Effective_Date__c.getDescribe();

		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
	  	for( Schema.PicklistEntry f : ple)
	   	{
	     	if (f.isDefaultValue())
	     	{
	      		return f.getLabel();
	     	}  
	   }   
	   
	   return '';
	}
   
    public String getThisYear(){
    	String currentYear = 'FY';
    	String year = String.valueOf(System.Now().Year());   	
    	currentYear += year.substring(year.length() - 2,year.length());   	
    	return currentYear;
    }
    
	// returns the v2mom Id , Not changing the String to ID. Dependency on TestClass
	public Id getV2momId(){
		return v2mom.Id;
	}
    
    public boolean getIsLocked(){
    	return v2mom.Locked__c;
    }
    
    public void Locked(boolean value){
    	v2mom.Locked__c = value;
    }
    public boolean getShowEditButton()
    { 
    		
    	if ( v2mom.locked__c == true && ! getIsSysAdminProfile()) return false;
    	return true;
    }
	
	public Boolean CheckPrivileges()
    {
         	//insertManagerIndividualSharing();
         	list<Id> group_member_list = new list<Id>();
             for (GroupMember share_group : [select Id
                                             from GroupMember
                                             where UserOrGroupId =:currentUser.Id]) {
                 group_member_list.add(share_group.Id);
             }

             V2MOM__Share[] shares = [select Id, AccessLevel
                                      from V2MOM__Share
                                      where ParentId =:  v2mom.Id
                                      and (UserOrGroupId = :currentUser.Id
                                              or UserOrGroupId in :group_member_list)];


               // if is System Administrator
             list<User> user = [Select u.ProfileId, u.Name
                                From User u
                                Where (u.Profile.id =: PerformanceAccessUtil.getSystem_Administrator_Id() or u.Profile.Name ='systemadministrator')
                                    And u.Id =:currentUser.Id];
             if (user.size() > 0)
                 return true;
            

             if (shares.size() > 0){
                 return true;
             }

          

             return false;
    }
	
	
	 
    public List<SelectOption> getV2MOMTypes() {	
				
	   	 	return optionsV2MOM;
    }
 
 	 public List<User> sortResult (List<User> result) {
         Integer n;
         Integer i;
         Integer j;
         n = result.size() - 1;   
         for (i = 1; i <= n; i++) {   
             for (j = n; j >= i ; j--) {
                 if (result.get(j).Name >= result.get(j - 1).Name) {
                     User tempLink;
                     tempLink = result.get(j - 1);
                     result.set(j - 1, result.get(j));
                     result.set(j, tempLink);    
                 }   
             }
         }
         
         n = result.size() - 1;  
         List<User> users = new List<User>();
         
         for (i = n; i >= 0; i--) {   
          	users.add(result.get(i));
         }
         
         return users;
     }
     
    public String getShareIndividuals()
    {
     	String individuals = '';
      	Boolean firstTime = true;
     
    	List<V2MOM__Share> v2momShare = [Select v.UserOrGroupId, v.ParentId From V2MOM__Share v Where ParentId =: v2mom.Id];
    	List<Id> userIds = new List<Id>();
    	List<User> users = new List<User>();
      	for (V2MOM__Share v2momS : v2momShare) {
          userIds.add(v2momS.UserOrGroupId);
      	}
        Map<Id, User> userMap = new Map<Id, User>([select id, Name, isActive from User where id in:userIds order by Name]);
        for (V2MOM__Share v2momS : v2momShare){
        	if (v2momS.UserOrGroupId != v2momOwner.Id) {
          		User currentUser = userMap.get(v2momS.UserOrGroupId);
          	
          		if (currentUser != null)
          		{
	                if (currentUser.isActive) {
	                	users.add(currentUser);
	              		
	          		}
        		}
     		}
  		}
  		
  		users = sortResult(users);
  		
  		
  		for (User currentUser : users)
  		{
  			if (firstTime)
      		{
              	individuals = currentUser.Name;
              	firstTime = false;
          	}
          	else
          	{
          		individuals = individuals + '; ' + currentUser.Name;
      		}
  		}
  		
        return individuals;
  	}
    
    
       public String getV2MOMShareWith()
       {
       	 	List<V2MOM__c>	v2moms = [select name, Share_With__c , status__c, v2mom_Type__c, Effective_Date__c, 
		                    Owner.Name, CreatedBy.Name, CreatedById, LastModifiedBy.Name, CreatedDate,LastModifiedDate,
		                     locked__c , IsLocked, Date_Approved__c, Date_Submitted__c ,  Vision__c, RecordType.Id, RecordType.Name,
		                     (Select Id, Status,CreatedBy.Name From ProcessInstances order by CreatedDate DESC),
		                     
		                     (Select Id, ProcessInstanceId, StepStatus, CreatedDate, Comments, CreatedBy.Name, OriginalActor.Name, Actor.Name, Actor.Id From ProcessSteps 
		                                          order by StepStatus)
		                                        
		                      from V2MOM__c where id =: v2mom.Id
		                      
		                      
		                      
		                      ];
		                      
		       
	      	List<RecordType> recordTypes = [Select Id, Name, r.SobjectType From RecordType r Where SobjectType = 'V2MOM__c' ];
	        Map<Id, RecordType> recordTypesMap = new Map<Id, RecordType>();
	        
	        for (RecordType rt : recordTypes)
	        {
	        	recordTypesMap.put(rt.Id, rt);
	        }
		        
		        
		     //It means that current logged user can't access this v2mom due to sharing rules
	        if (v2moms.size() == 0)
	        {
	        	 	
	        }
	        else
	        {
	        	v2mom = v2moms[0];
		        v2mom.RecordType = recordTypesMap.get(v2mom.RecordType.Id);
	        }	

			String shareWithSpaces = '';
			
			if (v2mom.Share_With__c != '' && v2mom.Share_With__c != null)
			{
				List<String> parseShareWith = v2mom.Share_With__c.split(';');
				
		        Boolean enter = false;
		        
		        for (String item:parseShareWith)
		        {
		        	if (! enter)
		        	{
		        		shareWithSpaces = item;
		        		enter = true;			
		        	}
		        	else
		        	{
		        		shareWithSpaces = shareWithSpaces + '; ' + item;
		        	}
		        
		        }
			}
			
		    return shareWithSpaces;
       }
    
      // Return true if the logged user is of System Administrator profile
    public boolean getIsSysAdminProfile(){
        if(currentUser.Profile.id == PerformanceAccessUtil.getSystem_Administrator_Id() || currentUser.Profile.Name == 'systemadministrator')
        {
            return true;
        }
        return false;
    }
    
    
     public boolean getIsManager()
    {
    	if (currentUser.Id == v2momOwner.ReviewManager__c)
    	{
    		return true;
    	} 
    	else
    	{
    		return false;	
    	}
    }
    
    public boolean getIsManagerOrSysAdmin()
    {
    	return getIsManager() || getIsSysAdminProfile();
    }
    
    public void EditMode()
    {
    	isEditMode = true;
    }
    
    public String getCreatedDate()
    { 
    	 return v2mom.CreatedDate.format();
    		
    }
    public String getModifiedDate()
    {
    	return v2mom.LastModifiedDate.format();	
    }
    
    public  Boolean getShowDelete()
    {
    	if (getIsSysAdminProfile()) return true;
    	
    	if (v2mom != null)
    	{
    	if (v2mom.OwnerId == userinfo.getUserId() && v2mom.locked__c == false && (v2mom.Status__c == 'Not Submitted' || v2mom.Status__c == 'Rejected')) 
    	{
			return true;    		
	    	}
    	}
    	
    	return false;
    }
    public String FormatDate(DateTime d)
    {
    	String formatMinute = '';
    	String formatMonth = '';
    	String formatDay = '';
    	
   
    	if (d.minute() < 10)
    	{
    		formatMinute = '0' + d.minute(); 
    	}
    	else
    	{
    		formatMinute = String.valueOf(d.minute());	
    	}
    	
   
    	
    	if (d.day() < 10)
    	{
    		formatDay = '0' + d.day(); 
    	}
    	else
    	{
    		formatDay = String.valueOf(d.day());	
    	}
    	
    	return  d.month() + '/' + formatDay +  '/' + d.year() + ' ' + d.hour() + ':' + formatMinute;
    }
   
    public PageReference SaveAndNew()
    {
            Schema.DescribeSObjectResult r = V2MOM__c.sObjectType.getDescribe();
            PageReference v2momAdd = new PageReference('/'+r.getKeyPrefix()+'/e');
            v2momAdd.setRedirect(true);
            return v2momAdd;

    }
    
    public PageReference SaveAndReturn()
    {
            PageReference v2momDetail = new PageReference('/'+v2mom.Id);
            v2momDetail.setRedirect(true);
            return v2momDetail;
    }       
        
     
    private void catchErrorsUpsertControl()
    {
        for (ApexPages.Message message : ApexPages.getMessages())
        {
            String fldLabel = message.getComponentLabel();
       
            if (fldLabel != null && fldLabel.equals(Label.V2MOM_label+' '+Label.Name_Label))
            {
                errName = message.getSummary();
                showErrorName = true;
            }
           
            if (fldLabel != null && fldLabel.equals(Label.Effective_Date_Label))
            {
               errEffDate = message.getSummary();
               showErrorEffDate = true;
            }
           
            if (fldLabel != null && fldLabel.equals(Label.Vision_label))
            {
                errVision = message.getSummary();
                showErrorVision = true;
            }
        }
    }
   
    public Boolean getShowErrorName()
    {
        return showErrorName;
    }
   
    public Boolean getShowErrorEffDate()
    {
        return showErrorEffDate;
    }
   
    public Boolean getShowErrorVision()
    {
        return showErrorVision;
    }
   
    public String getErrName()
    {
        return errName;
    }
   
    public String getErrEffDate()
    {
        return errEffDate;
    }
   
    public String getErrVision()
    {
        return errVision;
    }
    
    public Boolean getShowError()
    {
    	return showError;
    }
    public String getErrorText()
    {
    	return msgError;	
    }

	public PageReference Cancel()
    {
        PageReference v2momDetail = Page.V2MOMShowView;
        v2momDetail.getParameters().put('id', v2mom.id);
        v2momDetail.getParameters().put('from', idPerformanceReview);
        v2momDetail.setRedirect(true);
        return v2momDetail;	
    }    
  
    public Boolean getIsEditMode()
    {
    	return isEditMode;	
    }
    public String getWorkItemId()
    {
        List<ProcessInstanceWorkitem> pi = [Select Id From ProcessInstanceWorkitem  Where ProcessInstanceId =: processInstanceId];
        
        if (pi.size() > 0)
        {
            return pi[0].Id;    
        }
        
        return '';
    }
    
    public Id getV2MOMShortId()
    {
    	String idV2mom = v2mom.Id;
    	
    	idV2mom = idV2mom.substring(0, idV2mom.length() - 3);
    	
    	return idV2mom;
    }
    public Boolean getShowRecallButton()
    {
        
     
        
        for (ProcessInstanceCustom pi:processInstance)
        {
            for (ProcessInstanceHistoryCustom pih:pi.getProcessHistory())   
            {
                if (pih.getStatus() == 'Submitted' &&  (IsPending()))
                {
                    return true;    
                }   
            }
        
        }
        
        return false;
    }
    public Boolean getShowSubmitButton()
    {
    	
    	for (ProcessInstanceCustom pi:processInstance)
        {
            for (ProcessInstanceHistoryCustom pih:pi.getProcessHistory())   
            {
                if (pih.getStatus() == 'Pending')
                {
                    return true;    
                }   
            }
        
        }
        
        return false;
        
    }
    public Boolean IsRecalled()
    {
        for (ProcessInstanceCustom pi:processInstance)
        {
            for (ProcessInstanceHistoryCustom pih:pi.getProcessHistory())   
            {
                if (pih.getStatus() == 'Recalled')
                {
                    return true;    
                }   
            }
        
        }
        
        return false;
            
    }
    
    
    public Boolean IsPending()
    {
        for (ProcessInstanceCustom pi:processInstance)
        {
            for (ProcessInstanceHistoryCustom pih:pi.getProcessHistory())   
            {
                if (pih.getStatus() == 'Pending')
                {
                    return true;    
                }   
            }
        
        }
        
        return false;
            
    }
    
    public Boolean IsApproved()
    {
    	 for (ProcessInstanceCustom pi:processInstance)
        {
            for (ProcessInstanceHistoryCustom pih:pi.getProcessHistory())   
            {
                if (pih.getStatus() == 'Approved')
                {
                    return true;    
                }   
            }
        
        }
        
        return false;
            
    }
    
    public Boolean IsRejected()
    {
        for (ProcessInstanceCustom pi:processInstance)
        {
            for (ProcessInstanceHistoryCustom pih:pi.getProcessHistory())   
            {
                if (pih.getStatus() == 'Rejected')
                {
                    return true;    
                }   
            }
        
        }
        
        return false;
            
    }
    

    public Id getShortId()
    {
        String id = v2mom.Id;
        
        return id.substring(0,id.length() - 3);     
    }
    
    public String getRecallId()
    {
        for (ProcessInstanceCustom pi:processInstance)
        {
            for (ProcessInstanceHistoryCustom pih:pi.getProcessHistory())   
            {
                if (pih.getStatus() == 'Pending')
                {
                    return pih.getProcessInstanceHistory().Id;  
                }   
            }
        
        }
        
        return '';  
    }
    public Boolean getHasBeenSubmited()
    {
        if (processInstance.size() == 0)
        {
            return false;   
        }
        return true;
    }
    
    public V2MOM__c getV2MOM()
    {
     	return v2mom;
    }
    
    public void dummy(){
    	
    }
    
    public List<ProcessInstanceCustom> getProcessInstanceCustom()
    {
        return processInstance;
    }
    
    
   

    public class ProcessInstanceCustom
    {
        
        private String status = '';
        List<ProcessInstanceHistoryCustom> processInstanceHistory;
        ProcessInstance processInstance;
        
        public ProcessInstanceCustom(ProcessInstance pi, List<ProcessInstanceHistoryCustom> pih )
        {
            processInstance = pi;
            processInstanceHistory = pih;
        }   
        
        public String getStatus()
        {
            return status;  
        }
        
        public List<ProcessInstanceHistoryCustom> getProcessHistory()
        {
            return  processInstanceHistory;
        }
        
        public ProcessInstance getProcessInstance()
        {
            return processInstance; 
        }
        public void setStatus(String s)
        {
            status = s;
        }
    }
    
    public class ProcessInstanceHistoryCustom
    {
        private ProcessInstanceHistory processInstanceHistory;
        private User currentUser; 
        
        public  ProcessInstanceHistoryCustom(ProcessInstanceHistory prh, User cu)
        {
            processInstanceHistory = prh;
            currentUser = cu;
        }
        
        
        public ProcessInstanceHistory getProcessInstanceHistory()
        {
            return  processInstanceHistory;
        }
        
        public Boolean getIsSubmitedStatus()
        {
            if (getStatus() == Label.Submitted_label)
            {
                return true;    
            }
            return false;
        }
        public Boolean getIsRecalledStatus()
        {
            if (getStatus() == 'Recalled')
            {
                return true;    
            }
            return false;
            
        }
        public Boolean getIsPendingStatus()
        {
            if (processInstanceHistory.StepStatus == 'Pending')
            {
                return true;    
            }
            return false;
        }
        
	            // Return true if the logged user is of System Administrator profile
	    public boolean getIsSysAdminProfile(){
	        if(currentUser.Profile.id == PerformanceAccessUtil.getSystem_Administrator_Id() || currentUser.Profile.Name=='systemadministrator')
	        {
	            return true;
	        }
	        return false;
	    }
    
    	public Boolean getUserCanView()
    	{
    		if (getIsSysAdminProfile() && processInstanceHistory.StepStatus == 'Pending' )
    		{
    			return true;	
    		}
    		
    		if (processInstanceHistory.StepStatus == 'Pending' && processInstanceHistory.Actor.Id == currentUser.Id)
    		{
    			return true;	
    		}
    		return false;
    	}
    	
        public Boolean getIsApprovedStatus()
        {
            if (getStatus() == 'Approved')
            {
                return true;    
            }
            return false;
        }
        
        public Boolean getIsRejectedStatus()
        {
            if (getStatus() == 'Rejected')
            {
                return true;    
            }
            return false;
        }
        
        public String getStatus()
        {
            if (processInstanceHistory.StepStatus != 'Started')
            {
                if (processInstanceHistory.StepStatus == 'Removed')
                {
                    return  Label.Recalled_label;
                }
                
                return processInstanceHistory.StepStatus;
                
            }
            else
            {
                return Label.Submitted_label;  
            }
        }
        
        public String getCreatedDate()
        {
        	return processInstanceHistory.CreatedDate.format();
        }
        public String FormatDate(DateTime d)
	    {
	    	String formatMinute = '';
	    	String formatMonth = '';
	    	String formatDay = '';
	    	
	   
	    	if (d.minute() < 10)
	    	{
	    		formatMinute = '0' + d.minute(); 
	    	}
	    	else
	    	{
	    		formatMinute = String.valueOf(d.minute());	
	    	}
	    	
	   
	    	
	    	if (d.day() < 10)
	    	{
	    		formatDay = '0' + d.day(); 
	    	}
	    	else
	    	{
	    		formatDay = String.valueOf(d.day());	
	    	}
	    	
	    	return  d.month() + '/' + formatDay +  '/' + d.year() + ' ' + d.hour() + ':' + formatMinute;
	    }
    
    }
 
	
	public void returnNewV2MOMTypes()
	{
			optionsV2MOM = new List<SelectOption>();
	 
   	 		optionsV2MOM.add(new SelectOption('Individual',Label.IndividualV2MOMType));
   	 		optionsV2MOM.add(new SelectOption('Department',Label.Department_label));
   	 		optionsV2MOM.add(new SelectOption('Organization',Label.OrganizationV2MOMType));
   	 		optionsV2MOM.add(new SelectOption('Onboarding',Label.OnBoarding_label));
   	 		optionsV2MOM.add(new SelectOption('Year End Short','Year End Short'));
   	 		optionsV2MOM.add(new SelectOption('Sales','Sales'));
   	 		
   	 		if (v2mom.Id != null)
   	 		{
	   	 		if (V2MOM.V2MOM_Type__c == 'Ad Hoc')
				{
					optionsV2MOM.add(new SelectOption('Ad Hoc',Label.MyTeamController_AdHocType));
				}
   	 		}
	   	 		
	   	 	
	}
	
	public void returnNewV2MOMTypesScorecard()
	{
			optionsV2MOM = new List<SelectOption>();
				
			optionsV2MOM.add(new SelectOption('Individual Q1/Q2',Label.IndividualQ1_Q2V2MOMType));
   	 		optionsV2MOM.add(new SelectOption('Individual Q3/Q4',Label.IndividualQ3_Q4V2MOMType));
   	 		optionsV2MOM.add(new SelectOption('Department',Label.Department_label));
   	 		optionsV2MOM.add(new SelectOption('Organization',Label.OrganizationV2MOMType));
   	 		optionsV2MOM.add(new SelectOption('Onboarding',Label.OnBoarding_label));
   	 		optionsV2MOM.add(new SelectOption('Year End Short','Year End Short'));
   	 		optionsV2MOM.add(new SelectOption('Sales','Sales'));
   	 		if (v2mom.Id != null)
   	 		{
	   	 		if (V2MOM.V2MOM_Type__c == 'Ad Hoc')
				{
					optionsV2MOM.add(new SelectOption('Ad Hoc',Label.MyTeamController_AdHocType));
				}
   	 		}
	}	

	//creates new career plan object and redirects to edit page, or shows the created one.
	public pageReference careerPlan(){
		MyCarrerPlan__c plan;
		try{
			plan = [select id from myCarrerPlan__c where myCarrerPlan__c.v2mom__c=:v2mom.id order by createdDate desc][0];
			return new pageReference('/apex/myCareerPlan?id='+plan.id);
			}
			
		catch(exception e){	
			return new pageReference('/apex/myCareerPlan?id=' +'new'+'&v2mom='+v2mom.id);
		}
			
	}	
    
}