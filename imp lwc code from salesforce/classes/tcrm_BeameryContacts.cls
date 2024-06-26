/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 04-11-2023
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class tcrm_BeameryContacts {
    public class CustomFields {
		public String displayName;
		public String displayValue;
		public String id;
		public String name;
		public String value;
		public List<String> values;
		public List<String> visibleTo;
	}

	public class Experience {
		public Boolean current;
		public String description;
		public String endDate;
		public String id;
		public String organisationName;
		public String role;
		public String startDate;
	}

	public class Integrations {
		public Workday workday;
	}

    public class workday{
        public String id;
        public String url;
    }

	public List<Contacts> contacts;


	public class Contacts extends CoreObject {
		public String assignedTo;
		public Boolean confidential;
		public Confidentiality confidentiality;
		public String createdTime;
		public CreationSource creationSource;
		public List<CustomFields> customFields;
		public Boolean doNotContact;
		public List<Education> education;
		public List<String> emails;
		public List<Experience> experience;
		public String firstName;
        public String lastName;
		public String fullName;
		public Boolean gdprConsent;
		public String gdprConsentDate;
		public List<CreationSource> globalTags;
		public String id;
		public Integrations integrations;
		public Location location;
		public String primaryEmail;
		public List<String> links;
		public Source source;
		public List<Language> languages;
		public List<Pool> lists;
	}

	public class Language {
		public String languageCode;
		public String value;
	}

	public class Confidentiality {
		public String mode;
		public Shares shares;
	}

	public class Education {
		public Boolean current;
		public String degree;
		public String endDate;
		public String grade;
		public String id;
		public String major;
		public String organisationName;
		public String program;
		public String startDate;
	}

	public class CreationSource {
		public String id;
		public String value;
	}

	public class Source {
		public String value;
	}

	public class Location {
		public String address;
		public String country;
	}

	public class Shares {
		public List<String> teams;
		public List<String> users;
	}

	public class Pool{
		public String id;
		public String name;
		public String owner;
		public String updated_at;
	}
	
	public Integer last_batch;
	public Long total_count;

	public static tcrm_BeameryContacts parse(String json) {
		return (tcrm_BeameryContacts) System.JSON.deserialize(json, tcrm_BeameryContacts.class);
	}
}