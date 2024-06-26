/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: Mauricio Bustamante  $
 * $Change:  $
 * $DateTime: 3/16/2010 $
 * $File: LTIBAgreementController.cls $
 * $Id:  $
 * $Revision:  $
 */
public with sharing class LTIBAgreementController{
  public List<Attachment> attach;
  public Compensation__c ltib {get;set;}
  public User theCurrentUser{get;set;}
  public Id idAgreement;
  public String theTerms{get;set;}
  public Id termsID;
  public String acknowledgeAndAccept;
  public String userName {get{
  return UserInfo.getName();}set;}
  public String userID {get{
    return UserInfo.getUserID();}set;}
  public String theDate {get 
    {
      date d= ltib.LtibEffective_date__c;
      Datetime d2 = Datetime.newInstance(d.year(), d.month(), d.day()); 
      return d2.format('dd-MMM-yyyy') ;
    }set;}
    public Id LTIBId{get;set;}

    public Boolean TermsConditions {get{ return ltib.Status__c.equals('Terms & Conditions'); } set;}
    public Boolean AwardDeclined {get{ return ltib.Status__c.equals('Award Declined'); } set;}
    public Boolean PendingElectronic {get{ return ltib.Status__c.equals('Pending Electronic Signature Acceptance'); } set;}
    public Boolean PendingPhysical {get{ return ltib.Status__c.equals('Pending Physical Signature Acceptance'); } set;}
    public Boolean PendingEmployee {get{ return ltib.Status__c.equals('Pending Employee Success Confirmation'); } set;}
    public Boolean AwardElectronic {get{ return ltib.Status__c.equals('Award Accepted (Electronic Signature)'); } set;}
    public Boolean AwardPhysical {get{ return ltib.Status__c.equals('Award Accepted (Physical Signature)'); } set;}
    public Boolean acknowledgeAccept {get{ return ltib.AgreementDocument__r.AcknowledgeAndAccept__c != null; } set;}
    
    //Constructor
  public LTIBAgreementController(){
    LTIBId = System.currentPageReference().getParameters().get('id');
    attach = [select  id, 
              name, 
              CreatedDate, 
              CreatedByID 
              from Attachment 
              where parentID =: ltibID];
    theCurrentUser=[Select  id, 
                profile.Name 
                from User where id =: userID];
    //gets the Compensation object from the referal url
    list<Compensation__c> myList = [Select  Owner.Name, 
                        Owner.ID, 
                        User__r.ID, 
                        User__r.Name, 
                        User__r.EmployeeNumber, 
                        User__r.Title,  
                        LTIBEffective_Date__c,
                        Annual_Award_Payment__c,
                        id,
                        LTIBAmount__c, 
                        SignedDocument__c, 
                        Status__c,
                        AgreementDocument__r.termsID__c, 
                        AgreementDocument__r.documentID__c, 
                        AgreementDocument__r.CreatedBy.name, 
                        AgreementDocument__r.CreatedDate, 
                        AgreementDocument__r.LastModifiedBy.name,
                        AgreementDocument__r.LastModifiedDate,
                        AgreementDocument__r.AcknowledgeAndAccept__c
                        from Compensation__c 
                        where id =:LTIBId];
    //if it doesnt exist sends error page
    if(myList.size()==0){
        landInErrorPage();
      }
    else{
      ltib=myList[0];
    }
  }
  
  //gets the acknowledgeAndAccept
  public string getAcknowledgeAndAccept(){
    return ltib.AgreementDocument__r.AcknowledgeAndAccept__c;
  }
  
  //checks that the user accessing the page is either the owner of the object or the ESR
  public pageReference havePermits(){
    pageReference theReturn=null;
    if( (ltib.User__r.ID != theCurrentUser.Id) && (ltib.OwnerId!= theCurrentUser.ID) && (theCurrentUser.profile.Name!='Employee Success Representative') && (theCurrentUser.profile.id != PerformanceAccessUtil.getSystem_Administrator_Id())&& (theCurrentUser.profile.name!='systemadministrator') && (theCurrentUser.profile.Name!='Employee Success/Business Partner') && (theCurrentUser.profile.Name!='ES Admin')){
      theReturn=landInErrorPage();  
    }
    return theReturn;
  }
  public string getTheAgreementCreatedDate(){
    datetime d = ltib.AgreementDocument__r.createdDate;
    string formattedDate= d.format('dd-MMM-yyyy hh:mm a z');
    return formattedDate;
  }
  //returns the last modified 
  public string getTheAgreementLastModifiedDate(){
    datetime d = ltib.AgreementDocument__r.lastModifiedDate;
    string formattedDate = d.format('dd-MMM-yyyy hh:mm a z');
    return formattedDate;
    
  }
  
  //sends an error page as pagereference
  public PageReference landInErrorPage(){
    return new PageReference('/apex/LTIBError');
  }
  //sends the page url as pagereference for reload
  public Pagereference reload(){
    return new PageReference('/apex/ltibAgreement?id='+LTIBId);
  }
  //gets the agreementDocument id
  public String getIdAgreement(){
      return ltib.AgreementDocument__r.documentID__c;
  }
  //confirms whether a specific profile can see the accept controls or not.
  public boolean getCanSeeAcceptControls(){
    boolean thereturn=false;
    if((theCurrentUser.profile.Name=='Employee Success Representative') || (theCurrentUser.profile.id == PerformanceAccessUtil.getSystem_Administrator_Id()) || (theCurrentUser.profile.Name=='systemadministrator')||(theCurrentUser.profile.Name=='Employee Success/Business Partner') || (theCurrentUser.profile.Name=='ES Admin')){
      theReturn=true; 
    }   
    return theReturn;
  }
  //gets the terms & conditions id
  public String getTermsID(){
    return ltib.AgreementDocument__r.termsID__c;
  }
  public string getTermsValue(){
    Document d = [Select Name, Body from Document d where d.id=:getTermsID()];
    return d.Body.toString();
  }
  public string getAgreementValue(){
    Document d = [Select Name, Body from Document d where d.id=:getIdAgreement()];
    return d.Body.toString();
  }
  
  
  
  
  //uploads the selected document and sets the document id reference. 
  //removed all the pagereference related DML
  
  
  //returns the status history list
  public list<Hist> getMyHistory(){
    list<hist> theRecords = new list<hist>();
    list <Compensation__History> myList=[Select   L.NewValue, 
                            L.CreatedBy.Name,
                            L.CreatedDate, 
                            L.OldValue,
                            L.Field
                            from Compensation__History L 
                            where L.ParentID=:ltib.Id 
                            and field='Status__c' 
                            order by L.CreatedDate desc];
    for (Compensation__History element:myList){
      hist h = new hist(element);
      theRecords.add(h);
      
    }
    return theRecords;
  }
  //returns the created date of the compensation record
  public list<hist> getMyCreatedDate(){
    list<hist> theRecords = new list<hist>();
    list <Compensation__History> myList=[Select   L.CreatedDate,
                            L.CreatedBy.Name
                            from Compensation__History L 
                            where L.ParentID=:ltib.Id 
                            and field='created' 
                            order by L.CreatedDate desc];
    for (Compensation__History element:myList){
      hist h = new hist(element);
      theRecords.add(h);
      
    }
    return theRecords;
  }
  //returns true if the ltib record has an attached file
  public boolean getHasAttachments(){
    return (attach.size()>0&&attach!=null);
  }
  //returns the id of the first attachment
  public string getAttachmentID(){
    String result;
    if(getHasAttachments()){
      result= attach[0].Id;
    }
    return result;
  }
  //returns the name of the first attachment
  public string getAttachmentName(){
    String result;
    if(getHasAttachments()){
      result= attach[0].name;
    }
    return result;
  }
  //returns the date when the award was accepted
  public String getTheAcceptanceDate(){
    
    list <Compensation__History> theAcceptanceDate=[Select  l.CreatedDate, 
                                l.newValue 
                                from Compensation__History l 
                                where l.ParentID=:ltib.id 
                                and field='Status__c'];
    String acceptanceDate;
    for (Compensation__History his:theAcceptanceDate){
      if ((his.NewValue=='Award Accepted (Physical Signature)')||(his.newValue=='Award Accepted (Electronic Signature)')){
        acceptanceDate=his.CreatedDate.format(' EEEE MMMM dd , yyyy');  
      }
      
    }
    return acceptanceDate;
  }
  // inner class to be able to modify the date format for the history records.
  public class hist
  {
    public String myDate{get;set;}
    public Compensation__History  theHistory{get;set;}
    public hist(Compensation__History aHistory){
      theHistory=aHistory;
      myDate=aHistory.CreatedDate.format('dd-MMM-yyyy hh:mm a z');
    }
    
  }
  

    
}