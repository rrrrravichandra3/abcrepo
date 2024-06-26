public class DeDupCandidateUtils {
  
    private static Id candidateRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
    
    public static void dedup(Set<String> emailSet) {
        Map<String,List<Contact>>  contactMap = null;
        if(Schema.sObjectType.Contact.fields.email.isAccessible()) { 	
        	contactMap = getAllCandidatesMatchingEmails(emailSet);
        }
        else {
            System.debug('Insufficient FLS access  on Contact object');
        }
        
        System.debug('contactMap--------->'+ contactMap);
        if (contactMap != null && contactMap.size() > 0) {
            List<Contact> candidateList = null;
            Contact parentCandidate = null; 
            List<Contact> childCandidateList = null;
            Integer totalIterations = 0;
            for(String email : contactMap.keySet()) {
                candidateList = contactMap.get(email);
                if (candidateList != null && candidateList.size() > 1) {
                    parentCandidate = getParentCandidate(candidateList);
                    System.debug('parentCandidate--------->'+ parentCandidate);
                    childCandidateList = getAllChildCandidates(parentCandidate,candidateList);
                    System.debug('childCandidateList--------->'+ childCandidateList);
                    System.debug('totalIterations--------->'+ totalIterations);
                    totalIterations =mergeCandidates(parentCandidate,childCandidateList,totalIterations);
                    if (totalIterations >= 149) {
                        break;
                    }
                }
            }
        }
        
    }
    
    private static Integer mergeCandidates(Contact parentContact, List<Contact> childCandidatesList, Integer totalIterations) {
        Integer iterationCnt = childCandidatesList.size()/2;
        Integer remainder = math.mod(childCandidatesList.size(), 2);
        if (remainder > 0) {
            iterationCnt = iterationCnt + 1;
        }
        List<Id> childCandidateIDMergeList = null;
        Contact clonedParentContact = parentContact.clone(true, false);
        for (Integer i=0;  i < iterationCnt; i++) {
                try {
                   childCandidateIDMergeList = getChildCandidateIDsToMerge(childCandidatesList,i);
                   System.debug('parentContact-------->'+ parentContact + ':: ------>'+childCandidateIDMergeList + ':: Iteration ::'+ i );
                   totalIterations = totalIterations + 1;
                   ShiftContactSource ( clonedParentContact, childCandidatesList );
                   merge clonedParentContact childCandidateIDMergeList;
                   if (totalIterations >= 149) {
                        break;
                    }
                } catch (DmlException e) {
                    System.debug('Exception ---------->'+ e.getMessage());
                }
        }
        return totalIterations;
        
    }

	private static void ShiftContactSource( Contact parent, List<Contact> childContactList ){

	
	}
    
    private static List<Id> getChildCandidateIDsToMerge(List<Contact> childCandidatesList, Integer iterationCnt) {
        List<Id> childCandidateIDMergeList= new List<Id>();
        Integer count = 0;
        Integer starting = 0;
        if (iterationCnt > 0) {
            starting = iterationCnt* 2;
        }
        for (Integer i=starting;  i < childCandidatesList.size(); i++) {
            childCandidateIDMergeList.add(childCandidatesList.get(i).Id);
            count++;
            if (count >= 2) {
                break;
            }
        }
        
        return childCandidateIDMergeList;
    }
    
    /*
    private static List<Contact> getChildCandidatesToMerge( List<Contact> childCandidatesList, Integer iterationCnt) {
        List<Contact> childCandidateMergeList= new List<Contact>();
        Integer count = 0;
        Integer starting = 0;
        if (iterationCnt > 0) {
            starting = iterationCnt* 2;
        }
        for (Integer i=starting;  i < childCandidatesList.size(); i++) {
            childCandidateMergeList.add(childCandidatesList.get(i));
            count++;
            if (count >= 2) {
                break;
            }
        }
        
        return childCandidateMergeList;
    }
    */
    private static Map<String,List<Contact>> getAllCandidatesMatchingEmails(Set<String> emailSet) {    	
        Map<String,List<Contact>>  contactMap = new Map<String,List<Contact>>();
        
        if(candidateRecordTypeId == null){
        	return contactMap;
        }
        
        for(Contact candidate :[Select id,email,phone,createdDate from Contact Where email IN : emailSet and recordTypeId =:candidateRecordTypeId order by createddate desc]) {
            
             if (!contactMap.containsKey(candidate.email)) {
                 contactMap.put(candidate.email, new List<Contact>());
             }
             
             contactMap.get(candidate.email).add(candidate);
        }
        return contactMap;
    }
    
     private static Contact getParentCandidate(List<Contact> candidateList) {
        Contact parentCandidate = null;

        for(Contact candidateInfo : candidateList) {
            if (parentCandidate == null) {
                parentCandidate = candidateInfo;
            } else {
                if (parentCandidate.CreatedDate != null && candidateInfo.CreatedDate != null && parentCandidate.CreatedDate < candidateInfo.CreatedDate) {
                    parentCandidate = candidateInfo;
                }
            }
        }       
        return parentCandidate;
    }
    
    /**
     * Method to get all the 
     *
     */
    private static List<Contact> getAllChildCandidates(Contact parentCandidate,List<Contact> candidateList) {
        List<Contact> childCandidateList= new List<Contact>();
        for(Contact candidateInfo : candidateList) {
            if (candidateInfo.Id != parentCandidate.Id) {
                childCandidateList.add(candidateInfo);
            }
        }
        return childCandidateList;
    }

}