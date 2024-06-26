public abstract with sharing class REWS_Ergo_Base_Form_Validation {
    
    public Case newCase{get; set;}
    
    public List<AttachmentWrapper> attachments{ get; set; }
    
    private static final Integer MAX_ATTACHMENT_SIZE = 9;
    
    private boolean isDetailsSet = false;
    
    private static ESDJC_Settings__c setting = ESDJC_Settings__c.getInstance();
    public static final Set<String> ERGO_LOCATIONS = new Set<String>(); 
    static{
        if(setting.Ergo_Locations__c!=null){
            for(String s : setting.Ergo_Locations__c.split(',',-1)){
                ERGO_LOCATIONS.add(s);
            }
        }
    }
    
    public boolean isErgoPresentOnSite {
        get{
            if (rewsController.contactCity == null){
                return false;
            }
            for (String location: ERGO_LOCATIONS){
                if (rewsController.contactCity.toLowerCase().contains(location)){
                    return true;
                }
            }       
            return false;
        }
    }
    
    
    
    public REWS_Controller rewsController { get; 
                                           set {
                                               rewsController = value;
                                               if ( !isDetailsSet ) {
                                                   newCase = rewsController.getNewCase();
                                                   setCaseDetails();
                                                   isDetailsSet = true;
                                               }
                                           } 
                                          }
    
    public REWS_Ergo_Base_Form_Validation() {
        attachments = new List<AttachmentWrapper>();
        for (Integer i = 0; i < MAX_ATTACHMENT_SIZE; i++) {
            attachments.add(new AttachmentWrapper());
        }
    }
    
    public virtual PageReference saveCase() {
        if (validateCase()) {
            isDetailsSet = false;
            setAttachments();
            PageReference pr = rewsController.saveCase(newCase);
            return pr;
        }
        return null;
    }
    
    
    
    
    public void cancelCase() {
        rewsController.cancelCase();
    }
    
    protected abstract boolean validateCase();
    protected abstract void setCaseDetails();
    
    public boolean isBlank(Object o) {
        return (o == null || o == '');
    }
    
    private void setAttachments() {
        rewsController.setAttachment1(attachments[0].attachment, attachments[0].fileName);
        rewsController.setAttachment2(attachments[1].attachment, attachments[1].fileName);
        rewsController.setAttachment3(attachments[2].attachment, attachments[2].fileName);
        rewsController.setAttachment4(attachments[3].attachment, attachments[3].fileName);
        rewsController.setAttachment5(attachments[4].attachment, attachments[4].fileName);
        rewsController.setAttachment6(attachments[5].attachment, attachments[5].fileName);
        rewsController.setAttachment7(attachments[6].attachment, attachments[6].fileName);
        rewsController.setAttachment8(attachments[7].attachment, attachments[7].fileName);
        rewsController.setAttachment9(attachments[8].attachment, attachments[8].fileName);
        
        for (Integer i = 0; i < MAX_ATTACHMENT_SIZE; i++) {
            attachments[i] = new AttachmentWrapper();
        }
    }
    
    class AttachmentWrapper {
        public transient blob attachment {get; set;}
        public String fileName {get; set;}
    }
}