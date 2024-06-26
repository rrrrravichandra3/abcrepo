/*
*********************************************************
Apex Class Name    : PbCaseCommentWrapper
Created Date       : November 1, 2023
@description       : This is a wrapper class that is used to re-format
                    the data from CaseComment records
@author            : Mia de Haan
*********************************************************
*/
public class PbCaseCommentWrapper {
	@auraEnabled
    public Id Id; 
    @auraEnabled
    public String ParentId;
    @auraEnabled
    public String CommentBody;
    @auraEnabled
    public Datetime CreatedDate;
    @auraEnabled
    public String CreatedById;
    @auraEnabled
    public String CreatedByName;
}