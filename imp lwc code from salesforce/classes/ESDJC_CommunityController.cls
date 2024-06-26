/**
* #DreamJobCentral
* @date:        4/23/2013 
* @description: Controller for ESDJC_Communities. Show all the Chatter Communities with sidebar components like Program and announcements.
**/
public with sharing class ESDJC_CommunityController {
    public string programHeader{get;set;}
    public string url{get;set;}
    private Id userId;
    public boolean showAnnouncements{get;set;}
    public list<ESDJC_ContryContent__c> contents{get;set;}
    
    
    public boolean showChat{get;set;}
    private user currentUser;
    public string currentCommunity {get;private set;}
    public string currentCommunityName{get;private set;}
    public string nextComm{get;set;}
    public list<communityWrapper> communityList {get;private set;}
    public boolean isManager{get;set;}
    public boolean isESRepresentative {get;set;}
    public string artId{get;set;}
    private Contact userContact;
    public Boolean isLiveAgentAvailable{get;set;}
    public Boolean showVideo{get;set;}
    public string videoURL{get;set;}    
    public string case_topic{get;set;}
    public string case_subject{get;set;}
    public string case_desc{get;set;}
    
    
    public final String REGION_AMER = 'Americas';
    public final String REGION_EMEA = 'EMEA';
    public final String REGION_APAC = 'APAC';
    public final String REGION_JAPAN = 'Japan';
    public final String REGION_DEFAULT = 'Default';
    
    
    public ESDJC_CommunityController(){
    
    system.debug('ssourl'+ApexPages.currentPage().getParameters().get('knoParam'));
        programHeader = System.Label.ES_DJC_Home_Prog_Announcement;        
        showVideo = false;
        
        ESDJC_Settings__c video = ESDJC_Settings__c.getInstance();
        if ((UserInfo.getLanguage().equalsIgnoreCase('ja'))){
            if(video != null && video.VideoURLForJapan__c != null){
                videoURL = video.VideoURLForJapan__c;    
                showVideo = true;
            }                       
        }else{
            if(video != null && video.VideoURL__c != null){
                videoURL = video.VideoURL__c;    
                showVideo = true;
            }
        }
        
        isManager = true;
        //url=ESDJC_Util.getSSOURL();
        url=ESDJC_Util.getSiteURL();
        userId = UserInfo.getUserId(); 
        string artId = ApexPages.currentPage().getParameters().get('id');
        
        communityList = new list<communityWrapper>();
        
        if (ApexPages.currentPage().getParameters().get('commId') != null ) {
            currentCommunity = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('commId'));
        }
        
        //Get names of Communities from Custom Setting.
        Map<String, ESDJC_Comunities__c> communityMap = ESDJC_Comunities__c.getAll();
        List<string> communityNames =  new list<string>{'',''};
        string defaultCommunity;
        
        for (ESDJC_Comunities__c c :communityMap.values()) {
            if (Integer.valueOf(c.Sequence__c) == 1) {
                defaultCommunity = c.name;
            }
            communityNames[Integer.valueOf(c.Sequence__c)-1]=c.Name;
        }
        
        Map<string,Community> communityIdMap= new Map<string,Community>();
        
        for (Community c : [select id,name from Community where name in : communityNames]) {
        
            communityIdMap.put(c.Name,c);
            if (currentCommunity == null && c.Name == defaultCommunity) {
                currentCommunity = c.id;  
                currentCommunityName = c.Name;  
            } else if (currentCommunity==c.Id) {
                currentCommunityName=c.name;
            
            }
            
        }
        communityList = new list<communityWrapper>();
        
        
        for (integer i=0;i<communityNames.size(); i++ ) {
            if (communityIdMap.containsKey(communityNames[i])) {
                if (UserInfo.getLanguage().equalsIgnoreCase('ja')) {
                    communityList.add(new communityWrapper(communityIdMap.get(communityNames[i]).Id,communityMap.get(communityNames[i]).Image_Japanese__c,communityMap.get(communityNames[i]).Title_Japanese__c));
                } else {
                    communityList.add(new communityWrapper(communityIdMap.get(communityNames[i]).Id,communityMap.get(communityNames[i]).Image__c,communityMap.get(communityNames[i]).Title__c));
                }
            }
        }      
        
        List<User> users = [SELECT ContactId, Name, Email, Phone, Division FROM User WHERE id =: UserInfo.getUserId()];
        if (!users.isEmpty()) {
            currentUser = users.get(0);
            userContact = [select id,Name,Email,Phone,ES_DJC_Is_Manager__c,Division__c, ES_DJC_Contact_Country__c, ES_DJC_Cost_Center__c from Contact where id =: currentUser.ContactId];
        }
        //if current user is not manager dont show Manager community.
        if (userContact != null && !userContact.ES_DJC_Is_Manager__c && !checkESRepresentative()) {
            
            isManager = false;
            
            communityList.remove(communityList.size()-1);
        }
        
        if (String.isNotEmpty(currentUser.Division)  && currentUser.Division.containsIgnoreCase(REGION_EMEA)) {
            showChat = true;
        } else {
            showChat = false;
        }
        
        showAnnouncements = false;          
        getContents();
        

    }
    
    private boolean checkESRepresentative() {
        ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
        List<String> costCenterList = new List<String>();
        isESRepresentative = false;
        if (settings.ES_Representative_Cost_Centers__c != null) {
            costCenterList = settings.ES_Representative_Cost_Centers__c.split(';',-1);
            for (String costCenter : costCenterList) {
                if (costCenter == userContact.ES_DJC_Cost_Center__c)
                    isESRepresentative = true;
            }
        }       
        return isESRepresentative;
    }
    /*
    *Get program and Announcement articles.
    */
    public void getContents() {
        
        String region = ESDJC_Util.getRegionFromDivision(currentUser.Division);
        
        contents = new list<ESDJC_ContryContent__c>();
            String countryC;
            if (userContact.ES_DJC_Contact_Country__c!=null) {
                if (userContact.ES_DJC_Contact_Country__c.contains('United States')) {
                countryC = 'United States';
                } else {
                    countryC= userContact.ES_DJC_Contact_Country__c;
                }
            }
            
            for (ESDJC_Country__c cc : [select id,Name, (select id,ESDJC_Content__r.id,ESDJC_Content__r.Name from ESDJC_ContryContents__r) from ESDJC_Country__c where name =: countryC]) {
                contents.addAll(cc.ESDJC_ContryContents__r) ;
            }
        
        if (contents.size()>0)
            showAnnouncements = true;
        
    }
    /*
    *Change chatter community to selected tab. 
    */
    public pagereference ChangeCommunity(){
         //pagereference pr = new pagereference(url+'/apex/ESDJC_Communities?commId='+ApexPages.currentPage().getParameters().get('curr'));
        pagereference pr = new pagereference('/apex/ESDJC_Communities?commId='+ApexPages.currentPage().getParameters().get('curr'));
        pr.setRedirect(true);
        return pr;
          
    }
    /*
    *Wrapper class to store Community details.
    */
    public with sharing class communityWrapper {
        public String communityId {get; private set;}
        public string imageLogo {get; private set;}
        public string imageLogoSelected {get; private set;}
        public string title {get;private set;}
        
        public communityWrapper(String communityId, string logo,string title) {
            
            Map<String,ES_DJC_Image__c> imageMap = ES_DJC_Image__c.getAll();
            //imageLogo =  logo + '.png'; 
            this.communityId = communityId; 
            imageLogo=''; 
            imageLogoSelected='';
            if(imageMap.get(logo)!=null){
                imageLogo = imageMap.get(logo).Image_Url__c;
            }
           
            
            //imageLogoSelected =  logo + '_Selected.png';  
            if(imageMap.get(logo+'_Selected')!=null){
                imageLogoSelected =  imageMap.get(logo+'_Selected').Image_Url__c;   
            }
            
            this.title = title;
            
        }
    }
    
    public List<PermissionSetAssignment> PermSetAssignment{
        get{
            if (PermSetAssignment == null){
                PermSetAssignment = new List<PermissionSetAssignment>();
                ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
                List<String> PermSetList = new List<String>{settings.Portal_User_Emea_Permset_Id__c,
                                                            settings.Portal_User_Amer_Permset_Id__c,
                                                            settings.Portal_User_Apac_Permset_Id__c,
                                                            settings.Portal_User_Japan_Permset_Id__c};                  

                PermSetAssignment = [select id,PermissionSetId 
                                        from PermissionSetAssignment 
                                        where AssigneeId = :UserInfo.getUserId() and 
                                        PermissionSetId IN :PermSetList];
            }
            return PermSetAssignment; 
        }
        set;
    }



    public boolean EMEAPermSetUser{
        get{
            if (EMEAPermSetUser == null){
                EMEAPermSetUser = false;
                ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
                if(settings != null && settings.Portal_User_Emea_Permset_Id__c != null){
                                                            
                    if ((PermSetAssignment!=null)&& (PermSetAssignment.size() == 1)&&
                            (((String)PermSetAssignment[0].PermissionSetId).contains(settings.Portal_User_Emea_Permset_Id__c) )){
                        EMEAPermSetUser = true;
                    }                                           
                }                       
            }
            return EMEAPermSetUser;
        }
        set;
    }

    public boolean JapanPermSetUser{
        get{
            if (JapanPermSetUser == null){
                JapanPermSetUser = false;
                ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
                if(settings != null && settings.Portal_User_Japan_Permset_Id__c != null){                                                           
                    if ((PermSetAssignment!=null)&& (PermSetAssignment.size() == 1)&&
                            (((String)PermSetAssignment[0].PermissionSetId).contains(settings.Portal_User_Japan_Permset_Id__c) )){
                        JapanPermSetUser = true;
                    }                                           
                }                       
            }
            return JapanPermSetUser;
        }
        set;
    }
    

    public void createCase() {
        Case c = new Case();
        c.Subject = case_subject;
        if (case_Desc!=null){           
            c.Description = case_Desc.stripHtmlTags().removeEndIgnoreCase('<br>').removeStartIgnoreCase('<br>');             
            c.ES_DJC_Description__c = case_Desc;
        }
        
        String case_topic_api = getDataCategoryApiName();
        List<ESDJC_QuestionTopic2CaseType_Mapping__c> topic2caseList = [SELECT Question_Topic__c, Case_Type__c from ESDJC_QuestionTopic2CaseType_Mapping__c
                                                                        where Question_Topic__c = :case_topic_api limit 1];
        
        if (topic2caseList.size() > 0){         
            c.Type = topic2caseList[0].Case_Type__c;
        }
        c.Origin = 'Chatter Answers';
        c.CommunityId = currentCommunity;
        c.Status = 'New';
        c.Tier__c = 'Tier 1';
        c.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(userContact.division__c));
        insert c;        
        
    }
    
    private String getDataCategoryApiName() {
        try {
            DataCategoryGroupSobjectTypePair pair = new DataCategoryGroupSobjectTypePair();
            pair.setSobject('Question');
            pair.setDataCategoryGroupName('Topic');
            
            List<DescribeDataCategoryGroupStructureResult> dataCategoryStructureResult = 
                Schema.describeDataCategoryGroupStructures(new List<DataCategoryGroupSobjectTypePair>{pair}, false);
            
            for (DescribeDataCategoryGroupStructureResult singleResult : dataCategoryStructureResult) {
                    DataCategory[] topLevelCategories = singleResult.getTopCategories();
                    
                if (topLevelCategories != null && topLevelCategories.size() > 0) {
                    DataCategory[] childCategoriesOfAll = topLevelCategories[0].getChildCategories();
                    
                    for (DataCategory c : childCategoriesOfAll) {
                        if (c.getLabel() == currentCommunityName) {
                            for (DataCategory childCategoryOfCurrentCommunity : c.getChildCategories()) {
                                if (childCategoryOfCurrentCommunity.getLabel() == case_topic) {
                                    return childCategoryOfCurrentCommunity.getName();
                                }
                            }
                        }
                    }
                }
            }
        } catch(Exception e) { }
        return '';
    }
 

}