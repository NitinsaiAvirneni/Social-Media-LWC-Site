public with sharing class SocialMediaContentController {
/////////////////////////////////////genral reply and genral data from objec/////
@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getSMAData(Id recordId) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();

    // Query Social_Media_Account__c by recordId
    List<Social_Media_Account__c> accounts = [
        SELECT Id, Name, Account__c, Platform__c, Platform_Account_ID__c, Platform_Username__c,
               Connection_Status__c, Is_Active__c, Last_Sync__c, Sync_Frequency__c,
               Access_Token__c, Refresh_Token__c, Token_Expires__c, OwnerId, CreatedById, LastModifiedById 
        FROM Social_Media_Account__c
        WHERE Id = :recordId
    ];

    for (Social_Media_Account__c acc : accounts) {
        Map<String, Object> row = new Map<String, Object>();
        row.put('id', acc.Id);
        row.put('name', acc.Name);
        row.put('accountId', acc.Account__c);
        row.put('platform', acc.Platform__c);
        row.put('platformAccountId', acc.Platform_Account_ID__c);
        row.put('platformUsername', acc.Platform_Username__c);
        row.put('connectionStatus', acc.Connection_Status__c);
        row.put('isActive', acc.Is_Active__c);
        row.put('lastSync', acc.Last_Sync__c);
        row.put('syncFrequency', acc.Sync_Frequency__c);
        row.put('accessToken', acc.Access_Token__c);
        row.put('refreshToken', acc.Refresh_Token__c);
        row.put('ownerId', acc.OwnerId);
        row.put('createdById', acc.CreatedById);
        row.put('lastModifiedById', acc.LastModifiedById);
        result.add(row);
    }

    return result;
}


/////////////////////////////////////genral reply and genral data from objec/////
@AuraEnabled(cacheable=true)
public static Map<String, Object> getSocialMediaContentById(Id contentId) {
    Map<String, Object> result = new Map<String, Object>();

    // Query Social_Media_Content__c by Id
    Social_Media_Content__c content = [
        SELECT Id, Name, Author_Name__c, Author_Platform_ID__c, Content_Text__c, Content_Type__c,
               Content_URL__c, CreatedById, Engagement_Score__c, Facebook_Page_ID__c, Has_Image__c,
               Has_Video__c, Is_Company_Content__c, LastModifiedById, Last_Updated__c, Lead_Potential__c,
               OwnerId, Platform__c, Platform_Content_ID__c, Published_Date__c, Rating__c,
               Response_Priority__c, Response_Required__c, Sentiment__c, Social_Media_Account__c, User__c
        FROM Social_Media_Content__c
        WHERE Id = :contentId
        LIMIT 1
    ];

    if (content != null) {
        result.put('id', content.Id);
        result.put('name', content.Name);
        result.put('authorName', content.Author_Name__c);
        result.put('authorPlatformId', content.Author_Platform_ID__c);
        result.put('contentText', content.Content_Text__c);
        result.put('contentType', content.Content_Type__c);
        result.put('contentUrl', content.Content_URL__c);
        result.put('createdById', content.CreatedById);
        result.put('engagementScore', content.Engagement_Score__c);
        result.put('facebookPageId', content.Facebook_Page_ID__c);
        result.put('hasImage', content.Has_Image__c);
        result.put('hasVideo', content.Has_Video__c);
        result.put('isCompanyContent', content.Is_Company_Content__c);
        result.put('lastModifiedById', content.LastModifiedById);
        result.put('lastUpdated', content.Last_Updated__c);
        result.put('leadPotential', content.Lead_Potential__c);
        result.put('ownerId', content.OwnerId);
        result.put('platform', content.Platform__c);
        result.put('platformContentId', content.Platform_Content_ID__c);
        result.put('publishedDate', content.Published_Date__c);
        result.put('rating', content.Rating__c);
        result.put('responsePriority', content.Response_Priority__c);
        result.put('responseRequired', content.Response_Required__c);
        result.put('sentiment', content.Sentiment__c);
        result.put('socialMediaAccountId', content.Social_Media_Account__c);
        result.put('userId', content.User__c);
    }

    return result;
}


/////////////////////////////////////////////to show all interacation based on content id ////////////////////////////////////////

@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getDataFromContent(Id contentId) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();

    // Query Social_Media_Interaction__c where the lookup matches the given contentId
    List<Social_Media_Interaction__c> interactions = [
        SELECT Id, Author_Name__c, Sentiment__c, Urgency_Level__c, Interaction_Text__c, CreatedDate, Response_Date__c,Parent_Interaction_Id__c	
        FROM Social_Media_Interaction__c
        WHERE Social_Media_Content__c = :contentId
    ];

    for (Social_Media_Interaction__c i : interactions) {
        Map<String, Object> row = new Map<String, Object>();
    
       
    
        /////////////////////////////////////// comments Data block //////////////////////////////////////
        if (i != null) {
            row.put('id', i.Id != null ? i.Id : 'No data');
            row.put('author', String.isNotBlank(i.Author_Name__c) ? i.Author_Name__c : 'No data');
            row.put('date', i.Response_Date__c != null ? String.valueOf(i.Response_Date__c) : 'No data');
            row.put('sentiment', String.isNotBlank(i.Sentiment__c) ? i.Sentiment__c.toLowerCase() : 'No data');
            row.put('message', String.isNotBlank(i.Interaction_Text__c) ? i.Interaction_Text__c : 'No data');
            row.put('parentInteractionId', i.Parent_Interaction_Id__c != null ? i.Parent_Interaction_Id__c : 'No data');
       
        } else {
            row.put('id', 'No data');
            row.put('author', 'No data');
            row.put('source', 'No data');
            row.put('date', 'No data');
            row.put('sentiment', 'No data');
            row.put('message', 'No data');
        }
    
        result.add(row);
    }

    return result;
}    
    


////////////////////////////to see all interactions with content via view buton /////////////////////////////////////
 @AuraEnabled(cacheable=true)
    public static Social_Media_Content__c getContentDetails(Id contentId) {
        return [
            SELECT Id, Name, Author_Name__c, Content_Text__c, Published_Date__c, Sentiment__c
            FROM Social_Media_Content__c
            WHERE Id = :contentId
            LIMIT 1
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Social_Media_Interaction__c> getInteractionsByContentId(Id contentId) {
        return [
            SELECT Id, Name, Author_Name__c, Interaction_Text__c, Sentiment__c, CreatedDate, Has_Response__c
            FROM Social_Media_Interaction__c
            WHERE Social_Media_Content__c = :contentId
            ORDER BY CreatedDate DESC
        ];
    }
    
    ///////////Insert to Leads with error handling and field validation///
    @AuraEnabled
    public static Lead createLead(Map<String, Object> lead) {
        // Null check for lead
        if (lead == null) {
            throw new AuraHandledException('Lead data is required.');
        }
        // Basic validation (example: required fields)
        String lastName = (String)lead.get('LastName');
        String company = (String)lead.get('Company');
        if (String.isBlank(lastName) || String.isBlank(company)) {
            throw new AuraHandledException('LastName and Company are required.');
        }
        Lead leadData = new Lead();
        leadData.FirstName = (String)lead.get('FirstName');
        leadData.LastName = lastName;
        leadData.Company = company;
        leadData.Title = (String)lead.get('Title');
        leadData.Email = (String)lead.get('Email');
        leadData.Phone = (String)lead.get('Phone');
        try {
            insert leadData;
            return leadData;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating Lead: ' + e.getMessage());
        }
    }
    
    ///////////Insert to Cases///
    @AuraEnabled
    public static Case createCase(Map<String, Object> caseMap) {
        // Null check for caseMap
        if (caseMap == null) {
            throw new AuraHandledException('Case data is required.');
        }
        // Basic validation (example: required fields)
        String subject = (String)caseMap.get('Subject');
        String origin = (String)caseMap.get('Origin');
        if (String.isBlank(subject) || String.isBlank(origin)) {
            throw new AuraHandledException('Subject and Origin are required.');
        }
        Case caseData = new Case();
        caseData.Subject = subject;
        caseData.Origin = origin;
        caseData.Status = (String)caseMap.get('Status');
        caseData.Priority = (String)caseMap.get('Priority');
        caseData.Description = (String)caseMap.get('Description');
        caseData.ContactId = (Id)caseMap.get('ContactId');
        caseData.AccountId = (Id)caseMap.get('AccountId');
        // Add support for SuppliedEmail and SuppliedPhone
        caseData.SuppliedEmail = (String)caseMap.get('SuppliedEmail');
        caseData.SuppliedPhone = (String)caseMap.get('SuppliedPhone');
        try {
            insert caseData;
            return caseData;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating Case: ' + e.getMessage());
        }
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
                
                List<String> allContentTypes = new List<String>{ 'Post', 'Review', 'Tweet' ,'Reel','Video','Story'};
                
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
    public static List<Map<String, Object>> getDataFromAccount(Id accountId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        
        // Get related content
        List<Social_Media_Content__c> contents = [
            SELECT Id, Author_Name__c, Author_Platform_ID__c, Platform__c, Content_Text__c,
                   Content_Type__c, Sentiment__c, Published_Date__c,
                   Engagement_Score__c, Platform_Content_ID__c
            FROM Social_Media_Content__c
            WHERE Social_Media_Account__r.Account__c = :accountId
        ];
        
        for (Social_Media_Content__c c : contents) {
            Map<String, Object> row = new Map<String, Object>();
//////////////////////////////SMM Data block//////////////////////////////////////////////////////////////////////////////////            
            row.put('id', c.Id != null ? c.Id : 'No data');
            row.put('author', String.isNotBlank(c.Author_Name__c) ? c.Author_Name__c : 'No data');
            row.put('source', String.isNotBlank(c.Platform__c) ? c.Platform__c : 'No data');
            row.put('contentId', String.isNotBlank(c.Platform_Content_ID__c) ? c.Platform_Content_ID__c : 'No data');
            row.put('contentType', String.isNotBlank(c.Content_Type__c) ? c.Content_Type__c.toLowerCase() : 'No data');
            row.put('date', c.Published_Date__c != null ? String.valueOf(c.Published_Date__c) : 'No data');
            row.put('sentiment', String.isNotBlank(c.Sentiment__c) ? c.Sentiment__c.toLowerCase() : 'No data');
            row.put('message', String.isNotBlank(c.Content_Text__c) ? c.Content_Text__c : 'No data');
 ///////////////////////////////////////////// AI Analysis block/////////////////////////////////////////////////////////////

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
    
    
    /////////////////////////////////////////////////For Pie Chart Data////////////////////////////////////////////////////
    // @AuraEnabled(cacheable=true)
    // public static List<Map<String, Object>> getInteractionSummaryByParent(Id parentId) {
    //     List<Map<String, Object>> result = new List<Map<String, Object>>();

    //     // Query all Social Media Accounts under the given parent Account
    //     List<Social_Media_Account__c> accounts = [
    //         SELECT Id, Name, Platform__c
    //         FROM Social_Media_Account__c
    //         WHERE Account__c = :parentId
    //     ];

    //     // Collect all Social_Media_Account__c Ids for batch query
    //     Set<Id> socialMediaAccountIds = new Set<Id>();
    //     for (Social_Media_Account__c acc : accounts) {
    //         socialMediaAccountIds.add(acc.Id);
    //     }

    //     // Query all Social_Media_Content__c for these accounts
    //     Map<Id, List<Social_Media_Content__c>> accountIdToContents = new Map<Id, List<Social_Media_Content__c>>();

    //     // Query all interactions for these contents
    //     Map<Id, Integer> contentIdToInteractionCount = new Map<Id, Integer>();
    //     if (!contentIds.isEmpty()) {
    //         AggregateResult[] interactionCounts = [
    //             SELECT Social_Media_Content__c contentId, COUNT(Id) cnt
    //             FROM Social_Media_Interaction__c
    //             WHERE Social_Media_Content__c IN :contentIds
    //             GROUP BY Social_Media_Content__c
    //         ];
    //         for (AggregateResult ar : interactionCounts) {
    //             contentIdToInteractionCount.put(
    //                 (Id)ar.get('contentId'),
    //                 (Integer)ar.get('cnt')
    //             );
    //         }
    //     }

    //     // For each account, sum up the interactions of its contents
    //     for (Social_Media_Account__c acc : accounts) {
    //         Integer count = 0;
    //         for (Social_Media_Content__c content : acc.Social_Media_Contents__r) {
    //             count += contentIdToInteractionCount.containsKey(content.Id) ? contentIdToInteractionCount.get(content.Id) : 0;
    //         }
    //         result.add(new Map<String, Object>{
    //             'label' => acc.Name,
    //             'value' => count,
    //             'id' => acc.Id
    //         });
    //     }
        
    //     return result;
    // }
    
    
    // @AuraEnabled(cacheable=true)
    // public static List<Map<String, Object>> getPlatformBreakdownByAccount(Id accountId) {
    //     List<Map<String, Object>> output = new List<Map<String, Object>>();
    //     AggregateResult[] groupedResults = [
    //         SELECT Content_Type__c contentType, COUNT(Id) total
    //         FROM Social_Media_Content__c
    //         WHERE Social_Media_Account__c = :accountId
    //         GROUP BY Content_Type__c
    //     ];
        
    //     for (AggregateResult ar : groupedResults) {
    //         output.add(new Map<String, Object>{
    //             'label' => String.valueOf(ar.get('contentType')),
    //             'value' => (Integer) ar.get('total')
    //         });
    //     }
        
    //     return output;
    // }

     @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getInteractionSummaryByParent(Id parentId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        // Query all Social Media Accounts under the given parent Account
        List<Social_Media_Account__c> accounts = [
            SELECT Id, Name, Platform__c
            FROM Social_Media_Account__c
            WHERE Account__c = :parentId
        ];

        // Collect all Social_Media_Account__c Ids for batch query
        Set<Id> socialMediaAccountIds = new Set<Id>();
        for (Social_Media_Account__c acc : accounts) {
            socialMediaAccountIds.add(acc.Id);
        }

        // Query all Social_Media_Content__c for these accounts
        Map<Id, List<Social_Media_Content__c>> accountIdToContents = new Map<Id, List<Social_Media_Content__c>>();
        Set<Id> contentIds = new Set<Id>();
        if (!socialMediaAccountIds.isEmpty()) {
            List<Social_Media_Content__c> contents = [
                SELECT Id, Social_Media_Account__c
                FROM Social_Media_Content__c
                WHERE Social_Media_Account__c IN :socialMediaAccountIds
            ];
            for (Social_Media_Content__c content : contents) {
                contentIds.add(content.Id);
                if (!accountIdToContents.containsKey(content.Social_Media_Account__c)) {
                    accountIdToContents.put(content.Social_Media_Account__c, new List<Social_Media_Content__c>());
                }
                accountIdToContents.get(content.Social_Media_Account__c).add(content);
            }
        }

        // Query all interactions for these contents
        Map<Id, Integer> contentIdToInteractionCount = new Map<Id, Integer>();
        if (!contentIds.isEmpty()) {
            AggregateResult[] interactionCounts = [
                SELECT Social_Media_Content__c contentId, COUNT(Id) cnt
                FROM Social_Media_Interaction__c
                WHERE Social_Media_Content__c IN :contentIds
                GROUP BY Social_Media_Content__c
            ];
            for (AggregateResult ar : interactionCounts) {
                contentIdToInteractionCount.put(
                    (Id)ar.get('contentId'),
                    (Integer)ar.get('cnt')
                );
            }
        }

        // For each account, sum up the interactions of all its contents
        for (Social_Media_Account__c acc : accounts) {
            Integer count = 0;
            List<Social_Media_Content__c> contents = accountIdToContents.containsKey(acc.Id) ? accountIdToContents.get(acc.Id) : new List<Social_Media_Content__c>();
            for (Social_Media_Content__c content : contents) {
                count += contentIdToInteractionCount.containsKey(content.Id) ? contentIdToInteractionCount.get(content.Id) : 0;
            }
            result.add(new Map<String, Object>{
                'label' => acc.Name,
                'value' => count,
                'id' => acc.Id
            });
        }

        return result;
    }
    public static Set<Id> getAllDescendantAccountIds(Id parentId) {
    Set<Id> allIds = new Set<Id>{parentId};
    List<Account> children = [SELECT Id FROM Account WHERE ParentId = :parentId];
    for (Account child : children) {
        allIds.addAll(getAllDescendantAccountIds(child.Id));
    }
    return allIds;
}


    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPlatformBreakdownByAccount(Id accountId) {
        List<Map<String, Object>> output = new List<Map<String, Object>>();
        // Get all Social Media Accounts for the given Account
        List<Social_Media_Account__c> smAccounts = [
            SELECT Id
            FROM Social_Media_Account__c
            WHERE Account__c = :accountId
        ];
        Set<Id> smAccountIds = new Set<Id>();
        for (Social_Media_Account__c sma : smAccounts) {
            smAccountIds.add(sma.Id);
        }
        if (!smAccountIds.isEmpty()) {
            AggregateResult[] groupedResults = [
                SELECT Content_Type__c contentType, COUNT(Id) total
                FROM Social_Media_Content__c
                WHERE Social_Media_Account__c IN :smAccountIds
                GROUP BY Content_Type__c
            ];
            for (AggregateResult ar : groupedResults) {
                output.add(new Map<String, Object>{
                    'label' => String.valueOf(ar.get('contentType')),
                    'value' => (Integer) ar.get('total')
                });
            }
        }
        return output;
    }
    // create comment/reply
    @AuraEnabled
    public static void sendComment(String id, String message, String platformName, String commentType) {
        // Input validation
        if (String.isBlank(id) || String.isBlank(message) || String.isBlank(platformName) || String.isBlank(commentType)) {
            throw new IllegalArgumentException('All parameters must be provided');
        }
        
        // Validate comment type
        if (commentType != 'comment' && commentType != 'post') {
            throw new IllegalArgumentException('Invalid comment type. Must be "comment" or "post"');
        }
        
        try {
            switch on platformName.toLowerCase() {
                when 'instagram' {
                    handleInstagramComment(id, message, commentType);
                }
                when 'facebook' {
                    handleFacebookComment(id, message, commentType);
                }
                when else {
                    throw new UnsupportedOperationException('Platform "' + platformName + '" is not supported');
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in sendComment: ' + e.getMessage());
            throw new AuraHandledException('Failed to send comment: ' + e.getMessage());
        }
    }

    private static void handleInstagramComment(String id, String message, String commentType) {
        InstagramService instaService = new InstagramService();
        
        if (commentType == 'post') {
            instaService.sentReplyToPost(id, message);
        } else {
            instaService.sentReplyToComment(id, message);
        }
    }

    private static void handleFacebookComment(String id, String message, String commentType) {
        FacebookService facebookService = new FacebookService();
        String pageId = getPageIdForFacebook(id, commentType);
        String pageAccessToken = facebookService.getPageAccessTokenByPageId(pageId);
        
        if (commentType == 'comment') {
            facebookService.sentReplyToPost(id, message, pageAccessToken);
        } else {
            facebookService.sentReplyToComment(id, message, pageAccessToken);
        }
    }

    private static String getPageIdForFacebook(String id, String commentType) {
        String pageId;
        
        if (commentType == 'comment') {
            List<Social_Media_Interaction__c> records = [
                SELECT Facebook_Page_ID__c 
                FROM Social_Media_Interaction__c 
                WHERE Platform_Interaction_Id__c = :id 
                LIMIT 1
            ];
            
            if (records.isEmpty()) {
                throw new QueryException('No Social Media Interaction found for ID: ' + id);
            }
            pageId = records[0].Facebook_Page_ID__c;
            
        } else { // reply
            List<Social_Media_Content__c> records = [
                SELECT Facebook_Page_ID__c 
                FROM Social_Media_Content__c 
                WHERE Platform_Content_ID__c = :id 
                LIMIT 1
            ];
            
            if (records.isEmpty()) {
                throw new QueryException('No Social Media Content found for ID: ' + id);
            }
            System.debug('records: '+records);
            pageId = records[0].Facebook_Page_ID__c;
        }
        
        if (String.isBlank(pageId)) {
            throw new AuraHandledException('Facebook Page ID is blank for record with ID: ' + id);
        }
        
        return pageId;
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}