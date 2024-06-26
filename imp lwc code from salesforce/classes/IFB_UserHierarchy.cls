public class IFB_UserHierarchy {
	// Each call to the 'getManagerHierarchyUserId' method get 4 managers above in the hierarchy.
	// If we set this limit to 3 recursive calls it means that we could get up to 16 managers above
	// a given user: 1 original call + 3 recursive calls = 4 managers + 4*3 managers = 16 managers.
	private static final Integer MAX_RECURSIVE_CALLS_getManagerHierarchyUserId =  3;
	private static Integer recursiveCallsCounterGetManagerHierarchyUserIdSet = 0;

	// Holds a cache of the manager hierarchy.
	private static Map<Id, IFB_Hierarchy> managerHiearchyMap = null;

	/**
	 * Auxiliar class used to hold and ordered list of managers:
	 * All managers for a given user since first level manager (first element) to
	 * the highest level manager (last element) are hold in the'managers' variable.
	 * The 'done' flag is used to indicate that the manager list is complete. Note
	 * that we could be done with the manager list before we reach the highest level 
	 * manager: based on business logic criteria/the way that this class is used we may
	 * stop at the third level manager (for example) and mark the hierachy as done.
	 */

	public class IFB_Hierarchy {
		public List<User> managers;
		public Boolean done;
		public Boolean reachedCEO;
		public IFB_Hierarchy() {
			this.managers = new List<User>();
			this.done = false;
			this.reachedCEO = false;
		}

		public User getLastManager() {
			User lastManager = null;
			if (managers.size() > 0) {
				lastManager = managers[managers.size() - 1];
			}
			return lastManager;
		}
	}

	/**
	 * Based on the managers hierarchy defined in the Manager__c field in User object, 
	 * populates a map with all the users above the provided user Ids.
	 *
	 * The hierarchyByUserId parameter serves both as an input and as and output parameter.
	 *
	 * To call this method pass an instance of a Map<Id, IFB_Hierarchy> where all the keys
	 * are the user Ids of the users you want to get the manager hiearchy. The values of this
	 * keys can be null or a fresh or partially pre-populated  instance of the IFB_Hierarchy__c class.
	 *
	 * After the execution of this method, the  IFB_Hierarchy__c instanace  by user id 
	 * will be now a populated list with the users in the manager hierarchy.
	 */
	public static void getManagerHierarchyUserIdSet(Map<Id, IFB_Hierarchy> hierarchyByUserId) {
		final String INVALID_PARAMETER_EXCEPTION = 'Can not get the user manager hierarchy for a set of users if their Ids are not provided.';
		final String NO_USER_FOUND_EXCEPTION = 'Can not get the user manager hierarchy. User was not found in the query results.';
		final String HIERARCHY_TOO_DEEP_EXCEPTION = 'There are to many managers in the hierarchy above this ';

		String CEO_MANAGEMENT_LEVEL = IFB_SIFTCustomMetadata.getSIFTSettingsMetadata().CEO_Management_Level__c;
	 	String FOUNDATIONCEOEMPNUMBER = TF2Settings__c.getInstance().Offer_Foundation_CEO_EID__c != null ? TF2Settings__c.getInstance().Offer_Foundation_CEO_EID__c:'F00001';

	 	if (CEO_MANAGEMENT_LEVEL == null || CEO_MANAGEMENT_LEVEL == '') {
	 		CEO_MANAGEMENT_LEVEL = '1.1 CEO & Chairman';
	 	}

		if (hierarchyByUserId == null) {
			throw new IFB_UserHierarchyException(INVALID_PARAMETER_EXCEPTION);
		}
		
		// For each of the users: If a new fresh/pre-populated instance of the hierarchy is not provided, 
		// we initialize a fresh new (empty) instance of the hierarchy.
		for (Id userId : hierarchyByUserId.keySet()) {
			if (hierarchyByUserId.get(userId) == null) {
				hierarchyByUserId.put(userId, new IFB_Hierarchy());
			}
		}

		// For the user hierarchies that we are not done yet, we query for manager users higher in the hierachy.
		// For pre-populated hierarchies we set the highest manager in the hierarchy (so far) as the base user in the query.
		Set<Id> userIdsToQuery = new Set<Id>();
		for (Id userId : hierarchyByUserId.keySet()) {
			if (hierarchyByUserId.get(userId).done == false) {
				if (hierarchyByUserId.get(userId).getLastManager() != null) {
					userIdsToQuery.add(hierarchyByUserId.get(userId).getLastManager().Id);
				} else{
					userIdsToQuery.add(userId);
				}
			}
		}

		// TODO: Verify if we should use the Manager__c or Manager field.
		// We query all the user's manager we can in a single query via 'relationships queries'
		// Relationship queries can be up to 5 levels deep
		Map<Id, User> queriedUsers = new Map<Id, User>([select Id,
									  	Manager__c, EmployeeNumber,
									  	Manager__r.isActive,
									  	Manager__r.Management_Level__c,
										Manager__r.Manager__c, Manager__r.EmployeeNumber,
										Manager__r.Manager__r.isActive,
										Manager__r.Manager__r.Management_Level__c,
										Manager__r.Manager__r.Manager__c, Manager__r.Manager__r.EmployeeNumber,
										Manager__r.Manager__r.Manager__r.isActive,
										Manager__r.Manager__r.Manager__r.Management_Level__c,
										Manager__r.Manager__r.Manager__r.Manager__c, Manager__r.Manager__r.Manager__r.EmployeeNumber,
										Manager__r.Manager__r.Manager__r.Manager__r.isActive,
										Manager__r.Manager__r.Manager__r.Manager__r.Management_Level__c, Manager__r.Manager__r.Manager__r.Manager__r.EmployeeNumber
										from User
										where Id = :userIdsToQuery]);
		
		for (Id userId : hierarchyByUserId.keySet()) {
			// We do the processing only for the hierarchies that we haven't maked as completed ('done')	
			IFB_Hierarchy hierarchy = hierarchyByUserId.get(userId);
			if (hierarchy.done == false) {
				
				// For the hiearchies that we have already started we get managers info of the highest
				// manager captured so far: it is a continuation of hiearchy.
				// For those hierarchies that we haven't started creating yet, we get the manager's info
				// of the user provided.
				User u = null;
				if (hierarchy.getLastManager() != null) {
					u = queriedUsers.get(hierarchy.getLastManager().Id);
				} else {
					u = queriedUsers.get(userId);
				}

				// Before or after adding the manager to the hierarchy, you can add your logic 
				// to stop the hierarchy here by doing hiearchy.done = true".
				// Regardles of any custom logic that could be implemented, if the manager field is
				// null, it means that we have reached the end of the manager hierarchy.
				if (u != null) {
					User manager = null;
					// First level manager
					if (u.Manager__c != null) {
						manager = new User(Id = u.Manager__c, isActive = u.Manager__r.isActive, Management_Level__c = u.Manager__r.Management_Level__c, EmployeeNumber = u.Manager__r.EmployeeNumber);
						if (manager.Management_Level__c == CEO_MANAGEMENT_LEVEL || manager.EmployeeNumber == FOUNDATIONCEOEMPNUMBER) {
							hierarchy.done = true;
							hierarchy.reachedCEO = true;
							if(manager.EmployeeNumber == FOUNDATIONCEOEMPNUMBER) {
								hierarchy.managers.add(manager);
							}
						} else {
							hierarchy.managers.add(manager);
						}
						
						// Second level manager
						if (hierarchy.done  == false && u.Manager__r.Manager__c != null) {
							manager = new User(Id = u.Manager__r.Manager__c, isActive = u.Manager__r.Manager__r.isActive, Management_Level__c = u.Manager__r.Manager__r.Management_Level__c, EmployeeNumber = u.Manager__r.Manager__r.EmployeeNumber);
							if (manager.Management_Level__c == CEO_MANAGEMENT_LEVEL || manager.EmployeeNumber == FOUNDATIONCEOEMPNUMBER) {
								hierarchy.done = true;
								hierarchy.reachedCEO = true;
								if(manager.EmployeeNumber == FOUNDATIONCEOEMPNUMBER) {
									hierarchy.managers.add(manager);
								}
							} else {
								hierarchy.managers.add(manager);
							}
							
							// Third level manager
							if (hierarchy.done  == false && u.Manager__r.Manager__r.Manager__c != null) {
								manager = new User(Id = u.Manager__r.Manager__r.Manager__c, isActive = u.Manager__r.Manager__r.Manager__r.isActive, Management_Level__c = u.Manager__r.Manager__r.Manager__r.Management_Level__c,
									               EmployeeNumber = u.Manager__r.Manager__r.Manager__r.EmployeeNumber);
								if (manager.Management_Level__c == CEO_MANAGEMENT_LEVEL || manager.EmployeeNumber == FOUNDATIONCEOEMPNUMBER) {
									hierarchy.done = true;
									hierarchy.reachedCEO = true;
									if(manager.EmployeeNumber == FOUNDATIONCEOEMPNUMBER) {
										hierarchy.managers.add(manager);
									}
								} else {
									hierarchy.managers.add(manager);
								}
								
								// Fourth level manager
								if (hierarchy.done  == false && u.Manager__r.Manager__r.Manager__r.Manager__c != null) {
									manager = new User(Id = u.Manager__r.Manager__r.Manager__r.Manager__c, isActive = u.Manager__r.Manager__r.Manager__r.Manager__r.isActive, 
										Management_Level__c = u.Manager__r.Manager__r.Manager__r.Manager__r.Management_Level__c, EmployeeNumber = u.Manager__r.Manager__r.Manager__r.Manager__r.EmployeeNumber);
									if (manager.Management_Level__c == CEO_MANAGEMENT_LEVEL || manager.EmployeeNumber == FOUNDATIONCEOEMPNUMBER) {
										hierarchy.done = true;
										hierarchy.reachedCEO = true;
										if(manager.EmployeeNumber == FOUNDATIONCEOEMPNUMBER) {
											hierarchy.managers.add(manager);
										}
									} else {
										hierarchy.managers.add(manager);
									}

								} else {
									hierarchy.done = true;
								}
							} else {
								hierarchy.done = true;
							}
						} else {
							hierarchy.done = true;
						}
					} else {
						hierarchy.done = true;
					}
				} else {
					// Somehow we got the Id of a user that does not exist or is not visible
					throw new IFB_UserHierarchyException(NO_USER_FOUND_EXCEPTION);
				}				
			}		
		}

		Boolean doneWithTheQueries = true;
		for (Id userId : hierarchyByUserId.keySet()) {
			if (hierarchyByUserId.get(userId).done == false) {
				doneWithTheQueries = false;
				break;
			}
		}
		
		if (doneWithTheQueries == false) {
			if (recursiveCallsCounterGetManagerHierarchyUserIdSet < MAX_RECURSIVE_CALLS_getManagerHierarchyUserId) {
				recursiveCallsCounterGetManagerHierarchyUserIdSet = recursiveCallsCounterGetManagerHierarchyUserIdSet + 1;
				// Recursive call!. Lets continue from the highest manager we got so far ...
				IFB_UserHierarchy.getManagerHierarchyUserIdSet(hierarchyByUserId);
			} else {
				// We have a user that has to many managers in the hierachy.
				// We want to prevent infinite recursion (and in consequece, query limits reached)
				// because of data issues.
				throw new IFB_UserHierarchyException(HIERARCHY_TOO_DEEP_EXCEPTION);
			}			
		}		
		return;
	}

	/* Get the Ids of all the Users that are above the given Users in the manager hierarchy */
	public static Map<Id, Set<Id>> getManagersIdsByUserId(Set<Id> userIds) {
		Map<Id, Set<Id>> managersIdsByUserId = new Map<Id, Set<Id>>();

		if (managerHiearchyMap == null) {
			managerHiearchyMap = new Map<Id, IFB_Hierarchy>();
		} 

		// For the users we have not get the hierarchy we initialize them in the map.
		if (managerHiearchyMap.keySet().containsAll(userIds) == false) {
			for (Id userId : userIds) {
				if (managerHiearchyMap.containsKey(userId) == false) {
					managerHiearchyMap.put(userId, null);
				}
			}
			getManagerHierarchyUserIdSet(managerHiearchyMap);
		}

		// Data structure transformation to return a set of Ids.
		for (Id userId : managerHiearchyMap.keySet()) {
			managersIdsByUserId.put(userId, new Set<Id>());
			for (User manager : managerHiearchyMap.get(userId).managers) {
				if (manager.isActive == true) {
					managersIdsByUserId.get(userId).add(manager.id);	
				}
				// If anywhere in the hierarchy there is an inactive user, we simply skip it.
			}
		}
		return managersIdsByUserId;
	}

	public static void resetrecursiveCallsCounterGetManagerHierarchyUserIdSet() {
		recursiveCallsCounterGetManagerHierarchyUserIdSet = 0;
	}
	
}