public with sharing class TrackFieldChanges_Util {

	private final Map<Id, sObject> oldRecordsMap;
	private final Map<Id,sObject> newRecordsMap;
	private final Set<String> fieldsToBeTracked;
	private Boolean errorExists;
	
	public TrackFieldChanges_Util(Map<Id,sObject> oldRecordsMap, Map<Id,sObject> newRecordsMap, Set<String> fieldsToBeTracked){
		this.oldRecordsMap = oldRecordsMap;
		this.newRecordsMap = newRecordsMap;
		this.fieldsToBeTracked = fieldsToBeTracked;
		validateForErrors();
	}

	public TrackFieldChanges_Util(List<sObject> oldRecords, List<sObject> newRecords, Set<String> fieldsToBeTracked){
		this.oldRecordsMap = new Map<Id, sObject>(oldRecords);
		this.newRecordsMap = new Map<Id, sObject>(newRecords);
        this.fieldsToBeTracked = fieldsToBeTracked;
        validateForErrors();
	}

	private void validateForErrors(){
		this.errorExists = False;
		if(oldRecordsMap == null || oldRecordsMap.isEmpty()){
			this.errorExists = True;
			return;
		}
		if(newRecordsMap == null || newRecordsMap.isEmpty()){
			this.errorExists = True;
			return;
		}
		if(fieldsToBeTracked == null || fieldsToBeTracked.isEmpty()){
			this.errorExists = True;
			return;
		}
		if(oldRecordsMap.keySet().equals(newRecordsMap.keySet()) == false){
			this.errorExists = True;
			return;
		}
	}

	/*
	* Method to find out which fields changed their values. Typically called from an update trigger
	* @return : For each Record, it gives Names of the fields (API names) that changed in value
	*/
	public Map<Id,Set<String>> findFieldChanges(){
		if(errorExists == True){
			return new Map<Id, Set<String>>();
		}
		Map<Id,Set<String>> recIdToFieldNamesMap = new Map<Id,Set<String>>();
		for(sObject currOldRecord : oldRecordsMap.values()){
			sObject currNewRecord = newRecordsMap.get(currOldRecord.Id);
			if(currOldRecord == null || currNewRecord == null){
				continue;
			}
			for(String currField : fieldsToBeTracked){
				if(currOldRecord.get(currField) != currNewRecord.get(currField)){
					if(!recIdToFieldNamesMap.containsKey(currOldRecord.Id)){
						recIdToFieldNamesMap.put(currOldRecord.Id, new Set<String>());
					}
					(recIdToFieldNamesMap.get(currOldRecord.Id)).add(currField);
				}
			}
		}
		return recIdToFieldNamesMap;
	}
}