/*********************************************************************************
* @author           Julian Lopez
* @description      Callout Mock Class for CalloutsTest
* @date	            2022-05-11
* @group            N/A
**********************************************************************************/
global class BearerTokenCalloutMock implements HttpCalloutMock {
    /**********************************************************************************
    * @author		Julian Lopez
    * @date		    2022-05-11
    * @description  The method mocks an HTTP response to a request 
    * @return		HTTPResponse
    *******************************************************************************/
    global HttpResponse respond(HttpRequest req){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setStatusCode(200);
        if(req.getMethod()=='POST'){
            // BEARER TOKEN CALLOUT
            resp.setBody('{"token_type" : "Bearer", "access_token" : "azertyuiop"}');
        }else if(req.getMethod()=='GET'){
            // FOLDER STRUCTURE CALLOUT
            resp.setBody('{"@odata.context":"some obscure link","value":[{"createdDateTime":"2022-04-27T06:51:09Z","eTag":"etag","id":"01327QSL2W26A6U2IKT5BKHYAWNNYT42IY","lastModifiedDateTime":"2022-04-27T09:16:31Z","name":"Customers.doc","webUrl":"https://t06ks.sharepoint.com/sites/Real-Estate/Shared%20Documents/Customers","cTag":"cTag","size":21547433,"createdBy":{"user":{"email":"jullopez@t06ks.onmicrosoft.com","id":"b71143ca-9102-478f-b7a4-8dd86e99063d","displayName":"Julian Lopez"}},"lastModifiedBy":{"user":{"email":"jullopez@t06ks.onmicrosoft.com","id":"b71143ca-9102-478f-b7a4-8dd86e99063d","displayName":"Julian Lopez"}},"parentReference":{"driveType":"documentLibrary","driveId":"b!nJnAr9ML30GvdGZAVsQTZHfj_tfLU3ZGtmYzGf79E6EUavSa0Y0BRIQRqXubbfAN","id":"01327QSL56Y2GOVW7725BZO354PWSELRRZ","path":"/drives/b!nJnAr9ML30GvdGZAVsQTZHfj_tfLU3ZGtmYzGf79E6EUavSa0Y0BRIQRqXubbfAN/root:"},"fileSystemInfo":{"createdDateTime":"2022-04-27T06:51:09Z","lastModifiedDateTime":"2022-04-27T09:16:31Z"}}]}');
        }
        return resp;
    }
}