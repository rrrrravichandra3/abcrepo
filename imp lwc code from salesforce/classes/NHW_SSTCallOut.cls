/*
Generic class to fetch sst users from target org. 
 */

public class NHW_SSTCallOut {

	public static List<User> getSSTUsers(String targetOrg,String searchStr){
		NHW_SSTResults resultSSTC = new NHW_SSTResults();
		try{
			//get instance of target class .. 
			NHW_SST sst = (NHW_SST) Type.forName('NHW_'+targetOrg+'SST').newInstance(); 
			HttpResponse res = sst.fetchSSTUsers(searchStr);
			if(res!=null && res.getStatusCode() == 200){
				System.debug('success -->' + res.getBody());
				resultSSTC =  (NHW_SSTResults) JSON.deserialize(res.getBody(),NHW_SSTResults.class);
				return resultSSTC.records;

			} else{
				PF_Logger.log('NHW','ERROR', NULL,null, res.getBody(), 'NHW_SSTCallOut');
				EventBus.publish(
                                new PF_Logging_Channel__e(
                                        ApplicationName__c = 'NHW',
                                        LogLevel__c = 'ERROR',
                                        //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                        ErrorType__c = 'ERROR',
                                        Stack_Trace__c = 'NHW_SSTCallOut',
                                        Message__c = res.getBody(),
                                        Error__c = res.getBody()
                                        )
                        );
			}
		} catch(Exception e){
			System.debug('Exception ' + e.getMessage());
			//log... 
		}

		return null;

	}
}