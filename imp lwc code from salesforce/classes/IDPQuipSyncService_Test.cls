@isTest
private class IDPQuipSyncService_Test {
    @testsetup static void createData(){
        //user creation and assert check for perm set assignment
        user employeeProfileUser = GenerateEnvironmentTest.getEmployeeStandard();
        employeeProfileUser.employeeNumber = String.valueof(Math.random()*1000);
        update employeeProfileUser;
    }
        
    public static string getJsonInput(string careerInterest){
        return '{'+
                    '   "idp": {'+
                    '   "attributes":{'+
                    '       "type":"IDP__c"'+
                    '},'+
                    '"QuipId__c":"quipidp1",'+
                    '"Career_Interest__c":"'+careerInterest+'",'+
                    '"Manager_Name__c":"testMgr",'+
                    '"Quip_Document_Id__c":"quipidp1"'+
                    '},'+
                    '"idpObjectives":['+
                    '{'+
                    '   "idpObjective":{'+
                    '        "attributes":{'+
                    '          "type":"IDP_Objective__c"'+
                    '        },'+
                    '        "QuipId__c":"quipobj1",'+
                    '        "IDP_Objective_Name__c":"obj1",'+
                    '        "IsDeleted__c": false'+
                    '      },'+
                    '      "idpActions":['+
                    '        {'+
                    '          "attributes":{'+
                    '            "type":"IDP_Action__c"'+
                    '          },'+
                    '          "Action__c":"Test",'+
                    '          "Completed_Date__c":"2020-02-02",'+
                    '          "IsDeleted__c":false,'+
                    '          "Status__c":"In Progress",'+
                    '          "Support__c":"Yes",'+
                    '          "QuipId__c":"quipitem1"'+
                    '        }'+
                    '    ]'+
                    '   }'+
                    '  ]'+
                    '}';
    }
    //login as a user and check if he can insert or update
    @isTest static void positiveInsertUpdateChecks()
    {
        User employeeProfileUser =[Select id from user where username='testStandardemp@test.com' Limit 1];
        If(employeeProfileUser!=null){
            System.runas(employeeProfileUser){
                String jInput = getJsonInput('Test');
                System.assertEquals(0, [SELECT count() FROm IDP__c]);
                RestRequest request = new RestRequest();
                request.requestUri ='/services/apexrest/IDPQuipSyncService';
                request.httpMethod = 'PUT';
                request.requestBody = Blob.valueOf(jInput);
                RestContext.request = request;
                IDPQuipSyncService.syncIDP();
                System.assertEquals(1, [SELECT count() FROM IDP__c]);
                System.assertEquals('Test', [SELECT Career_Interest__c FROM IDP__c].Career_Interest__c);
                
                //for update
                jInput = getJsonInput('TestUpdate');
                System.assertEquals(1, [SELECT count() FROm IDP__c]);
                request = new RestRequest();
                request.requestUri ='/services/apexrest/IDPQuipSyncService';
                request.httpMethod = 'PUT';
                request.requestBody = Blob.valueOf(jInput);
                RestContext.request = request;
                IDPQuipSyncService.syncIDP();
                System.assertEquals(1, [SELECT count() FROM IDP__c]);
                System.assertEquals('TestUpdate', [SELECT Career_Interest__c FROM IDP__c].Career_Interest__c);
            }
        }
    }
}