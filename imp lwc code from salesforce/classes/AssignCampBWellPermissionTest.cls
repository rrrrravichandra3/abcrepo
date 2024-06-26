@isTest
public with sharing class AssignCampBWellPermissionTest {
	private class customLocalException extends Exception {
	}

	@TestSetup
	static void setUpContext() {
		ESDJC_Settings__c defaultSettings = new ESDJC_Settings__c(
			SetupOwnerId = UserInfo.getOrganizationId(),
			Thrive_Feature_Flag__c = true,
			Site_URL__c = 'foobar.com'
		);

		insert defaultSettings;
	}

	@isTest
	// Positive test
	public static void assignPermissionSet() {
		String permissionSetName = 'Camp_B_Well_User';
		PermissionSet campBWellPermissionSet;
		PermissionSetAssignment campBWellAssignment;

		Profile employeeProfile = [
			SELECT Id, Name
			FROM Profile
			WHERE Name = 'Employee'
			LIMIT 1
		];

		try {
			campBWellPermissionSet = [
				SELECT Id, Label
				FROM PermissionSet
				WHERE Name = :permissionSetName
				LIMIT 1
			];
		} catch (System.QueryException exc) {
			throw new customLocalException(
				permissionSetName + ' does not exist in this org'
			);
		}

		System.debug(UserInfo.getProfileId());

		Test.startTest();

		User newInternalUser = new User(
			FirstName = 'Internal',
			LastName = 'UserAHTest',
			Alias = 'IAHT',
			Email = 'angel.hernandez@salesforce.com',
			Username = 'IUAHTest@salesforce.com.pfdev3',
			ProfileId = employeeProfile.Id,
			EmployeeNumber = '9302testingNumber',
			emailencodingkey = 'UTF-8',
			languagelocalekey = 'en_US',
			localesidkey = 'en_US',
			TimeZoneSidKey = 'America/Los_Angeles'
		);

		insert newInternalUser;

		Test.stopTest();

		campBWellAssignment = [
			SELECT Id, AssigneeId, PermissionSetId
			FROM PermissionSetAssignment
			WHERE
				AssigneeId = :newInternalUser.Id
				AND PermissionSetId = :campBWellPermissionSet.Id
			LIMIT 1
		];

		System.assert(
			campBWellAssignment.AssigneeId == newInternalUser.Id &&
			campBWellAssignment.PermissionSetId == campBWellPermissionSet.Id,
			'There was a problem trying to assign ' +
			permissionSetName +
			' permission set.'
		);


	}

	@isTest
	// Negative test
	public static void avoidExternalUsers() {
		List<String> filteredEmployeeNumbers = new List<String>{
			'API ONLY',
			'APIONLY',
			'API Only',
			'APIOnly',
			'CNTRCT',
			'CRTCRT',
			'CTRCT',
			'HL - 703214',
			'HL - 705367',
			'mdavisMCSUB',
			'TBD',
			'NULL'
		};
		String permissionSetName = 'Camp_B_Well_User';
		PermissionSet campBWellPermissionSet;
		List<User> filteredUsers = new List<User>();

		Profile employeeProfile = [
			SELECT Id, Name
			FROM Profile
			WHERE Name = 'Employee'
			LIMIT 1
		];

		try {
			campBWellPermissionSet = [
				SELECT Id, Label
				FROM PermissionSet
				WHERE Name = :permissionSetName
				LIMIT 1
			];
		} catch (System.QueryException exc) {
			throw new customLocalException(
				permissionSetName + ' does not exist in this org'
			);
		}

		Test.startTest();

		for (String employeeNumber : filteredEmployeeNumbers) {
			User newInternalUser = new User(
				FirstName = generateRandomString(5),
				LastName = generateRandomString(5),
				Alias = generateRandomString(4),
				Email = 'foo.bar@salesforce.com',
				Username = generateRandomString(5) + '@salesforce.com.testing',
				ProfileId = employeeProfile.Id,
				EmployeeNumber = employeeNumber,
				emailencodingkey = 'UTF-8',
				languagelocalekey = 'en_US',
				localesidkey = 'en_US',
				TimeZoneSidKey = 'America/Los_Angeles'
			);

			filteredUsers.add(newInternalUser);
		}

		insert filteredUsers;

		Test.stopTest();

		List<PermissionSetAssignment> campBWellAssignment = [
			SELECT Id, AssigneeId, PermissionSetId
			FROM PermissionSetAssignment
			WHERE
				PermissionSetId = :campBWellPermissionSet.Id
				AND AssigneeId IN :filteredUsers
		];

		System.assert(
			campBWellAssignment.size() == 0,
			'There are one or more users that were not filtered by the permission set assignment.'
		);
	}

	private static String generateRandomString(Integer len) {
		String charSet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
		String randomString = '';
		while (randomString.length() < len) {
			Integer index = Math.mod(
				Math.abs(Crypto.getRandomInteger()),
				charSet.length()
			);
			randomString += charSet.substring(index, index + 1);
		}
		return randomString;
	}
}