/**
* @author Sanghamitra
* @date 07/06/2024
*
* @description This class is a helper class for IA_InsidersInvitationBatch.
*/
public with sharing class IA_InsidersInvitationBatchHelper {
    
    
    /**
* @description : This method is used to retrieve the query configuration for IA_Invitation_Criteria_Group__mdt.
* It returns the query configuration as a string.
*
* @return The query configuration for IA_Invitation_Criteria_Group__mdt as a string.
*/
    // QUERY CONFIGURATION:
    public static String retrieveGroupQuery() {
        List<IA_Invitation_Config__mdt> data = [
            SELECT Id, Object_API_Name__c, Query__c
            FROM IA_Invitation_Config__mdt
            WHERE Type__c = 'QUERY' AND Object_API_Name__c = 'IA_Invitation_Criteria_Group__mdt'
            WITH SECURITY_ENFORCED
        ];
        return data[0].Query__c;
    }
    /**
* @description : This method is used to retrieve the query configuration for IA_Invitation_Criteria_Persona__mdt.
* It returns the query configuration as a string.
*
* @return The query configuration for IA_Invitation_Criteria_Persona__mdt as a string.
*/
    public static String retrievePersonaQuery() {
        List<IA_Invitation_Config__mdt> data = [
            SELECT Id, Object_API_Name__c, Query__c
            FROM IA_Invitation_Config__mdt
            WHERE Type__c = 'QUERY' AND Object_API_Name__c = 'IA_Invitation_Criteria_Persona__mdt'
            WITH SECURITY_ENFORCED
        ];
        return data[0].Query__c;
    }
    /**
* @description : This method is used to retrieve the query configuration for WDR_Application__c.
* It returns the query configuration as a string.
*
* @return The query configuration for WDR_Application__c as a string.
*/
    public static String retrieveJobAppQuery() {
        List<IA_Invitation_Config__mdt> data = [
            SELECT Id, Object_API_Name__c, Query__c
            FROM IA_Invitation_Config__mdt
            WHERE Type__c = 'QUERY' AND Object_API_Name__c = 'WDR_Application__c'
            WITH SECURITY_ENFORCED
        ];
        return data[0].Query__c;
    }
    /**
* @description : This method is used to retrieve the query configuration for Insiders_Tracking__c.
* It returns the query configuration as a string.
*
* @return The query configuration for Insiders_Tracking__c as a string.
*/
    public static String retrieveTrackingIVTQuery() {
        List<IA_Invitation_Config__mdt> data = [
            SELECT Id, Object_API_Name__c, Query__c
            FROM IA_Invitation_Config__mdt
            WHERE Type__c = 'QUERY' AND Object_API_Name__c = 'Insiders_Tracking__c'
            WITH SECURITY_ENFORCED
        ];
        return data[0].Query__c;
    }
    /**
* @description : This method is used to extract the email templates from the provided list of configuration wrappers.
* It returns a string containing the email templates separated by commas and enclosed in single quotes.
* If no email templates are found, it returns an empty string enclosed in parentheses.
*
* @param input The list of configuration wrappers to extract the email templates from.
* @return A string containing the email templates separated by commas and enclosed in single quotes, or an empty string enclosed in parentheses if no email templates are found.
*/
    public static String extractTemplates(List<IA_InsidersInvitationBatchHelper.ConfigWrapper> input) {
        // SELECT Id FROM EmailTemplate WHERE DeveloperName
        Set<String> resultSet = new Set<String>();
        String result = '';
        if (!input.isEmpty()) {
            for (IA_InsidersInvitationBatchHelper.ConfigWrapper item : input) {
                String name = (String)item.fields.get('Email_Template__c');
                resultSet.add(name);
            }
            List<String> resultList = new List<String>(resultSet);
            Integer increment = 0;
            Integer len = resultSet.size();
            for (String item : resultSet) {
                increment++;
                result += increment >= len ?  '\'' + item + '\'' : '\'' + item + '\', ';
            }
        }
        return resultSet.isEmpty() ? '(\'\')' : '(' + result + ')';
    }
    /**
* @description : This method is used to compose the scope of job applications to retrieve.
* It takes a list of job applications as input and returns a string containing the names of the job applications separated by commas and enclosed in single quotes.
* If no job applications are found, it returns an empty string enclosed in parentheses.
*
* @param data The list of job applications to compose the scope for.
* @return A string containing the names of the job applications separated by commas and enclosed in single quotes, or an empty string enclosed in parentheses if no job applications are found.
*/
    // CONFIG PREPARATION:
    public static String composeJobAppScopeToRetrieve(List<IA_Invitation_JobApplication__c> data) {
        String result = '';
        for (IA_Invitation_JobApplication__c item : data) {
            result = String.isNotBlank(result) ? result + ', ' + '\'' + item.Name + '\'' : '\'' + item.Name + '\'';
        }
        return String.isBlank(result) ? '(\'\')' : '(' + result + ')';
    }
    /**
* @description : This method is used to retrieve the query configuration for IA_Invitation_Criteria_Group__mdt and IA_Invitation_Criteria_Persona__mdt.
* It returns a list of `IA_Invitation_Config__mdt` objects where the `Type__c` field value is 'FIELDS'.
*
* @return A list of `IA_Invitation_Config__mdt` objects containing the query configuration for the specified types.
*/
    public static List<IA_Invitation_Config__mdt> fieldsCriteriaConfig() {
        List<IA_Invitation_Config__mdt> data = [
            SELECT Id, Type__c,
            Object_API_Name__c,
            Job_Application_Fields__c,
            Job_Requisition_Fields__c
            FROM IA_Invitation_Config__mdt
            WHERE Type__c = 'FIELDS' WITH SECURITY_ENFORCED
        ];
        return data;
    }
    /**
* @description : This method is used to compose the scope of job applications to retrieve.
* It takes a list of job applications as input and returns a list of `ConfigWrapper` objects.
* Each `ConfigWrapper` object contains the fields, criteria, and list of personas for a specific job application.
*
* @param fieldsConfigList The list of job application configurations to compose the scope for.
* @param criteriaList The list of criteria configurations to match with the job application configurations.
* @return A list of `ConfigWrapper` objects containing the job application configurations and their corresponding criteria configurations.
*/
    public static List<ConfigWrapper> compose(List<SObject> fieldsConfigList, List<IA_Invitation_Config__mdt> criteriaList) {
        List<ConfigWrapper> result = new List<ConfigWrapper>();
        for (SObject fields : fieldsConfigList) {
            Id index = (Id)fields.get('IA_Invitation_Config__c');
            IA_Invitation_Config__mdt criteria = findConfigByIndex(criteriaList, index);
            List<ConfigWrapper> personas = new List<ConfigWrapper>();
            ConfigWrapper item = new ConfigWrapper(fields, criteria, personas);
            result.add(item);
        }
        return result;
    }
    /**
* @description : This method is used to group the personas based on their associated criteria junctions.
* It takes two lists of `ConfigWrapper` objects as input: the first list contains the group configurations,
* and the second list contains the persona configurations. The method iterates through the group configurations,
* retrieves the junction ID from each group's fields, and then searches for the corresponding personas in the second list.
* If a match is found, the persona is added to the group's list of personas. Finally, the method returns a list of `ConfigWrapper` objects,
* each containing a group of personas that share the same criteria junction.
* @param groupsList The list of group configurations to group the personas by.
* @param personasList The list of persona configurations to group by their associated criteria junctions.
* @return A list of `ConfigWrapper` objects, each containing a group of personas that share the same criteria junction.
*/
    public static List<ConfigWrapper> groupPersonas(List<ConfigWrapper> groupsList, List<ConfigWrapper> personasList) {
        List<ConfigWrapper> result = new List<ConfigWrapper>();
        for (ConfigWrapper groupItem : groupsList) {
            Id junctionId = (Id)groupItem.fields.get('IA_Invitation_Criteria_Junction__c');
            if (junctionId != null) {
                List<ConfigWrapper> groupedPersonas = new List<ConfigWrapper>();
                for (ConfigWrapper persona : personasList) {
                    if ((Id)persona.fields.get('IA_Invitation_Criteria_Junction__c') == junctionId) {
                        groupedPersonas.add(persona);
                    }
                }
                if (!groupedPersonas.isEmpty()) {
                    groupItem.personas = groupedPersonas;
                    result.add(groupItem);
                }
            }
        }
        return result;
    }
    /**
* @description : This method is used to find a specific configuration by its index.
* It takes a list of `IA_Invitation_Config__mdt` objects and an `Id` as input, and returns the configuration object if it exists in the list.
* If the configuration object is not found, it returns `null`.
*
* @param items The list of `IA_Invitation_Config__mdt` objects to search through.
* @param index The `Id` of the configuration to find.
* @return The `IA_Invitation_Config__mdt` object associated with the given index, or `null` if no match is found.
*/
    private static IA_Invitation_Config__mdt findConfigByIndex(List<IA_Invitation_Config__mdt> items, Id index) {
        for (IA_Invitation_Config__mdt item : items) {
            if (item.Id == index) {
                return item;
            }
        }
        return null;
    }
    
    
    /**
* @description : This method is used to match job application personas with the provided criteria.
* It takes a job application and a list of group configurations as input, and returns a list of matching wrappers.
* Each matching wrapper contains a group of personas that share the same criteria junction.
*
* @param jobApp The job application to match with the group configurations.
* @param groups The list of group configurations to match with the job application configurations.
* @return A list of matching wrappers, each containing a group of personas that share the same criteria junction.
*/
    // EXECUTION:
    public static List<MatchingWrapper> matchPersonaByCriteria(WDR_Application__c jobApp, List<ConfigWrapper> groups) {
        List<MatchingWrapper> result = new List<MatchingWrapper>();
        for (ConfigWrapper groupItem : groups) {
            Boolean toInverseGroup = (Boolean)groupItem.fields.get('Inversion__c');
            Boolean isGroup = filterByConfig(jobApp, groupItem.criteria, groupItem.fields, toInverseGroup, false);
            if(!isGroup) continue;
            String groupTemplate = (String)groupItem.fields.get('Email_Template__c');
            Integer groupPriority = Integer.valueOf(groupItem.fields.get('Priority_Order__c'));
            List<MatchingWrapper> personasResult = new List<MatchingWrapper>();
            if (!groupItem.personas.isEmpty()) {
                personasResult = getPersonaList(groupItem.personas,jobApp);
            }
            personasResult.sort();
            MatchingWrapper groupOut = new MatchingWrapper(groupTemplate, groupPriority, personasResult);
            result.add(groupOut);
        }
        result.sort();
        return result;
    }
    
    /**
* @description: This method return the Matching Wrapper
* @param configList list of config wrapper.
* @param jobApp object of Wdr Application.
* @return A List of match wrapping.
*/
    private static List<MatchingWrapper> getPersonaList(List<ConfigWrapper> configList, WDR_Application__c jobApp) {
        List<MatchingWrapper> personasResult = new List<MatchingWrapper>();
        for (ConfigWrapper persona : configList) {
            Boolean toInversePersona = (Boolean)persona.fields.get('Inversion__c');
            Boolean isPersona = filterByConfig(jobApp, persona.criteria, persona.fields, toInversePersona, true);
            if (!isPersona) continue;
            
            String personaTemplate = (String)persona.fields.get('Email_Template__c');
            Integer personaPriority = Integer.valueOf(persona.fields.get('Priority_Order__c'));
            MatchingWrapper personaMatching = new MatchingWrapper(personaTemplate, personaPriority, null);
            personasResult.add(personaMatching);
            
        }
        return personasResult;
    }
    
    /**
* @description This method is used to determine if a job application matches the criteria specified in a configuration.
* It takes a job application and a configuration as input, and returns a boolean value indicating if the job application matches the criteria.
* The method checks if the job application fields specified in the configuration match the actual job application fields, and if the job requisition fields specified in the configuration match the actual job requisition fields.
* If the job application fields and job requisition fields match the criteria specified in the configuration, the method returns true; otherwise, it returns false.
* The method also takes into account an "inversion" parameter, which can be used to invert the matching logic. If the "inversion" parameter is true, the method returns the opposite of the matching result.
* @param jobApp The job application to match with the configuration.
* @param criteria The configuration to match with the job application.
* @param fields The fields of the job application to compare with the configuration.
* @param inversion A boolean value indicating whether the matching logic should be inverted.
* @param isDebug A boolean value indicating whether the method should be executed in debug mode.
* @return A boolean value indicating if the job application matches the criteria specified in the configuration.
*/
    private static Boolean filterByConfig(WDR_Application__c jobApp, IA_Invitation_Config__mdt criteria, SObject fields, Boolean inversion, Boolean isDebug) {
        String jAFieldsSrc = criteria.Job_Application_Fields__c;
        String jRFieldsSrc = criteria.Job_Requisition_Fields__c;
        List<String> jAFields = extractFields(jAFieldsSrc);
        List<String> jRFields = extractFields(jRFieldsSrc);
        Boolean isJAFields = (jAFields != null);
        Boolean isJRFields = (jRFields != null);
        Boolean sholdMatch = (isJAFields || isJRFields);
        // should our config match (any of configuration comes)
        // in no config comes overall gonna be FALSE
        // in case any of these configs come those configs are core for matching
        // the main question is SHOULD IT REALLY MATCH and in case 'YES'
        // those that have config have to match based on config
        // but those that do not have config considered as TRUE
        // and in case no config overall it is FALSE
        // validation for config match to field
        WDR_Job__c jobReq = jobApp.Job__r;
        String jobAppName = 'WDR_Application__c';
        String jobReqName = 'WDR_Job__c';
        Boolean hasMatchJAFields = isJAFields ? matchCriteria(jobApp, jobAppName, jAFields, fields, isDebug) : sholdMatch;
        Boolean hasMatchJRFields = isJRFields ? matchCriteria(jobReq, jobReqName, jRFields, fields, isDebug) : sholdMatch;
        Boolean result = hasMatchJAFields && hasMatchJRFields;
        return inversion ? !result : result;
    }
    
    /**
* @description This method is used to determine if a job application matches the criteria specified in a configuration.
* It takes a job application and a configuration as input, and returns a boolean value indicating if the job application matches the criteria.
* The method checks if the job application fields specified in the configuration match the actual job application fields, and if the job requisition fields specified in the configuration match the actual job requisition fields.
* If the job application fields and job requisition fields match the criteria specified in the configuration, the method returns true; otherwise, it returns false.
* The method also takes into account an "inversion" parameter, which can be used to invert the matching logic. If the "inversion" parameter is true, the method returns the opposite of the matching result.
* @param record The job application to match with the configuration.
* @param objName The API name of the object containing the job application.
* @param examinedFields A list of fields to compare with the configuration.
* @param criteriaInput The configuration to match with the job application.
* @param isDebug A boolean value indicating whether the method should be executed in debug mode.
* @return A boolean value indicating if the job application matches the criteria specified in the configuration.
*/
    private static Boolean matchCriteria(sObject record, String objName, List<String> examinedFields, sObject criteriaInput, Boolean isDebug) {
        List<Boolean> resultList = new List<Boolean>();
        for (String field : examinedFields) {
            String fieldName = field.trim();
            String type = getFieldObjectFieldType(objName, fieldName);
            Object recordFieldValue = record.get(fieldName);
            Object criteriaFildValue = criteriaInput.get(fieldName);
            Boolean inverse = false;
            Boolean isMatch = false;
            if (type == 'STRING' || type == 'PICKLIST') {
                // validation for string values and set not NULL values instead of NULL
                String recordFieldValueStr = (String)recordFieldValue;
                String criteriaFildValueStr = (String)criteriaFildValue;
                recordFieldValueStr = !String.isEmpty(recordFieldValueStr) ? recordFieldValueStr.trim() : '';
                criteriaFildValueStr = !String.isEmpty(criteriaFildValueStr) ? criteriaFildValueStr.trim() : '';
                // validation for empty string and populated are different
                if (!String.isEmpty(criteriaFildValueStr)) {
                    isMatch = matchFieldValueWithConfig(recordFieldValueStr, criteriaFildValueStr, isDebug);
                } else {
                    isMatch = recordFieldValueStr == criteriaFildValueStr;
                }
            } else {
                // other from STRING type values match here
                isMatch = recordFieldValue == criteriaFildValue;
            }
            if (isMatch) {
                resultList.add(isMatch);
            }
        }
        Boolean result = examinedFields.size() == resultList.size();
        return result;
    }
    /**
* @description This method is used to match a field value with a configuration value.
* It takes a record value and a configuration value as input, and returns a boolean value indicating if the record value matches any of the configuration values.
* The method splits the configuration value into an array of strings and iterates through the array to find a match for the record value.
* If the configuration value starts with an exclamation mark (!), it is considered as an inverse match, meaning that the record value should not match the configuration value.
* The method returns true if the record value matches any of the configuration values, or false otherwise.
*
* @param recordValue The value of the field in the record to be matched with the configuration value.
* @param configValue The configuration value to be matched with the record value.
* @param isDebug Use this option for debugging.
* @return A boolean value indicating if the record value matches any of the configuration values.
*/
    private static Boolean matchFieldValueWithConfig(String recordValue, String configValue, Boolean isDebug) {
        Boolean isRecordValue = !String.isEmpty(recordValue);
        Boolean isConfigValue = !String.isEmpty(configValue);
        List<String> values = configValue.split(',');
        List<String> matchValues = new List<String>();
        String ptrn = '^\\![A-Za-z\\s->_\'.0-9]+';
        Boolean toInverse = false;
        for (String value : values) {
            String clearConfigValue = value.replace('!', '').trim();
            Boolean isMatch = clearConfigValue == recordValue;
            toInverse = Pattern.matches(ptrn, value) ? true : toInverse;
            if (isMatch) {
                matchValues.add(value);
            }
        }
        Boolean result = toInverse ? matchValues.isEmpty() : !matchValues.isEmpty();
        return result;
    }
    
    /**
* @description This method is used to split the input string into an array of strings.
* It is used to extract the fields from the configuration.
*
* @param input The input string to be split.
* @return A list of strings representing the split input.
*/
    public static List<String> getSplitValues(String input) {
        List<String> result = new List<String>();
        return result;
    }
    /**
* @description This method is used to get the data type of a field in a specified object.
*
* @param objectApiNameInput The API name of the object to get the field type from.
* @param fieldAPINameInput The API name of the field to get the type of.
* @return The data type of the specified field as a string.
*/
    private static String getFieldObjectFieldType(String objectApiNameInput, String fieldAPINameInput) {
        String objectApiName = objectApiNameInput.trim();
        String fieldAPIName = fieldAPINameInput.trim();
        Map <String, Schema.SObjectType> foundSchema = Schema.getGlobalDescribe();
        Schema.SObjectType foundObject = foundSchema.get(objectApiName);
        Map<String, Schema.SObjectField> foundFields = foundObject.getDescribe().fields.getMap();
        Schema.SObjectField foundField = foundFields.get(fieldAPIName);
        String result = String.valueOf(foundField.getDescribe().getType());
        return result;
    }
    /**
* @description This method is used to get the data type of a field in a specified object.
*
* @param objectApiNameInput The API name of the object to get the field type from.
* @param fieldAPINameInput The API name of the field to get the type of.
* @return The data type of the specified field as a string.
*/
    private static List<String> extractFields(String fieldSource) {
        Boolean isFields = fieldSource != null || !String.isBlank(fieldSource);
        if (isFields) {
            List<String> src = fieldSource.split(',');
            List<String> result = new List<String>();
            for (String item : src) {
                item.trim();
                result.add(item);
            }
            return result;
        } else {
            return null;
        }
    }
    /**
* @description : This method is used to filter the MatchingWrapper objects based on the presence of personas.
* It returns a list of MatchingWrapper objects that have at least one persona.
*
* @param input The input list of MatchingWrapper objects to be filtered.
* @return A list of MatchingWrapper objects that have at least one persona.
*/
    public static List<MatchingWrapper> filterMatchingWrapper(List<MatchingWrapper> input) {
        List<MatchingWrapper> result = new List<MatchingWrapper>();
        for (MatchingWrapper item : input) {
            if (!item.personas.isEmpty()) {
                result.add(item);
            }
        }
        return result;
    }
    /**
* @description : This method is used to store the history of job applications that have been invited.
* It takes a list of job applications as input and returns a map where the keys are the IDs of the job applications and the values are the job applications themselves.
*
* @param jobapps The list of job applications to be stored in the history.
* @return A map containing the IDs of the job applications as keys and the job applications themselves as values.
*/
    public static Map<id, WDR_Application__c> invitationHistory(List<WDR_Application__c> jobapps){
        Map<Id, WDR_Application__c> mapInvitationHistory = new Map<Id, WDR_Application__c>();
        for(WDR_Application__c jobApp : jobapps){
            mapInvitationHistory.put(jobApp.id, jobApp);
        }
        return mapInvitationHistory;
    }
    /**
* @description : This method is used to identify if a job application belongs to the Futureforce persona.
* It checks if the employment type is either 'Intern (Fixed Term)' or 'Regular' and the request creation reason is 'Futureforce'.
*
* @param employmentType The employment type of the job application.
* @param reqCreationReason The request creation reason of the job application.
* @return A boolean value indicating if the job application belongs to the Futureforce persona.
*/
    public static Boolean identifyFutureforcePersona(String employmentType, String reqCreationReason) {
        if (employmentType == 'Intern (Fixed Term)' && reqCreationReason == 'Futureforce') {
            return true;
        } else if (employmentType == 'Regular' && reqCreationReason == 'Futureforce')  {
            return true;
        } 
        return false;
    }
    /**
* @description : This method is used to identify the Insiders_Tracking__c record associated with a given job application ID.
* It iterates through the provided list of Insiders_Tracking__c records and returns the first one where the job application ID matches the WD_Job_Application__c field.
* If no matching record is found, it returns null.
*
* @param trackings The list of Insiders_Tracking__c records to search through.
* @param jobAppId The ID of the job application to find a matching Insiders_Tracking__c record for.
* @return The Insiders_Tracking__c record associated with the given job application ID, or null if no match is found.
*/
    public static Insiders_Tracking__c findTracking(List<Insiders_Tracking__c> trackings, String jobAppId) {
        for (Insiders_Tracking__c tracking : trackings) {
            if (jobAppId == (String)tracking.WD_Job_Application__c) {
                tracking.Invitation_Email_Sent__c = true;
                return tracking;
            }
        }
        return null;
    }
    
    
    
    // ENTITIES:
    /**
* @description : This class represents a configuration wrapper that contains fields, criteria, and a list of personas.
* It is used to store and manage the configuration data for the invitation batch helper.
*
*/
    public class ConfigWrapper {
        /**
* The fields associated with the configuration.
*/
        public SObject fields { get; set; }
        
        /**
* The criteria associated with the configuration.
*/
        public IA_Invitation_Config__mdt criteria { get; set; }
        
        /**
* The list of personas associated with the configuration.
*/
        public List<ConfigWrapper> personas { get; set; }
        
        /**
* @description : Constructor for the ConfigWrapper class.
*
* @param fields The fields associated with the configuration.
* @param criteria The criteria associated with the configuration.
* @param personas The list of personas associated with the configuration.
*/
        public ConfigWrapper(SObject fields, IA_Invitation_Config__mdt criteria, List<ConfigWrapper> personas) {
            this.fields = fields;
            this.criteria = criteria;
            this.personas = personas;
        }
    }
    
    /**
* @description: This class represents a matching wrapper that contains a template, priority, and a list of personas.
* It is used to store and manage the matching data for the invitation batch helper.
*
*/
    public class MatchingWrapper implements Comparable {
        /**
* The template associated with the matching.
*/
        public String template { get; set; }
        
        /**
* The priority associated with the matching.
*/
        public Integer priority { get; set; }
        
        /**
* The list of personas associated with the matching.
*/
        public List<MatchingWrapper> personas { get; set; }
        
        /**
* @description: Constructor for the MatchingWrapper class.
*
* @param template The template associated with the matching.
* @param priority The priority associated with the matching.
* @param personas The list of personas associated with the matching.
*/
        public MatchingWrapper(String template, Integer priority, List<MatchingWrapper> personas) {
            this.template = template;
            this.priority = priority;
            this.personas = personas;
        }
        
        /**
* @description: This method is used to compare two MatchingWrapper objects based on their priorities.
* It returns a negative integer, zero, or a positive integer as the first object's priority is less than, equal to, or greater than the second object's priority.
*
* @param compareTo The MatchingWrapper object to compare with.
* @return A negative integer, zero, or a positive integer depending on the comparison of the priorities.
*/
        public Integer compareTo(Object compareTo) {
            MatchingWrapper compareToInput = (MatchingWrapper)compareTo;
            if ((this.priority == null) && (compareToInput.priority == null)) {
                return 0;
            } else if ((this.priority == null) && (compareToInput.priority != null)) {
                return -1;
            } else if ((this.priority != null) && (compareToInput.priority == null)) {
                return 1;
            } else if (this.priority > compareToInput.priority) {
                return -1;
            } else if (this.priority < compareToInput.priority) {
                return 1;
            }
            return 0;
        }
    }
    
}