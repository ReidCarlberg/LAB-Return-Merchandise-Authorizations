global class RMA_InstallHandler implements InstallHandler {
	global void onInstall(InstallContext context) {
		//want to make sure we have settings
		Boolean doInsert = false;
		RMA_Settings__c settings = RMA_Settings__c.getOrgDefaults();

		if (settings.SetupOwnerId == null) {
			settings.SetupOwnerId = UserInfo.getOrganizationId(); 
			insert settings;
		} else {
			//update with new ones based on version

			update settings;
		}
        


	}
}