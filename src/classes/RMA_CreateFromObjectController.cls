public with sharing class RMA_CreateFromObjectController {

    public SObject target {get;set;}
    Id originalId {get;set;}
    
    public RMA_CreateFromObjectController() {
    }
    
    public RMA_CreateFromObjectController(ApexPages.StandardController standardController) {
        target =  standardController.getRecord();
    }
    
    public PageReference createFromObject() {
        //is it a case?
        Id rmaId = null;

        
        if (target.getSObjectType() == Case.sObjectType) {
            originalId = ((Case)target).Id;
            rmaId = createFromCaseId(originalId);
        } else if (target.getSObjectType() == Opportunity.sObjectType) {
            originalId = ((Opportunity)target).Id;
            rmaId = createFromOpportunityId(originalId);
        }
        
        if (rmaId != null) {
            return new PageReference('/'+rmaId);
        } 
        return null;
    }


    public Id createFromCaseId(ID caseID) {
        if (caseId == null) {
            return null;
        }
            
        Case targetCase = null;
        
        try {
            targetCase = [Select Id, AccountID, ContactID, CreatedDate From Case Where ID = :caseID];
        } catch (Exception e) {
            throw new RMA_Exception('Couldn\'t find the target case (' + caseID + ')');
        }

        return createFromCase(targetCase);
    }
     
    public Id createFromCase(Case targetCase) {    //validation against custom settings
        //check to be sure we have a created date
        if (targetCase.CreatedDate == null) {
            targetCase = [select id, createddate, accountid, contactid from case where id = :targetCase.id];
        }
        RMA_Settings__c settings = RMA_Settings__c.getInstance();
        System.debug('***** days between ' + targetCase.CreatedDate.date().daysBetween(Date.today()));
        if (targetCase.CreatedDate.date().daysBetween(Date.today()) > settings.Max_Case_Age__c) {
            //can't create it
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Cannot create an RMA on a case older than ' + settings.Max_Case_Age__c );    
            ApexPages.addMessage(myMsg);
            return null;
        }
              
        
        
        RMA__c newRMA = new RMA__c();
        newRMA.Account__c = targetCase.AccountID;
        newRMA.Contact__c = targetCase.ContactID;
        newRMA.Case__c = targetCase.id;
        
        insert(newRMA);
        
        return newRMA.Id;
            
    }
    
    public Id createFromOpportunityId(ID opportunityId) {
        if (opportunityId == null) {
            return null;
        }
            
        Opportunity targetOpportunity = null;
        
        try {
            targetOpportunity = [Select Id, AccountID, CloseDate From Opportunity Where ID = :opportunityId];
        } catch (Exception e) {
            throw new RMA_Exception('Couldn\'t find targetOpportunity (' + opportunityId + ')');
        }

        return createFromOpportunity(targetOpportunity);
    }
    public Id createFromOpportunity(Opportunity targetOpportunity) {
        RMA_Settings__c settings = RMA_Settings__c.getInstance();
        if (targetOpportunity.CloseDate.daysBetween(Date.today()) > settings.Max_Opportunity_Age__c) {
        //if (Date.today().daysBetween(targetOpportunity.CloseDate) > settings.Max_Opportunity_Age__c) {
            //can't create it
            System.debug('********** Days Between ' + targetOpportunity.CloseDate.daysBetween(Date.today()));
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Cannot create an RMA on an opportunity older than ' + settings.Max_Opportunity_Age__c );    
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        
        RMA__c newRMA = new RMA__c();
        newRMA.Account__c = targetOpportunity.AccountID;
        newRMA.Opportunity__c = targetOpportunity.Id;
        
        insert(newRMA);
        
        return newRMA.Id;
            
    }
    

}