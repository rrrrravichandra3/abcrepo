public with sharing class IA_InsidersInvitationBatchEntity {
    // private IA_InsidersInvitationBatchEntity() {}

    public class ConfigWrapper {
        public SObject fields { get; set; }
        public IA_Invitation_Config__mdt criteria { get; set; }
        public List<ConfigWrapper> personas { get; set; }
        public ConfigWrapper(SObject fields, IA_Invitation_Config__mdt criteria, List<ConfigWrapper> personas) {
            this.fields = fields;
            this.criteria = criteria;
            this.personas = personas;
        }
    }

    public class MatchingWrapper implements Comparable {
        public String template { get; set; }
        public Integer priority { get; set; }
        public List<MatchingWrapper> personas { get; set; }
        public MatchingWrapper(String template, Integer priority, List<MatchingWrapper> personas) {
            this.template = template;
            this.priority = priority;
            this.personas = personas;
        }
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

    public class EmailWrapper {
        public Id recipient {get; set;}
        public String template {get; set;}
        public EmailTemplate templateObj {get; set;}
        public WDR_Application__c what {get; set;}
        public EmailWrapper(Id recipient, String template, EmailTemplate templateObj, WDR_Application__c what) {
            this.recipient = recipient;
            this.template = template;
            this.what = what;
        }
    }

    public class HandleScopeWrapper {
        List<IA_InsidersInvitationBatchHandler.EmailWrapper> emailsToBeSent { get; set; }
        List<IA_InsidersInvitationBatchHandler.EmailWrapper> defaultEmails { get; set; }
        public HandleScopeWrapper(List<IA_InsidersInvitationBatchHandler.EmailWrapper> s, List<IA_InsidersInvitationBatchHandler.EmailWrapper> d) {
            this.emailsToBeSent = s;
            this.defaultEmails = d;
        }
    }
}