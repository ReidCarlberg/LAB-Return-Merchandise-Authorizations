@isTest
public with sharing class RMA_InstallHandlerTest {
	static testmethod void testInstallScript() {
		RMA_InstallHandler postinstall = new RMA_InstallHandler();
		Test.testInstall(postinstall, null);
		RMA_Settings__c settings = RMA_Settings__c.getOrgDefaults();
		System.assert(settings.Max_Case_Age__c != null);
	}
}