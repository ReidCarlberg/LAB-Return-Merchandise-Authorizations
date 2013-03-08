public class RMA_SelectLineItemsController {

    public RMA__c target {get; set;}
    
    public List<Id> rmaLines {get;set;}
    
    public RMA_SelectLineItemsController() {
        System.debug('***** simple constructor');
    }

    public RMA_SelectLineItemsController(ApexPages.StandardController controller) {
        target = (RMA__c) controller.getRecord();
        target = [select id, opportunity__c from RMA__c where Id = :target.id];
        System.debug('**** ' + target);
    }
    
    public List<SelectOption> getLineItems() {
        System.debug('**** getLineItems');
        if (target.Opportunity__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must define an opportunity prior to selecting RMA_Lines' );    
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        //make sure we are showing only opportunity line items that aren
        List<RMA_Item__c> existingItems = [Select OpportunityLineItemId__c From RMA_Item__c Where RMA__c = :target.id and OpportunityLineItemId__c != null];
        List<Id> opportunityLineItemIds = new List<Id>();
        for (RMA_Item__c current : existingItems) {
            opportunityLineItemIds.add((ID)current.OpportunityLineItemId__c);
        }
    
    
        List<OpportunityLineItem> oli = [Select Id, Quantity, TotalPrice,
            PricebookEntry.Product2.ProductCode,PricebookEntry.Product2.Name 
            From OpportunityLineItem Where OpportunityId = :target.Opportunity__c And Id Not In :opportunityLineItemIds limit 100];

        List<SelectOption> ret = new List<SelectOption>();

        for (OpportunityLineItem current : oli) {
            ret.add(new SelectOption(current.id, current.PricebookEntry.Product2.Name));
        }

        return ret;
    }
    
    public PageReference doSomething() {
        System.debug('**** something');
        return new PageReference('/' + target.id);
    }

    public PageReference addRmaItems() {
        System.debug('***** add Rma Items ' + rmaLines);

        PageReference ret = new PageReference('/' + target.id);
        //basic rules
        //can't re-add something that has already been added
        //return to original RMA page.
        if (rmaLines.size() == 0) {
            //back to RMA
            return ret;
        }
        
        //for the items that are selected, we need to be sure we don't attempt to insert another one.
        List<RMA_Item__c> existingItems =  [Select OpportunityLineItemId__c, Name From RMA_Item__c WHERE RMA__c = :target.Id];

        Set<Id> existingItemIds = new Set<id>();
        for (RMA_Item__c current : existingItems) {
            existingItemIds.add((Id)current.OpportunityLineItemId__c);
        }

        System.debug('***** RMALines (original) ' + rmaLines);
        System.debug('***** Existing Item Ids ' + existingItemIds);

        //remove these from the list to work with
        if (existingItemIds.size() > 0) {
            Set<id> temp = new Set<id>();
            temp.addAll(rmaLines);
            temp.removeAll(existingItemIds);
            rmaLines = new List<Id>();
            rmaLines.addAll(temp);
        }

        System.debug('***** RMALines (clean) ' + rmaLines);

        //OK now go out and get the OLIs
        List<OpportunityLineItem> items = [Select Id, Quantity, TotalPrice,
            PricebookEntry.Product2.ProductCode,PricebookEntry.Product2.Name,
            UnitPrice from OpportunityLineItem Where Id in :rmaLines];


        List<RMA_Item__c> itemsToInsert = new List<RMA_Item__c>();
        
        for (OpportunityLineItem current : items) {
            RMA_Item__c newItem = new RMA_Item__c();
            newItem.RMA__c = target.id;
            newItem.OpportunityLineItemId__c = current.id;
            newItem.OLI_Original_Product_Code__c = current.PricebookEntry.Product2.ProductCode;
            newItem.OLI_Original_Product_Name__c = current.PricebookEntry.Product2.Name;
            newItem.OLI_Original_Quantity__c = current.Quantity;
            newItem.OLI_Original_Total_Price__c = current.TotalPrice;
            newItem.OLI_Original_Unit_Price__c = current.UnitPrice;
            itemsToInsert.add(newItem);
        }
        
        insert itemsToInsert;

        return ret;
    }
    

    

}