@isTest
private class Test_ESDJC_AdminContentController {
	static testMethod void testKnowledgeSearch() {
		ESDJC_TestUtil.createRegionRecords();
		ESDJC_Content__c content1 = new ESDJC_Content__c(Content__c = 'test',name='test');
        insert content1;
        
        // Test Adding content to Country
        
        PageReference pageRef = Page.ESDJC_AdminContent;
		Test.setCurrentPageReference(pageRef);
		ApexPages.currentPage().getParameters().put('id',content1.id);
		ApexPages.StandardController controller = new ApexPages.StandardController(content1);
    	ESDJC_AdminContentController con = new ESDJC_AdminContentController(controller);
    	con.regionMap.values()[0][0].isSelected= true;
    	con.regionMap.values()[1][0].isSelected= true;
    	con.regionMap.values()[2][0].isSelected= true;
    	con.addRemoveContents();
    	system.assertEquals(3, [select count() from ESDJC_ContryContent__c ]);
    	
    	
    	// Test Removal of content from country.
    	ESDJC_AdminContentController con1 = new ESDJC_AdminContentController(controller);
    	con1.regionMap.values()[0][0].isSelected= false;
    	con1.regionMap.values()[1][0].isSelected= false;
    	con1.addRemoveContents();
    	system.assertEquals(1, [select count() from ESDJC_ContryContent__c ]);
    	
    	list<ESDJC_Content__c> ContentList = new list<ESDJC_Content__c>();
    	for(integer i = 0; i<10; i++){	
    		ContentList.add(new ESDJC_Content__c(Content__c = 'test',name='test'));
    	}
    	insert ContentList;
    	
    	list<ESDJC_ContryContent__c> countryContentList = new list<ESDJC_ContryContent__c>();
    	for(integer i = 0; i<10; i++){	
    		countryContentList.add(new ESDJC_ContryContent__c(ESDJC_Content__c = ContentList[i].id,ESDJC_Country__c = con1.regionMap.values()[0][0].countryId));
    	}
    	insert countryContentList;
    	ESDJC_Content__c content2 = new ESDJC_Content__c(Content__c = 'test',name='test');
        insert content2;
    	PageReference pageRef1 = Page.ESDJC_AdminContent;
		Test.setCurrentPageReference(pageRef1);
		ApexPages.currentPage().getParameters().put('id',content2.id);
		ApexPages.StandardController controller1 = new ApexPages.StandardController(content2);
    	ESDJC_AdminContentController con2 = new ESDJC_AdminContentController(controller1);
    	
    	con2.addRemoveContents();
    	con2.regionMap.values()[0][0].isSelected= true;
    	con2.addRemoveContents();
    	
    	system.assert(ApexPages.getMessages()[0].getDetail().contains('Already has 5 Contents'));
	}
}