/*********************************************************************************
* @author           Julian Lopez
* @description      Test Class for the Callouts Class
* @date	            2022-05-11
* @group            N/A
**********************************************************************************/
@isTest
public class CalloutsTest {
    /**********************************************************************************
    * @author		Julian Lopez
    * @date		    2022-05-11
    * @description  The method tests the getAzureDetails method from Callouts Class
    * @return		void
    *******************************************************************************/
    @isTest static void testGetAzureAppDetails(){
        TestDataUtil.createAzureAppMdt();
        Test.startTest();
        Azure_Active_Directory_Auth__mdt testAzureApp = Callouts.getAzureAppDetails('')[0];
        String testMasterLabel = testAzureApp.MasterLabel;
        System.assert(!String.isEmpty(testMasterLabel));
        testAzureApp = Callouts.getAzureAppDetails('Real_Estate')[0];
        testMasterLabel = testAzureApp.MasterLabel;
        System.assert(!String.isEmpty(testMasterLabel));
        
        Test.stopTest();
    }

    /**********************************************************************************
    * @author		Julian Lopez
    * @date		    2022-05-11
    * @description  The method tests the getCommonHeaders (no azureApp parameter entered) method from Callouts Class
    * @return		void
    *******************************************************************************/
    @isTest static void testGetCommonHeaders(){
        HttpRequest req = new HttpRequest();
        
        Test.setMock(HttpCalloutMock.class, new BearerTokenCalloutMock());
        Test.startTest();

        Callouts.getCommonRequestHeaders(req,'','xxx');

        Test.stopTest();

        System.assertEquals('application/json', req.getHeader('Content-Type'));
        System.assertEquals('application/json', req.getHeader('Accept'));
        System.assertEquals('Bearer xxx', req.getHeader('Authorization'));
    }

    /**********************************************************************************
    * @author		Julian Lopez
    * @date		    2022-05-11
    * @description  The method tests the getCommonHeaders (with azureApp parameter entered) method from Callouts Class
    * @return		void
    *******************************************************************************/
    @isTest static void testGetCommonHeadersTwo(){
        TestDataUtil.createAzureAppMdt();
        HttpRequest req = new HttpRequest();
        
        Test.setMock(HttpCalloutMock.class, new BearerTokenCalloutMock());
        Test.startTest();

        Callouts.getCommonRequestHeaders(req,'','');

        Test.stopTest();

        System.assertEquals('application/json', req.getHeader('Content-Type'));
        System.assertEquals('application/json', req.getHeader('Accept'));
        System.assertEquals('Bearer azertyuiop', req.getHeader('Authorization'));
    }

    /**********************************************************************************
    * @author		Julian Lopez
    * @date		    2022-05-11
    * @description  The method tests the getFoldersCallout method from Callouts Class
    * @return		void
    *******************************************************************************/
    @isTest static void testGetFoldersCallout(){
        TestDataUtil.createAzureAppMdt();
        Test.setMock(HttpCalloutMock.class, new BearerTokenCalloutMock());
        Test.startTest();

        HttpResponse resp = Callouts.getFoldersCallout('','','');

        Test.stopTest();

        System.assertEquals(resp.getStatusCode(), 200);
        System.assertEquals(resp.getBody(), '{"@odata.context":"some obscure link","value":[{"createdDateTime":"2022-04-27T06:51:09Z","eTag":"etag","id":"01327QSL2W26A6U2IKT5BKHYAWNNYT42IY","lastModifiedDateTime":"2022-04-27T09:16:31Z","name":"Customers.doc","webUrl":"https://t06ks.sharepoint.com/sites/Real-Estate/Shared%20Documents/Customers","cTag":"cTag","size":21547433,"createdBy":{"user":{"email":"jullopez@t06ks.onmicrosoft.com","id":"b71143ca-9102-478f-b7a4-8dd86e99063d","displayName":"Julian Lopez"}},"lastModifiedBy":{"user":{"email":"jullopez@t06ks.onmicrosoft.com","id":"b71143ca-9102-478f-b7a4-8dd86e99063d","displayName":"Julian Lopez"}},"parentReference":{"driveType":"documentLibrary","driveId":"b!nJnAr9ML30GvdGZAVsQTZHfj_tfLU3ZGtmYzGf79E6EUavSa0Y0BRIQRqXubbfAN","id":"01327QSL56Y2GOVW7725BZO354PWSELRRZ","path":"/drives/b!nJnAr9ML30GvdGZAVsQTZHfj_tfLU3ZGtmYzGf79E6EUavSa0Y0BRIQRqXubbfAN/root:"},"fileSystemInfo":{"createdDateTime":"2022-04-27T06:51:09Z","lastModifiedDateTime":"2022-04-27T09:16:31Z"}}]}');
    }

    /**********************************************************************************
    * @author		Julian Lopez
    * @date		    2022-05-11
    * @description  The method tests the parseResponse method from Callouts Class
    * @return		void
    *******************************************************************************/
    @isTest static void testParseResponse(){
        TestDataUtil.createAzureAppMdt();
        HttpResponse resp = new HttpResponse();
        resp.setBody('{"@odata.context":"some obscure link","value":[{"createdDateTime":"2022-04-27T06:51:09Z","eTag":"etag","id":"01327QSL2W26A6U2IKT5BKHYAWNNYT42IY","lastModifiedDateTime":"2022-04-27T09:16:31Z","name":"Customers.doc","webUrl":"https://t06ks.sharepoint.com/sites/Real-Estate/Shared%20Documents/Customers","cTag":"cTag","size":21547433,"createdBy":{"user":{"email":"jullopez@t06ks.onmicrosoft.com","id":"b71143ca-9102-478f-b7a4-8dd86e99063d","displayName":"Julian Lopez"}},"lastModifiedBy":{"user":{"email":"jullopez@t06ks.onmicrosoft.com","id":"b71143ca-9102-478f-b7a4-8dd86e99063d","displayName":"Julian Lopez"}},"parentReference":{"driveType":"documentLibrary","driveId":"b!nJnAr9ML30GvdGZAVsQTZHfj_tfLU3ZGtmYzGf79E6EUavSa0Y0BRIQRqXubbfAN","id":"01327QSL56Y2GOVW7725BZO354PWSELRRZ","path":"/drives/b!nJnAr9ML30GvdGZAVsQTZHfj_tfLU3ZGtmYzGf79E6EUavSa0Y0BRIQRqXubbfAN/root:"},"fileSystemInfo":{"createdDateTime":"2022-04-27T06:51:09Z","lastModifiedDateTime":"2022-04-27T09:16:31Z"}}]}');
        resp.setStatusCode(200);
        
        Test.startTest();
        List<Callouts.Item> root = Callouts.parseResponse(resp);
        Test.stopTest();

        System.assertEquals('Customers.doc', root[0].label);
    }

    /**********************************************************************************
    * @author		Julian Lopez
    * @date		    2022-05-11
    * @description  The method tests the getFiles method from Callouts Class
    * @return		void
    *******************************************************************************/
    @isTest static void testGetFiles(){
        TestDataUtil.createAzureAppMdt();

        Test.setMock(HttpCalloutMock.class, new BearerTokenCalloutMock());
        Test.startTest();

        List<Callouts.Item> root = Callouts.getFiles('','','');

        Test.stopTest();

        System.assertEquals('Customers.doc', root[0].label);
    }
    
}