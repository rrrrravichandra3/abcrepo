public class UpdateRoleHierarchy {
    /* bsoby 3/10/2011
     */
     
    /* updateForUsers()
     *
     * Take a list of users and update their roles to point to the roles
     * of their User.Manager__c (note that this is different than the standard
     * manager field. Apparently that's the field we use in Peopleforce).  
     * It doesn't support the case where a manager without a role exists.  
     * 
     * 
     * It's assumed that users passed to this function need their roles updated.  Check
     * that the manager field has changed before passing the user to this function
     */
       
    public static List<User> updateForUsers(User[] users) {        
        
        // Ids for managers and user roles so we can use a SOQL IN clause
        Set<Id> managerIds = new Set<Id>();
        Set<Id> userRoles = new Set<Id>();
        
        // We don't assume that all users have roles currently
        Map<User,UserRole> newRoles = new Map<User,UserRole>();
        
        for (User u : users) {
            if (u.Manager__c != null) {
                managerIds.add(u.Manager__c);
            }
            
            
            // Make sure the user has a role.  
            if (u.UserRoleId == null) {
                //Nope, create one and add it to a list for bulk insert
                String rName = '';
                if (u.FirstName != null) { rName += u.FirstName; }
                rName += u.LastName; // required field
                if (u.EmployeeNumber != null) { rName += u.EmployeeNumber; }
                
                newRoles.put(u,new UserRole(Name=rname));
            } else {
                // The role exists.  We're going to query these in bulk so grab the ID
                userRoles.add(u.UserRoleId);
            }
        }
        
        // If we wanted to support the case where managers didn't have roles,
        // we'd query all of the managers right about here, check their roles, and
        // create the missing ones.  I don't think this will happen though
        
        
        // If there are new roles, insert them.  After insert they have IDs so we
        // can go back and update their owning user with the ID
        if (newRoles.size() > 0) {  
            // Commented out for trigger mode (no User DML)
            // List<User> userUpdates = new List<User>();
            
            insert newRoles.values();
            for (User u : newRoles.keySet()) {
                // Now that we've created the new roles, update the users with the role IDs
                u.UserRoleId = newRoles.get(u).Id;
                
                // commented out for trigger mode (no User DML)
                // userUpdates.add(u);
                
            }
            
            // Normally we'd call update here but this is intended to be called from
            // a trigger and these users are coming from a trigger.new, something we
            // can't perform DML on. We're just going to make changes to the records
            // and our changes will be inserted in the normal course of business
            // "update userUpdates;"
        }
        
        // Bulk queries for stuff we'll use later
        Map<Id,User> managerMap = new Map<Id,User>([SELECT Id,Name,UserRoleId,EmployeeNumber 
                                                    FROM User 
                                                    WHERE Id IN: managerIds
                                                   ]);
        Map<Id,UserRole> roleMap = new Map<Id,UserRole> ([SELECT Id,Name,ParentRoleId
                                                          FROM UserRole
                                                          WHERE Id IN: userRoles
                                                         ]);
        for (UserRole r : newRoles.values()) {
            // Let's get these all in one place
            roleMap.put(r.Id,r);
        }
                                                         
        // List to hold roles for bulk update                                                 
        List<UserRole> updates = new List<UserRole>();
        UserRole uRole;
        for (User u: users) { 
            if (u.Manager__c != null) {
                User manager = managerMap.get(u.Manager__c);
                if (manager.UserRoleId == null) {
                    // We don't support this
                    u.Manager__c.addError('Peopleforce\'s manager-based hierarchy requires that user "'+
                                          manager.Name+'" has a role before they can have direct reports. '+
                                          'Please open and save the record and a role will be created for it '+
                                          'automatically');
                }
            }

            // Definitely exists because we would have created it earlier
            uRole = roleMap.get(u.UserRoleId);

            if (u.Manager__c != null) {
                // Set the user's UserRole's parent to that of the user's manager
                uRole.ParentRoleId = managerMap.get(u.Manager__c).UserRoleId;
            } else {
                // No manager?  Well, null out their parent role to reflect that status
                uRole.ParentRoleId = null;
            }
            updates.add(uRole);
        }
        update updates ;
        
        // Return the now-modified users.  Just for fun
        return users;
    }
}