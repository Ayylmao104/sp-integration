/*********************************************************************************
* @author           Julian Lopez
* @description      Test Class for Opportunity Controller Class
* @date	            2022-05-11
* @group            N/A
**********************************************************************************/
@isTest
public class OpportunityControllerTest {
    /**********************************************************************************
    * @author		Julian Lopez
    * @date		    2022-05-11
    * @description  The method tests the geSingleOpportunity method from OpportunityController Class
    * @return		void
    *******************************************************************************/
    @isTest static void testGetSingleOpportunity(){
        Test.startTest();
        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.SP_path__c = 'something/something';
        opp.CloseDate = Date.newInstance(1970, 1, 1);
        opp.StageName = 'Prospecting';
        insert opp;
        Opportunity result = OpportunityController.getSingleOpportunity(opp.Id);
        Test.stopTest();

        System.assertEquals('testOpp', result.Name);
    }
}
