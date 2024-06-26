public with sharing class IA_UtilCustomization {
    public String candidateContactId { get; set; }

    /*******************************************************************************************************
     * @description Getter method used in IA_Email_Candidate_Start_Date Visualforce component, retrieves
     *              the Candidate's Start Date based on the last Job Application record that was updated.
     */
    public String getCandidateStartDate() {
        WDR_Application__c jobApp = [SELECT Start_Date__c FROM WDR_Application__c WHERE Candidate__r.Candidate_Contact__c = :candidateContactId ORDER BY LastModifiedDate DESC LIMIT 1];

        String startDate;
        if (jobApp.Start_Date__c != null) {
            Datetime d = Date.Valueof(jobApp.Start_Date__c);
            startDate = ' on ' + d.formatGMT('EEEE, MMMM d yyyy');
        } else {
            startDate = ' soon';
        }

        return startDate;
    }
}