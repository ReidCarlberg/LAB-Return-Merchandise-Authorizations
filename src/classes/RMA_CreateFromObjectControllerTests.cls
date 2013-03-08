@isTest
public class RMA_CreateFromObjectControllerTests {

    static testmethod void testSimpleCreateFromCase() {
        RMA_Settings__c settings = RMA_TestUtilities.createRMASettings();
        Account a = RMA_TestUtilities.createNewAccount();
        Contact c = RMA_TestUtilities.createNewContact();
        c.AccountId = a.Id;
        update c;
        
        Case sampleCase = RMA_TestUtilities.createNewCase();
        sampleCase.AccountId = a.id;
        sampleCase.ContactId = c.id;
        update sampleCase;
        
        RMA_CreateFromObjectController cfc = new RMA_CreateFromObjectController();
        
        Id rmaId = cfc.createFromCaseId(sampleCase.Id);
        
        System.assert(rmaId != null);
        
                //test fail due to null Id
        rmaId = cfc.createFromCaseId(null);
        System.assert(rmaId == null);
        
        //test fail due to invalid Id
        try {
            rmaId = cfc.createFromCaseId(a.Id);
            System.assert(false, 'Should have failed.');
        } catch (Exception e) {
            //means its OK
        }
        
        
    }
    
    static testmethod void testSimpleCreateFromOldCaseShouldFail() {
        // http://salesforce.stackexchange.com/questions/62/unit-testing-code-which-has-logic-around-the-createddate
        RMA_Settings__c settings = RMA_TestUtilities.createRMASettings();
        Account a = RMA_TestUtilities.createNewAccount();
        Contact c = RMA_TestUtilities.createNewContact();
        c.AccountId = a.Id;
        update c;
        
        Case sampleCase = RMA_TestUtilities.createNewCase();
        sampleCase.AccountId = a.id;
        sampleCase.ContactId = c.id;
        update sampleCase;
        sampleCase = [select id, createddate, accountid, contactid from case where id=:sampleCase.id];
        
        String original = ''+sampleCase.createdDate.dateGMT();
        Date updated = sampleCase.createdDate.dateGMT();
        updated = updated.addDays(-1 * (settings.Max_Case_Age__c.intValue() + 1));
        
        String serializedCase = JSON.serialize(sampleCase);
        System.debug('***** case fail original ' + original + ' updated ' + updated);
        System.debug('serialized case original: ' + serializedCase);
        serializedCase = serializedCase.replace(original.left(10), ('' + updated).left(10));
        System.debug('serialized case updated: ' + serializedCase);
        
        Case updateCase = (Case) JSON.deserialize(serializedCase, Case.class );        
        
        RMA_CreateFromObjectController cfc = new RMA_CreateFromObjectController();
        System.debug('***** Should be testing the in memory options updated case ' + updateCase.CreatedDate);
        Id rmaId = cfc.createFromCase(updateCase);

        System.assert(rmaId == null);
    
    }
    
    static testmethod void testSimpleCreateFromOpportunity() {
        //basic data
        RMA_Settings__c settings = RMA_TestUtilities.createRMASettings();
        System.debug('****SETTINGS:' + settings);
        System.assert(settings.Max_Opportunity_Age__c != null);
        Account a = RMA_TestUtilities.createNewAccount();
        Opportunity o = RMA_TestUtilities.createNewOpportunity();
        o.AccountID = a.id;
        update o;
            
        //test success
        RMA_CreateFromObjectController cfc = new RMA_CreateFromObjectController();
        Id rmaId = cfc.createFromOpportunityId(o.Id);
        System.assert(rmaId != null);
        
        //test fail due to max date
        Date newCloseDate = Date.today().addDays(-1 * (settings.Max_Opportunity_Age__c.intValue() + 1));
        o.CloseDate = newCloseDate;
        update o;
        
        rmaId = cfc.createFromOpportunityId(o.Id);
        System.assert(rmaId == null);

        //test fail due to null Id
        rmaId = cfc.createFromOpportunityId(null);
        System.assert(rmaId == null);
        
        //test fail due to invalid Id
        try {
            rmaId = cfc.createFromOpportunityId(a.Id);
            System.assert(false, 'Should have failed.');
        } catch (Exception e) {
            //means its OK
        }
        
    }
    
    static testmethod void testController() {
        RMA_Settings__c settings = RMA_TestUtilities.createRMASettings();
        Account a = RMA_TestUtilities.createNewAccount();
        Contact c = RMA_TestUtilities.createNewContact();
        c.AccountId = a.Id;
        update c;
        Case sampleCase = RMA_TestUtilities.createNewCase();
        sampleCase.AccountId = a.id;
        sampleCase.ContactId = c.id;
        update sampleCase;        

        //case                
        ApexPages.StandardController sc = new ApexPages.StandardController(sampleCase);
        RMA_CreateFromObjectController controller = new RMA_CreateFromObjectController(sc);
        System.assert(controller.target == sampleCase);
        PageReference result = controller.createFromObject();
        System.assert(result != null);

        //opportunity
        Opportunity o = RMA_TestUtilities.createNewOpportunity();
        o.AccountID = a.id;
        update o;

        ApexPages.StandardController scOppty = new ApexPages.StandardController(o);
        RMA_CreateFromObjectController controllerOppty = new RMA_CreateFromObjectController(scOppty);
        System.assert(controllerOppty.target == o);
        PageReference resultOppty = controllerOppty.createFromObject();
        System.assert(resultOppty != null);
        
        //contact -- should fail
        ApexPages.StandardController scContact = new ApexPages.StandardController(c);
        RMA_CreateFromObjectController controllerContact = new RMA_CreateFromObjectController(scContact);
        System.assert(controllerContact.target == c);
        PageReference resultContact = controllerContact.createFromObject();
        System.assert(resultContact == null);
        
        
    
    }
    



}