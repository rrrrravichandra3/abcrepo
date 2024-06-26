public class IFB_SIFTCustomMetadata {

	private static IFB_SIFT_Settings_Metadata__mdt siftSettingsMetadata;

	// Returns the 'SIFT' metadata (settings)
	public static IFB_SIFT_Settings_Metadata__mdt getSIFTSettingsMetadata() {
		if (siftSettingsMetadata == null) {
			siftSettingsMetadata = [select CEO_Management_Level__c from IFB_SIFT_Settings_Metadata__mdt
								    where DeveloperName = 'SIFT'];

		}
		return siftSettingsMetadata;
	}

}