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

public class V2MOM_Constants {
 
	// Every user has the following groups that are used for sharing:
	// 1) Manager: includes the user's manager
	// 2) Mgmt Hierarchy: includes the user and the Mgmt Hierarchy group for the user's manager
	// 3) Direct Reports: includes all of the user's direct reports
	// 4) Team: includes the user's Direct Reports group and the Team groups of all of the user's direct reports
	// 5) Peers: includes the manager's direct reports group
	public static final String ManagerGroupSuffix = '-Manager_V2MOM';
	public static final String MgmgHierarchyGroupSuffix = '-Mgmt_Hierarchy_PAM';
	public static final String ReviewMgmgHierarchyGroupSuffix = '-R_Mgmt_Hierarchy_PAM';
	public static final String DirectReportsGroupSuffix = '-Direct_Reports_V2MOM';
	public static final String TeamGroupSuffix = '-Team_V2MOM';
	public static final String PeersGroupSuffix = '-Peers_V2MOM';

	// Sharing on each V2MOM is determined by the value of a multi-select picklist
	public static final String ManagerPicklistValue = 'My Manager';
	public static final String MgmgHierarchyPicklistValue = 'My Management Hierarchy';
	public static final String DirectReportsPicklistValue = 'My Direct Reports';
	public static final String TeamPicklistValue = 'My Entire Team';
	public static final String PeersPicklistValue = 'My Peers';

}