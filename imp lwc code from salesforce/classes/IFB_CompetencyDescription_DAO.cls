/*
*  This class is used for retrieving records of Object "Competency Description"
*  No sharing rules are enforced, so that any interviewer can view it
*/
public without sharing class IFB_CompetencyDescription_DAO {

	public static List<IFB_Competency_Description__c> getRecordsFromCompetencyNames(List<String> competencyNames, String groupValue, String interviewTypeValue, String positionValue){
		if(competencyNames == null || competencyNames.size()==0){
			return new List<IFB_Competency_Description__c>();
		}else{
			return [SELECT Id, Name, LastModifiedDate, Competency_Description__c, Group__c, SIFT_Group_Lookup__c, SIFT_Group_Lookup__r.Name, Interview_Record_Type__c, SIFT_Interview_Type_Lookup__c, SIFT_Interview_Type_Lookup__r.Name, Position__c, SIFT_Position_Lookup__c, SIFT_Position_Lookup__r.Name, Additional_Questions__c, Japan_Additional_Question__c, Japan_Competency_Description__c, Japan_Name__c 
              FROM IFB_Competency_Description__c 
              WHERE Name IN :competencyNames AND(
                (SIFT_Group_Lookup__c = null               and SIFT_Interview_Type_Lookup__c = null                         and SIFT_Position_Lookup__c = null               ) or
                (SIFT_Group_Lookup__r.Name = :groupValue   and SIFT_Interview_Type_Lookup__c = null                         and SIFT_Position_Lookup__c = null               ) or
                (SIFT_Group_Lookup__c = null               and SIFT_Interview_Type_Lookup__r.Name = :interviewTypeValue     and SIFT_Position_Lookup__c = null               ) or
                (SIFT_Group_Lookup__c = null               and SIFT_Interview_Type_Lookup__c = null                         and SIFT_Position_Lookup__r.Name = :positionValue) or
                (SIFT_Group_Lookup__r.Name = :groupValue   and SIFT_Interview_Type_Lookup__r.Name = :interviewTypeValue     and SIFT_Position_Lookup__c = null               ) or
                (SIFT_Group_Lookup__r.Name = :groupValue   and SIFT_Interview_Type_Lookup__c = null                         and SIFT_Position_Lookup__r.Name = :positionValue) or
                (SIFT_Group_Lookup__c = null               and SIFT_Interview_Type_Lookup__r.Name = :interviewTypeValue     and SIFT_Position_Lookup__r.Name = :positionValue) or
                (SIFT_Group_Lookup__r.Name = :groupValue   and SIFT_Interview_Type_Lookup__r.Name = :interviewTypeValue     and SIFT_Position_Lookup__r.Name = :positionValue)
              )];
		}
	}	
}