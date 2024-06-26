public with sharing class Acquisition_Docusign_List_Controller{

    public Boolean tooManyRecords{get;set;}
    public Boolean noRecord{get;set;}
    public Boolean processingInProgress {get;set;}
    public Boolean processingComplete {get;set;}
    public Integer currentIndex{get;set;}
    public Integer totalRecords{get;set;}
    private ApexPages.StandardSetController standardController{get;set;}
    public List<Acquisition_Offer__c> selectedAcqOffers{get;set;}
    transient String showProgress;
    transient String barLength;
    private final integer defaultRecordLimit = 200;
    private final integer recordLimit;
    
    
    //constructor to initialize variables
    public Acquisition_Docusign_List_Controller(ApexPages.StandardSetController standardController){
        this.standardController = standardController;
        this.recordLimit = getMaxAllowedRecords();
        this.noRecord = false;
        this.tooManyRecords = false;
        this.processingInProgress = false;
        this.currentIndex = 0;
        this.processingComplete = false;
        this.totalRecords = standardController.getSelected().size();
        checkRecordLimits();
        getAcquisitionOffers();
    }
    
    //It is absolutely necessary to have a value for recordLimit. If for any reason Label Acquisition_List_Max_Records shows unexpected behavior, resort to the default value stored in variable defaultRecordLimit
    public Integer getMaxAllowedRecords(){
        Integer maxRecords = defaultRecordLimit;
        try{
            maxRecords = Integer.valueOf(Label.Acquisition_List_Max_Records);
        }
        catch(Exception e){}
        return maxRecords;
    }

    public void getAcquisitionOffers(){
        Set<Id> selectedAcqOfferIDs = new Set<Id>();
        for(Acquisition_Offer__c currAcqOffer : (List<Acquisition_Offer__c>)standardController.getSelected()){
            selectedAcqOfferIDs.add(currAcqOffer.Id);
        }
        String query = Acquisition_Docusign_Util.getQueryFields();
        this.selectedAcqOffers = Database.query(query + ' where Id IN :selectedAcqOfferIDs');
    }

    public PageReference backToListView(){
        String prefixKey = Acquisition_Offer__c.sObjectType.getDescribe().getKeyPrefix();
        PageReference acqListView = new PageReference('/'+prefixKey+'/l');
        return acqListView;
    }

    public void checkRecordLimits(){
        if(this.totalRecords == 0){
            this.noRecord = true;
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.error,Label.Acquisition_List_No_record_Selected));
        }

        if(this.totalRecords > this.recordLimit){
            this.tooManyRecords = true;
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.error,getMaxRecordErrorMessage()));
        }
    }

    public String getMaxRecordErrorMessage(){
        //concatenation of 2 labels along with the variable recordLimit will allow us to display ANY custom message just by changing labels
        //Label1 + recordLimit + Label2
        //If any label is not needed, enter NA as it's value

        String msgString1 = (Label.Acquisition_List_Max_Error_1).trim();
        if(msgString1=='NA'){msgString1='';}
        String msgString2 = (Label.Acquisition_List_Max_Error_2).trim();
        if(msgString2=='NA'){msgString2='';}

        String errorMsg = msgString1 + ' ' + this.recordLimit + ' ' + msgString2;
        return errorMsg;
    }

    public String getshowProgress(){
        Integer currentRecordNumber = this.currentIndex + 1;
        String currentProgress = 'Processing '+currentRecordNumber+' of '+this.totalRecords+' Records';
        return currentProgress;
    }

    public String getbarLength(){
        Integer progressPercentage = 0;
        if(this.totalRecords!=0){
            if(this.processingInProgress){
                progressPercentage = ((this.currentIndex)*100)/(this.totalRecords);
            }else if(this.processingComplete){
                progressPercentage = ((this.currentIndex+1)*100)/(this.totalRecords);
            }
        }
        
        String width = progressPercentage+'%';
        return width;
    }

    public PageReference processRecord(){

        sendToDocuSign(this.selectedAcqOffers[this.currentIndex]);

        if((this.currentIndex+1)<(this.totalRecords)){
            this.currentIndex = this.currentIndex + 1;
        } else{
            this.processingInProgress = false;
            this.processingComplete = true;
        }
        return null;
    }

    public PageReference startProcess(){
        this.processingInProgress = true;
        return null;
    }



    /*
    * method to actually send docusign envelope
    */
    public void sendToDocuSign(Acquisition_Offer__c currAcqOffer){
        
            Acquisition_DocuSign_List_Contrl_Helper helperClassInstance = new Acquisition_DocuSign_List_Contrl_Helper();
            helperClassInstance.processAcquisitionOffer(currAcqOffer);
        
       
        
    }
}