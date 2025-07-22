public with sharing class InstagramService extends BaseAPIService {
    private static final String BASE_PATH = '/v19.0/';
    private static String INSTAGRAM_ACCESS_TOKEN = '' ;
    private static final Integer TIMEOUT = 120000;
    private String payload;
    private static final String NAMED_CREDENTIAL = 'Conscendo_HYD_Facebook_NamedCred';
    private static final String API_ENDPOINT = '';
    private static InstagramService instance;
    // Singleton getter
    public static InstagramService getInstance() {
        if(instance == null) {
            instance = new InstagramService();
        }
        return instance;
    }
        /**
     * @description Constructor initializing the Metadata API endpoint
     */
    public InstagramService() {
        super();
        setApiEndpoint(API_ENDPOINT);
        setNamedCredential(NAMED_CREDENTIAL);
        INSTAGRAM_ACCESS_TOKEN = Auth.AuthToken.getAccessToken('0SONS000001h58j', 'Facebook');
    }
    // get posts by page id with comments
    public Map<String,Object> getMediaAndComments(String socialMediaAccountId, String instaAccountId){
        APIService api = new APIService();
        Map<String, Object> postAndCommentMap = new Map<String, Object>();
        String fields = 'caption,comments{username,text,timestamp,replies{text,id,timestamp,username}},id,username,timestamp';
        String encodedFields = EncodingUtil.urlEncode(fields, 'UTF-8');
        String endpoint = BASE_PATH + instaAccountId + '/media?fields='+encodedFields+'&access_token=' + INSTAGRAM_ACCESS_TOKEN;
        String fullApiEndPoint = 'callout:'+namedCredential+apiEndpoint+endpoint;
        HttpResponse res = api.makeCallout(fullApiEndPoint, 'GET', null, null, 120000, true);
        // prepare post list and comments list
        List<Map<String,Object>> postList = new List<Map<String,Object>>();
        List<Map<String,Object>> commentList = new List<Map<String,Object>>();
        // Map<String,Object> commentListMap = new Map<String,Object>();
        if (res.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // post list
            List<Object> postData = (List<Object>) jsonResponse.get('data');
            for (Object postItem : postData) {
                Map<String,Object> postItemMap = (Map<String,Object>) postItem;
                postList.add(new Map<String,Object>{
                    'contentId'=>(String) postItemMap.get('id'),
                    'socialMediaAccountId'=>socialMediaAccountId,
                    'contentText'=>(String) postItemMap.get('caption'),
                    'contentType'=>'post',
                    'authorName'=>(String) postItemMap.get('username'),
                    'timeStamp'=>(String) postItemMap.get('timestamp')
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
                            'interactionText'=>(String) commentItemMap.get('text'),
                            'timeStamp'=>(String) commentItemMap.get('timestamp'),
                            'authorName'=>(String) postItemMap.get('username')
                        });
                        System.debug('commentItemMap: '+commentItemMap);
                        if(commentItemMap.containsKey('replies')){
                            Map<String,Object> repliesMap = (Map<String,Object>) commentItemMap.get('replies');
                            List<Object> replyData = (List<Object>) repliesMap.get('data');
                            for (Object replyItem : replyData) {
                                Map<String,Object> replyItemMap = (Map<String,Object>) replyItem;
                                commentList.add(new Map<String,Object>{
                                    'interactionId'=>(String) replyItemMap.get('id'),
                                    'parentInteractionId'=>(String) commentItemMap.get('id'),//parent interaction id
                                    'interactionText'=>(String) replyItemMap.get('text'),
                                    'timeStamp'=>(String) replyItemMap.get('timestamp'),
                                    'authorName'=>(String) replyItemMap.get('username')
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
    // reply post or comment
    @AuraEnabled
    public static Map<String,Object> sentReplyToPostTemp(String postId, String message){
        return InstagramService.getInstance().sentReplyToPost(postId, message);
    }
    public Map<String,Object> sentReplyToPost(String postId, String message){
        APIService api = new APIService();
        Map<String, Object> postAndCommentMap = new Map<String, Object>();
        String endpoint = BASE_PATH + postId + '/comments';
        String fullApiEndPoint = 'callout:'+namedCredential+apiEndpoint+endpoint;
        String payload = 'message=' + EncodingUtil.urlEncode(message, 'UTF-8') +
                         '&access_token=' + EncodingUtil.urlEncode(INSTAGRAM_ACCESS_TOKEN, 'UTF-8');
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
    public Map<String,Object> sentReplyToComment(String commentId, String message){
        APIService api = new APIService();
        Map<String, Object> postAndCommentMap = new Map<String, Object>();
        String endpoint = BASE_PATH + commentId + '/replies';
        String fullApiEndPoint = 'callout:'+namedCredential+apiEndpoint+endpoint;
        String payload = 'message=' + EncodingUtil.urlEncode(message, 'UTF-8') +
                         '&access_token=' + EncodingUtil.urlEncode(INSTAGRAM_ACCESS_TOKEN, 'UTF-8');
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