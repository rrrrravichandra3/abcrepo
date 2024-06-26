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

public class V2MOM_Sharing_Util {
 
	public static void assign_sharing(V2MOM__c v2mom, String picklist_value, String group_suffix, Map<String, Id> group_name_map, List<V2MOM__Share> new_shares) {
		System.assert(v2mom.Id != null);
		System.assert(v2mom.OwnerId != null);
		System.assert(v2mom.Share_With__c != null);
		
		if (v2mom.Share_With__c.contains(picklist_value)) {
			String group_name = '' + v2mom.OwnerId + group_suffix;
			Id share_group_id = group_name_map.get(group_name);
			if (share_group_id == null) {
				v2mom.Share_With__c.addError(Label.V2MOM_Sharing_Error1 + '.');
			} else {
				new_shares.add(new V2MOM__Share(AccessLevel = 'Read', ParentId = v2mom.id, UserOrGroupId = share_group_id));
			}
		}
	}
	
}