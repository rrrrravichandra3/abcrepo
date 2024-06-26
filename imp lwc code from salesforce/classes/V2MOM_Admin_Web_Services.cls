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

global class V2MOM_Admin_Web_Services {
	
    public class V2MOMException extends Exception {}

    public static final Integer max_v2moms_to_lock = Limits.getLimitDMLRows();

    WebService static Boolean lock_unlock_v2moms(String effective_date, Boolean lock) {
        if ((effective_date == null) || (effective_date.length() == 0)) {
            throw new V2MOMException(Label.V2MOM_Admin_Web_Services_Error1 + '.');
        }
		
        if (lock == null) {
            throw new V2MOMException(Label.V2MOM_Admin_Web_Services_Error2 + '.');
        }

        Integer record_count = 0;

        return record_count < max_v2moms_to_lock;
    }


    // Make sure that all the sharing groups for each user and all the sharing rows for each V2MOM are correct.
    // Pass in a list of users that includes the ID and Manager__c field for each user.
    WebService static List<String> scrutiny(List<User> users) {
        List<String> actions_taken = new List<String>();

        Set<String> group_names = new Set<String>();
        for (User user : users) {
            System.assert(user.Id != null);
            if (user.Manager__c != null) {
                String manager = user.Manager__c;
               
                if (manager.trim().length() == 0) {
                    user.Manager__c = null;
                }
            }

            if (user.ReviewManager__c != null) {
                String manager = user.ReviewManager__c;
                if (manager.trim().length() == 0) {
                    user.ReviewManager__c = null;
                }
            }

            group_names.add('' + user.Id + V2MOM_Constants.ManagerGroupSuffix);
            group_names.add('' + user.Id + V2MOM_Constants.MgmgHierarchyGroupSuffix);
            group_names.add('' + user.Id + V2MOM_Constants.ReviewMgmgHierarchyGroupSuffix);
            group_names.add('' + user.Id + V2MOM_Constants.DirectReportsGroupSuffix);
            group_names.add('' + user.Id + V2MOM_Constants.TeamGroupSuffix);
            group_names.add('' + user.Id + V2MOM_Constants.PeersGroupSuffix);

            if (user.Manager__c  != null) {
                group_names.add('' + user.Manager__c + V2MOM_Constants.MgmgHierarchyGroupSuffix);
                group_names.add('' + user.Manager__c + V2MOM_Constants.DirectReportsGroupSuffix);
                group_names.add('' + user.Manager__c + V2MOM_Constants.TeamGroupSuffix);
            }

            if (user.ReviewManager__c  != null) {
                group_names.add('' + user.ReviewManager__c + V2MOM_Constants.ReviewMgmgHierarchyGroupSuffix);
            }
        }
		
        Map<String, Group> existing_groups = new Map<String, Group>();
        for (Group g : [select Id, Name from Group where Name in :group_names]) {
            existing_groups.put(g.Name, g);
        }

        Map<Id, Map<Id, GroupMember>> groupToUserOrGroupToGroupMembersMap = new Map<Id, Map<Id, GroupMember>>();
        
        for (GroupMember gm : [select Id, GroupId, UserOrGroupId from GroupMember where GroupId in :existing_groups.values()]) {
            Map<Id, GroupMember> userOrGroupToGroupMemberMap = groupToUserOrGroupToGroupMembersMap.get(gm.GroupId);
            if (userOrGroupToGroupMemberMap == null) {
                userOrGroupToGroupMemberMap = new Map<Id, GroupMember>();
                groupToUserOrGroupToGroupMembersMap.put(gm.GroupId, userOrGroupToGroupMemberMap);
            }
            userOrGroupToGroupMemberMap.put(gm.UserOrGroupId, gm);
        }

        List<Group> groups_to_create = new List<Group>();

        // If any of the necessary groups to process a user do not exist, create them
        for (User user : users) {
            add_new_group_to_lists_if_necessary(groups_to_create, existing_groups, user.Id, V2MOM_Constants.ManagerGroupSuffix, actions_taken);
            add_new_group_to_lists_if_necessary(groups_to_create, existing_groups, user.Id, V2MOM_Constants.MgmgHierarchyGroupSuffix, actions_taken);
            add_new_group_to_lists_if_necessary(groups_to_create, existing_groups, user.Id, V2MOM_Constants.ReviewMgmgHierarchyGroupSuffix, actions_taken);
            add_new_group_to_lists_if_necessary(groups_to_create, existing_groups, user.Id, V2MOM_Constants.DirectReportsGroupSuffix, actions_taken);
            add_new_group_to_lists_if_necessary(groups_to_create, existing_groups, user.Id, V2MOM_Constants.TeamGroupSuffix, actions_taken);
            add_new_group_to_lists_if_necessary(groups_to_create, existing_groups, user.Id, V2MOM_Constants.PeersGroupSuffix, actions_taken);

            if (user.Manager__c != null) {
                add_new_group_to_lists_if_necessary(groups_to_create, existing_groups, user.Manager__c, V2MOM_Constants.MgmgHierarchyGroupSuffix, actions_taken);
                add_new_group_to_lists_if_necessary(groups_to_create, existing_groups, user.Manager__c, V2MOM_Constants.DirectReportsGroupSuffix, actions_taken);
                add_new_group_to_lists_if_necessary(groups_to_create, existing_groups, user.Manager__c, V2MOM_Constants.TeamGroupSuffix, actions_taken);
            }

            if (user.ReviewManager__c != null) {
                add_new_group_to_lists_if_necessary(groups_to_create, existing_groups, user.ReviewManager__c, V2MOM_Constants.ReviewMgmgHierarchyGroupSuffix, actions_taken);
            }
        }
        if (groups_to_create.size() > 0) {
            insert groups_to_create;
        }

        List<GroupMember> members_to_create = new List<GroupMember>();

        // For each user, make sure:
        // 1) The user's Mgmt Hierarchy group includes the user's ID
        // 2) The user's Team group includes the user's Direct Reports group
        // If the user's manager is not NULL:
        // 3) The user's Manager group includes the manager's ID
        // 4) The user's Mgmt Hierarchy group includes the manager's Mgmt Hierarchy group
        // 5) The user's Peers group includes the manager's Direct Reports group
        // 6) The manager's Direct Reports group includes the user's ID
        // 7) The manager's Team group includes the user's Team group
        // 8) The user's Review Mgmt Hierarchy group includes the user's ID
        // 9) The user's Review Mgmt Hierarchy group includes the manager's Review Mgmt Hierarchy group
        for (User user : users) {

            // 1) The user's Mgmt Hierarchy group includes the user's ID
            Group userMgmtHierarchy = existing_groups.get('' + user.Id + V2MOM_Constants.MgmgHierarchyGroupSuffix);
            System.assert(userMgmtHierarchy != null);
            System.assert(userMgmtHierarchy.Id != null);

            add_new_group_member_to_list_if_necessary(members_to_create, groupToUserOrGroupToGroupMembersMap, userMgmtHierarchy.Id, user.Id, actions_taken);

            // 2) The user's Team group includes the user's Direct Reports group
            Group userTeam = existing_groups.get('' + user.Id + V2MOM_Constants.TeamGroupSuffix);
            System.assert(userTeam != null);
            System.assert(userTeam.Id != null);

            Group userDirectReports = existing_groups.get('' + user.Id + V2MOM_Constants.DirectReportsGroupSuffix);
            System.assert(userDirectReports != null);
            System.assert(userDirectReports.Id != null);

            add_new_group_member_to_list_if_necessary(members_to_create, groupToUserOrGroupToGroupMembersMap, userTeam.Id, userDirectReports.Id, actions_taken);

            if (user.Manager__c != null) {

                // 3) The user's Manager group includes the manager's ID
                Group userManager = existing_groups.get('' + user.Id + V2MOM_Constants.ManagerGroupSuffix);
                System.assert(userManager != null);
                System.assert(userManager.Id != null);

                add_new_group_member_to_list_if_necessary(members_to_create, groupToUserOrGroupToGroupMembersMap, userManager.Id, user.Manager__c, actions_taken);

                // 4) The user's Mgmt Hierarchy group includes the manager's Mgmt Hierarchy group
                System.assert(userMgmtHierarchy != null);
                System.assert(userMgmtHierarchy.Id != null);

                Group managerMgmtHierarchy = existing_groups.get('' + user.Manager__c + V2MOM_Constants.MgmgHierarchyGroupSuffix);
                System.assert(managerMgmtHierarchy != null);
                System.assert(managerMgmtHierarchy.Id != null);

                add_new_group_member_to_list_if_necessary(members_to_create, groupToUserOrGroupToGroupMembersMap, userMgmtHierarchy.Id, managerMgmtHierarchy.Id, actions_taken);

                // 5) The user's Peers group includes the manager's Direct Reports group
                Group userPeers = existing_groups.get('' + user.Id + V2MOM_Constants.PeersGroupSuffix);
                System.assert(userPeers != null);
                System.assert(userPeers.Id != null);

                Group managerDirectReports = existing_groups.get('' + user.Manager__c + V2MOM_Constants.DirectReportsGroupSuffix);
                System.assert(managerDirectReports != null);
                System.assert(managerDirectReports.Id != null);

                add_new_group_member_to_list_if_necessary(members_to_create, groupToUserOrGroupToGroupMembersMap, userPeers.Id, managerDirectReports.Id, actions_taken);

                // 6) The manager's Direct Reports group includes the user's ID
                System.assert(managerDirectReports != null);
                System.assert(managerDirectReports.Id != null);

                add_new_group_member_to_list_if_necessary(members_to_create, groupToUserOrGroupToGroupMembersMap, managerDirectReports.Id, user.Id, actions_taken);

                // 7) The manager's Team group includes the user's Team group
                Group managerTeam = existing_groups.get('' + user.Manager__c + V2MOM_Constants.TeamGroupSuffix);
                System.assert(managerTeam != null);
                System.assert(managerTeam.Id != null);

                System.assert(userTeam != null);
                System.assert(userTeam.Id != null);

                add_new_group_member_to_list_if_necessary(members_to_create, groupToUserOrGroupToGroupMembersMap, managerTeam.Id, userTeam.Id, actions_taken);
            }

            // 8) The user's Mgmt Hierarchy group includes the user's ID
            Group userReviewMgmtHierarchy = existing_groups.get('' + user.Id + V2MOM_Constants.ReviewMgmgHierarchyGroupSuffix);
            System.assert(userReviewMgmtHierarchy != null);
            System.assert(userReviewMgmtHierarchy.Id != null);

            add_new_group_member_to_list_if_necessary(members_to_create, groupToUserOrGroupToGroupMembersMap, userReviewMgmtHierarchy.Id, user.Id, actions_taken);

            if (user.ReviewManager__c != null) {

                // 9) The user's Mgmt Hierarchy group includes the manager's Mgmt Hierarchy group
                System.assert(userReviewMgmtHierarchy != null);
                System.assert(userReviewMgmtHierarchy.Id != null);

                Group managerReviewMgmtHierarchy = existing_groups.get('' + user.ReviewManager__c + V2MOM_Constants.ReviewMgmgHierarchyGroupSuffix);
                System.assert(managerReviewMgmtHierarchy != null);
                System.assert(managerReviewMgmtHierarchy.Id != null);

                add_new_group_member_to_list_if_necessary(members_to_create, groupToUserOrGroupToGroupMembersMap, userReviewMgmtHierarchy.Id, managerReviewMgmtHierarchy.Id, actions_taken);
            }
        }

        if (members_to_create.size() > 0) {
            insert members_to_create;
        }

        // Validate the sharing on each of the given user's V2MOMs
        List<V2MOM__Share> shares_to_create = new List<V2MOM__Share>();
        List<V2MOM__Share> shares_to_delete = new List<V2MOM__Share>();

        for (V2MOM__c v : [select Id, Share_With__c, OwnerId, (select Id, UserOrGroupId from Shares where RowCause = 'Manual') from V2MOM__c where OwnerId in :users]) {
            System.assert(v.Id != null);
            System.assert(v.OwnerId != null);
            System.assert(v.Shares != null);

            Map<Id, V2MOM__Share> groups_shared_to_v2mom = new Map<Id, V2MOM__Share>();
            for (V2MOM__Share share : v.Shares) {
                System.assert(share.Id != null);
                System.assert(share.UserOrGroupId != null);
                groups_shared_to_v2mom.put(share.UserOrGroupId, share);
            }

          //  add_or_remove_shares_if_necessary(shares_to_create, shares_to_delete, v, V2MOM_Constants.ManagerPicklistValue, V2MOM_Constants.ManagerGroupSuffix, existing_groups, groups_shared_to_v2mom, actions_taken);
            add_or_remove_shares_if_necessary(shares_to_create, shares_to_delete, v, V2MOM_Constants.MgmgHierarchyPicklistValue, V2MOM_Constants.MgmgHierarchyGroupSuffix, existing_groups, groups_shared_to_v2mom, actions_taken);
            add_or_remove_shares_if_necessary(shares_to_create, shares_to_delete, v, V2MOM_Constants.DirectReportsPicklistValue, V2MOM_Constants.DirectReportsGroupSuffix, existing_groups, groups_shared_to_v2mom, actions_taken);
            add_or_remove_shares_if_necessary(shares_to_create, shares_to_delete, v, V2MOM_Constants.TeamPicklistValue, V2MOM_Constants.TeamGroupSuffix, existing_groups, groups_shared_to_v2mom, actions_taken);
            add_or_remove_shares_if_necessary(shares_to_create, shares_to_delete, v, V2MOM_Constants.PeersPicklistValue, V2MOM_Constants.PeersGroupSuffix, existing_groups, groups_shared_to_v2mom, actions_taken);
        }

        if (shares_to_delete.size() > 0) {
            delete shares_to_delete;
        }

        if (shares_to_create.size() > 0) {
            insert shares_to_create;
        }

        return actions_taken;
    }

    private static void add_new_group_member_to_list_if_necessary(List<GroupMember> members_to_create, Map<Id, Map<Id, GroupMember>> groupToUserOrGroupToGroupMembersMap, Id group_id, Id user_or_group_id, List<String> actions_taken) {
        Map<Id, GroupMember> userOrGroupToGroupMemberMap = groupToUserOrGroupToGroupMembersMap.get(group_id);
        if ((userOrGroupToGroupMemberMap == null) || (userOrGroupToGroupMemberMap.get(user_or_group_id) == null)) {
            if (userOrGroupToGroupMemberMap == null) {
                userOrGroupToGroupMemberMap = new Map<Id, GroupMember>();
                groupToUserOrGroupToGroupMembersMap.put(group_id, userOrGroupToGroupMemberMap);
            }
            GroupMember new_member = new GroupMember(GroupId = group_id, UserOrGroupId = user_or_group_id);
            actions_taken.add(Label.Inserting_label + ': ' + new_member);
            members_to_create.add(new_member);
            userOrGroupToGroupMemberMap.put(user_or_group_id, new_member);
        }
    }

    private static void add_new_group_to_lists_if_necessary(List<Group> groups_to_create, Map<String, Group> existing_groups, Id id, String suffix, List<String> actions_taken) {
        System.debug('entroooo ' + existing_groups + '\n \n \n');
        System.debug('entroooo ' + id + '\n \n \n');
        System.debug('entroooo ' + suffix + '\n \n \n');
        if (existing_groups.get('' + id + suffix) == null) {
        	
            Group new_group = new Group(Name = '' + id + suffix);
            actions_taken.add(Label.Inserting_label + ': ' + new_group);
            groups_to_create.add(new_group);
            existing_groups.put(new_group.Name, new_group);
        }
    }

    private static void add_or_remove_shares_if_necessary(List<V2MOM__Share> shares_to_create, List<V2MOM__Share> shares_to_delete, V2MOM__c v, String picklist_value, String group_name, Map<String, Group> existing_groups, Map<Id, V2MOM__Share> groups_shared_to_v2mom, List<String> actions_taken) {
        System.assert(v.OwnerId != null);

        Group sharing_group = existing_groups.get('' + v.OwnerId + group_name);
        System.assert(sharing_group != null);
        System.assert(sharing_group.Id != null);

        if ((v.Share_With__c != null) && v.Share_With__c.contains(picklist_value)) {
            if (!groups_shared_to_v2mom.containsKey(sharing_group.Id)) {
                V2MOM__Share new_share = new V2MOM__Share(AccessLevel = 'Read', ParentId = v.Id, UserOrGroupId = sharing_group.Id);
                actions_taken.add(Label.Inserting_label + ': ' + new_share);
                shares_to_create.add(new_share);
            }
        } else {
            if (groups_shared_to_v2mom.containsKey(sharing_group.Id)) {
                V2MOM__Share share_to_delete = groups_shared_to_v2mom.get(sharing_group.Id);
                System.assert(share_to_delete != null);
                actions_taken.add(Label.Deleting_label + ': ' + share_to_delete);
                shares_to_delete.add(share_to_delete);
            }
        }
    }
}