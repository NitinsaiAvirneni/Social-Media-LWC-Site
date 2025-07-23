public with sharing class FacebookService extends BaseAPIService {
    private static final String BASE_PATH = '/v19.0/';
    private static String FACEBOOK_ACCESS_TOKEN_USER = '';
    private static final Integer TIMEOUT = 120000;
    private String payload;
    private static final String NAMED_CREDENTIAL = 'Conscendo_HYD_Facebook_NamedCred';
    private static final String API_ENDPOINT = '';
    private static FacebookService instance;
    // Singleton getter
    public static FacebookService getInstance() {
        if(instance == null) {
            instance = new FacebookService();
        }
        return instance;
    }

        /**
     * @description Constructor initializing the Metadata API endpoint
     */
    public FacebookService() {
        super();
        setApiEndpoint(API_ENDPOINT);
        setNamedCredential(NAMED_CREDENTIAL);
        FACEBOOK_ACCESS_TOKEN_USER = Auth.AuthToken.getAccessToken('0SONS000001h58j', 'Facebook');
        // FACEBOOK_ACCESS_TOKEN_USER = Auth.AuthToken.refreshAccessToken('0SONS000001h58j', 'Google', FACEBOOK_ACCESS_TOKEN_USER);
    }
    // get posts by page id with comments
    public Map<String,Object> getPostsAndComments(String socialMediaAccountId, String pageAccessToken, String pageId){
        APIService api = new APIService();
        Map<String, Object> postAndCommentMap = new Map<String, Object>();
        String fields = 'comments{comments,id, message,created_time},id,message,created_time';
        String encodedFields = EncodingUtil.urlEncode(fields, 'UTF-8');
        String endpoint = BASE_PATH + pageId + '/posts?fields='+encodedFields+'&access_token=' + pageAccessToken;
        String fullApiEndPoint = 'callout:'+namedCredential+apiEndpoint+endpoint;
        HttpResponse res = api.makeCallout(fullApiEndPoint, 'GET', null, null, 120000, true);
        // prepare post list and comments list
        List<Map<String,Object>> postList = new List<Map<String,Object>>();
        List<Map<String,Object>> commentList = new List<Map<String,Object>>();
        if (res.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // post list
            List<Object> postData = (List<Object>) jsonResponse.get('data');
            for (Object postItem : postData) {
                Map<String,Object> postItemMap = (Map<String,Object>) postItem;
                postList.add(new Map<String,Object>{
                    'contentId'=>(String) postItemMap.get('id'),
                    'socialMediaAccountId'=>socialMediaAccountId,
                    'contentText'=>(String) postItemMap.get('message'),
                    'contentType'=>'post',
                    'pageId'=> pageId,
                    'platform'=>'Facebook',
                    'authorName'=>'anonymus',
                    'timeStamp'=>(String) postItemMap.get('created_time')
                });
                // comment list per post if comment present
                if(postItemMap.containsKey('comments')){
                    Map<String,Object> commentMap = (Map<String,Object>) postItemMap.get('comments');
                    List<Object> commentData = (List<Object>) commentMap.get('data');
                    for (Object commentItem : commentData) {
                        Map<String,Object> commentItemMap = (Map<String,Object>) commentItem;
                        commentList.add(new Map<String,Object>{
                            'interactionId'=>(String) commentItemMap.get('id'),
                            'contentId'=>(String) postItemMap.get('id'),
                            'interactionText'=>(String) commentItemMap.get('message'),
                            'timeStamp'=>(String) commentItemMap.get('created_time'),
                            'pageId'=> pageId,
                            'platform'=>'Facebook',
                            'authorName'=>'anonymus'
                        });
                        if(commentItemMap.containsKey('comments')){
                            Map<String,Object> repliesMap = (Map<String,Object>) commentItemMap.get('comments');
                            List<Object> replyData = (List<Object>) repliesMap.get('data');
                            for (Object replyItem : replyData) {
                                Map<String,Object> replyItemMap = (Map<String,Object>) replyItem;
                                commentList.add(new Map<String,Object>{
                                    'interactionId'=>(String) replyItemMap.get('id'),
                                    'parentInteractionId'=>(String) commentItemMap.get('id'), //parent interaction id
                                    'interactionText'=>(String) replyItemMap.get('message'),
                                    'timeStamp'=>(String) replyItemMap.get('created_time'),
                                    'pageId'=> pageId,
                                    'platform'=>'Facebook',
                                    'authorName'=>'anonymus'
                                });
                            }
                        }
                    }
                }
            }
            postAndCommentMap.put('posts', postList);
            postAndCommentMap.put('comments', commentList);
        }
        return postAndCommentMap;
    }
    // get pages by user id
    public List<Map<String, String>> getOwnedPagesByBusinessId(String userId){
        APIService api = new APIService();
        List<Map<String, String>> pages = new List<Map<String, String>>();
        String endpoint = BASE_PATH + userId + '/accounts?access_token=' + FACEBOOK_ACCESS_TOKEN_USER;
        String fullApiEndPoint = 'callout:'+namedCredential+apiEndpoint+endpoint;
        HttpResponse res = api.makeCallout(fullApiEndPoint, 'GET', null, null, 120000, true);
        if (res.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> data = (List<Object>) jsonResponse.get('data');
            for (Object obj : data) {
                Map<String, Object> page = (Map<String, Object>) obj;
                Map<String, String> pageMap = new Map<String, String>();
                pageMap.put('id', (String) page.get('id'));
                pageMap.put('name', (String) page.get('name'));
                pageMap.put('access_token', (String) page.get('access_token'));
                pages.add(pageMap);
            }
        }

        return pages;
    }
    public String getPageAccessTokenByPageId(String pageId){
        FacebookService service = new FacebookService();
        List<Social_Media_Account__c> socialMediaAccounts = [SELECT Id, Platform_Account_ID__c FROM Social_Media_Account__c WHERE Name = 'Conscendo Hyderabad Facebook' LIMIT 1];
        String userId = '';
        for( Social_Media_Account__c account : socialMediaAccounts ) {
            userId = account.Platform_Account_ID__c;
        }
        List<Map<String, String>> facebookPagesList = getOwnedPagesByBusinessId(userId);
        String pageAccessToken = '';
        for(Object facebookPages: facebookPagesList){
            Map<String,Object> facebookPagesMap = (Map<String,Object>) facebookPages;
            if((String)facebookPagesMap.get('id') == pageId){
                pageAccessToken = (String) facebookPagesMap.get('access_token');
            }
        }
        System.debug('userId: '+userId);
        System.debug('pageAccessToken: '+pageAccessToken);
        return pageAccessToken;
    }
    // get instagram accounts connected to facebook page.
    public List<Map<String, String>> getInstagramAccountsByPage(String pageId, String pageAccessToken){
        APIService api = new APIService();
        List<Map<String, String>> pages = new List<Map<String, String>>();
        String endpoint = BASE_PATH + pageId + '/instagram_accounts?fields=name&access_token=' + pageAccessToken;
        String fullApiEndPoint = 'callout:'+namedCredential+apiEndpoint+endpoint;
        HttpResponse res = api.makeCallout(fullApiEndPoint, 'GET', null, null, 120000, true);
        if (res.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> data = (List<Object>) jsonResponse.get('data');
            for (Object obj : data) {
                Map<String, Object> page = (Map<String, Object>) obj;
                Map<String, String> pageMap = new Map<String, String>();
                pageMap.put('id', (String) page.get('id'));
                pageMap.put('name', (String) page.get('name'));
                pages.add(pageMap);
            }
        }

        return pages;
    }
    public void syncComments(Id socialMediaAccountId, String businessId){
        FacebookPagesBatch facebookPagesBatch = new FacebookPagesBatch(this, businessId);
        Database.executeBatch(facebookPagesBatch, 1);
    }
     // reply post or comment
    @AuraEnabled
    public static Map<String,Object> sentReplyToPostTemp(String postId, String message, String pageAccessToken){
        return InstagramService.getInstance().sentReplyToPost(postId, message);
    }
    public Map<String,Object> sentReplyToPost(String postId, String message, String pageAccessToken){
        APIService api = new APIService();
        Map<String, Object> postAndCommentMap = new Map<String, Object>();
        String endpoint = BASE_PATH + postId + '/comments';
        String fullApiEndPoint = 'callout:'+namedCredential+apiEndpoint+endpoint;
        String payload = 'message=' + EncodingUtil.urlEncode(message, 'UTF-8') +
                         '&access_token=' + EncodingUtil.urlEncode(pageAccessToken, 'UTF-8');
        HttpResponse res = api.makeCallout(fullApiEndPoint, 'POST', payload, null, 120000, true);
        System.debug('res:'+ res.getBody());
        if (res.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if(jsonResponse.containsKey('id')){
                return new Map<String,Object>{
                'sccuess'=>true,
                'id'=>jsonResponse.get('id')
            };
            }else {
                return new Map<String,Object>{
                'sccuess'=>false,
                'error'=>res.getStatus()
            };
            }
        }else{
            return new Map<String,Object>{
                'sccuess'=>false,
                'error'=>res.getStatus()
            };
        }
    }
    @AuraEnabled
    public static Map<String,Object> sentReplyToCommentTemp(String commentId, String message){
        return InstagramService.getInstance().sentReplyToComment(commentId, message);
    }
    public Map<String,Object> sentReplyToComment(String commentId, String message, String pageAccessToken){
        APIService api = new APIService();
        Map<String, Object> postAndCommentMap = new Map<String, Object>();
        String endpoint = BASE_PATH + commentId + '/comments';
        String fullApiEndPoint = 'callout:'+namedCredential+apiEndpoint+endpoint;
        String payload = 'message=' + EncodingUtil.urlEncode(message, 'UTF-8') +
                         '&access_token=' + EncodingUtil.urlEncode(pageAccessToken, 'UTF-8');
        HttpResponse res = api.makeCallout(fullApiEndPoint, 'POST', payload, null, 120000, true);
        System.debug('res:'+ res.getBody());
        if (res.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if(jsonResponse.containsKey('id')){
                return new Map<String,Object>{
                'sccuess'=>true,
                'id'=>jsonResponse.get('id')
            };
            }else {
                return new Map<String,Object>{
                'sccuess'=>false,
                'error'=>res.getStatus()
            };
            }
        }else{
            return new Map<String,Object>{
                'sccuess'=>false,
                'error'=>res.getStatus()
            };
        }
    }
}