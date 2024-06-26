/* Scheduler to assign Tier1 to Tier4 Age fields..  */

global class ESDJC_AssignTierAges_Scheduler implements Schedulable {

    global ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();

    global void execute(SchedulableContext SC){
        if(settings.Tier_Age_Date_Filter__c!=null){
            String soqlQ = 'SELECT Id,CreatedDate,Tier__c,Tier_1_Age__c,Tier_2_Age__c,Tier_3_Age__c,Tier_4_Age__c, BusinessHoursId, IsStopped,'+ 
            '(Select Id, Case__c,'+ 
                    'Tier_1_Age_Milliseconds__c, Tier_2_Age_Milliseconds__c, Tier_3_Age_Milliseconds__c, Tier_4_Age_Milliseconds__c,'+ 
                    'Tier_1_Pause_Time_Milliseconds__c,Tier_2_Pause_Time_Milliseconds__c, Tier_3_Pause_Time_Milliseconds__c, Tier_4_Pause_Time_Milliseconds__c,'+
                    'Tier_1_Age_in_Days__c, Tier_2_Age_in_Days__c, Tier_3_Age_in_Days__c, Tier_4_Age_in_Days__c,'+
                    'Tier_1_Pause_Time_in_Days__c, Tier_2_Pause_Time_in_Days__c, Tier_3_Pause_Time_in_Days__c, Tier_4_Pause_Time_in_Days__c '+ 
                    'from Case_Resolution_Times__r) from Case where isClosed = false and Tier__c != null and Tier__c != \'Unknown\' and Status != \'Sent to Supportforce\' and Status != \'In Transit\' and ESDJC_Supportforce_Case_Number__c = null and createdDate >'+ 
                DateTime.newInstance(settings.Tier_Age_Date_Filter__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-dd-MM')+'T00:00:01.000Z';

            Database.Batchable<sObject> tierAgeBatch;

			if(Test.isRunningTest()){
            	tierAgeBatch = new ES_DJC_TierAgeBatchMock(soqlQ);
            }else{
            	tierAgeBatch = new ES_DJC_TierAgeBatch(soqlQ);
            }

            Database.executeBatch(tierAgeBatch);
        }
    }
}