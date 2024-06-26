//This class will be calling from trigger only
public without sharing class InterviewUtils{

    // Returning a Map contains Name of the record type and its associcated Id
    public static Map<String, Id> RecordtypeIdMap(){       
         
        List<Id> recordtypeList = new List<Id>();        
        Map<String, Id> RTMap = new Map<String, Id>();        
        
        List<recordtype> IntrecordtypeList = [ select Id, Name from recordtype where SObjectType = 'Interview_Feedback__c' and isactive = true];
        
        for ( recordtype i : IntrecordtypeList ){            
            RTMap.put(i.Name, i.Id);          
        }                
        
        return RTMap;    
        
    }

    //sobject version - To remove duplicate users and populate them into random but unique Users
    public static void removeDuplicateUserSobject( Sobject interviewer ){
        
        //for ( Sobject i : int ){
        Set<Id> userSet = new Set<Id>();
        Integer UserCounter = 0;
        
        if ( interviewer.get('Interviewer_1__c') != null ) { UserCounter++; userSet.add((Id)interviewer.get('Interviewer_1__c')); }
        if ( interviewer.get('Interviewer_2__c') != null ) { UserCounter++; userSet.add((Id)interviewer.get('Interviewer_2__c')); }
        if ( interviewer.get('Interviewer_3__c') != null ) { UserCounter++; userSet.add((Id)interviewer.get('Interviewer_3__c')); }
        if ( interviewer.get('Interviewer_4__c') != null ) { UserCounter++; userSet.add((Id)interviewer.get('Interviewer_4__c')); }
        if ( interviewer.get('Interviewer_5__c') != null ) { UserCounter++; userSet.add((Id)interviewer.get('Interviewer_5__c')); }
        if ( interviewer.get('Interviewer_6__c') != null ) { UserCounter++; userSet.add((Id)interviewer.get('Interviewer_6__c')); }
        if ( interviewer.get('Interviewer_7__c') != null ) { UserCounter++; userSet.add((Id)interviewer.get('Interviewer_7__c')); }
        if ( interviewer.get('Interviewer_8__c') != null ) { UserCounter++; userSet.add((Id)interviewer.get('Interviewer_8__c')); }
        if ( interviewer.get('Interviewer_9__c') != null ) { UserCounter++; userSet.add((Id)interviewer.get('Interviewer_9__c')); }
        if ( interviewer.get('Interviewer_10__c') != null ) { UserCounter++; userSet.add((Id)interviewer.get('Interviewer_10__c')); }
        
        if ( UserCounter != userSet.size() && userSet.size() != 10 ) {
           reroutedupUsersSobject( interviewer, userSet, userSet.size());
        }       
            
    }

    //sobjection version - reroute the user into the list
    public static void reroutedupUsersSobject( Sobject interviewer, Set<Id> userSet, Integer UserCount ){

        List<Id> TempUserList = new List<Id>();
        
        for ( Id i : userSet ){
            TempUserList.add(i);
        }
        
        if ( UserCount == 1 ){
            interviewer.put('Interviewer_1__c', TempUserList[0] );
            interviewer.put('Interviewer_2__c', null );
            interviewer.put('Interviewer_3__c', null );
            interviewer.put('Interviewer_4__c', null );
            interviewer.put('Interviewer_5__c', null );
            interviewer.put('Interviewer_6__c', null );
            interviewer.put('Interviewer_7__c', null );
            interviewer.put('Interviewer_8__c', null );
            interviewer.put('Interviewer_9__c', null );
            interviewer.put('Interviewer_10__c', null );            
        }

        if ( UserCount == 2 ){
            interviewer.put('Interviewer_1__c', TempUserList[0] );
            interviewer.put('Interviewer_2__c', TempUserList[1] );
            interviewer.put('Interviewer_3__c', null );
            interviewer.put('Interviewer_4__c', null );
            interviewer.put('Interviewer_5__c', null );
            interviewer.put('Interviewer_6__c', null );
            interviewer.put('Interviewer_7__c', null );
            interviewer.put('Interviewer_8__c', null );
            interviewer.put('Interviewer_9__c', null );
            interviewer.put('Interviewer_10__c', null );             
        }
        
        if ( UserCount == 3 ){
            interviewer.put('Interviewer_1__c', TempUserList[0] );
            interviewer.put('Interviewer_2__c', TempUserList[1] );
            interviewer.put('Interviewer_3__c', TempUserList[2] );
            interviewer.put('Interviewer_4__c', null );
            interviewer.put('Interviewer_5__c', null );
            interviewer.put('Interviewer_6__c', null );
            interviewer.put('Interviewer_7__c', null );
            interviewer.put('Interviewer_8__c', null );
            interviewer.put('Interviewer_9__c', null );
            interviewer.put('Interviewer_10__c', null );           
        }        
        
        if ( UserCount == 4 ){
            interviewer.put('Interviewer_1__c', TempUserList[0] );
            interviewer.put('Interviewer_2__c', TempUserList[1] );
            interviewer.put('Interviewer_3__c', TempUserList[2] );
            interviewer.put('Interviewer_4__c', TempUserList[3] );
            interviewer.put('Interviewer_5__c', null );
            interviewer.put('Interviewer_6__c', null );
            interviewer.put('Interviewer_7__c', null );
            interviewer.put('Interviewer_8__c', null );
            interviewer.put('Interviewer_9__c', null );
            interviewer.put('Interviewer_10__c', null );           
        }    
        if ( UserCount == 5 ){
            interviewer.put('Interviewer_1__c', TempUserList[0] );
            interviewer.put('Interviewer_2__c', TempUserList[1] );
            interviewer.put('Interviewer_3__c', TempUserList[2] );
            interviewer.put('Interviewer_4__c', TempUserList[3] );
            interviewer.put('Interviewer_5__c', TempUserList[4] );
            interviewer.put('Interviewer_6__c', null );
            interviewer.put('Interviewer_7__c', null );
            interviewer.put('Interviewer_8__c', null );
            interviewer.put('Interviewer_9__c', null );
            interviewer.put('Interviewer_10__c', null );           
        } 
        if ( UserCount == 6 ){
            interviewer.put('Interviewer_1__c', TempUserList[0] );
            interviewer.put('Interviewer_2__c', TempUserList[1] );
            interviewer.put('Interviewer_3__c', TempUserList[2] );
            interviewer.put('Interviewer_4__c', TempUserList[3] );
            interviewer.put('Interviewer_5__c', TempUserList[4] );
            interviewer.put('Interviewer_6__c', TempUserList[5] );
            interviewer.put('Interviewer_7__c', null );
            interviewer.put('Interviewer_8__c', null );
            interviewer.put('Interviewer_9__c', null );
            interviewer.put('Interviewer_10__c', null );           
        }       
        if ( UserCount == 7 ){
            interviewer.put('Interviewer_1__c', TempUserList[0] );
            interviewer.put('Interviewer_2__c', TempUserList[1] );
            interviewer.put('Interviewer_3__c', TempUserList[2] );
            interviewer.put('Interviewer_4__c', TempUserList[3] );
            interviewer.put('Interviewer_5__c', TempUserList[4] );
            interviewer.put('Interviewer_6__c', TempUserList[5] );
            interviewer.put('Interviewer_7__c', TempUserList[6] );
            interviewer.put('Interviewer_8__c', null );
            interviewer.put('Interviewer_9__c', null );
            interviewer.put('Interviewer_10__c', null );           
        }    
        if ( UserCount == 8 ){
            interviewer.put('Interviewer_1__c', TempUserList[0] );
            interviewer.put('Interviewer_2__c', TempUserList[1] );
            interviewer.put('Interviewer_3__c', TempUserList[2] );
            interviewer.put('Interviewer_4__c', TempUserList[3] );
            interviewer.put('Interviewer_5__c', TempUserList[4] );
            interviewer.put('Interviewer_6__c', TempUserList[5] );
            interviewer.put('Interviewer_7__c', TempUserList[6] );
            interviewer.put('Interviewer_8__c', TempUserList[7] );
            interviewer.put('Interviewer_9__c', null );
            interviewer.put('Interviewer_10__c', null );           
        }    
        if ( UserCount == 9 ){
            interviewer.put('Interviewer_1__c', TempUserList[0] );
            interviewer.put('Interviewer_2__c', TempUserList[1] );
            interviewer.put('Interviewer_3__c', TempUserList[2] );
            interviewer.put('Interviewer_4__c', TempUserList[3] );
            interviewer.put('Interviewer_5__c', TempUserList[4] );
            interviewer.put('Interviewer_6__c', TempUserList[5] );
            interviewer.put('Interviewer_7__c', TempUserList[6] );
            interviewer.put('Interviewer_8__c', TempUserList[7] );
            interviewer.put('Interviewer_9__c', TempUserList[8] );
            interviewer.put('Interviewer_10__c', null );           
        }   
            
    }

    //This is to insert interview feedback and remove feedback that is no longer in the panel
    public static void addInterviewFeedbackSobject( Sobject interview, Map<String, Id> RTMap, String templateOld, String templateNew ){

         List<Interview_Feedback__c> iflist = new list<Interview_Feedback__c>();
         List<Interview_Feedback__c> existingList = [select Id, Interviewer_User__c, DocuSign_Current_Status__c, Docusign_Template_ID__c from Interview_Feedback__c where ( Interview_1__c =: (Id)interview.get('Id')  or  Interview_2__c =: (Id)interview.get('Id') or Interview_3__c =: (Id)interview.get('Id') ) and Legacy__c != true];         
         Set<Id> existingUserSet = new Set<Id>();
         Set<Id> existingCompletedUserSet = new Set<Id>();
         Map<Id, Interview_Feedback__c> existingMap = new Map<Id, Interview_Feedback__c>();
         List<Interview_Feedback__c> ListToRemove = new List<Interview_Feedback__c>();
         Contact c = [ select Id, EmployeeNumber__c from contact where Id = : (Id)interview.get('ts2extams__Contact__c') ];

         
        if ( existingList.size() != 0 ){
            for ( Interview_Feedback__c ifc : existingList ){

				if ( templateOld != null ){
					if ( ifc.Docusign_Template_ID__c == templateOld.toUpperCase() ){
						existingUserSet.add( ifc.Interviewer_User__c );
						existingMap.put( ifc.Interviewer_User__c, ifc );
					}
            	}
            	if ( ifc.Docusign_Template_ID__c == templateNew.toUpperCase() && ( ifc.DocuSign_Current_Status__c == 'Completed' || ifc.DocuSign_Current_Status__c == 'Declined' ) ){
            		existingCompletedUserSet.add( ifc.Interviewer_User__c );
            	}
            }
        }
        
         List<Id> UserIdList = new List<Id>();
                 
         if ( interview.get('Interviewer_1__c') != null && !existingCompletedUserSet.contains( (Id)interview.get('Interviewer_1__c') ) ){
             UserIdList.add ( (Id)interview.get('Interviewer_1__c') );
         }        
         
         if ( interview.get('Interviewer_2__c') != null && !existingCompletedUserSet.contains( (Id)interview.get('Interviewer_2__c') )  ){
             UserIdList.add ( (Id)interview.get('Interviewer_2__c') );
         }             
         
         if ( interview.get('Interviewer_3__c') != null && !existingCompletedUserSet.contains( (Id)interview.get('Interviewer_3__c') ) ){
             UserIdList.add ( (Id)interview.get('Interviewer_3__c') );
         }             
         
         if ( interview.get('Interviewer_4__c') != null && !existingCompletedUserSet.contains( (Id)interview.get('Interviewer_4__c') ) ){
             UserIdList.add ( (Id)interview.get('Interviewer_4__c') );
         }            
         
         if ( interview.get('Interviewer_5__c') != null && !existingCompletedUserSet.contains( (Id)interview.get('Interviewer_5__c') ) ){
             UserIdList.add ( (Id)interview.get('Interviewer_5__c') );
         }            
         
         if ( interview.get('Interviewer_6__c') != null && !existingCompletedUserSet.contains( (Id)interview.get('Interviewer_6__c') ) ){
             UserIdList.add ( (Id)interview.get('Interviewer_6__c') );
         }          
         
         if ( interview.get('Interviewer_7__c') != null && !existingCompletedUserSet.contains( (Id)interview.get('Interviewer_7__c') ) ){
             UserIdList.add ( (Id)interview.get('Interviewer_7__c') );
         }            
         
         if ( interview.get('Interviewer_8__c') != null && !existingCompletedUserSet.contains( (Id)interview.get('Interviewer_8__c') ) ){
             UserIdList.add ( (Id)interview.get('Interviewer_8__c') );
         }  
         
         if ( interview.get('Interviewer_9__c') != null && !existingCompletedUserSet.contains( (Id)interview.get('Interviewer_9__c') ) ){
             UserIdList.add ( (Id)interview.get('Interviewer_9__c') );
         }          
         
         if ( interview.get('Interviewer_10__c') != null && !existingCompletedUserSet.contains( (Id)interview.get('Interviewer_10__c') ) ){
             UserIdList.add ( (Id)interview.get('Interviewer_10__c') );
         }   
                            	        
        if ( interview.get('Interview_Feedback_Template__c') != null || interview.get('Interview_Status__c') != null ){
            for ( Id i : UserIdList ) {
                    
                    String objectAPIName = ((Id)interview.get('Id')).getSObjectType().getDescribe().getName();
                    
                    Interview_Feedback__c ifc = new Interview_Feedback__c();
                    ifc.recordtypeid = RTMap.get((string)interview.get('Interview_Feedback_Template__c'));
                    ifc.Docusign_Template_ID__c = ((string)interview.get('Interview_Feedback_Template__c')).toUpperCase();
                    ifc.Candidate__c = (Id)interview.get('ts2extams__Contact__c');
                    
                        if ( objectAPIName == 'ts2extams__Custom_stage_2__c' )                  
                            ifc.Interview_1__c = (Id)interview.get('Id');
                        if ( objectAPIName == 'ts2extams__Custom_stage_3__c' )                  
                            ifc.Interview_2__c = (Id)interview.get('Id');
                        if ( objectAPIName == 'ts2extams__Custom_stage_4__c' )                  
                            ifc.Interview_3__c = (Id)interview.get('Id');
                            
                    ifc.Interviewer_User__c = i;
                    ifc.Interview_Status__c = (string)interview.get('Interview_Status__c');
                    ifc.DocuSign_Current_Status__c = 'Ready';
                    
                    if ( c.EmployeeNumber__c != null )
                    	ifc.Internal_Employee__c = true;
                    	
                if ( !existingUserSet.contains(i) ) {
                    iflist.add( ifc );
                }
                
                if ( existingUserSet.contains(i) ){
                    if ( existingMap.get(i).Docusign_Template_ID__c != ((string)interview.get('Interview_Feedback_Template__c')).toUpperCase() )
                         iflist.add( ifc );
                }
                
                if ( existingUserSet.size() != 0 ){
                    existingUserSet.remove(i);
                }   
            }
                            
            if ( !existingUserSet.isEmpty() ){
                
                for ( Id userId : existingUserSet  ){
                    if ( existingMap.get( userId ).DocuSign_Current_Status__c == 'Ready' || existingMap.get( userId ).DocuSign_Current_Status__c == 'Voided' ||
                    	 existingMap.get( userId ).DocuSign_Current_Status__c == 'Sent' || existingMap.get( userId ).DocuSign_Current_Status__c == 'Delivered' )
                        ListToRemove.add( existingMap.get( userId ) );
                }
                if ( ListToRemove != null )
                    delete ListToRemove;
            }

            if ( iflist != null )
            insert iflist;          
        } else {
            interview.addError('Interview Feedback Template is missing!');
        }                  
         
                 
    }

    public static void updateInterviewStatusSobject( Id interviewId, string status ){
        List<Interview_Feedback__c> listtoUpdate = [select Id, Interview_Status__c from Interview_Feedback__c where ( Interview_1__c = : interviewId or Interview_2__c = : interviewId or Interview_3__c = : interviewId ) and Legacy__c != true and DocuSign_Current_Status__c in ('Ready', 'Voided', 'Sent','Delivered' ) ];
        
        for ( Interview_Feedback__c intf : listtoUpdate ){
            intf.Interview_Status__c = status;
        }
        
        update listtoUpdate;
    }

    //Remove Interview Feedback that no longer needed when switching template unless it's completed for any record that match the Ids
    public static void removeUntouchedRecord( Id interviewId ){
    
        List<Interview_Feedback__c> listtoRemove = [select Id from Interview_Feedback__c where ( Interview_1__c = : interviewId or Interview_2__c = : interviewId or Interview_3__c = : interviewId ) and Legacy__c != true and DocuSign_Current_Status__c in ('Ready', 'Voided', 'Sent','Delivered' ) ];
        
        delete listtoRemove;
        
    }

    public static void RollUpSummaryFieldOnInterviewSobject( Set<Id> InterviewSet ){
        List<Interview_Feedback__c> FeedbackList = [SELECT Id, Interview_1__c, Interview_2__c, Interview_3__c, DocuSign_Current_Status__c FROM Interview_Feedback__c WHERE ( Interview_1__c IN : InterviewSet or Interview_2__c IN : InterviewSet or Interview_3__c IN : InterviewSet) AND Legacy__c != true ];
        // find out id
		if ( FeedbackList.size() != 0 ) {        
        string objectAPIName;
        if ( FeedbackList[0].Interview_1__c != null )
            objectAPIName = FeedbackList[0].Interview_1__c.getSObjectType().getDescribe().getName();
        if ( FeedbackList[0].Interview_2__c != null )
            objectAPIName = FeedbackList[0].Interview_2__c.getSObjectType().getDescribe().getName();
        if ( FeedbackList[0].Interview_3__c != null )
            objectAPIName = FeedbackList[0].Interview_3__c.getSObjectType().getDescribe().getName();
            
        String idString = '(\'';
        for (Id thisId : InterviewSet ) {
            idString += thisId + '\',\'';
        }
        idString = idString.substring(0,idString.length()-2); //removing ' from the end
        idString += ')';        
        
        String qry = 'SELECT Id, Overall_Status_Completed__c FROM ' + objectAPIName + ' WHERE Id IN ' + idString;
        List<Sobject> InterviewList = Database.query( qry ); 
        Map<Id, Sobject> InterviewMap = new Map<Id, Sobject>();
        Map<Id, Boolean> InterviewFlagMap = new Map<Id, Boolean>();

        for ( Sobject interview : InterviewList ){
            InterviewMap.put( (Id)interview.get('Id'), interview);
        }       
        
        for ( Interview_Feedback__c i : FeedbackList ){
            
            if ( i.Interview_1__c != null ){
                if ( InterviewFlagMap.containsKey(i.Interview_1__c) ){
                    if ( i.DocuSign_Current_Status__c == 'Sent' || i.DocuSign_Current_Status__c == 'Delivered' || i.DocuSign_Current_Status__c == 'Ready')
                        InterviewFlagMap.put((Id)i.Interview_1__c, false);
                } else {
                    if ( i.DocuSign_Current_Status__c == 'Sent' || i.DocuSign_Current_Status__c == 'Delivered' || i.DocuSign_Current_Status__c == 'Ready')
                        InterviewFlagMap.put((Id)i.Interview_1__c, false);
                    else                    
                        InterviewFlagMap.put((Id)i.Interview_1__c, true);
                }           
            }
            
            if ( i.Interview_2__c != null ){
                if ( InterviewFlagMap.containsKey(i.Interview_2__c) ){
                    if ( i.DocuSign_Current_Status__c == 'Sent' || i.DocuSign_Current_Status__c == 'Delivered' || i.DocuSign_Current_Status__c == 'Ready')
                        InterviewFlagMap.put((Id)i.Interview_2__c, false);
                } else {
                    if ( i.DocuSign_Current_Status__c == 'Sent' || i.DocuSign_Current_Status__c == 'Delivered' || i.DocuSign_Current_Status__c == 'Ready')
                        InterviewFlagMap.put((Id)i.Interview_2__c, false);
                    else                    
                        InterviewFlagMap.put((Id)i.Interview_2__c, true);
                }
            }

            if ( i.Interview_3__c != null ){                        
                if ( InterviewFlagMap.containsKey(i.Interview_3__c) ){
                    if ( i.DocuSign_Current_Status__c == 'Sent' || i.DocuSign_Current_Status__c == 'Delivered' || i.DocuSign_Current_Status__c == 'Ready')
                        InterviewFlagMap.put((Id)i.Interview_3__c, false);
                } else {
                    if ( i.DocuSign_Current_Status__c == 'Sent' || i.DocuSign_Current_Status__c == 'Delivered' || i.DocuSign_Current_Status__c == 'Ready')
                        InterviewFlagMap.put((Id)i.Interview_3__c, false);
                    else                    
                        InterviewFlagMap.put((Id)i.Interview_3__c, true);
                }
            }                       
        }

        for ( Sobject interview : InterviewList ){
            interview.put('Overall_Status_Completed__c', InterviewFlagMap.get( (Id)interview.get('Id') ) );
            InterviewMap.put( (Id)interview.get('Id'), interview );

        }       
        
        update InterviewMap.values();
    }
    }
            
}