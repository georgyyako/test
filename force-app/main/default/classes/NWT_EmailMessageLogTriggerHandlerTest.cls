@isTest
public class NWT_EmailMessageLogTriggerHandlerTest {
	 @IsTest public static void afterInsertTest() {
        NWT_EmailMessageLogTriggerHandler obj = new NWT_EmailMessageLogTriggerHandler();
        Map<Id, EmailMessageLog__c> emesMap = new Map<Id, EmailMessageLog__c>();
        EmailMessageLog__c e = new EmailMessageLog__c();
        e.Subject__c = 'Email de ejemplo';
        e.ToAddress__c = 'alloha@gmail.com';
        e.CcAddress__c = 'alloha@gmail.com';
        e.BccAddress__c = 'alloha@gmail.com';
        insert e;
        emesMap.put(e.Id, e);
        obj.afterInsert(emesMap.values(),emesMap);
    }
}