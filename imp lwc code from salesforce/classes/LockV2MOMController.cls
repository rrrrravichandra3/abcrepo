/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 */

/*
 * this class will take an account and assign it to a user.
 * @author Mike Fullmore - 4/2/2009
*/

public class LockV2MOMController {
		private Boolean processing = false;
		private String effectiveDate = null;
		private String lockUnlockSelection = 'Lock';
        private List<String> results = new List<String>();
         
        public LockV2MOMController() {
                
        }
        
        public Boolean getDebugging() {
                return false;
        }
        
        public String[] getResults() {
                
                return this.results;
        }
        
        public String getEffectiveDate() {
        	return this.effectiveDate;
        }
        
        public void setEffectiveDate(String effectiveDate) {
        	this.effectiveDate = effectiveDate;
        }
        
        public String getLockUnlockSelection() {
        	return this.lockUnlockSelection;
        } 
        
        public String getLockUnlockSelectionToShow()
        {
        	if (lockUnlockSelection == 'Lock')
        	{
        		return Label.lockv2mom_Lock;	
        	}
        	else
        	{
        		return Label.lockv2mom_Unlock;
        	}
        }
        
        public void setLockUnlockSelection(String lockUnlockSelection) {
        	
        		this.lockUnlockSelection = lockUnlockSelection;
        	
        }
        
        public Boolean getProcessing() {
            
        	return this.processing;
        }
        
        public PageReference lockUnlockV2MOMs() {
                
                System.assert((this.getEffectiveDate() != null) && (this.getEffectiveDate().length() > 0));
                System.assert((this.getLockUnlockSelection() != null) && ((this.getLockUnlockSelection() == 'Lock') || (this.getLockUnlockSelection() == 'Unlock')));
                
                this.processing = true;
                
                this.results.add(this.getLockUnlockSelectionToShow() + ' ' + Label.LockV2MOMController_V2momStartedText + ' ' + System.Now().Format());
                
                // Note that due to governor limits if we need to lock/unlock more than 10,000 V2MOMs
                // then this will need to be rewritten to chunk through the V2MOMs
                System.assert((this.getEffectiveDate() != null) && (this.getEffectiveDate().length() > 0));
                V2MOM_Admin_Web_Services.lock_unlock_v2moms(this.getEffectiveDate(), (this.getLockUnlockSelection() == 'Lock'));
                
                this.results.add(this.getLockUnlockSelectionToShow() + ' ' + Label.LockV2MOMController_V2mom_completedText + ' ' + System.Now().Format());
                
                this.processing = false;
                
                return null;
        }
}