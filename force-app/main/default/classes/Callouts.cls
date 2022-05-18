/*********************************************************************************
* @author         Lopez Julian
* @description    Callouts class for SharePoint Integration
* @date	          2022-05-04
* @group          N/A
**********************************************************************************/
public with sharing class Callouts {
    
    /**********************************************************************************
    * @author		Lopez Julian
    * @date		    2022-05-04
    * @description  The method returns a valid (up to 6h) access token for Graph APIcallouts 
    * @param		sharePointName (String): the Name of the SharePoint Site as written in the metadata object
    * @return		String: the valid access token
    *******************************************************************************/
    @AuraEnabled
    public static String getGraphBearerToken(String sharePointName){
        try{
            String access_token;
            Http h = new Http();
            Azure_Active_Directory_Auth__mdt azureAuth = getAzureAppDetails(sharePointName)[0];
            //Setting up the request
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            // endpoint URL
            String endpoint = 'https://login.microsoftonline.com/' + EncodingUtil.urlEncode(azureAuth.Tenant_Id__c, 'UTF-8') 
                + '/oauth2/token?Content-Type=application/x-www-form-urlencoded';
            req.setEndpoint(endpoint);
            // Setting up the headers
            req.setHeader('Content-Length', '2000');
            req.setHeader('Accept', '*/*');
            req.setHeader('Connection','keep-alive');
            //Setting up the body w/ necessary data
            String bodyInString = 
                'grant_type=client_credentials&' + 
                'client_id='+ azureAuth.Client_Id__c + '&'+
                'client_secret=' + azureAuth.Client_Secret__c + '&'+
                'resource=https://graph.microsoft.com';
            req.setBody(bodyInString);
            HttpResponse res = h.send(req);
            if(res.getStatusCode() == 200){
                Map<String,Object> resMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                if(String.valueOf(resMap.get('token_type'))=='Bearer'){
                    access_token = String.valueOf(resMap.get('access_token'));
                    System.debug(access_token);
                }
            }
            return access_token;
        }catch(Exception err){
            throw new AuraHandledException(err.getMessage());
        }
    }
    
    /**********************************************************************************
    * @author		Lopez Julian
    * @date		    2022-05-04
    * @description  The method returns all details from the SharePoint metadata object pre-entered in SF 
    * @param		AzureApp (String): the Name of the SharePoint Site as written in the metadata object
    * @return		List<Azure_Active_Directory_Auth__mdt> : metadata types (should only return one if parameter not null/empty)
    *******************************************************************************/
    @TestVisible private static List<Azure_Active_Directory_Auth__mdt> getAzureAppDetails(String azureApp){
        String query = 'SELECT '
            +'MasterLabel, DeveloperName, Client_Id__c, Client_Secret__c, Azure_Scope__c, '
            +'Tenant_Id__c, Azure_Grant_Type__c, SharePoint_Site_Id__c, sharedFolderId__c '
            +'FROM Azure_Active_Directory_Auth__mdt';
        if(!String.isBlank(azureApp)){
            query += ' WHERE DeveloperName=:azureApp';
        }
        return Database.query(String.escapeSingleQuotes(query));
    }

    /**********************************************************************************
    * @author		Lopez Julian
    * @date		    2022-05-04
    * @description  The method fills in the headers needed for the HTTP requests
    * @param        req (HttpRequest) the request to fill the header of
    * @param		AzureApp (String): the Name of the SharePoint Site as written in the metadata object
    * @param        accessToken (String) : the accesstoken for reuseability
    * @return		void : the headers are returned via the req parameter
    *******************************************************************************/
    @TestVisible private static void getCommonRequestHeaders(HttpRequest req, String azureApp, String accessToken){
        if(string.isEmpty(accessToken)){
            req.setHeader('Authorization','Bearer '+ getGraphBearerToken(azureApp) );
        }else{
            req.setHeader('Authorization','Bearer '+ accessToken );
        }
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
    }
    
    /*@AuraEnabled
    public static void uploadFileToDriveItem(String azureApp,FileDetails fileDetails){
        String endPoint = 'https://graph.microsoft.com/v1.0/drives/' + fileDetails.driveId+'/items/'
            +fileDetails.itemId+':/'+fileDetails.fileName+':/content';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('PUT');
        getCommonRequestHeaders(req,azureApp);
        // Override the content-type from json to respective file type
        req.setHeader('Content-Type',fileDetails.fileType);
        // Ensure fileBody to be in base64 string
        req.setBodyasBlob(EncodingUtil.base64Decode(fileDetails.fileBody));
        HttpResponse res = h.send(req);
        if(res.getStatusCode()==201){
            System.debug('File created.');
        } else{
            throw new AuraHandledException(res.getStatus());
        }
        }*/
    
    /**********************************************************************************
    * @author		Lopez Julian
    * @date		    2022-05-04
    * @description  The method builds and sends the request to access the folder structure
    * @param        folderPath (string) : the path of the folder the code is trying to get the content of
    * @param		sharePointName (String): the Name of the SharePoint Site as written in the metadata object
    * @param        accessToken (String) : the accesstoken for reuseability
    * @return		HttpResponse : the response of the callout
    *******************************************************************************/
    public static HttpResponse getFoldersCallout(String folderPath, String sharePointName, String accessToken){
        try{
        Azure_Active_Directory_Auth__mdt azureAuth = getAzureAppDetails(sharePointName)[0];
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String endpoint = 'https://graph.microsoft.com/v1.0/sites/' 
            + EncodingUtil.urlEncode(azureAuth.SharePoint_Site_Id__c , 'UTF-8') + '/drives/' 
            + azureAuth.sharedFolderId__c;
        if(string.isEmpty(folderPath)){
            endpoint += '/root/children/'; 
        }else{
            endpoint += '/root:/' + folderPath.replaceAll(' ', '%20') + ':/children';
        }
        System.debug(endPoint);
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        getCommonRequestHeaders(req,sharePointName,accessToken);
        HttpResponse resp = h.send(req);
        return resp;
        }catch(Exception err){
            throw new AuraHandledException(err.getMessage());
        }
    }

    /**********************************************************************************
    * @author		Lopez Julian
    * @date		    2022-05-04
    * @description  The method gets the content of a folder under a list of Item objects
    * @param        folderPath (string) : the path of the folder the code is trying to get the content of
    * @param		sharePointName (String): the Name of the SharePoint Site as written in the metadata object
    * @param        accessToken (String) : the accesstoken for reuseability
    * @return		HttpResponse : the response of the callout
    *******************************************************************************/
    @AuraEnabled
    public static List<Item> getFiles(String folderPath, String sharePointName, String accessToken){
        try {
        HttpResponse resp = getFoldersCallout(folderPath, sharePointName, accessToken);
        List<Item> rootItem = parseResponse(resp);
        for(Item it : rootItem){
            if(it.isFolder){
                if(string.isEmpty(folderPath)){
                    it.items = getFiles(it.label, sharePointName, accessToken);
                }else{
                    it.items = getFiles(folderPath + '/' + it.label, sharePointName,accessToken);
                }
                if(it.items.isEmpty()){
                    it.metatext = 'Empty Folder';
                }
            }
        }
        return rootItem;
        }catch(Exception err){
            throw new AuraHandledException(err.getMessage());
        }
    }

    /**********************************************************************************
    * @author		Lopez Julian
    * @date		    2022-05-04
    * @description  The method puts the http response information into an Item List
    * @param        resp (HttpRespone) : the path of the folder the code is trying to get the content of
    * @return		List<Item> : the list of Items extracted from the respone
    *******************************************************************************/
    public static List<Item> parseResponse(HttpResponse resp){
        List<Item> rootItem = new List<Item>();
        String tempName;
        String tempId;
        String tempUrl;
        Boolean tempIsFolder;
        String oldItemName = null;
        String oldItemUrl = null;
        try{
        if(resp.getStatusCode()==200){
            JSONParser parser = JSON.createParser(resp.getBody());
            while(parser.nextToken()!=null){
                if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText()== 'id'){
                    parser.nextToken();
                    tempId = parser.getText();
                    parser.nextToken();
                }
                if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText()== 'name'){
                    parser.nextToken();
                    tempName = parser.getText();
                    if(tempName.length() - tempName.lastIndexOf('.') >= 2 && tempName.length() - tempName.lastIndexOf('.') <= 5){
                        tempIsFolder = False;
                    }else{
                        tempIsFolder = True;
                    }
                    parser.skipChildren();
                    parser.nextToken();
                } 
                if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText()== 'webUrl'){
                    parser.nextToken();
                    tempUrl = parser.getText();
                    parser.skipChildren();
                    parser.nextToken();
                }
                if(oldItemName!=tempName){
                    Item newItem = new Item(tempName, tempUrl, tempId, tempIsFolder);
                    rootItem.add(newItem);
                    oldItemName = tempName;
                }
            }   
            System.debug(tempName);
        }
        return rootItem;
        }catch(Exception err){
            throw new AuraHandledException(err.getMessage());
        }
    }
    
    
    /*********************************************************************************
    * @author         Lopez Julian
    * @description    Item class for folders and files representation
    * @date	          2022-05-04
    * @group          N/A
    **********************************************************************************/
    public class Item {
        // label is actually the name of the file/folder
        @AuraEnabled public String label;
        // will be useful when "click to show in SP" will be added
        @AuraEnabled public String href;
        // name  is actually the id of the folder
        @AuraEnabled public String name;
        // true if we want to show children in the tree
        @AuraEnabled public boolean expanded;
        // List of children
        @AuraEnabled public List<Item> items;
        // True if item is a Folder
        @AuraEnabled public Boolean isFolder;
        // information text
        @AuraEnabled public String metatext;
        // redirection msg
        @AuraEnabled public String redirection;
        // icon name
        @AuraEnabled public String ldsIconName;

        // Constructor
        public Item(String fileName, String sPUrl, String fileId, Boolean isAFolder){
            label = fileName;
            href = sPUrl;
            name = fileId;
            isFolder = isAFolder;
            expanded = false;
            items = null;
            metatext = getMetatext(label,isFolder);
            redirection = getRedirectionMsg(isFolder);
            ldsIconName = getLDSIconName(label, isFolder);
        }
        
        /**********************************************************************************
        * @author		Lopez Julian
        * @date		    2022-05-04
        * @description  The method returns the meta text to associate to an item based on its extension
        * @param        label (string) : the actual name of the item
        * @param		isFolder (Boolean): True if item is a folder (hence not a file)
        * @return		String : the meta text to associate to an item based on its extension
        *******************************************************************************/
        public String getMetatext(String label, Boolean isFolder){
            if(isFolder){
                ldsIconName = 'doctype:folder';
                return 'Folder';
            }else{
                switch on label.substringAfterLast('.').toLowerCase() {
                    when 'docx' {
                        return 'Word Document';
                    }
                    when 'xlsx'{
                        return 'Excel Workbook';
                    }
                    when 'txt'{
                        return 'Plain Text File';
                    }
                    when 'bmp'{
                        return 'BitMap Image';
                    }
                    when 'pdf' {
                        return 'Portable Document Format File';
                    }
                    when 'xml'{
                        return 'XML File';
                    }
                    when 'zip'{
                        return 'Zipped File';
                    }
                    when 'csv'{
                        return 'Comma-Separated Values File';
                    }
                    when 'jpg'{
                        return 'JPEG image';
                    }
                    when 'pptx'{
                        return 'PowerPoint Presentation';
                    }
                    when else {
                        return label.substringAfterLast('.').toUpperCase() + ' File';
                    }
                }
            }
        }

        /**********************************************************************************
        * @author		Lopez Julian
        * @date		    2022-05-04
        * @description  The method returns the redirection message for the user to click on
        * @param		isFolder (Boolean): True if item is a folder (hence not a file)
        * @return		String : the redirection message to show in column
        *******************************************************************************/
        public String getRedirectionMsg(Boolean isFolder){
            if(isFolder)
                return 'Open Folder';
            else {
                return 'View/Edit File';
            }
        }

        /**********************************************************************************
        * @author		Lopez Julian
        * @date		    2022-05-04
        * @description  The method returns the Lightning Design System Icon name based on the extension of the file/ if it's a folder
        * @param        label (string) : the actual name of the item
        * @param		isFolder (Boolean): True if item is a folder (hence not a file)
        * @return		String : the LDS icon name of the item
        *******************************************************************************/
        public String getLDSIconName(String label, Boolean isFolder){
            if(isFolder){
                return 'doctype:folder';
            }else{
                switch on label.substringAfterLast('.') {
                    when 'docx' {
                        return 'doctype:word';
                    }
                    when 'xlsx'{
                        return 'doctype:excel';
                    }
                    when 'txt'{
                        return 'doctype:txt';
                    }
                    when 'bmp'{
                        return 'doctype:image';
                    }
                    when 'pdf' {
                        return 'doctype:pdf';
                    }
                    when 'xml'{
                        return 'doctype:xml';
                    }
                    when 'zip'{
                        return 'doctype:zip';
                    }
                    when 'csv'{
                        return 'doctype:csv';                        }
                    when 'jpg'{
                        return 'doctype:image';
                    }
                    when 'pptx'{
                        return 'doctype:ppt';
                    }
                    when else {
                        return 'doctype:unknown';
                    }
                }
            }
        }
    }
}