@isTest
public class PF_NHW_StartEndDateConfigurator_Test {

    private static testMethod void testLightningComponenetConfiguration() {
        ESDJC_TestUtil.init();
        RecordType employeeRT = [Select Id from RecordType where sObjectType='Contact' and Name='Employee' LIMIT 1];
        String dateFormat = 'yyyy-MM-dd';
        PF_NHW_ProcessHandler proccessHandler = new PF_NHW_ProcessHandler();
        String startDateMin, startDateMax, endDateMin, endDateMax;
        Date d = Date.today().addDays(1);
        startDateMin = DateTime.newInstance(d.year(), d.month(), d.day()).format(dateFormat);
        d = d.addDays(1);
        endDateMin = DateTime.newInstance(d.year(), d.month(), d.day()).format(dateFormat);
        d = d.addDays(-2);
        d = d.addYears(1);
        startDateMax = DateTime.newInstance(d.year(), d.month(), d.day()).format(dateFormat);
        d = d.addYears(1);
        endDateMax = DateTime.newInstance(d.year(), d.month(), d.day()).format(dateFormat);

        
        Contact con = new Contact(FirstName='TestMailApp',LastName='TestLast',Email='testmailapp@salesforce.com',RecordTypeId = employeeRT.Id);
        insert con;
        Case ca = new Case(contactId = con.Id,origin = 'Package Delivery',Type='Mail Services',ES_DJC_Topic__c='Package Delivery',REWS_Received_Location__c='One California',REWS_Sender__c='Amazon',REWS_Carrier__c='USPS',REWS_Oversized__c=true);
        PF_NHW_StartEndDateConfigurator startEndDateConfigurator = new PF_NHW_StartEndDateConfigurator();
        List<PF_NHW_LightningComponentAttribute> configuratedComponents =  startEndDateConfigurator.getComponentConfiguration(ca);

        PF_NHW_LightningComponentAttribute cmpStartDateMin = new PF_NHW_LightningComponentAttribute('SDMIN', startDateMin);
        PF_NHW_LightningComponentAttribute cmpStartDateMax = new PF_NHW_LightningComponentAttribute('SDMAX', startDateMax);
        PF_NHW_LightningComponentAttribute cmpEndDateMin = new PF_NHW_LightningComponentAttribute('EDMIN', endDateMin);
        PF_NHW_LightningComponentAttribute cmpEndDateMax = new PF_NHW_LightningComponentAttribute('EDMAX', endDateMax);

        System.assertEquals(configuratedComponents.get(0).Name, cmpStartDateMin.Name);
        System.assertEquals(configuratedComponents.get(1).Name, cmpStartDateMax.Name);
        System.assertEquals(configuratedComponents.get(2).Name, cmpEndDateMin.Name);
        System.assertEquals(configuratedComponents.get(3).Name, cmpEndDateMax.Name);
        System.assertEquals(configuratedComponents.get(0).value, cmpStartDateMin.value);
        System.assertEquals(configuratedComponents.get(1).value, cmpStartDateMax.value);
        System.assertEquals(configuratedComponents.get(2).value, cmpEndDateMin.value);
        System.assertEquals(configuratedComponents.get(3).value, cmpEndDateMax.value);

    }
}