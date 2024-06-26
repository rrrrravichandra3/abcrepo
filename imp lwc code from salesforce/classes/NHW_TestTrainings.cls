@istest
public class NHW_TestTrainings {
        @testsetup
        public static void NHWconfigDataLoad(){
            list<NHW_Provisioning__c> NHWOrgs = Test.loadData(NHW_Provisioning__c.sObjectType, 'NHW_Orgs');
			system.assertEquals(NHWOrgs.size(),6, 'Expecting 6 NHW orgs'+NHWOrgs);	
        
            list<NHW_Provisioning__c> NHWRoles = Test.loadData(NHW_Provisioning__c.sObjectType, 'NHW_Roles');
			system.assertNotEquals(NHWRoles.size(),0, 'Expecting Roles');
			
	        list<NHW_Provisioning__c> NHWTraining = Test.loadData(NHW_Provisioning__c.sObjectType, 'NHW_Training');
			system.assertNotEquals(NHWTraining.size(),0, 'Expecting  NHWTraining');

             list<NHW_Provisioning_Default__c> NHWDefaults = Test.loadData(NHW_Provisioning_Default__c.sObjectType, 'NHW_Default');
			system.assertNotEquals(NHWDefaults.size(),0, 'Expecting NHW Defaults');           
        }


        /*Test if correct Bootcamp and BSF types corresponding to new hire Org/Role 
          are surfaced from org62  in page 3 of NHW
        */
        public static testmethod void  NHW_Validate_Bootcamp_And_BSF_Types(){

	       	NHW_TestFactory.populateOnBoardingSetting(); 
	         
	      	Newhirewizardcontroller NHWCtrllerInit = new Newhirewizardcontroller();
	        NHWCtrllerInit.newhirecase= new Case(RecordTypeId = NHW_Util.getnhwCaseRecordTypeId(),Origin='NHW');           
	        NHWCtrllerInit.newhirecase.Email_Address__c='testContact@salesforce.com';
	        NHWCtrllerInit.newhirecase.First_Name__c='Test';
	        NHWCtrllerInit.newhirecase.Last_Name__c='Contact';
               
            Test.startTest(); 
                Test.setMock(HttpCalloutMock.class, new NHW_MockCampaignResponseGenerator());
		        NHW_Org62Service.accessToken = 'testToken'; // hardcode some dummy auth Token; 
                NHWCtrllerInit.loadCampaignsAndContact();
            Test.stopTest();
   
			          
                system.assertEquals(NHWCtrllerInit.fullCampaignMap.size(),7,'Expecting 7 campaigns to be loaded');
      
                NHWCtrllerInit.newHireCase.NHW_Start_Date__c= system.today();      

                /* *Internal Bootcamp Campaign picklist Validation for Salesforce core BUs **/

                // **Specialized Trainings **
                // CSG - Internal CSG Bootcamp.
                // **BSF Trainings **               
                // CSG has BSF campaigns of  type sales 
                NHWCtrllerInit.newhirecase.NHW_Organization__c = 'CSG';
                NHWCtrllerInit.newhirecase.NHW_Role__c = 'CSG - CFL';

                NHWCtrllerInit.currentPageNumber=2;             
                NHWCtrllerInit.newHireCase.Laptop_Type__c='Macbook Air';  
                NHWCtrllerInit.newHireCase.Computer_Type__c='Linux';  
                NHWCtrllerInit.newHireCase.Floor_Location_Cube_Location__c='22';
                NHWCtrllerInit.newHireCase.office_city__c='Bellevue';
                NHWCtrllerInit.newHireCase.Desk_and_VoiceMail__c='Yes';
                NHWCtrllerInit.next();//go to  page 3   
                //Use the new config model
                NHWCtrllerInit.getTrainings();

                system.assertEquals(NHWCtrllerInit.traininglist.size() ,1,'Expecting only 1 Bootcamp for CSG Org.');
                system.assertEquals(NHWCtrllerInit.traininglist[0].name ,NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE,'Expecting CSG Bootcamp Type');

                NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(22));
                system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null,'Expecting Test CSG Campaign record to be picked ');

                NHWCtrllerInit.getBSF();
                system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,true),true,'Expecting  Sales BSF');

                //Old config model
                NHWCtrllerInit.fillCampaignList();
                NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(22));
                system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
                NHWCtrllerInit.BSFForBootcamp();
                system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,true),true,'Expecting  Sales BSF');

                // ** Specialized Trainings  - Sales Org **
                //  Sales - Solution Engineer Roles - Internal SE Bootcamp.
                //  Sales - Other Role - Internal Sales Bootcamp.
                // **BSF Trainings **               
                //  Sales has BSF campaigns of  type sales 

                NHWCtrllerInit.newhirecase.NHW_Organization__c = 'Sales';
                NHWCtrllerInit.newhirecase.NHW_Role__c = 'Other';

                //Use the new config model
                NHWCtrllerInit.currentPageNumber=2;             
                NHWCtrllerInit.next();
                NHWCtrllerInit.getTrainings();
                system.assertEquals(NHWCtrllerInit.traininglist.size() ,1,'Expecting only 1 Bootcamp Type for Sales Org.');
                system.assertEquals(NHWCtrllerInit.traininglist[0].name ,NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE,'Expecting Sales Bootcamp Type');               
                
                NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(22));
                system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
                NHWCtrllerInit.getBSF();
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,true),true,'Expecting  Sales BSF');

                //Old config model
                NHWCtrllerInit.fillCampaignList();
                NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(22));
                NHWCtrllerInit.BSFForBootcamp();
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,true),true,'Expecting  Sales BSF');

                NHWCtrllerInit.newhirecase.NHW_Role__c = 'Solution Engineer - EBU';
                //Use the new config model
                //Use the new config model
                NHWCtrllerInit.currentPageNumber=2;             
                NHWCtrllerInit.next();
                NHWCtrllerInit.getTrainings();
                system.assertEquals(NHWCtrllerInit.traininglist.size() ,1,'Expecting only 1 Bootcamp Type for Sales Org.');
                system.assertEquals(NHWCtrllerInit.traininglist[0].name ,NHW_Util.INTERNAL_TRAINING_SEBOOTCAMP_CAMPAIGN_TYPE,'Expecting SE Bootcamp Type');               
                
                NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SEBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(30));
                system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
                NHWCtrllerInit.getBSF();
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,true),true,'Expecting  Sales BSF');

                //Old config model
                NHWCtrllerInit.fillCampaignList();
                NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SEBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(30));
                NHWCtrllerInit.BSFForBootcamp();
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,true),true,'Expecting  Sales BSF');


                // **Specialized Trainings  - T&P Org**
                // T&P -  'T&P Bootcamp: Wk 1: All T&P New Hires' & 'T&P Bootcamp: Wk 2: Coding in the Cloud'.
                // **BSF Trainings **               
                // T&P has BSF campaigns of  type NON-Sales 

                NHWCtrllerInit.newhirecase.NHW_Organization__c = 'T&P';
                NHWCtrllerInit.newhirecase.NHW_Role__c = 'CCE';

                //Old config model               
                NHWCtrllerInit.fillCampaignList();
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,false),true,'Expecting Non Sales BSF');

                //Use the new config model
                NHWCtrllerInit.currentPageNumber=2;             
                NHWCtrllerInit.next();
                NHWCtrllerInit.getTrainings();
                system.assertEquals(NHWCtrllerInit.traininglist.size() ,2,'Expecting  2 Bootcamp Type for T&P Org.');
                system.assertEquals(NHWCtrllerInit.traininglist[0].name ,NHW_Util.INTERNAL_TRAINING_TPBOOTCAMP1_CAMPAIGN_TYPE,'Expecting T&P Bootcamp Type');               
                system.assertEquals(NHWCtrllerInit.traininglist[1].name ,NHW_Util.INTERNAL_TRAINING_TPBOOTCAMP2_CAMPAIGN_TYPE,'Expecting T&P Bootcamp Type');               
                
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,false),true,'Expecting Non Sales BSF');


                // **Specialized Trainings  - Sales Support Org**
                //  None .
                // **BSF Trainings **               
                // Sales Support has BSF campaigns of  type Sales 

                NHWCtrllerInit.newhirecase.NHW_Organization__c = 'Sales Support';
                NHWCtrllerInit.newhirecase.NHW_Role__c = 'Market Readiness';

                //Old config model               
                NHWCtrllerInit.fillCampaignList();
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,true),true,'Expecting  Sales BSF');

                //Use the new config model
                NHWCtrllerInit.currentPageNumber=2;             
                NHWCtrllerInit.next();
                NHWCtrllerInit.getTrainings();
                system.assertEquals(NHWCtrllerInit.traininglist.size() ,0,'Expecting No Specialized Training');         
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,true),true,'Expecting  Sales BSF');


                // **Specialized Trainings  - Other Org**
                //  None .
                // **BSF Trainings **               
                // Sales Support has BSF campaigns of  type  Non-Sales 

                NHWCtrllerInit.newhirecase.NHW_Organization__c = 'Other';
                NHWCtrllerInit.newhirecase.NHW_Role__c = 'XYZ';

                //Old config model               
                NHWCtrllerInit.fillCampaignList();
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,false),true,'Expecting  Non Sales BSF');


                //Use the new config model
                NHWCtrllerInit.currentPageNumber=2;             
                NHWCtrllerInit.next();
                NHWCtrllerInit.getTrainings();
                system.assertEquals(NHWCtrllerInit.traininglist.size() ,0,'Expecting No Specialized Training');         
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,false),true,'Expecting Non Sales BSF');


                /** Internal Bootcamp Campaign picklist Validation for Marketing Cloud BUs **/
                
                // ** Specialized Trainings **  
                // Role - Sales    - Internal Sales Campaign .                           
                // Role - Services - Internal CSG Campaign  .                          
                // ** BSF Trainings **                              
                //  Roles - Service and Sales have BSF sales campaigns.
                //  All others have BSF non-sales campaigns.

                NHWCtrllerInit.newhirecase.NHW_Organization__c = 'Marketing Cloud';

                NHWCtrllerInit.newhirecase.NHW_Role__c = 'Services';              
                NHWCtrllerInit.fillCampaignList();
                NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(22));
                system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
                NHWCtrllerInit.BSFForBootcamp();
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,true),true,'Expecting  Sales BSF');


                //Use the new config model
                NHWCtrllerInit.currentPageNumber=2;             
                NHWCtrllerInit.next();
                NHWCtrllerInit.getTrainings();
                system.assertEquals(NHWCtrllerInit.traininglist.size() ,1,'Expecting  1 Bootcamp Type for Marketing Cloud - Services.');
                system.assertEquals(NHWCtrllerInit.traininglist[0].name ,NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE,'Expecting Sales Bootcamp Type');               
  
                NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(22));
                system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
                NHWCtrllerInit.getBSF();
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,true),true,'Expecting  Sales BSF');

                NHWCtrllerInit.newhirecase.NHW_Role__c = 'Sales';
                NHWCtrllerInit.fillCampaignList();
                NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(22));
                system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
                NHWCtrllerInit.BSFForBootcamp();
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,true),true,'Expecting  Sales BSF');    

                //Use the new config model
                NHWCtrllerInit.currentPageNumber=2;             
                NHWCtrllerInit.next();
                NHWCtrllerInit.getTrainings();
                system.assertEquals(NHWCtrllerInit.traininglist.size() ,1,'Expecting  1 Bootcamp Type for Marketing Cloud - Sales.');
                system.assertEquals(NHWCtrllerInit.traininglist[0].name ,NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE,'Expecting CSG Bootcamp Type');               
  
                NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(22));
                system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
                NHWCtrllerInit.getBSF();
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,true),true,'Expecting  Sales BSF');  

                NHWCtrllerInit.newhirecase.NHW_Role__c = 'Support';
                NHWCtrllerInit.fillCampaignList();
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,false),true,'Expecting Non Sales BSF');       
                 
                //Use the new config model
                NHWCtrllerInit.currentPageNumber=2;             
                NHWCtrllerInit.next();
                NHWCtrllerInit.getTrainings();              
 				system.assertEquals(validateBSFPicklistVals(NHWCtrllerInit.NHOcampaignList,false),true,'Expecting Non Sales BSF');               
        
        }
        //Helper method for NHW_Validate_BSF_Types
        public static boolean validateBSFPicklistVals(List<SelectOption> NHOcampaignList,Boolean isSales){
                Boolean isValid = false;
                String ExpectedCampaignName = '';
                system.assertEquals(NHOcampaignList.size(),1,'BSF Autoselected');
                system.assertNotEquals(NHOcampaignList[0].getLabel(),'--Select--','having BSF nAME Valye');
                if(isSales){
                	ExpectedCampaignName = 'Becoming Salesforce'+'-'+system.today().month()+'-'+'Sales'; 
                }
                else{
                 	ExpectedCampaignName = 'Becoming Salesforce'+'-'+system.today().month(); 
                	
                }
				for(SelectOption option:NHOcampaignList){
					if(option.getLabel()!='--Select--'){
						system.assertEquals(option.getLabel(),ExpectedCampaignName,'Campaign of expected type not surfaced!');
						isValid = true;
						NHOcampaignList = new list<selectoption>();//Reset the picklist values for consequent validations.
					}
				} 
				
				return isValid;    	
        }
        /*Test if correct  BSF is populated based on CSG/Sales Bootcamp selected.
        */
        public static testmethod void  NHW_Test_BSFSelection_For_BootcampTypes_DrivingBSF(){
 	       	NHW_TestFactory.populateOnBoardingSetting(); 

 	       	
	         
	      	Newhirewizardcontroller NHWCtrllerInit = new Newhirewizardcontroller();
	        NHWCtrllerInit.newhirecase= new Case(RecordTypeId = NHW_Util.getnhwCaseRecordTypeId(),Origin='NHW');           
	        NHWCtrllerInit.newhirecase.Email_Address__c='testContact@salesforce.com';
	        NHWCtrllerInit.newhirecase.First_Name__c='Test';
	        NHWCtrllerInit.newhirecase.Last_Name__c='Contact';

            
            NHWCtrllerInit.newHireCase.NHW_Start_Date__c= system.today().adddays(1);          

            set<Date> CSGStartdates = new set<Date>{System.today().addMonths(1),System.today().adddays(3)};
 	       	set<Date> SalesStartdates = new set<Date>{System.today().addMonths(1),System.today().adddays(3)};
 	       	set<Date> BSFSalesStartdates = new set<Date>{System.today().addMonths(1).adddays(-1),System.today().adddays(2)};
 	       	set<Date> BSFNonSalestartdates = new set<Date>{System.today().addMonths(1).adddays(-1),System.today().adddays(2)};
                
           
            NHW_MockCampaignResponseGenerator NHWCustomMockObj = new NHW_MockCampaignResponseGenerator();
            
            NHWCustomMockObj.setCampaignDatesForCampaignType(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE,CSGStartdates);
            NHWCustomMockObj.setCampaignDatesForCampaignType(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE,SalesStartdates);
            NHWCustomMockObj.setCampaignDatesForCampaignType(NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE,BSFSalesStartdates);
            NHWCustomMockObj.setCampaignDatesForCampaignType(NHW_Util.INTERNAL_TRAINING_NONSALES_CAMPAIGN_TYPE,BSFNonSalestartdates);
			NHWCustomMockObj.generateCustomCampaigns = true;
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, NHWCustomMockObj);
	        NHW_Org62Service.accessToken = 'testToken'; // hardcode some dummy auth Token;  
            NHWCtrllerInit.loadCampaignsAndContact();	     
 			Test.stopTest();
            system.assertEquals(NHWCtrllerInit.fullCampaignMap.size(),8,'Expecting 8 campaigns to be loaded');
	           			          
    
            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'CSG';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'CSG - CFL';
            
            NHWCtrllerInit.currentPageNumber=2;             
            NHWCtrllerInit.newHireCase.Laptop_Type__c='Macbook Air';  
            NHWCtrllerInit.newHireCase.Computer_Type__c='Linux';  
            NHWCtrllerInit.newHireCase.Floor_Location_Cube_Location__c='22';
            NHWCtrllerInit.newHireCase.office_city__c='Bellevue';
            NHWCtrllerInit.newHireCase.Desk_and_VoiceMail__c='Yes';
            NHWCtrllerInit.next();//go to  page 3   

            NHWCtrllerInit.fillCampaignList();

            //Assert the NHO is disabled on page load as there is no selection
             system.assertEquals(NHWCtrllerInit.traininglist[0].selectedCampaign,null);
             system.assertEquals(NHWCtrllerInit.NHOdisabled,true);
            
           
            //Assert the CSGBootcamp campaign types are loaded.
            system.assertNotEquals(NHWCtrllerInit.traininglist.size(),0,'Expecting training list to be populated');
            system.assertEquals(NHWCtrllerInit.traininglist[0].name,NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE);
 
            //Select CSGBootcamp in this month and assert that the BSF the day before is autoselected.
            NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(3));
            system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
            NHWCtrllerInit.BSFForBootcamp();
            system.assertEquals(NHWCtrllerInit.NHOcampaignList[0].getValue(),NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE+'-'+system.today().adddays(2)));
            system.assertEquals(NHWCtrllerInit.NHOdisabled,false);
  
            //Change CSGBootcamp to prev month and assert that the BSF the day before is autoselected.
            NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().addmonths(1));
            system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
            NHWCtrllerInit.BSFForBootcamp();
            
            system.assertEquals(NHWCtrllerInit.NHOcampaignList[0].getValue(),NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE+'-'+System.today().addMonths(1).adddays(-1)));
            system.assertEquals(NHWCtrllerInit.NHOdisabled,false);


            //Use the new Model
             NHWCtrllerInit.currentPageNumber=2; 
             NHWCtrllerInit.next();            
             NHWCtrllerInit.getTrainings();
            
            //Assert the NHO is disabled on page load as there is no selection
             system.assertEquals(NHWCtrllerInit.traininglist[0].selectedCampaign,null);
             system.assertEquals(NHWCtrllerInit.NHOdisabled,true);
            
           
            //Assert the CSGBootcamp campaign types are loaded.
            system.assertNotEquals(NHWCtrllerInit.traininglist.size(),0,'Expecting training list to be populated');
            system.assertEquals(NHWCtrllerInit.traininglist[0].name,NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE);
 
            //Select CSGBootcamp in this month and assert that the BSF the day before is autoselected.
            NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(3));
            system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
            NHWCtrllerInit.getBSF();
            system.assertEquals(NHWCtrllerInit.NHOcampaignList[0].getValue(),NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE+'-'+system.today().adddays(2)));
            system.assertEquals(NHWCtrllerInit.NHOdisabled,false);
  
            //Change CSGBootcamp to prev month and assert that the BSF the day before is autoselected.
            NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().addmonths(1));
            system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
            NHWCtrllerInit.getBSF();
            
            system.assertEquals(NHWCtrllerInit.NHOcampaignList[0].getValue(),NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE+'-'+System.today().addMonths(1).adddays(-1)));
            system.assertEquals(NHWCtrllerInit.NHOdisabled,false);           
                

            //Assert if above validations hold good for Sales Bootcamp.
            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'Sales';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'AE - EBU'; 
            
            //OLD Config Model
            NHWCtrllerInit.fillCampaignList();
            
            system.assertNotEquals(NHWCtrllerInit.traininglist.size(),0,'Expecting training list to be populated');
            system.assertEquals(NHWCtrllerInit.traininglist[0].name,NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE);
            NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(3));
            system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
            NHWCtrllerInit.BSFForBootcamp();
            system.assertEquals(NHWCtrllerInit.NHOdisabled,false);            
            system.assertEquals(NHWCtrllerInit.NHOcampaignList[0].getValue(),NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE+'-'+system.today().adddays(2)));
            NHWCtrllerInit.next();//go to  page 3          

            //New Config Model
               NHWCtrllerInit.currentPageNumber=2; 
             NHWCtrllerInit.next();            
             NHWCtrllerInit.getTrainings();
            
            system.assertNotEquals(NHWCtrllerInit.traininglist.size(),0,'Expecting training list to be populated');
            system.assertEquals(NHWCtrllerInit.traininglist[0].name,NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE);
            NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(3));
            system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
            NHWCtrllerInit.getBSF();
            system.assertEquals(NHWCtrllerInit.NHOdisabled,false);            
            system.assertEquals(NHWCtrllerInit.NHOcampaignList[0].getValue(),NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE+'-'+system.today().adddays(2)));






            //Assert if above validations hold good for Marketing Bootcamp.
            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'Marketing Cloud';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'Services'; 
            //Old config Model
            NHWCtrllerInit.fillCampaignList();
            
            system.assertNotEquals(NHWCtrllerInit.traininglist.size(),0,'Expecting training list to be populated');
            system.assertEquals(NHWCtrllerInit.traininglist[0].name,NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE);
            NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(3));
            system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
            NHWCtrllerInit.BSFForBootcamp();
            system.assertEquals(NHWCtrllerInit.NHOdisabled,false);            
            system.assertEquals(NHWCtrllerInit.NHOcampaignList[0].getValue(),NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE+'-'+system.today().adddays(2)));
            //New config Model
            NHWCtrllerInit.currentPageNumber=2;             
            NHWCtrllerInit.next();//go to  page 3          

            NHWCtrllerInit.getTrainings();
            
            system.assertNotEquals(NHWCtrllerInit.traininglist.size(),0,'Expecting training list to be populated');
            system.assertEquals(NHWCtrllerInit.traininglist[0].name,NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE);
            NHWCtrllerInit.traininglist[0].selectedCampaign = NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(3));
            system.assertNotEquals(NHWCtrllerInit.traininglist[0].selectedCampaign ,null);
            NHWCtrllerInit.getBSF();
            system.assertEquals(NHWCtrllerInit.NHOdisabled,false);            
            system.assertEquals(NHWCtrllerInit.NHOcampaignList[0].getValue(),NHWCtrllerInit.fullCampaignIdMap.get(NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE+'-'+system.today().adddays(2)));                       
	            
        }
    
         /*Test if  BSF is NOT  populated based on if Bootcamp which doesnt drive BSF is loaded.
        */
        public static testmethod void  NHW_Test_BSFSelection_For_BootcampTypes_Not_DrivingBSF(){
  	       	NHW_TestFactory.populateOnBoardingSetting(); 
   
	      	Newhirewizardcontroller NHWCtrllerInit = new Newhirewizardcontroller();
	        NHWCtrllerInit.newhirecase= new Case(RecordTypeId = NHW_Util.getnhwCaseRecordTypeId(),Origin='NHW');           
	        NHWCtrllerInit.newhirecase.Email_Address__c='testContact@salesforce.com';
	        NHWCtrllerInit.newhirecase.First_Name__c='Test';
	        NHWCtrllerInit.newhirecase.Last_Name__c='Contact';
	        
           
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new NHW_MockCampaignResponseGenerator());
	        NHW_Org62Service.accessToken = 'testToken'; // hardcode some dummy auth Token;  
            NHWCtrllerInit.loadCampaignsAndContact();	     
 			Test.stopTest();       
            system.assertEquals(NHWCtrllerInit.fullCampaignMap.size(),7,'Expecting 7 BSF campaigns to be loaded');
	          
			          
            NHWCtrllerInit.newHireCase.NHW_Start_Date__c= system.today();               
            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'T&P';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'CCE';
            NHWCtrllerInit.fillCampaignList();    
            
            system.assertEquals(NHWCtrllerInit.NHOdisabled,false);            
            system.assertEquals(NHWCtrllerInit.NHOcampaignList[0].getValue(),NHWCtrllerInit.fullCampaignIdMap.get('Becoming Salesforce'+'-'+system.today().month()));            
            
            //New Config
            NHWCtrllerInit.currentPageNumber=2;             
            NHWCtrllerInit.newHireCase.Laptop_Type__c='Macbook Air';  
            NHWCtrllerInit.newHireCase.Computer_Type__c='Linux';  
            NHWCtrllerInit.newHireCase.Floor_Location_Cube_Location__c='22';
            NHWCtrllerInit.newHireCase.office_city__c='Bellevue';
            NHWCtrllerInit.newHireCase.Desk_and_VoiceMail__c='Yes';
            NHWCtrllerInit.next();//go to  page 3   

            //New Config
            NHWCtrllerInit.getTrainings(); 

            system.assertEquals(NHWCtrllerInit.NHOdisabled,false);            
            system.assertEquals(NHWCtrllerInit.NHOcampaignList[0].getValue(),NHWCtrllerInit.fullCampaignIdMap.get('Becoming Salesforce'+'-'+system.today().month()));            

            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'Sales';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'Solution Engineer - EBU';
            
            NHWCtrllerInit.fillCampaignList();     
            system.assertEquals(NHWCtrllerInit.NHOdisabled,false);            
            system.assertEquals(NHWCtrllerInit.NHOcampaignList[0].getValue(),NHWCtrllerInit.fullCampaignIdMap.get('Becoming Salesforce'+'-'+system.today().month()+'-'+'Sales'));            
            //New Config
            NHWCtrllerInit.currentPageNumber=2;             
            NHWCtrllerInit.next();//go to  page 3   
            NHWCtrllerInit.getTrainings();  

            system.assertEquals(NHWCtrllerInit.NHOdisabled,false);            
            system.assertEquals(NHWCtrllerInit.NHOcampaignList[0].getValue(),NHWCtrllerInit.fullCampaignIdMap.get('Becoming Salesforce'+'-'+system.today().month()+'-'+'Sales'));  

        }
         /*Test if  BSF is REQUIRED And CSG/Sales bootcamp are required .
        */
        public static testmethod void  NHW_Test_BSF_Bootcamp_Reqd(){
        	NHW_testfactory.populateOnBoardingSetting();
            //CSG is required
	      	Newhirewizardcontroller NHWCtrllerInit = new Newhirewizardcontroller();
	        NHWCtrllerInit.newhirecase= new Case(RecordTypeId = NHW_Util.getnhwCaseRecordTypeId(),Origin='NHW');           
	        NHWCtrllerInit.newhirecase.Email_Address__c='testContact@salesforce.com';
	        NHWCtrllerInit.newhirecase.First_Name__c='Test';
	        NHWCtrllerInit.newhirecase.Last_Name__c='Contact';

            
            NHWCtrllerInit.newHireCase.NHW_Start_Date__c= system.today().adddays(1);          

            set<Date> CSGStartdates = new set<Date>{System.today().addMonths(1),System.today().adddays(3)};
 	       	set<Date> SalesStartdates = new set<Date>{System.today().addMonths(1),System.today().adddays(3)};
 	       	set<Date> BSFSalesStartdates = new set<Date>{System.today().addMonths(1).adddays(-1),System.today().adddays(2)};
 	       	set<Date> BSFNonSalestartdates = new set<Date>{System.today().addMonths(1).adddays(-1),System.today().adddays(2)};
                
           
            NHW_MockCampaignResponseGenerator NHWCustomMockObj = new NHW_MockCampaignResponseGenerator();
            
            NHWCustomMockObj.setCampaignDatesForCampaignType(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE,CSGStartdates);
            NHWCustomMockObj.setCampaignDatesForCampaignType(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE,SalesStartdates);
            NHWCustomMockObj.setCampaignDatesForCampaignType(NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE,BSFSalesStartdates);
            NHWCustomMockObj.setCampaignDatesForCampaignType(NHW_Util.INTERNAL_TRAINING_NONSALES_CAMPAIGN_TYPE,BSFNonSalestartdates);
			NHWCustomMockObj.generateCustomCampaigns = true;

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, NHWCustomMockObj);
	        NHW_Org62Service.accessToken = 'testToken'; // hardcode some dummy auth Token;  
            NHWCtrllerInit.loadCampaignsAndContact();	     
 			Test.stopTest();
            system.assertEquals(NHWCtrllerInit.fullCampaignMap.size(),8,'Expecting 8 campaigns to be loaded');
            
            Newhirewizardcontroller.useNewConfigForBootcamps=true; 
			          
            ts2__placement__c selectedPlacement = [select id,name,ts2__Job__r.region__c 
                                                                  from ts2__placement__c limit 1];

            //Go to page 2
            NHWCtrllerInit.currentPageNumber = 2;
            NHWCtrllerInit.newHireCase.NHW_Employee__c = NHW_TestFactory.con.id ;//Point to test employee.
            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'CSG';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'CSG - CFL'; 
            NHWCtrllerInit.newHireCase.Mobile_Phone_Required__c='No'; 
            NHWCtrllerInit.newHireCase.Laptop_Type__c='Macbook Air';  
            NHWCtrllerInit.newHireCase.Computer_Type__c='Linux';  
            NHWCtrllerInit.newHireCase.Floor_Location_Cube_Location__c='22';
            NHWCtrllerInit.newHireCase.office_city__c='Bellevue';
            NHWCtrllerInit.newHireCase.Desk_and_VoiceMail__c='Yes';
            NHWCtrllerInit.next();//go to  page 3   

            system.assertNotEquals(NHWCtrllerInit.traininglist.size(), 0,'Expecting bootcamps to be populated');                       


            //NHWCtrllerInit.getTrainings();    
            NHWCtrllerInit.next();//try to  page 3 
            system.assertEquals(Apexpages.hasMessages(),true,'Expecting  error messages - as no Bootcamp selection has been made');
			system.assertEquals(Apexpages.getMessages()[0].getsummary().contains('Please select the required trainings(s) before proceeding to the next page.'),true,'Expecting CSG bootcamp missing '+Apexpages.getMessages()[0].getsummary());

            Newhirewizardcontroller.useNewConfigForBootcamps=false;
            NHWCtrllerInit.fillCampaignList();    
            system.assertNotEquals(NHWCtrllerInit.traininglist.size(), 0,'Expecting bootcamps to be populated');              
            NHWCtrllerInit.next();//try to  page 3          
            system.assertEquals(Apexpages.hasMessages(),true,'Expecting  error messages - as no Bootcamp selection has been made');
			system.assertEquals(Apexpages.getMessages()[1].getsummary().contains('Please select a CSG Bootcamp before proceeding to the next page.'),true,'Expecting CSG bootcamp missing ');


            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'Sales';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'AE - EBU'; 

            //New Config
            Newhirewizardcontroller.useNewConfigForBootcamps=true;
            NHWCtrllerInit.getTrainings(); 
            system.assertNotEquals(NHWCtrllerInit.traininglist.size(), 0,'Expecting bootcamps to be populated');                  
            NHWCtrllerInit.next();//try to  page 3
            system.assertEquals(NHWCtrllerInit.currentPageNumber,3,'Expecting to be in page 3');



            Newhirewizardcontroller.useNewConfigForBootcamps=false;
            NHWCtrllerInit.fillCampaignList(); 
            NHWCtrllerInit.next();//try to  page 3
            system.assertEquals(NHWCtrllerInit.currentPageNumber,3,'Expecting to be in page 3');
     

			//For BSFs NOT driven off bootcamp ,additional --select-- option will be shown.Manager has to explicitly click on BSF otherwise will not be able to proceed.
            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'T&P';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'CCE';

            Newhirewizardcontroller.useNewConfigForBootcamps=false;  
            NHWCtrllerInit.fillCampaignList();  
            NHWCtrllerInit.next();//try to  navigate to page 3
            system.assertEquals(NHWCtrllerInit.currentPageNumber,3,'Expecting to be in page 3');

             //New Config
            Newhirewizardcontroller.useNewConfigForBootcamps=true;           
            NHWCtrllerInit.getTrainings();  
            NHWCtrllerInit.next();//try to  navigate to page 3
            system.assertEquals(NHWCtrllerInit.currentPageNumber,3,'Expecting to be in page 3');

        }    
        /*Test   Page 3 Changes for japan .
           -  Sales and CSG training - which are required - Skip page 3
           -  
        */
        public static testmethod void  NHW_Test_Bootcamp_Japan(){
            
            Newhirewizardcontroller NHWCtrllerInit = new Newhirewizardcontroller();
    	    NHW_TestFactory.populateOnBoardingSetting();          
            NHWCtrllerInit.SelectedRecruitmentDataObject.Region='Japan';
            NHWCtrllerInit.newhirecase.Office_Country__c = 'Japan';                
            NHWCtrllerInit.currentPageNumber = 2;
            
            NHWCtrllerInit.newHireCase.Laptop_Type__c = 'Mac';
            NHWCtrllerInit.newHireCase.Computer_Type__c = 'Not Reqd';
            NHWCtrllerInit.newHireCase.Floor_Location_Cube_Location__c='23';
            NHWCtrllerInit.newHireCase.NHW_Employee__c = NHW_TestFactory.con.id; //Point to test employee.
            
            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'CSG';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'CSG - CFL';
            NHWCtrllerInit.newhirecase.NHW_Training__c = 'Some XYZ';  
            Newhirewizardcontroller.useNewConfigForBootcamps = true;       
            

            Test.startTest();

            NHWCtrllerInit.next();//try to  navigate to page 3
            system.assertEquals(NHWCtrllerInit.hasSpecializedTraining,false,'Expecting prov recs to be excluded');            
            system.assertEquals(NHWCtrllerInit.currentPageNumber,4,'Expecting page 3 to be skipped as no spl are not available');
            system.assertEquals(NHWCtrllerInit.newhirecase.NHW_Training__c,'','Expecting any prev training values to be wiped out.');

            NHWCtrllerInit.previous();
            system.assertEquals(NHWCtrllerInit.currentPageNumber,2,'Expecting page 3 to be skipped as no spl are not available');


            Newhirewizardcontroller.useNewConfigForBootcamps = false;       
            
            NHWCtrllerInit.next();//try to  navigate to page 3
            system.assertEquals(NHWCtrllerInit.skippage3,true,'Expecting Boolean to be set');            
            system.assertEquals(NHWCtrllerInit.currentPageNumber,4,'Expecting page 3 to be skipped as no spl are not available');
            system.assertEquals(NHWCtrllerInit.newhirecase.NHW_Training__c,'','Expecting any prev training values to be wiped out.');

            NHWCtrllerInit.previous();
            system.assertEquals(NHWCtrllerInit.currentPageNumber,2,'Expecting page 3 to be skipped as no spl are not available');

            Newhirewizardcontroller.useNewConfigForBootcamps = true;                  
            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'T&P';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'Other'; 
           
            NHWCtrllerInit.next();//try to  navigate to page 3
            system.assertEquals(NHWCtrllerInit.currentPageNumber,3,'Expecting page 3 to be there as t&p in new model');
            system.assertEquals(NHWCtrllerInit.hasSpecializedTraining,true,'Expecting specialized trainings');

            NHWCtrllerInit.currentPageNumber=2;
            Newhirewizardcontroller.useNewConfigForBootcamps = false;                  
            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'T&P';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'Other'; 
           
            NHWCtrllerInit.next();//try to  navigate to page 3
            system.assertEquals(NHWCtrllerInit.currentPageNumber,3,'Expecting page 3 to be there as t&p in old model');
            system.assertEquals(NHWCtrllerInit.hasSpecializedTraining,true,'Expecting specialized trainings');

            NHWCtrllerInit.currentPageNumber=2;
            Newhirewizardcontroller.useNewConfigForBootcamps = true;                  
            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'Finance';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'Other'; 
           
            NHWCtrllerInit.next();//try to  navigate to page 3
            system.assertEquals(NHWCtrllerInit.currentPageNumber,4,'Expecting page 3 to be  skipped ');


            NHWCtrllerInit.currentPageNumber=2;
            Newhirewizardcontroller.useNewConfigForBootcamps = false;                  
            NHWCtrllerInit.newhirecase.NHW_Organization__c = 'Finance';
            NHWCtrllerInit.newhirecase.NHW_Role__c = 'Other'; 
           
            NHWCtrllerInit.next();//try to  navigate to page 3
            system.assertEquals(NHWCtrllerInit.currentPageNumber,4,'Expecting page 3 to be skipped');
            Test.stopTest();
                  
        } 
}