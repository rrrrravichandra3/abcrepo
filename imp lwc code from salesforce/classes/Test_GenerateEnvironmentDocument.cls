@isTest
private class Test_GenerateEnvironmentDocument {

    static testMethod void unitTest1() {
        Test.startTest();
			GenerateEnvironmentAgreementDocument.genEnviroment();
			GenerateEnvironmentAgreementDocument.getAgreementDocument();
			GenerateEnvironmentAgreementDocument.getDocument();
			GenerateEnvironmentAgreementDocument testDoc = new GenerateEnvironmentAgreementDocument();
			testDoc.getAgreement();
			testDoc.getId1();
			System.assert( testDoc != null );
			testDoc.getId2();
		Test.stopTest();
    }
}