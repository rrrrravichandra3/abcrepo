@isTest
public with sharing class Test_ESDJC_CollectionHelper {

	public static TestMethod void CollectionHelperTests() {
        
        List<Account> accs = new List<Account>();
        
        Account acc = new Account();
        acc.Name = 'This is a test name 1';
        insert acc;
        accs.add(acc);
        
        acc = new Account();
        acc.Name = 'This is a test name 2';
        insert acc;
        accs.add(acc);
        
        acc = new Account();
        acc.Name = 'This is a test name 3';
        insert acc;
        accs.add(acc);
        
        acc = new Account();
        acc.Name = 'This is a test name 4';
        insert acc;
        accs.add(acc);
        
        acc = new Account();
        acc.Name = 'This is a test name 5';
        insert acc;
        accs.add(acc);
        
        List<Id> ids = ESDJC_CollectionHelper.getIdFieldList(accs, 'Id');
        Set<Id> ids2 = ESDJC_CollectionHelper.getIdFieldSet(accs, 'Id');
        
        Map<Id, List<SObject>> accsMappedById = ESDJC_CollectionHelper.getIdMappedObjects(accs, 'Id');
        Map<Id, SObject> accsMappedByIdSimple = ESDJC_CollectionHelper.getSimpleIdMappedObjects(accs, 'Id');
        
        System.assertEquals(5, ids.size());
        System.assertEquals(5, ids2.size());
        System.assertEquals(5, accsMappedById.size());
        System.assertEquals(5, accsMappedByIdSimple.size());
                
        for (Id id: ids) {
            System.debug('Id - ' + id);
        }
    }
    
}