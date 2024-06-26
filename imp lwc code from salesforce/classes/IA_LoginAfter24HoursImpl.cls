/**
 * @author VenkateswaraReddy Komireddy
 * @date 29/04/2022
 * @params : userId Id
 * @description : This Implements IA_LoginAfter24HoursInterface to Update Insiders Tracking object CandidateLogin field  
 * specific to  Peopleforce
 */
public without sharing class IA_LoginAfter24HoursImpl implements IA_LoginAfter24HoursInterface {
    public static void loginAfter24HoursReminder(Id userId) {
        System.enqueueJob(new IA_LoginAfter24HoursReminderQueuable(userId));
	}
}