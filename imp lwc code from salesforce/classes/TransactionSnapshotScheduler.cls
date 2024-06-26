/* jmendezona@cleartask.com 3/18/2011
 *
 * TransactionSnapshotScheduler
 *
 * This class schedules the Batchable Transaction Snapshot class.
 * 
 * To start the scheduler, open the System Log, and enter these lines: 
 * --------------------------------------------------------------------
 * TransactionSnapshotScheduler sched = new TransactionSnapshotScheduler();
 * System.schedule('Transaction Snapshot', '0 0 17-23 2 * ?', sched);
 * --------------------------------------------------------------------
 *
 */
global class TransactionSnapshotScheduler implements Schedulable {

	global void execute(SchedulableContext sc) {
		Snapshot_Schedule_Record__c ssr;
		try {
			 ssr = [select id, Department_Snapshot_Done__c, Employee_Snapshot_Done__c, Transaction_Snapshot_Done__c
					from Snapshot_Schedule_Record__c 
					where Date__c = :Date.Today().toStartOfMonth().addDays(-1) 
					and Department_Snapshot_Done__c = true 
					and Employee_Snapshot_Done__c = true
					limit 1];
															
		} catch (Exception e) {
			return;
		}
		
		if ((ssr != null && ssr.Department_Snapshot_Done__c == true && ssr.Employee_Snapshot_Done__c == true && ssr.Transaction_Snapshot_Done__c == false) || Test.isRunningTest()) {
			
		
		Map<String,Id>empRecordTypeMap;
		Map<String,Id>deptRecordTypeMap;
		Map<String, Id>transRecordTypeMap;
		/*
			Get record type ids employees
		*/
		
		List<RecordType> rtypes = [select Name, Id from RecordType 
                  				   where sObjectType='TF2_Department__c' and isActive=true];
        deptRecordTypeMap = new Map<String, String>();
        for (RecordType rt : rtypes) {
        	deptRecordTypeMap.put(rt.Name, rt.Id);
        }   
		
		List<RecordType> etypes = [select Name, Id from RecordType 
                  				   where sObjectType='Employee__c' and isActive=true];
                  				   
		empRecordTypeMap = new Map<String, String>();
		for (RecordType et : eTypes) {
			empRecordTypeMap.put(et.Name, et.Id);
		}
		
		List<RecordType> ttypes = [select Name, Id from RecordType  
                  				   where sObjectType='Transaction__c' and isActive=true];
        transRecordTypeMap = new Map<String, String>();
        for (RecordType tt : ttypes) {
        	transRecordTypeMap.put(tt.Name, tt.Id);  
        }   
        
        
		Date tDate = Date.Today().toStartOfMonth().addDays(-1);
		String dateString = tDate.Year() + '-';
		if (tDate.month().format().length() < 2) {
			dateString += '0' + tDate.month().format() + '-';
		} else {
			dateString += tDate.month().format() + '-';
		}
		if (tDate.day().format().length() < 2) {
			dateString += '0' + tDate.day().format();
		} else {
			dateString += tDate.day().format();
		}
		String query = 'select Transaction_Type__c, Termination_Type__c, Snapshot_Employee__c, TF2_Snapshot_Department__c, ' +
							'Snapshot_Date__c, Regrettable__c, RecordTypeId, Name, Id, Employee__c, ECOMM_Level_5_Change__c, ' +
							'ECOMM_Level_4_Change__c, ECOMM_Level_3_Change__c, ECOMM_Level_2_Change__c, ECOMM_Level_1_Change__c, ' +
							'TF2_Department__c, Department_Level_Change__c, Date__c, TF2_Department__r.Department_Number__c, Employee__r.Employee_Number__c ' + 
						'from Transaction__c ' + 
						'where RecordTypeId = \'' + transRecordTypeMap.get('Current') + '\' and Date__c <= ' + dateString;
		
		System.debug('QUERY: ' + query);			  
		BatchableTransactionSnapshot bts = new BatchableTransactionSnapshot(query, transRecordTypeMap.get('Snapshot'), deptRecordTypeMap.get('Snapshot'), empRecordTypeMap.get('Snapshot'), tDate);
		ID batchprocessid = Database.executeBatch(bts, 50);
		}
	}
}