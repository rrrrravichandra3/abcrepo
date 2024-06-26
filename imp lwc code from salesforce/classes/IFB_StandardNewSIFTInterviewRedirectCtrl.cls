/**
 * @author Angel Abrego <aabrego@salesfore.com>
 * @date 2017-09-28
 * @description Refers users to the appropiate way of creating 'SIFT Interview' 
 *              records. Controlled by a custom setting, it refers the user to 
 *              the "Interview 1, 2 or 3" in Talentforce or the 
 *              "WD Job Application" record of WDR
 */
public with sharing class IFB_StandardNewSIFTInterviewRedirectCtrl {
  private Boolean referToTalentforce;

  public IFB_StandardNewSIFTInterviewRedirectCtrl(ApexPages.StandardController stdController) {
      this.referToTalentforce = false;
      IFB_SIFT_Settings_List__c settings;
      settings =  IFB_SIFT_Settings_List__c.getInstance('SIFT');
      if (settings != null) {
          this.referToTalentforce = settings.Refer_to_Talentforce_for_SIFT_Interviews__c;
      }
  }

  /**
   * @description Refers users to the appropiate way of creating 
   *              'SIFT Interview' records.
   * @return Title of the message to be displayed to the user
   */
  public String getRedirectMessageTitle() {
      String title;        
      if (referToTalentforce == true) {
          title = Label.IFB_NewSIFTIntRedirectTF_title;
      } else {
          title = Label.IFB_NewSIFTIntRedirect_title;
      }
      return title;
  }

  /**
   * @description Refers users to the appropiate way of creating
   *              'SIFT Interview' records
   * @return Summary of the message to be displayed to the user
   */
  public String getRedirectMessageSummary() {
      String summary;        
      if (referToTalentforce == true) {
          summary = Label.IFB_NewSIFTIntRedirectTF_summary;
      } else {
          summary = Label.IFB_NewSIFTIntRedirect_summary;
      }
      return summary;
  }
}