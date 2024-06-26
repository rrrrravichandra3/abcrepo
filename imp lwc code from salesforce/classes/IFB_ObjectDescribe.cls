public class IFB_ObjectDescribe {

	private static Map<String, String> objectKeyPrefixByObjectAPIName = new Map<String, String>();

	// Gets the 3 letter object prefix of a Custom Object
	public static String getObjectPrefix(String objectAPIName) {
		String keyPrefix;

		if (objectKeyPrefixByObjectAPIName.containsKey(objectAPIName) == true) {
			keyPrefix = objectKeyPrefixByObjectAPIName.get(objectAPIName);
		} else {
			keyPrefix = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().getKeyPrefix();
			objectKeyPrefixByObjectAPIName.put(objectAPIName, keyPrefix);
		}

		return keyPrefix;
	}

	// Gets the salesforce.com Id of a Custom Object
	public static Id getObjectId(String objectAPIName, String fieldAPIName) {
		Id objectId;

		return objectId;
	}

	// Gets the saleforce.com Id of a Custom Field
	public static Id getFieldId(String objectAPIName, String fieldAPIName) {
		Id fieldId;

		return fieldId;
	}
}