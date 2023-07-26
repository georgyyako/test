public class NWT_EmailMessageLogTriggerHandler {
    public void afterInsert(List<EmailMessageLog__c> newList , Map<Id, EmailMessageLog__c> newMap) {
        System.debug('NWT_EmailMessageLogTriggerHandler | afterInsert');
		for (EmailMessageLog__c eml : newList) {
            if (EmailMessage_Settings__c.getInstance().EmailMessage_closeSending__c) {
                sendAlertMail(eml);
            }
        } 
    }
    
    public static void sendAlertMail (EmailMessageLog__c eml) {
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[] {'devinbox-salesforce@nowbrains.com'}; 
            mail.setToAddresses(toAddresses);
        //mail.setCcAddresses(ccAddresses);
        mail.OrgWideEmailAddressId = '0D25E0000000C4wSAE';
        //mail.setSenderDisplayName('Salesforce Dev');
        mail.setSubject('ALERT | New Email bug found | CaseId : ' + eml.ParentId__c +' | EmailMessageId : ' + eml.EmailMessageId__c);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('Sending emails has been blocked: ' + eml.ParentId__c +' EmailMessageId : '  + eml.EmailMessageId__c);
        
        mail.setHtmlBody('<h2>Sending emails has been blocked : </h2><p>'+
                         'CaseId : <a href=https://nowteam.lightning.force.com/lightning/r/Case/'+eml.ParentId__c+'/view> '+eml.ParentId__c+' </a><br>'+
                         'EmailMessage : <a href=https://nowteam.lightning.force.com/lightning/r/EmailMessage/'+eml.EmailMessageId__c+'/view> '+eml.EmailMessageId__c+' </a><br>' + 
                         'EmailMessageLog<a href=https://nowteam.lightning.force.com/lightning/r/EmailMessage/'+eml.Id+'/view> '+eml.Id+' </a>' +
                         '<br>Use this SOQL to enable email sending:<br>'+
                         '<i>SELECT isClosedSending__c FROM Case WHERE Id = \''+eml.ParentId__c+'\'</i>'
                        );
        System.debug(mail);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}