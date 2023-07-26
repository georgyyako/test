public class NWT_EmailMessageTriggerHandler {
    // public void beforeInsert(List<sObject> newList) {
    // }
    public void afterInsert(List<EmailMessage> newList , Map<Id, EmailMessage> newMap) {
        for (EmailMessage em : newList) {
            if (EmailMessage_Settings__c.getInstance().EmailMessage_checkForDuplicate__c) {
                checkDuplicates(em);
            }
        }
    }
    public void beforeUpdate(List<EmailMessage> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        if(checkSyncUserNowboard()) {
            List<EmailMessage> caseEmailMessageList = new List<EmailMessage>();
            for (EmailMessage em : newList) {
                if (em.ParentId != null) {
                    caseEmailMessageList.add(em);
                }
            }
            NWT_NowboardUpdateCheck.isUpdated(caseEmailMessageList, oldMap);
        }
    }
    // public void afterUpdate(List<EmailMessage> newList, Map<Id, EmailMessage> newMap, List<EmailMessage> oldList, Map<Id, EmailMessage> oldMap) {
    // }
    public void beforeDelete(List<sObject> oldList ,Map<Id, sObject> oldMap) {
        // create record on NWT_Nowboard_Deleted__c object that this record is deleted
        if (checkSyncUserNowboard()) {
            NWT_NowboardDeletedRecords.createRecords(oldList, false, null, false, false, null);
        }
    }
    // public void afterDelete(List<EmailMessage> oldList , Map<Id, EmailMessage> oldMap) {
    // }
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
        if (checkSyncUserNowboard()) {
            NWT_NowboardDeletedRecords.createRecords(newList, true, null, true, false, null);
        }
    }
    public Boolean checkSyncUserNowboard() {
        List<User> userList = [SELECT User_for_Sync_Nowboard__c FROM User WHERE Id =: UserInfo.getUserId()];
        if (userList != null && !userList.isEmpty()) {
            if (userList[0].User_for_Sync_Nowboard__c != true) {
                return true;
            }
        }
        return false;
    }
    public static void checkDuplicates(EmailMessage em) {
        Boolean checkBody = false;
        List<EmailMessage> emDuplicateList = [SELECT Id, HTMLbody, TextBody
                                              FROM EmailMessage
                                              WHERE Id !=: em.Id AND
                                              CreatedDate = TODAY AND
                                              Subject =: em.Subject AND
                                              FromAddress =: em.FromAddress AND
                                              ToAddress =: em.ToAddress AND
                                              CcAddress =: em.CcAddress AND
                                              BccAddress =: em.BccAddress 
                                             ];
        if(emDuplicateList != null && !emDuplicateList.isEmpty()) { 
            for (EmailMessage emD : emDuplicateList){
                if (emD.TextBody == em.TextBody || emD.HtmlBody == em.HtmlBody){
                    checkBody = true;
                }
            }
            if (checkBody) {
                insert new EmailMessageLog__c(
                    EmailMessageId__c  = em.Id,
                    Subject__c = em.subject,
                    HtmlBody__c = em.HTMLbody, 
                    TextBody__c = em.TextBody,
                    ToAddress__c = em.ToAddress,
                    CcAddress__c = em.CcAddress,
                    BccAddress__c = em.BccAddress,
                    FromAddress__c = em.FromAddress,
                    Headers__c = em.Headers,
                    ParentId__c = em.ParentId,
                    RelatedToId__c = em.RelatedToId
                );
                if (em.ParentId != null) {
                    List<Case> caseList = [SELECT id FROM Case WHERE id =: em.ParentId Limit 1];
                    if (caseList != null && !caseList.isEmpty()) {
                        caseList[0].isClosedSending__c = true;
                        Update caseList;
                    }
                }
            }
        }
    }
}