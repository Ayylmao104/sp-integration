/*********************************************************************************
* @author           Julian Lopez
* @description      Class that creates a custom metadata type for testing purposes
* @date	            2022-05-11
* @group            N/A
**********************************************************************************/
@isTest
public class TestDataUtil {
    /**********************************************************************************
    * @author		Julian Lopez
    * @date		    2022-05-11
    * @description  The method creates a custom metadata type record for testing purposes
    * @return		void: the  record is created for the duration of the test
    *******************************************************************************/
    @TestSetup
    public static void createAzureAppMdt(){
        Azure_Active_Directory_Auth__mdt testData = new Azure_Active_Directory_Auth__mdt();
        testData.MasterLabel = 'MastLbl';
        testData.DeveloperName = 'DevName';
        testData.Client_Id__c = 'ClientId';
        testData.Azure_Scope__c = 'AzureScope';
        testData.Tenant_Id__c = 'tenantId';
        testData.Azure_Grant_Type__c = 'grantType';
        testData.SharePoint_Site_Id__c = '';
    }
}