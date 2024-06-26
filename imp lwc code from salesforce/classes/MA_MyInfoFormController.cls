public without sharing class MA_MyInfoFormController {

    /* To query MA MyInfo Fieldset based on logged in users community */
    @AuraEnabled
    public static List<MA_My_Info_Section__c> getMAFieldSets(){
        List<MA_My_Info_Section__c> MAFieldsSets = new List<MA_My_Info_Section__c>();
        //Query to get current users company name
        Acquisition_Contacts__c acqCon = [SELECT Id,Acquisition_Company__r.Name FROM Acquisition_Contacts__c WHERE Email_Address_Target__c = :UserInfo.getUserEmail() limit 1];
        //get fieldsets corresponding to current users acq company ordered by Sortorder
        for(MA_My_Info_Section__c myInfoFieldSet : [SELECT Name,Company__c,Field_Set_Name__c,Object__c,Section_Label__c,Sort_Order__c, Editable_Fields__c FROM MA_My_Info_Section__c WHERE Company__c=:acqCon.Acquisition_Company__r.Name ORDER BY sort_order__c] ) {
            MAFieldsSets.add(myInfoFieldSet);
        }
        return MAFieldsSets;
    }
    /* To query MA_MyInfo_Customizations based on logged in users community */
    @AuraEnabled
    public static List<MA_MyInfo_Customizations__c> getMyInfoCustomizations(){
        List<MA_MyInfo_Customizations__c> MACustomizations = new List<MA_MyInfo_Customizations__c>();
        Acquisition_Contacts__c acqCon = [SELECT Id,Acquisition_Company__r.Name FROM Acquisition_Contacts__c WHERE Email_Address_Target__c = :UserInfo.getUserEmail() limit 1];
        for(MA_MyInfo_Customizations__c myInfoCustomization : [SELECT Id,Name,Community_Name__c,Render_Confirm_Button__c,Render_Edit_Button__c FROM MA_MyInfo_Customizations__c WHERE Community_Name__c=:acqCon.Acquisition_Company__r.Name ORDER BY CreatedDate DESC]){
            MACustomizations.add(myInfoCustomization);
        }
        return MACustomizations;
    }
    /* To fetch the fieldsets from MA MyInfo Feildset custom metadata and build dynamic query
-- supporting Acquisition company, Acquisition Contact, Acquisition Compensation, Acquisition Provisioning Objects */
    @AuraEnabled
    public static Acquisition_Contacts__c  getAcquistionContactDetails(){
        String queryString ='SELECT ';
        String compensationQueryString='';
        String provisioningQueryString='';
        String companyQueryString='';
        string currentUserEmail = UserInfo.getUserEmail();
        Boolean contactInfoNeeded = False;
        //get fieldsets corresponding to the community
        List<MA_My_Info_Section__c> MAFieldsSets =MA_MyInfoFormController.getMAFieldSets();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        //Iterate through each fieldset and append to corresponding querystring
        for(MA_My_Info_Section__c fs:MAFieldsSets) {
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(fs.Object__c);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            for(Schema.FieldSet fieldset:DescribeSObjectResultObj.FieldSets.getMap().values()) {
                if(fs.Field_Set_Name__c == fieldset.getName()) {
                    for(Schema.FieldSetMember fieldSetMember: fieldset.getFields()) {
                        if(fs.Object__c.equalsIgnoreCase('Acquisition_Contacts__c')) {
                            queryString = queryString + fieldSetMember.getFieldPath() +',';
                            contactInfoNeeded = True;
                        }
                        else if(fs.Object__c.equalsIgnoreCase('Acquisition_Compensation__c')) {
                            compensationQueryString = compensationQueryString + fieldSetMember.getFieldPath() +',';
                        }
                        else if(fs.Object__c.equalsIgnoreCase('Acquisition_Provisioning__c')) {
                            provisioningQueryString = provisioningQueryString + fieldSetMember.getFieldPath() +',';
                        }
                        else if(fs.Object__c.equalsIgnoreCase('Acquisition_Company__c')) {
                            companyQueryString = companyQueryString + 'Acquisition_company__r.'+fieldSetMember.getFieldPath() +',';
                        }
                        
                    }
                }
            }
        }
        // Build dynamic query based on query strings
        queryString = queryString.removeEnd(',');
        compensationQueryString = compensationQueryString.removeEnd(',');
        provisioningQueryString = provisioningQueryString.removeEnd(',');
        companyQueryString = companyQueryString.removeEnd(',');
        if(contactInfoNeeded == False){
            //query at this stage would be Select ,(Select Name from Acquisition_Provisioning__r) from Acquisition_Contacts__c
            //if there was no custom setting entry with Object__c = Acquisition_Contacts__c
            //We remove the first occurrence of comma
            queryString = queryString + 'Id';
        }
        if(String.isNotBlank(compensationQueryString)) {
            compensationQueryString = !compensationQueryString.contains('Id')? compensationQueryString+',Id': compensationQueryString;
            queryString =  queryString + ',(Select '+compensationQueryString +' From Acquisition_compensation__r) ';
        }
        if(String.isNotBlank(provisioningQueryString)) {
            provisioningQueryString = !provisioningQueryString.contains('Id')? provisioningQueryString+',Id': provisioningQueryString;
            queryString =  queryString + ',(Select '+provisioningQueryString +' From Acquisition_Provisioning__r) ';
        }
        if(String.isNotBlank(companyQueryString)) {
            companyQueryString = !companyQueryString.contains('Acquisition_company__r.Id')? companyQueryString+',Acquisition_company__r.Id': companyQueryString;
            queryString = queryString+ ','+companyQueryString ;
        }
        
        queryString = queryString + ' FROM Acquisition_Contacts__c WHERE Email_Address_Target__c = :currentUserEmail LIMIT 1';
        
        Acquisition_Contacts__c acqContactRecord = Database.query(queryString);
        system.debug('query.   '+queryString);
        return acqContactRecord;
    }
    
    @AuraEnabled
    public static Map<String, String> getComponentsType(){
        Map<String, String> componentsByTypeField = new Map<String, String>();
        for(MA_MyInfoFormComponents__c myInfoComponent : [SELECT Id, Name, Component_Name__c FROM MA_MyInfoFormComponents__c]){
            componentsByTypeField.put(myInfoComponent.Name, myInfoComponent.Component_Name__c);
        }
        return componentsByTypeField;
    }
    
    /* To Build Sections that would be displayed in the My Info Page */
    @auraEnabled
    public static String getSections(){
        Acquisition_Contacts__c acqContactRecord = MA_MyInfoFormController.getAcquistionContactDetails();
        Map<String, List<MA_My_Info_Updates__c>> fieldInfoMap = new Map<String, List<MA_My_Info_Updates__c>>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        List<MA_My_Info_Section__c> MAFieldsSets = MA_MyInfoFormController.getMAFieldSets();
        List<MA_MyInfo_Customizations__c> MACustomizations = MA_MyInfoFormController.getMyInfoCustomizations();
        Map<String, String> componentsByTypeField = getComponentsType();
        set<Id> recordIdset = getMyInfoRecordIds(acqContactRecord, MAFieldsSets);
        fieldInfoMap = getMyInfoUpdates(recordIdset);
        List<Section> sections = new List<Section>();
        List<CustomizeSections> customizeSectionList = new List<CustomizeSections>();
       
        for(MA_My_Info_Section__c cmdtFieldset: MAFieldsSets) {
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(cmdtFieldset.Object__c);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = SObjectTypeObj.getDescribe().fields.getMap();
            Boolean fieldReadonly = cmdtFieldset.Editable_Fields__c == null ? true : false;
            Boolean editableAllField = cmdtFieldset.Editable_Fields__c == '*' && cmdtFieldset.Editable_Fields__c != null ? true : false;
            List<String> fieldsEditables = editableAllField ? new List<String>() : getNameFieldsEditables(cmdtFieldset, DescribeSObjectResultObj);
            if(editableAllField){
                fieldReadonly = false;
            }
            for(Schema.FieldSet fieldset:DescribeSObjectResultObj.FieldSets.getMap().values()) {
              
                if(cmdtFieldset.Field_Set_Name__c == fieldset.getName()) {
                    Section section = new Section();
                    section.sectionName = cmdtFieldset.Section_Label__c;
                    List<SectionMember> sectionMembers = new List<SectionMember>();
                    for(Schema.FieldSetMember fieldSetMember: fieldset.getFields()) {
                        
                        SectionMember sectionMember = new SectionMember();
                        sectionMember.SectionMemberName  = fieldSetMember.getlabel();
                        sectionMember.sectionMemberObjectName = cmdtFieldset.Object__c;
                        sectionMember.sectionMemberObjectField = fieldSetMember.getFieldPath();
                        
                        if(cmdtFieldset.Object__c.equalsIgnoreCase('Acquisition_Contacts__c')) {
                            sectionMember.recordId = acqContactRecord.Id;
                            sectionMember.SectionMemberValue = getDisplayValue(fieldSetMember.getType(),String.valueOf(acqContactRecord.get(fieldSetMember.getFieldPath())));
                        }
                        else if(cmdtFieldset.Object__c.equalsIgnoreCase('Acquisition_Compensation__c')) {
                            sectionMember.recordId = acqContactRecord.acquisition_compensation__r[0].Id;
                            sectionMember.SectionMemberValue = getDisplayValue(fieldSetMember.getType(),String.valueOf(acqContactRecord.acquisition_compensation__r[0].get(fieldSetMember.getFieldPath())));
                        }
                        else if(cmdtFieldset.Object__c.equalsIgnoreCase('Acquisition_Provisioning__c')) {
                            sectionMember.recordId = acqContactRecord.acquisition_provisioning__r[0].Id;
                            sectionMember.SectionMemberValue = getDisplayValue(fieldSetMember.getType() ,String.ValueOf(acqContactRecord.acquisition_provisioning__r[0].get(fieldSetMember.getFieldPath())));
                        }
                        else if(cmdtFieldset.Object__c.equalsIgnoreCase('Acquisition_Company__c')) {
                            sectionMember.recordId = acqContactRecord.Acquisition_Company__r.Id;
                            sectionMember.SectionMemberValue = getDisplayValue(fieldSetMember.getType(),String.valueOf(acqContactRecord.Acquisition_Company__r.get(fieldSetMember.getFieldPath())));
                        }
                        string keyValue = sectionMember.recordId+'-'+fieldSetMember.getFieldPath();
                        if(fieldInfoMap.containsKey(keyValue) && !fieldInfoMap.get(keyValue).isEmpty()) {
                            sectionMember.SectionMemberValue = +fieldInfoMap.get(keyValue)[0].New_Value__c;
                            sectionMember.helpText = system.label.MA_MyInfo_Help_Text+ ' ' +fieldInfoMap.get(keyValue)[0].Old_Value__c;
                            sectionMember.approvalRecordId = fieldInfoMap.get(keyValue)[0].Id;
                        }
                        Boolean staticValue;
                        if(!fieldReadonly && !editableAllField){
                            staticValue = !fieldsEditables.contains(fieldSetMember.getFieldPath());
                        }else{
                            staticValue = fieldReadonly;
                        }
                        sectionMember.readOnly = staticValue;
                        Boolean isRequired = fieldMap.get(fieldSetMember.getFieldPath()).getDescribe().isNameField() || !fieldMap.get(fieldSetMember.getFieldPath()).getDescribe().isNillable() || fieldSetMember.getRequired();
                        sectionMember.required = isRequired;
                        String typeFieldString = String.valueOf(fieldSetMember.getType());
                        if(typeFieldString == 'BOOLEAN') {
                            if(fieldSetMember.getSObjectField().getDescribe().getName() != 'Rehire_Former_Worker__c') {
                                typeFieldString = 'Default';
                            }
                        }
                        if(componentsByTypeField.containsKey(typeFieldString)){
                            sectionMember.component = componentsByTypeField.get(typeFieldString);
                        }else{
                            sectionMember.component = componentsByTypeField.get('Default');
                        }
                        if(typeFieldString == 'PICKLIST'){
                            Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldSetMember.getFieldPath()).getDescribe();
                            List<Schema.PicklistEntry> picklistValuesField = fieldResult.getPicklistValues();
                            sectionMember.optionList = getpicklistOptions(picklistValuesField);
                        }
                        sectionMembers.add(sectionMember);
                    }
                    section.sectionMembers = sectionMembers;
                    sections.add(section);
                }
            }
            
        }
        if(sections.size() > 0){
            CustomizeSections customizeSection = new CustomizeSections();
            Boolean renderEdit = false;
            Boolean rendercomfirm = false;
            if(MACustomizations.size() > 0){
                renderEdit = MACustomizations.get(0).Render_Edit_Button__c;
                rendercomfirm = MACustomizations.get(0).Render_Confirm_Button__c;
            }
            customizeSection.sectionList = sections;
            customizeSection.renderEditButton = renderEdit;
            customizeSection.renderConfirmButton = rendercomfirm;
            customizeSectionList.add(customizeSection);
        }
        String serializedString = JSON.serialize(customizeSectionList);
        return serializedString;
    }

    public static List<pickListOptions> getpicklistOptions(List<Schema.PicklistEntry> picklistValuesField){
        List<pickListOptions> activeOptions = new List<pickListOptions>();
        for(Schema.PicklistEntry option : picklistValuesField){
            if(option.isActive()){
                pickListOptions optionObject = new pickListOptions();
                optionObject.label = option.getLabel();
                optionObject.value = option.getValue();
                activeOptions.add(optionObject);
            }
        }
        return activeOptions;
    }

    public static List<String> getNameFieldsEditables(MA_My_Info_Section__c myInfoSection, Schema.DescribeSObjectResult DescribeSObjectResultObj){
        List<String> fieldsEditables = new List<String>();
        for(Schema.FieldSet fieldset:DescribeSObjectResultObj.FieldSets.getMap().values()) {
            if(myInfoSection.Editable_Fields__c == fieldset.getName()){
                for(Schema.FieldSetMember fieldSetMember: fieldset.getFields()) {
                    fieldsEditables.add(fieldSetMember.getFieldPath());
                }
            }
        }
        return fieldsEditables;
    }

    public static String getDisplayValue(Schema.DisplayType fieldType, String fieldValue){
        if(fieldType == Schema.DisplayType.DATE && fieldValue!=null){
            fieldValue = fieldValue.removeEnd(' 00:00:00');
        }
        return fieldValue;
    }
    
    public static set<Id> getMyInfoRecordIds(Acquisition_Contacts__c acqContactRecord, List<MA_My_Info_Section__c> MAFieldsSets) {
        set<Id> recordIdset = new set<Id>();
        for(MA_My_Info_Section__c cmdtFieldset: MAFieldsSets) {
            if(cmdtFieldset.Object__c.equalsIgnoreCase('Acquisition_Contacts__c')) {
                recordIdset.add(acqContactRecord.Id);
            }
            else if(cmdtFieldset.Object__c.equalsIgnoreCase('Acquisition_Compensation__c')) {
                recordIdset.add(acqContactRecord.acquisition_compensation__r[0].Id);
            }
            else if(cmdtFieldset.Object__c.equalsIgnoreCase('Acquisition_Provisioning__c')) {
                recordIdset.add(acqContactRecord.acquisition_provisioning__r[0].Id);
            }
            else if(cmdtFieldset.Object__c.equalsIgnoreCase('Acquisition_Company__c')) {
                recordIdset.add(acqContactRecord.Acquisition_Company__r.Id);
            }
        }
        return recordIdset;
    }
    //Getting Awating Approval Records
    public static Map<String, List<MA_My_Info_Updates__c>> getMyInfoUpdates(set<Id> setRecordIds) {
        Map<String, List<MA_My_Info_Updates__c>> fieldInfoMap = new Map<String, List<MA_My_Info_Updates__c>>();
        for(MA_My_Info_Updates__c myInfo: [SELECT Id,status__c,New_Value__c,Old_Value__c,Field_Name__c,Record_Id__c 
                                           FROM MA_My_Info_Updates__c 
                                           WHERE status__c = 'Submit']){
            String keyValue = myInfo.Record_Id__c+'-'+myInfo.Field_Name__c;                                   
            if(!fieldInfoMap.containsKey(keyValue)){
                 fieldInfoMap.put(keyValue, new List<MA_My_Info_Updates__c>());                                   
            }
            fieldInfoMap.get(keyValue).add(myInfo);                                   
         }
        return fieldInfoMap;
    }
    
    @AuraEnabled
    public static void insertApprovalRecords(List<String> recordsToInsert) {
        List<MA_My_Info_Updates__c> MMIUList = new List<MA_My_Info_Updates__c>();
        for(string str: recordsToInsert){
           
            //Code to convert JSON string to Account
            MA_My_Info_Updates__c  MMIU  = (MA_My_Info_Updates__c )JSON.deserialize(str, MA_My_Info_Updates__c.Class);
            MMIUList.add(MMIU);
        }
        Upsert MMIUList;        
    }
    
    public class Section {
        @AuraEnabled
        public String sectionName {get; set;}
        @AuraEnabled
        public List<SectionMember> sectionMembers {get; set;}        
    }
    public class SectionMember {
        @AuraEnabled
        public String sectionMemberName {get; set;}
        @AuraEnabled
        public String sectionMemberValue {get; set;}
        @AuraEnabled
        public String sectionMemberObjectName {get; set;}
        @AuraEnabled
        public String sectionMemberObjectField {get; set;}
        @AuraEnabled
        public String recordId {get; set;}
        @AuraEnabled
        public Boolean isDisbaled {get; set;}
        @AuraEnabled
        public String helpText {get; set;}
        @AuraEnabled
        public Boolean readOnly {get; set;}
        @AuraEnabled
        public Boolean required {get; set;}
        @AuraEnabled
        public String component {get; set;}
        @AuraEnabled
        public List<pickListOptions> optionList {get; set;}
        @AuraEnabled
        public String approvalRecordId {get; set;} 
    }

    public class CustomizeSections{
        @AuraEnabled
        public List<Section> sectionList {get; set;}
        @AuraEnabled
        public Boolean renderEditButton {get; set;}
        @AuraEnabled
        public Boolean renderConfirmButton {get; set;}
    }

    public class pickListOptions{
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
    }

    /* To populate the datetime on click of confirm section or to load the datetime on page load*/
    @auraEnabled
    public static String getLastConfirmDate(Boolean flag){
        String formatedDateTime;
        Acquisition_Contacts__c acqContactRecord = [Select Id, Confirmed_On__c FROM Acquisition_Contacts__c WHERE Email_Address_Target__c = :UserInfo.getUserEmail() LIMIT 1]; 
        if(flag){
            acqContactRecord.Confirmed_On__c = System.now();
            Update acqContactRecord;
        }   
        if(acqContactRecord.Confirmed_On__c != null) {
            formatedDateTime = acqContactRecord.Confirmed_On__c.format();        
        }
        return formatedDateTime;   
    } 

    /* To populate the Status of Changes and Last Modified on page load*/
    @auraEnabled
    public static String getStatusChanges(){
        String userName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
        List<MA_My_Info_Updates__c> MMIU  = [Select Id, Status__c, Status_Last_Updated__c,CreatedBy.Name FROM MA_My_Info_Updates__c WHERE CreatedBy.Name = :userName ORDER BY Status_Last_Updated__c DESC NULLS LAST]; 
        ConfirmSection cs = new ConfirmSection();
        cs.StatusOfChanges = MMIU[0].Status__c;
        String formatedLastModifiedOn = MMIU[0].Status_Last_Updated__c.format();
        cs.LastModifiedOn = formatedLastModifiedOn;
        String serializedString = JSON.serialize(cs);
        return serializedString;
     } 

    public class ConfirmSection {
        @AuraEnabled
        public String StatusOfChanges {get; set;}
        @AuraEnabled
        public String LastModifiedOn {get; set;}
    }           

}