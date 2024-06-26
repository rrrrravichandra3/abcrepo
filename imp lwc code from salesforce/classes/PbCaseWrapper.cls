/*
*********************************************************
Apex Class Name    : PbCaseWrapper
Created Date       : October 26, 2023
@description       : This is a wrapper class that is used to re-format
                    the data from Case records
@author            : Mia de Haan
*********************************************************
*/
public class PbCaseWrapper {
 	@auraEnabled
    public Id Id; 
    @auraEnabled
    public String CreatedDate;
    @auraEnabled
    public String LastModifiedDate;
    @auraEnabled
    public String Subject;
    @auraEnabled
    public String CaseNumber;
    @auraEnabled
    public String Status;
    @auraEnabled
    public Boolean IsClosed;
    @auraEnabled
    public String OwnerId;
    @auraEnabled
    public String OwnerName;
    @auraEnabled
    public String Description;
    @auraEnabled
    public ContentDocumentLink[] ContentDocumentLinks;
}