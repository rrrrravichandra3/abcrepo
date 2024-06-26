/*
*Apex Class to Handle Insertion/Deletion/Updation of Lead Records
*/

public class LeadHandler {

    //Max DML statement is 150 - 5
    public static Final Integer MAX = 145;
    public static Integer Current = 0;
    public static Boolean isRun = true;

    public static void createCandidateSecureInfoOnLead(Set<Id> LeadIdSet) {
        
        List<Candidate_Secure_Info__c> candidateSecureInfoList = new List<Candidate_Secure_Info__c>();

        for(Id leadId : LeadIdSet) {
                candidateSecureInfoList.add(new Candidate_Secure_Info__c(Lead__c =leadId));
        }
        if (candidateSecureInfoList.size() > 0) {
            insert candidateSecureInfoList;
        }
    }

    //To prevent trigger to run after the each record merge 
    public static Boolean RunOnce(){

        if ( isRun == true ){
            isRun = false;
            return true;
        } else

            return isRun;

    }


    public static void DedupLead( Set<Id> LeadIdSet ){

        Set<String> EmailSet = new Set<String>();
        Set<String> URLSet = new Set<String>();

        List<Lead> LeadEmailURLList = [select Email, CreatedDate, Linked_In_URL__c, OwnerId, Company  from Lead where Id in: LeadIdSet ];
        List<Lead> LeadList = new List<Lead>();
        List<Lead> LeadURLList = new List<Lead>();

        if ( LeadEmailURLList.size() > 0 ){
            for ( Lead l : LeadEmailURLList ){ 
                if ( l.Email != null )
                    EmailSet.add( l.Email );
                if ( l.Linked_In_URL__c != null )
                    URLSet.add( l.Linked_In_URL__c );
            }
        }   

        DedupLeadOnValues( EmailSet, getAllLeadMatchingEmail( EmailSet ) );
        DedupLeadOnValues( URLSet, getAllLeadMatchingURL( URLSet ) );

    }


    public static void DedupLeadOnValues( Set<String> ValuesSet, Map<String,List<Lead>> ValuesLeadMaps ){

        List<Lead> LeadList = new List<Lead>();

        if ( ValuesSet.size() > 0 && ValuesLeadMaps != null  ){

            Lead parentLead = null;
            List<Lead> childLeadList = null;            

            for ( String Value : ValuesLeadMaps.keySet()  ){
                LeadList = ValuesLeadMaps.get( Value );

                parentLead = getParentLead( LeadList );

                Lead cloneparentLead = parentLead.clone(true, false);
                childLeadList = getChildLead( parentLead, LeadList );

                ShiftValues( cloneparentLead, childLeadList );
                List<Id> childLeadIdList = getChildLeadIds( childLeadList, cloneparentLead.Id );

                if ( childLeadIdList.size() > 0 ){

                    //seperating the list into 2 sets, as each merge operation has parent, 2 child records
                    //The code breaks at 145 merge silently. 
                    Integer remainder = math.mod( childLeadIdList.size(), 2);

                    Integer counter = childLeadIdList.size()/2;

                    if ( remainder != 0 )
                        counter++;


                    for ( Integer i = 0, j = 0; i < counter; i++ ){    
                
                        List<Id> subChildLead = new List<Id>();
                        integer x = i * 2; 
                        subChildLead.add( childLeadIdList[x] );
                        j = x + 1;
                        if ( j < childLeadIdList.size() )
                            subChildLead.add( childLeadIdList[j] );
                        if ( Current > MAX )
                            break;
                        try { 
                            merge cloneparentLead subChildLead;
                            Current++;
                        } catch (DmlException e) {
                            System.debug('Exception ---------->'+ e.getMessage());
                        } 
                    }
                }
            }

        }

    }

    //Shifting value from the child to the parent, if the parent value is blank, copy from the child
    //Fieldvalues are each field need to be copied. Make sure to add field into the query as well.
    //ConcatFieldValues are to concatenate, value is trim into their respective length 
    public static void ShiftValues( Lead shiftValueLead, List<Lead> shiftValueChildLeadList ){

        Set<String> FieldValues = new Set<String>{'MobilePhone','Phone','Home_Phone__c','Mailing_City__c','Employer_Organization_Name_1__c',
        'Employer_1_Title__c','Mailing_State_Province__c','Website', 'Mailing_Zip_Postal_Code__c', 'Facebook_Profile__c'};

        Set<String> ConcatFieldValues = new Set<String>{'Memo__c','Description'};

        for ( String s : FieldValues ){
            if ( shiftValueLead.get(s) == null && shiftValueChildLeadList.size() > 0 &&
                 shiftValueChildLeadList[0] != null && shiftValueChildLeadList[0].get(s) != null && shiftValueChildLeadList[0].get(s) != ' ' )
            shiftValueLead.put(s, shiftValueChildLeadList[0].get(s));

        }

        for ( Lead l : shiftValueChildLeadList ){

            for ( String s : ConcatFieldValues ){

                if ( l.get(s) != null ){
                    String cloneValue = shiftValueLead.get(s) == null ? String.valueOf( l.get(s) ) : shiftValueLead.get(s)+'|'+ String.valueOf( l.get(s) );

                    if ( s == 'Memo__c' )
                        cloneValue = cloneValue.left( 255 );
                    if ( s == 'Description' )
                        cloneValue = cloneValue.left( 32000 );
                        
                    shiftValueLead.put( s, cloneValue );
                }

            }

        }
    }

    public static Map<String, List<Lead>> getAllLeadMatchingURL( Set<String> allLeadMatching_URLSet ){
        Map<String, List<Lead>> LeadMap = new Map<String, List<Lead>>();

        List<Lead> LeadList = [select Id, Linked_In_URL__c, CreatedDate, OwnerId, Company, MobilePhone,Phone,Home_Phone__c,Mailing_City__c,Employer_Organization_Name_1__c,
Employer_1_Title__c,LeadSource,Mailing_State_Province__c,Website,Facebook_Profile__c,Memo__c,Description,Mailing_Zip_Postal_Code__c from Lead where Linked_In_URL__c in: allLeadMatching_URLSet and Linked_In_URL__c != null and IsConverted = false order by createddate desc ];

        if ( LeadList.size() > 0 ){

            for ( Lead l : LeadList ){

                if ( !LeadMap.containsKey( l.Linked_In_URL__c ) ){
                    LeadMap.put( l.Linked_In_URL__c, new List<Lead>() );
                }

                LeadMap.get( l.Linked_In_URL__c ).add( l );
            }

        }

        return LeadMap;

    }

    public static Map<String, List<Lead>> getAllLeadMatchingEmail( Set<String> allLeadMatching_EmailSet ){
        Map<String, List<Lead>> LeadMap = new Map<String, List<Lead>>();

        List<Lead> LeadList = [select Id, Email, CreatedDate, OwnerId, Company, MobilePhone,Phone,Home_Phone__c,Mailing_City__c,Employer_Organization_Name_1__c,
Employer_1_Title__c,LeadSource,Mailing_State_Province__c,Website,Facebook_Profile__c,Memo__c,Description,Mailing_Zip_Postal_Code__c from Lead where Email in: allLeadMatching_EmailSet and Email != null and IsConverted = false order by createddate desc ];

        if ( LeadList.size() > 0 ){

            for ( Lead l : LeadList ){

                if ( !LeadMap.containsKey( l.email ) ){
                    LeadMap.put( l.email, new List<Lead>() );
                }

                LeadMap.get( l.email ).add( l );
            }

        }

        return LeadMap;

    }

    public static List<Id> getChildLeadIds( List<Lead> childLeadis_LeadList, Id LeadParentId ){

        List<Id> childLeadIDList= new List<Id>();

        for ( Lead l : childLeadis_LeadList ){
            if ( l.Id != LeadParentId )
                childLeadIDList.add( l.Id );            
        }
        
        return childLeadIDList;

    }

    public static Lead getParentLead ( List<Lead> parentLead_LeadList ){
        Lead parentLead = null;

        for ( Lead l : parentLead_LeadList ){

            if ( parentLead == null )
                parentLead = l;
            else {
                if (parentLead.CreatedDate != null && l.CreatedDate != null && parentLead.CreatedDate > l.CreatedDate) {
                    parentLead = l;
                }
            }
        }

        return parentLead;
    } 


    public static List<Lead> getChildLead ( Lead childLead_ParentLead, List<Lead> childLead_LeadList ){

        List<Lead> childLeadList = new List<Lead>();

        for ( Lead l : childLead_LeadList ){
            if ( l.Id != childLead_ParentLead.Id )
                childLeadList.add( l );             
        }

        return childLeadList;
    }

}