/*
adapted from
https://github.com/ForceDotComLabs/ActionPlans/blob/master/src/classes/ActionPlansTestUtilities.cls
*/


public class RMA_TestUtilities {
    
    static String error = 'Pre deploy test failed, This may be because of custom validation rules in your Org. You can check ignore apex errors or temporarily deactivate your validation rules for Accounts and try again.';
    
    /**
    * Random words are required for testing 
    * as you will likely run into any word I can insert
    * during a test class and produce false test results.
    */
    public static String createRandomWord() {
      
      String ret = 'SampleData' + math.rint(math.random() * 100000);
      
      return ret;
    }
 
    /*
    * A random user is useful for testing in order to be 
    * sure that you are able to see data across posts regardless
    * of follow status.
    */
    /*
    public static User createRandomTestUser() {
        for( Profile p : [ Select Id, PermissionsModifyAllData, Name from Profile limit 100 ] ){
            if( p.PermissionsModifyAllData ){
                return RMA_TestUtilities.createTestUser( p );
            }
        }
        return new User();
    }
    */
    /**
    * Creates a new User
    * @return testUser
    */
    /*
    public static User createTestUser( Profile p ) {
    
        String namePrefix = RMA_TestUtilities.createRandomWord();
    
        User testUser = new User();
        testUser.Email              = 'test@test.com';
        testUser.Username           = namePrefix + '@testuser.com';
        testUser.LastName           = 'test';
        testUser.Alias              = 'test';
        testUser.ProfileId          = p.Id;
        testUser.LanguageLocaleKey  = 'en_US';
        testUser.LocaleSidKey       = 'en_US';
        testUser.TimeZoneSidKey     = 'America/Chicago';
        testUser.EmailEncodingKey   = 'UTF-8';
        
        insert testUser;
        
        return testUser;
    }
    */
    
    /**
    * Creates a new Account Object 
    * @return newAccount
    */
    public static Account createNewAccount(){
        
        Account newAccount  = new Account();
        newAccount.Name     = RMA_TestUtilities.createRandomWord();
        
        try{
            insert newAccount;
        }
        catch( Exception ex ){
            System.assert( false , RMA_TestUtilities.error);
        }
        
        return newAccount;
    }
    

    
    /**
    * Creates a new Case Object 
    * @return newCase
    */
    public static Case createNewCase(){
        
        Case newCase    = new Case();
        newCase.Status  = 'New';
        newCase.Origin  = 'Email'; 
        
        try{
            insert newCase;
        }
        catch( Exception ex ){
            System.assert( false ,RMA_TestUtilities.error);
        }
        
        return newCase;
    }
    
    /**
    * Creates a new Contact Object
    * @return newContact
    */
    public static Contact createNewContact(){
        
        Contact newContact  = new Contact();
        newContact.LastName = RMA_TestUtilities.createRandomWord();
        
        try{
            insert newContact;
        }
        catch( Exception ex ){
            System.assert( false ,RMA_TestUtilities.error);
        }
        
        return newContact;
    }
    
    

    
    /**
    * Creates a new Opportunity Object 
    * @return newOpportunity
    */
    public static Opportunity createNewOpportunity(){
        
        Opportunity newOpportunity  = new Opportunity();
        newOpportunity.Name         = RMA_TestUtilities.createRandomWord();
        newOpportunity.CloseDate    = Date.today();
        newOpportunity.StageName    = 'Prospecting';
        
        try{
            insert newOpportunity;
        }
        catch( Exception ex ){
            System.assert( false ,RMA_TestUtilities.error);
        }
        
        return newOpportunity;
    }
    
    public static RMA_Settings__c createRMASettings() {
    
        RMA_Settings__c settings = RMA_Settings__c.getOrgDefaults();

        if (settings.Default_Days_to_Complete_Return__c == null) { settings.Default_Days_to_Complete_Return__c = 14; }
        if (settings.Max_Case_Age__c == null) { settings.Max_Case_Age__c = 30; }
        if (settings.Max_Opportunity_Age__c == null) { settings.Max_Opportunity_Age__c = 30; }
        if (settings.SetupOwnerId == null) { settings.SetupOwnerId = UserInfo.getUserId(); }

        insert settings;

        return settings;
    }

    public static Pricebook2 createPricebook() {
        Pricebook2 ret = new Pricebook2();
        ret.name = RMA_TestUtilities.createRandomWord();
        insert ret;
        return ret;
    }
    
    public static Product2 createProduct() {
        Product2 ret = new Product2();
        ret.name = RMA_TestUtilities.createRandomWord();
        insert ret;
        return ret;
    }

    public static PricebookEntry createPricebookEntry (Pricebook2 standard, Pricebook2 newPricebook, Product2 prod) {
        System.debug('***** starting one');
        PricebookEntry one = new PricebookEntry();
        one.pricebook2Id = standard.id;
        one.product2id = prod.id;
        one.unitprice = 1249.0;
        one.isactive = true;
        insert one;
        System.debug('***** one complete, ret next');
        PricebookEntry ret = new PricebookEntry();
        ret.pricebook2Id = newPricebook.id;
        ret.product2id = prod.id;
        ret.unitprice = 1250.0;
        ret.isactive = true;
        insert ret;
        return ret;
    }

    public static OpportunityLineItem createOpportunityLineItem(Opportunity o, PricebookEntry pbe) {
        OpportunityLineItem ret = new OpportunityLineItem();
        ret.OpportunityId = o.id;
        ret.PricebookEntryId = pbe.id;
        ret.quantity = 1;
        ret.unitprice = 17;
        ret.description = RMA_TestUtilities.createRandomWord();
        insert ret;
        return ret;

    }
}