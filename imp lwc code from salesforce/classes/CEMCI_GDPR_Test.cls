@isTest
public with sharing class CEMCI_GDPR_Test {
  @testSetup
  static void setup() {
    CEMCI_Test_Util.createCEMCICustomSetting();

    List<Lead> leadList = new List<Lead>();

    for (Integer i = 1; i < 3; i++) {
      Lead l = new Lead();
      l.firstname = 'Test';
      l.lastname = 'Lead ' + i;
      l.email = 'test' + i + '@abc.com';
      l.phone = '123456789' + i + '';
      l.Company = 'Test';
      leadList.add(l);
    }
    Lead cpLead = new Lead();
    cpLead.firstname = 'Lead';
    cpLead.lastname = 'with CP';
    cpLead.email = 'test@abc.com';
    cpLead.phone = '123456789';
    cpLead.Company = 'Test';
    leadList.add(cpLead);

    insert leadList;

    Individual idRec = new Individual();
    idRec.firstname = cpLead.firstname;
    idRec.lastname = cpLead.lastname;

    insert idRec;

    cpLead.IndividualId = idRec.Id;
    update cpLead;

    ContactPointEmail cpemail = new ContactPointEmail();
    cpemail.ParentId = idRec.Id;
    cpemail.EmailAddress = cpLead.email;
    cpemail.ActiveFromDate = System.today();
    insert cpemail;

    ContactPointPhone cpphone = new ContactPointPhone();
    cpphone.ParentId = idRec.Id;
    cpphone.TelephoneNumber = cpLead.Phone;
    cpphone.ActiveFromDate = System.today();
    insert cpphone;
  }

  @isTest
  static void test_createIndividualRecordsForsObject() {
    List<Lead> leadList = [SELECT Id, FirstName, LastName FROM Lead WHERE FirstName LIKE '%Test'];
    Test.startTest();
    CEMCI_GDPR_DispatcherClass.createIndividualRecordsForsObject(leadList, 'Lead');
    Test.stopTest();
    List<Lead> leadListwithIndividual = [SELECT Id, IndividualId FROM Lead WHERE FirstName LIKE '%Test'];

    for (Lead l : leadListwithIndividual) {
      System.assert(l.IndividualId != null);
    }
  }

  @isTest
  static void test_dispatchGDPRProcessingforRecordsWithUpdates() {
    Lead leadRec = [SELECT Id, FirstName, LastName, Phone, Email FROM Lead WHERE FirstName LIKE '%Lead' LIMIT 1];
    leadRec.Phone = '9876543215';
    leadRec.Phone = 'test@bcd.com';

    update leadRec;

    Test.startTest();
    CEMCI_GDPR_DispatcherClass.createIndividualRecordsForsObject(new List<Lead>{ leadRec }, 'Lead');
    Test.stopTest();
    List<Lead> leadListwithIndividual = [SELECT Id, IndividualId FROM Lead WHERE FirstName LIKE '%Lead'];

    for (Lead l : leadListwithIndividual) {
      System.assert(l.IndividualId != null);
    }
  }

  @isTest
  static void test_mergeGDPRRecords() {
    Lead leadRec1 = [SELECT Id, FirstName, LastName, Phone, Email FROM Lead WHERE FirstName LIKE '%Lead' LIMIT 1];
    leadRec1.Phone = '9876543215';
    leadRec1.Phone = 'test@bcd.com';

    update leadRec1;

    Lead leadRec2 = [
      SELECT Id, FirstName, LastName, Phone, Email, IndividualId
      FROM Lead
      WHERE FirstName LIKE '%Test'
      LIMIT 1
    ];

    Test.startTest();
    Database.merge(leadRec1, leadRec2);
    Test.stopTest();

    Individual validateDeletion = [
      SELECT Id, isDeleted
      FROM Individual
      WHERE Id = :leadRec2.IndividualId
      LIMIT 1
      ALL ROWS
    ];
    System.assertEquals(true, validateDeletion.isDeleted);
  }
}