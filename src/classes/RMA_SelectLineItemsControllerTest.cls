@isTest (seeAllData=true)
public with sharing class RMA_SelectLineItemsControllerTest {

    static testmethod void testUnassociatedRMA() {
        RMA__c target = new RMA__c();
        insert target;

        ApexPages.StandardController sc = new ApexPages.StandardController(target);

        RMA_SelectLineItemsController controller = new RMA_SelectLineItemsController(sc);

        List<SelectOption> results = controller.getLineItems();
        System.assert(results == null);

    }

    static testmethod void testAssociatedSimple() {
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        if (!standard.isActive) {
            standard.isActive = true;
            update standard;
        }

        Pricebook2 pb = RMA_TestUtilities.createPricebook();
        Product2 prod = RMA_TestUtilities.createProduct();
        PricebookEntry pbe = RMA_TestUtilities.createPricebookEntry(standard,pb,prod);

        Opportunity o = RMA_TestUtilities.createNewOpportunity();
        OpportunityLineItem oli = RMA_TestUtilities.createOpportunityLineItem(o, pbe);

        RMA__c target = new RMA__c();
        target.Opportunity__c = o.id;
        insert target;

        ApexPages.StandardController sc = new ApexPages.StandardController(target);

        RMA_SelectLineItemsController controller = new RMA_SelectLineItemsController(sc);

        //make sure there's one
        List<SelectOption> results = controller.getLineItems();
        System.assert(results != null);
        System.assert(results.size() == 1);

        //update to make sure there's 0 when that 1 is already associated
        RMA_Item__c rmaItem = new RMA_Item__c();
        rmaItem.RMA__c = target.id;
        rmaItem.OpportunityLineItemId__c = oli.id;
        insert rmaItem;

        List<SelectOption> resultsNone = controller.getLineItems();
        System.assert(resultsNone != null);
        System.assert(resultsNone.size() == 0);

    }

    static testmethod void testInsertLines() {
        Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        if (!standard.isActive) {
            standard.isActive = true;
            update standard;
        }

        Pricebook2 pb = RMA_TestUtilities.createPricebook();
        Product2 prod = RMA_TestUtilities.createProduct();
        PricebookEntry pbe = RMA_TestUtilities.createPricebookEntry(standard,pb,prod);

        Opportunity o = RMA_TestUtilities.createNewOpportunity();
        OpportunityLineItem oli1 = RMA_TestUtilities.createOpportunityLineItem(o, pbe);

        OpportunityLineItem oli2 = RMA_TestUtilities.createOpportunityLineItem(o, pbe);

        RMA__c target = new RMA__c();
        target.Opportunity__c = o.id;
        insert target;

        ApexPages.StandardController sc = new ApexPages.StandardController(target);

        RMA_SelectLineItemsController controller = new RMA_SelectLineItemsController(sc);

        //nothing selected
        List<Id> rmaLines = new List<Id>();
        controller.rmaLines = rmaLines;
        controller.addRmaItems();
        List<RMA_Item__c> items = [Select Id From RMA_Item__c WHERE RMA__c = :target.id];
        System.assert(items.size() == 0);

        //now ensure that one is selected and added
        rmaLines = new List<Id>();
        rmaLines.add(oli1.id);
        controller.rmaLines = rmaLines;
        controller.addRmaItems();
        items = [Select Id From RMA_Item__c WHERE RMA__c = :target.id];
        System.assert(items.size() == 1);       

        //now ensure that two are selected but only one added
        rmaLines = new List<Id>();
        rmaLines.add(oli1.id);
        rmaLines.add(oli2.id);
        controller.rmaLines = rmaLines;
        controller.addRmaItems();
        items = [Select Id From RMA_Item__c WHERE RMA__c = :target.id];
        System.assert(items.size() == 2, 'Item size was not 2, but ' + items.size());       


    }


}