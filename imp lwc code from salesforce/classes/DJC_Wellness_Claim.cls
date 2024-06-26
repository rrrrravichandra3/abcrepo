/**
 * Wrapper over wellness reimbursement claims
 * */
public class DJC_Wellness_Claim {
    
    public DJC_Wellness_Reimbursement_Claim__c claim { public get; private set;}
    public transient blob attachmentBlob { public get; public set;}
    public string fileName{public get; public set;}   
    public boolean isNew {public get; private set;}
    public List<Attachment> existingAttachments {public get; private set;}
    
    public DJC_Wellness_Claim (DJC_Wellness_Reimbursement_Claim__c claim, boolean isNew, List<Attachment> existingAttachments, String defaultCurrencyCode) {
        this.claim = claim;
        if (this.claim.DJC_Wellness_Amount_Requested__c == null) {
        	this.claim.CurrencyIsoCode = defaultCurrencyCode;    
        }        
        this.isNew = isNew;
        this.existingAttachments = existingAttachments;
    }
    
    public DJC_Wellness_Claim (DJC_Wellness_Reimbursement_Claim__c claim, boolean isNew, String defaultCurrencyCode) {
        this(claim, isNew, null, defaultCurrencyCode);
    }
    
    public Attachment getNewAttachment() {
        if ((attachmentBlob != null) && (fileName != null)) {
            return new Attachment(name= fileName, body= attachmentBlob, OwnerId = UserInfo.getUserId(), ParentId=claim.id);
        }
        return null;
    }
    
    public boolean validateAttachments() {
        if ((existingAttachments == null) && (attachmentBlob == null)) {
            return false;
        }        
        return true;
    }
    
    
    
}