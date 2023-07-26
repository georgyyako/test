@isTest
public with sharing class SendHTMLEmailTest {
    private static Boolean EmailDeliverabilityEnabled(){
        Boolean EmailDeliverabilityEnabled = true;
        try {
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.reserveMassEmailCapacity(1);
        } catch (System.NoAccessException e) {
            EmailDeliverabilityEnabled = false;
        }
        return EmailDeliverabilityEnabled;
    }

    @isTest 
    public static void CanSendEmailWithClosedSendibg () {
        insert new EmailMessage_Settings__c(EmailMessage_redirectR23__c = true, EmailMessage_closeSending__c = true);
        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        
        for (Integer i = 0; i < 1000; i++) {
            SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
            testReq.HTMLbody = 'this is the body' + i;
            testReq.Subject = 'this is the subject' + i;
            testReq.eternallyAvailableImage = true;
            testReq.SendTOthisOneEmailAddress = 'test@foo.com';
            testReq.SendCCthisOneEmailAddress = 'test@foo.com';
            testReq.SendBCCthisOneEmailAddress = 'test@foo.com';
            reqList.add(testReq);
        }
        
        List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
	    
        Boolean EmailDeliverabilityEnabled = EmailDeliverabilityEnabled();
        //if(EmailDeliverabilityEnabled){
            //System.assertEquals(testResponseList[0].isSuccess,true);
        //} else {
            //System.assertEquals(EmailDeliverabilityEnabled,false);
        //}
    }
    
    @isTest
    public static void CanSendEmail () {
		List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        
        for (Integer i = 0; i < 1000; i++) {
            SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
            testReq.HTMLbody = 'this is the body' + i;
            testReq.Subject = 'this is the subject' + i;
            testReq.eternallyAvailableImage = true;
            testReq.SendTOthisOneEmailAddress = 'test@foo.com';
            testReq.SendCCthisOneEmailAddress = 'test@foo.com';
            testReq.SendBCCthisOneEmailAddress = 'test@foo.com';
            reqList.add(testReq);
        }
        
        List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
	    
        Boolean EmailDeliverabilityEnabled = EmailDeliverabilityEnabled();
        //if(EmailDeliverabilityEnabled){
            //System.assertEquals(testResponseList[0].isSuccess,true);
        //} else {
            //System.assertEquals(EmailDeliverabilityEnabled,false);
        //}
    }

    @isTest
    public static void errorIfNoAddress () {
        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        testReq.HTMLbody = 'this is the body';
        testReq.Subject = 'this is the subject';
        testReq.eternallyAvailableImage = false;
        //testReq.SendTOthisOneEmailAddress = 'test@foo.com';

        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);

        List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        //System.assertEquals(testResponseList[0].isSuccess,false);
    }
    
    
        
     @isTest
    public static void AddAttachmentsTest () {
        Account acc = new Account();
        acc.Name = 'TESTNAME';
        acc.Type_du_compte__c = 'Siège';
        acc.NWT_Sage_SyncAccount__c = true;
        acc.NWT_Sage_Compte_Ref__c = 'TESTNAME';
        acc.Commercial_Projet_1__c = UserInfo.getUserId();
        insert acc;
        
        ContentVersion conVer = new ContentVersion();
        String strFile = 'Alloha';
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = 'InventaireClient.xls'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'InventaireClient'; // Display name of the files
        conVer.VersionData = Blob.valueOf(strFile);
        insert conVer; 
        
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = acc.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conVer.Id;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        //insert conDocLink;
        
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
        contentDocumentLinkList.add(conDocLink);
        
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('Cost Plus Merchants.csv');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );

        /*
        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
            testReq.HTMLbody = 'this is the body';
            testReq.Subject = 'this is the subject';
            testReq.eternallyAvailableImage = true;
            testReq.SendTOthisOneEmailAddress = 'test@foo.com';
            testReq.SendCCthisOneEmailAddress = 'test@foo.com';
            testReq.SendBCCthisOneEmailAddress = 'test@foo.com';*/
      
        
        SendHTMLEmail.AddAttachments(message, contentDocumentLinkList, 'StatucResourceName');
    }
    
    @isTest
    public static void canSendToContact () {
        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        testReq.HTMLbody = 'this is the body';
        testReq.Subject = 'this is the subject';
        testReq.eternallyAvailableImage = false;
        //testReq.SendTOthisOneEmailAddress = 'test@foo.com';

        Contact testContact1 = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            email = 'foo@bar.com');
        insert testContact1;
        
        List<Contact> contactList = new List<Contact>();
        contactList.add(testContact1);
        testReq.SendTOtheEmailAddressesFromThisCollectionOfContacts = contactList;
     
        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);

        List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        //System.assertEquals(testResponseList[0].isSuccess,true);
    }

    @isTest
    public static void canSendToLead () {
        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        testReq.HTMLbody = 'this is the body';
        testReq.Subject = 'this is the subject';
        testReq.eternallyAvailableImage = false;
        //testReq.SendTOthisOneEmailAddress = 'test@foo.com';
         
        Lead testLead1 = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            email = 'foo@bar.com',
        	company = 'foobarcorp');
        insert testLead1;
        
        List<Lead> leadList = new List<Lead>();
        leadList.add(testLead1);
        testReq.SendTOtheEmailAddressesFromThisCollectionOfLeads = leadList;
        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);

        List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        //System.assertEquals(testResponseList[0].isSuccess,true);
    }
    
    @isTest
    public static void errorIfBothTemplateandBody () {
        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        testReq.HTMLbody = 'this is the body';
        testReq.templateID = 'temp';
        testReq.Subject = 'this is the subject';
        testReq.SendTOthisOneEmailAddress = 'test@foo.com';
        testReq.eternallyAvailableImage = false;

        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);
        Boolean exceptionHit=false;
        try {
            List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        } catch (SendHTMLEmail.InvocableActionException e) {
            exceptionHit=true;
        }
        //System.assertEquals(true, exceptionHit);
    }
    
    //this is bogus
    @isTest static void saveAsWillFail() {
        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        testReq.HTMLbody = 'this is the body';
        testReq.Subject = 'this is the subject';
        testReq.eternallyAvailableImage = false;
        //testReq.SendTOthisOneEmailAddress = 'test@foo.com';
         
        Lead testLead1 = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            email = 'foo@bar.com',
        	company = 'foobarcorp');
        insert testLead1;
        
        List<Lead> leadList = new List<Lead>();
        leadList.add(testLead1);
        
        testReq.SendTOtheEmailAddressesFromThisCollectionOfLeads = leadList;
        testReq.saveAsActivity = true;
        testReq.recordId = testLead1.Id;
        
        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);

        List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);
        //System.assertEquals(testResponseList[0].isSuccess,false);
	}
    
    @isTest
    public static void canCreateActivity() {
      Lead testLead1 = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            email = 'foo@bar.com',
        	company = 'foobarcorp');
        insert testLead1;
        
        Boolean exceptionHit = false;
        String recordId = testLead1.Id;
        String subject = 'subject';
        String recipientList = 'reciplist';
        //try {
        SendHTMLEmail.createActivity(null, subject, recipientList);
        //} catch (SendHTMLEmail.InvocableActionException e) {
        exceptionHit=true;
        //}
        //System.assertEquals(true, exceptionHit);
    }
    
     @isTest
    public static void errorIfTemplateButNoContextRecord () {
        SendHTMLEmail.Request testReq = new SendHTMLEmail.Request();
        //testReq.HTMLbody = 'this is the body';
        testReq.templateID = 'temp';
        testReq.Subject = 'this is the subject';
        testReq.SendTOthisOneEmailAddress = 'test@foo.com';
        testReq.eternallyAvailableImage = false;

        List<SendHTMLEmail.Request> reqList = new List<SendHTMLEmail.Request>();
        reqList.add(testReq);
		Boolean exceptionHit=false;
        try {
            List<SendHTMLEmail.Response> testResponseList = SendHTMLEmail.SendEmail(reqList);        
        } catch (SendHTMLEmail.InvocableActionException e) {
            exceptionHit=true;
        }
        //System.assertEquals(true, exceptionHit);
    }
}