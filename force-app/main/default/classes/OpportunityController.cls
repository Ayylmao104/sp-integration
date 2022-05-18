/*********************************************************************************
* @author           Julian Lopez
* @description      Opportunity Controller
* @date	            2022-05-11
* @group            N/A
**********************************************************************************/
public with sharing class OpportunityController {
    /**********************************************************************************
    * @author		Julian Lopez
    * @date		    2022-05-11
    * @description  The method queries and returns the selected fields of an opportunity given by the record Id
    * @return		Opportunity 
    *******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Opportunity getSingleOpportunity(Id recordId){
        return [SELECT Id, Name, SP_path__c FROM Opportunity WHERE Id=:recordId LIMIT 1];
    }
}