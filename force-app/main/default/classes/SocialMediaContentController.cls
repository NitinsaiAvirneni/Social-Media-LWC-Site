public with sharing class SocialMediaContentController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Account>> getVisitsByAccountId(Id accountId) {
        Map<String, List<Account>> groupedAccounts = new Map<String, List<Account>>();

        List<Account> accounts = [
            SELECT Id, Name, CreatedDate
            FROM Account
            WHERE ParentId = :accountId
            ORDER BY CreatedDate DESC
        ];

        for (Account acc : accounts) {
            String dateKey = acc.CreatedDate != null ? String.valueOf(acc.CreatedDate) : 'No Date';
            if (!groupedAccounts.containsKey(dateKey)) {
                groupedAccounts.put(dateKey, new List<Account>());
            }
            groupedAccounts.get(dateKey).add(acc);
        }

        return groupedAccounts;
    }
/////////////////////////////////test///
@AuraEnabled(cacheable=true)
public static Map<String, String> getLookups(String recordId, String objectApiName) {
    Map<String, String> lookups = new Map<String, String>();

    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
    if (objType == null) return lookups;

    Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
    List<String> refFieldNames = new List<String>();

    for (String fieldName : fieldsMap.keySet()) {
        Schema.DescribeFieldResult fieldDesc = fieldsMap.get(fieldName).getDescribe();
        if (fieldDesc.getType() == Schema.DisplayType.REFERENCE) {
            refFieldNames.add(fieldName);
        }
    }

    if (refFieldNames.isEmpty()) return lookups;

    // Build dynamic SOQL with relationship fields for lookups
    List<String> selectFields = new List<String>();
    for (String refField : refFieldNames) {
        // For Social_Media_Content__c, get Name field from parent
        if (refField == 'Social_Media_Content__c') {
            selectFields.add('Social_Media_Content__r.Name');
        } else {
            selectFields.add(refField);
        }
    }
    String soql = 'SELECT ' + String.join(selectFields, ', ') + ' FROM ' + objectApiName + ' WHERE Id = :recordId LIMIT 1';
    List<SObject> records = Database.query(soql);
    if (records.isEmpty()) {
        return lookups;
    }
    SObject record = records[0];

    for (String refField : refFieldNames) {
        Schema.DescribeFieldResult fieldDesc = fieldsMap.get(refField).getDescribe();
        String label = fieldDesc.getLabel();
        if (refField == 'Social_Media_Content__c') {
            // Get parent Social Media Content Name
            SObject parentContent = (SObject)record.getSObject('Social_Media_Content__r');
            if (parentContent != null && parentContent.get('Name') != null) {
                lookups.put(label, (String)parentContent.get('Name'));
            }
        } else {
            Object refValue = record.get(refField);
            if (refValue != null && refValue instanceof SObject) {
                SObject refRecord = (SObject) refValue;
                String parentName = (String)refRecord.get('Name');
                lookups.put(label, parentName);
            }
        }
    }

    return lookups;
}
////////////////////////////to see all interactions with content via view buton /////////////////////////////////////
 @AuraEnabled(cacheable=true)
    public static Social_Media_Content__c getContentDetails(Id contentId) {
        return [
            SELECT Id, Name, Author_Name__c, Content_Text__c, Published_Date__c, Platform__c, Sentiment__c
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
            SELECT Id, Author_Name__c, Author_Platform_ID__c,Platform__c, Content_Text__c,
                   Content_Type__c, Sentiment__c, Published_Date__c,
                   Engagement_Score__c
            FROM Social_Media_Content__c
            WHERE Social_Media_Account__r.Account__c = :accountId
        ];
        
        for (Social_Media_Content__c c : contents) {
            Map<String, Object> row = new Map<String, Object>();
//////////////////////////////SMM Data block//////////////////////////////////////////////////////////////////////////////////            
            row.put('id', c.Id != null ? c.Id : 'No data');
            row.put('author', String.isNotBlank(c.Author_Name__c) ? c.Author_Name__c : 'No data');
            row.put('source', String.isNotBlank(c.Platform__c) ? c.Platform__c : 'No data');
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
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}