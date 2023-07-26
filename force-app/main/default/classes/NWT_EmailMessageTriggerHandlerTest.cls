@IsTest
public class NWT_EmailMessageTriggerHandlerTest {
    @IsTest public static void emailMessageDMLTest() {
        EmailMessage e = new EmailMessage();
        e.Subject = 'Email de ejemplo';
        e.ToAddress = 'alloha@gmail.com';
        e.CcAddress = 'alloha@gmail.com';
        e.BccAddress = 'alloha@gmail.com';
        insert e;

        e.Subject = 'testUpdate';
        update e;
        delete e;
        undelete e;
    }
    
    @IsTest public static void afterInsertTest() {
        NWT_EmailMessageTriggerHandler obj = new NWT_EmailMessageTriggerHandler();
        Map<Id, EmailMessage> emesMap = new Map<Id, EmailMessage>();
        EmailMessage e1 = new EmailMessage();
        e1.Subject = 'Email de ejemplo';
        e1.ToAddress = 'alloha@gmail.com';
        e1.CcAddress = 'alloha@gmail.com';
        e1.BccAddress = 'alloha@gmail.com';
        insert e1;
        
        EmailMessage e2 = new EmailMessage();
        e2.Subject = 'Email de ejemplo';
        e2.ToAddress = 'alloha@gmail.com';
        e2.CcAddress = 'alloha@gmail.com';
        e2.BccAddress = 'alloha@gmail.com';
        insert e2;
        
        insert new EmailMessage_Settings__c(EmailMessage_redirectR23__c = true, EmailMessage_closeSending__c = true);
        //EmailMessage_Settings__c.EmailMessage_redirectR23__c
        //List<EmailMessage> emList = new List<EmailMessage>();
        //emList.add(e);
        emesMap.put(e1.Id, e1);
        emesMap.put(e2.Id, e2);
        obj.afterInsert(emesMap.values(),emesMap);
    }
        
    
}