public with sharing class SocialMediaContentController {
    
    public class FakeDataWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String author;
        @AuraEnabled public String source;
        @AuraEnabled public String datee;
        @AuraEnabled public String sentiment;
        @AuraEnabled public String message;
        @AuraEnabled public Analysis analysis;
    }

    public class Analysis {
        @AuraEnabled public String contentType;
        @AuraEnabled public String intent;
        @AuraEnabled public String urgency;
        @AuraEnabled public Integer engagement;
        @AuraEnabled public Integer confidence;
        @AuraEnabled public String action;
    }

    ////////////////////////GEt Parent Accounts with Child Counts/////////////////////////////////////

@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getParentAccountsWithChildCount() {
    try {
        List<Account> parentAccounts = [SELECT Id, Name FROM Account WHERE ParentId = null];
        List<Account> childAccounts = [SELECT Id, ParentId FROM Account WHERE ParentId != null];
        Map<Id, Integer> childCounts = new Map<Id, Integer>();

        // Count children for each parent
        for (Account acc : parentAccounts) {
            Integer count = 0;
            for (Account child : childAccounts) {
                if (child.ParentId == acc.Id) {
                    count++;
                }
            }
            childCounts.put(acc.Id, count);
        }

        // Prepare result with parent details and child count
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        for (Account acc : parentAccounts) {
            Map<String, Object> entry = new Map<String, Object>();
            entry.put('Id', acc.Id);
            entry.put('Name', acc.Name);
            entry.put('ChildCount', childCounts.get(acc.Id));
            results.add(entry);
        }
        return results;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}

///////////////////////////////////////////////////Child accounts //////////////////////////////////////////////////////////////////

@AuraEnabled(cacheable=true)
public static List<Account> getChildAccountsByParentId(Id parentId) {
    try {
        // Query all child accounts for the given parent account Id
        List<Account> childAccounts = [
            SELECT Id, Name, ParentId, Parent.Name 
            FROM Account 
            WHERE ParentId = :parentId
            ORDER BY Name
        ];
        return childAccounts;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}

///////////////////////////////////////////GET child accounts review ,comments,posts,tweets//////////////////////////////////////////////////////////////////////////


@AuraEnabled(cacheable=true)
public static Map<String, Object> getChildAccountsWithContentTypeCountsByParentId(Id parentId) {
    try {
        // Query child accounts for the given parent
        List<Account> childAccounts = [
            SELECT Id, Name, ParentId
            FROM Account
            WHERE ParentId = :parentId
            ORDER BY Name
        ];

        // Collect child account Ids
        Set<Id> childAccountIds = new Set<Id>();
        for (Account acc : childAccounts) {
            childAccountIds.add(acc.Id);
        }

        // Query Social Media Accounts related to child Accounts
        Map<Id, List<Id>> accountToSocialMediaAccountIds = new Map<Id, List<Id>>();
        if (!childAccountIds.isEmpty()) {
            List<Social_Media_Account__c> socialMediaAccounts = [
                SELECT Id, Account__c
                FROM Social_Media_Account__c
                WHERE Account__c IN :childAccountIds
            ];
            for (Social_Media_Account__c sma : socialMediaAccounts) {
                if (!accountToSocialMediaAccountIds.containsKey(sma.Account__c)) {
                    accountToSocialMediaAccountIds.put(sma.Account__c, new List<Id>());
                }
                accountToSocialMediaAccountIds.get(sma.Account__c).add(sma.Id);
            }
        }

        // Query Social Media Content records for all Social Media Accounts
        Map<Id, Map<String, Integer>> accountContentTypeCounts = new Map<Id, Map<String, Integer>>();
        Set<Id> allSocialMediaAccountIds = new Set<Id>();
        for (List<Id> ids : accountToSocialMediaAccountIds.values()) {
            allSocialMediaAccountIds.addAll(ids);
        }
        if (!allSocialMediaAccountIds.isEmpty()) {
            List<AggregateResult> contentCounts = [
                SELECT Social_Media_Account__c, Content_Type__c, COUNT(Id) cnt
                FROM Social_Media_Content__c
                WHERE Social_Media_Account__c IN :allSocialMediaAccountIds
                GROUP BY Social_Media_Account__c, Content_Type__c
            ];
            // Map Social Media Account Id to Content Type counts
            Map<Id, Map<String, Integer>> socialMediaAccountContentTypeCounts = new Map<Id, Map<String, Integer>>();
            for (AggregateResult ar : contentCounts) {
                Id smaId = (Id)ar.get('Social_Media_Account__c');
                String type = (String)ar.get('Content_Type__c');
                Integer cnt = (Integer)ar.get('cnt');
                if (!socialMediaAccountContentTypeCounts.containsKey(smaId)) {
                    socialMediaAccountContentTypeCounts.put(smaId, new Map<String, Integer>());
                }
                socialMediaAccountContentTypeCounts.get(smaId).put(type, cnt);
            }
            // For each Account, sum up counts for all its Social Media Accounts
            for (Id accId : accountToSocialMediaAccountIds.keySet()) {
                Map<String, Integer> typeCounts = new Map<String, Integer>();
                for (Id smaId : accountToSocialMediaAccountIds.get(accId)) {
                    if (socialMediaAccountContentTypeCounts.containsKey(smaId)) {
                        for (String type : socialMediaAccountContentTypeCounts.get(smaId).keySet()) {
                            Integer cnt = socialMediaAccountContentTypeCounts.get(smaId).get(type);
                            typeCounts.put(type, typeCounts.containsKey(type) ? typeCounts.get(type) + cnt : cnt);
                        }
                    }
                }
                accountContentTypeCounts.put(accId, typeCounts);
            }
        }

        // Prepare result map
        Map<String, Object> result = new Map<String, Object>();
        List<Map<String, Object>> children = new List<Map<String, Object>>();
        for (Account acc : childAccounts) {
            Map<String, Object> entry = new Map<String, Object>();
            entry.put('Id', acc.Id);
            entry.put('Name', acc.Name);

           List<String> allContentTypes = new List<String>{ 'post', 'review', 'tweet' ,'reel','video','story'};

            // Prepare content type counts for this child account
           

List<Map<String, Object>> contentTypeList = new List<Map<String, Object>>();
Map<String, Integer> counts = accountContentTypeCounts.containsKey(acc.Id)
    ? accountContentTypeCounts.get(acc.Id)
    : new Map<String, Integer>();

for (String type : allContentTypes) {
    Integer count = counts.containsKey(type) ? counts.get(type) : 0;
    contentTypeList.add(new Map<String, Object>{
        'ContentType' => type,
        'Count' => count

    });
}
            entry.put('ContentTypesWithCount', contentTypeList);

            children.add(entry);

            
        }
        result.put('ParentId', parentId);
        result.put('Children', children);
        system.debug(result);
        return result;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}



///////////////////////////////////////////Child DND//////////////////////////////////////////////////


    @AuraEnabled(cacheable=true)
    public static List<FakeDataWrapper> getSocialContent() {
        List<FakeDataWrapper> results = new List<FakeDataWrapper>();

        // Query Social Media Content with related Interaction and AI Analysis
        List<Social_Media_Content__c> contents = [
            SELECT Id, Author_Name__c, Social_Media_Account__c, Published_Date__c, Sentiment__c, Content_Text__c,
                (SELECT Id, Sentiment__c, Intent_Category__c, Urgency_Level__c, Interaction_Text__c
                 FROM Social_Media_Interactions__r
                 
                 LIMIT 1)
            FROM Social_Media_Content__c
            WHERE Published_Date__c != NULL
            ORDER BY Published_Date__c DESC
            LIMIT 10
        ];

        for (Social_Media_Content__c content : contents) {
            if (content.Social_Media_Interactions__r.isEmpty()) continue;

            Social_Media_Interaction__c interaction = content.Social_Media_Interactions__r[0];
            FakeDataWrapper wrapper = new FakeDataWrapper();

            wrapper.id = content.Id;
            wrapper.author = content.Author_Name__c;
            wrapper.source = content.Social_Media_Account__c;
            wrapper.datee = String.valueOf(content.Published_Date__c);
            wrapper.sentiment = content.Sentiment__c;
            wrapper.message = content.Content_Text__c;

            Analysis analysis = new Analysis();
            analysis.contentType = content.Content_Type__c;
            analysis.intent = interaction.Intent_Category__c;
            analysis.urgency = interaction.Urgency_Level__c;
            analysis.engagement = 10 + Math.mod(Crypto.getRandomInteger(), 20); // Simulated engagement
            analysis.action = getRecommendedAction(interaction.Urgency_Level__c, interaction.Intent_Category__c);

            wrapper.analysis = analysis;
            results.add(wrapper);
        }

        return results;
    }
//////////////////////////////////////SOCAIL MEDIA CONTENT BASES ON SUB ACCOUNT////////////////////////////////////////////////////

@AuraEnabled(cacheable=true)
    public static Map<String, Object> getContentWithInteractions(Id accountId) {
        Map<String, Object> result = new Map<String, Object>();
        
        // Step 1: Get Social Media Content related to the Account via lookup
        List<Social_Media_Content__c> contentList = [
            SELECT Id, Name, Author_Name__c, Author_Platform_ID__c, Content_Text__c,
                   Content_Type__c, Content_URL__c, Engagement_Score__c, Sentiment__c,
                   Published_Date__c, Platform_Content_ID__c
            FROM Social_Media_Content__c
            WHERE Social_Media_Account__r.Account__c = :accountId
        ];
        
        // Step 2: Collect Content Ids
        Set<Id> contentIds = new Set<Id>();
        for (Social_Media_Content__c c : contentList) {
            contentIds.add(c.Id);
        }

        // Step 3: Get related interactions
        List<Social_Media_Interaction__c> interactionList = new List<Social_Media_Interaction__c>();
        if (!contentIds.isEmpty()) {
            interactionList = [
                SELECT Id, Name, Author_Name__c, Interaction_Text__c, Intent_Category__c,
                       Sentiment__c, Urgency_Level__c, Response_Text__c, Response_Date__c,
                       Has_Response__c, CreatedDate
                FROM Social_Media_Interaction__c
                WHERE Social_Media_Content__c IN :contentIds
            ];
        }

        result.put('contents', contentList);
        result.put('interactions', interactionList);
        return result;
    }
///////////////////////////Above same with samlpe 2///////////////

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getFakeDataFromAccount(Id accountId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        // Get related content
        List<Social_Media_Content__c> contents = [
            SELECT Id, Author_Name__c, Author_Platform_ID__c, Content_Text__c,
                   Content_Type__c, Sentiment__c, Published_Date__c,
                   Engagement_Score__c
            FROM Social_Media_Content__c
            WHERE Social_Media_Account__r.Account__c = :accountId
        ];

        for (Social_Media_Content__c c : contents) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('id', c.Id);
            row.put('author', c.Author_Name__c);
            row.put('source', c.Author_Platform_ID__c);
            row.put('date', String.valueOf(c.Published_Date__c));
            row.put('sentiment', c.Sentiment__c != null ? c.Sentiment__c.toLowerCase() : 'neutral');
            row.put('message', c.Content_Text__c);

            // AI Analysis block
            Map<String, Object> analysis = new Map<String, Object>();
            analysis.put('contentType', c.Content_Type__c);
            analysis.put('intent', 'Purchase Interest'); // Example fallback
            analysis.put('urgency', 'Medium');
            analysis.put('engagement', c.Engagement_Score__c != null ? c.Engagement_Score__c : 0);
            analysis.put('confidence', 87); // example static, or based on logic
            analysis.put('action', 'Follow up within 2 hours');

            row.put('analysis', analysis);
            result.add(row);
        }

        return result;
    }


    ///////////////////////////////////////RECOMMENDED ACTION BASED ON URGENCY AND INTENT////////////////////////////////////////////////////

    private static String getRecommendedAction(String urgency, String intent) {
        if (urgency == 'high' || urgency == 'critical') {
            return 'Immediate Response';
        } else if (intent == 'purchase_inquiry') {
            return 'Follow up within 2 hours';
        } else {
            return 'Respond within 1 day';
        }
    }
}