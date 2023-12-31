public with sharing class SendHTMLEmail {
    static final String folderName = 'SendHTMLEmail_Image';
    static final String orgId = UserInfo.getOrganizationId();
    
    public static void redirectR23(List<Request> requests){
        if (requests != null && !requests.isEmpty() && EmailMessage_Settings__c.getInstance().EmailMessage_redirectR23__c) {
            List<Domain> domList = [Select id, Domain 
                                    FROM Domain];
            Boolean checkOrg = false;
            for (Domain dom: domList) {
                if (dom.Domain == 'nowteam.my.site.com') {
                    checkOrg = true;
                }
            }
            if (checkOrg == false) {
                
                if (requests[0].recordId != null) {
                    Boolean cid = String.valueof(requests[0].recordId).startswith('500');
                    if (cid) {
                        requests[0].SendBCCthisOneEmailAddress = 'dev-salesforce@3-pm45ad2eqc2gwcn50hx0s6s7adw476utr4pfmnibg8fop69uh.5e-a5fxuas.cs84.case.sandbox.salesforce.com';
                    } else {
                        requests[0].SendBCCthisOneEmailAddress = null;
                    }
                } else {
                    requests[0].SendBCCthisOneEmailAddress = null;
                }
            	requests[0].replyEmailAddress = null;
            	requests[0].orgWideEmailAddressId = '0D25E0000000C4wSAE';
                requests[0].senderDisplayName = null;
                requests[0].SendTOthisOneEmailAddress = 'devinbox-salesforce@nowbrains.com';
                //requests[0].SendTOthisOneEmailAddress = 'george.yanushko@nowbrains.com';
                requests[0].SendTOthisStringCollectionOfEmailAddresses = null;
                requests[0].SendTOtheEmailAddressesFromThisCollectionOfContacts = null;
                requests[0].SendTOtheEmailAddressesFromThisCollectionOfUsers = null;
                requests[0].SendTOtheEmailAddressesFromThisCollectionOfLeads = null;
                requests[0].SendCCthisOneEmailAddress = null;
                requests[0].SendCCthisStringCollectionOfEmailAddresses = null;
                requests[0].SendCCtheEmailAddressesFromThisCollectionOfContacts = null;
                requests[0].SendCCtheEmailAddressesFromThisCollectionOfUsers = null;
                requests[0].SendCCtheEmailAddressesFromThisCollectionOfLeads = null;
                requests[0].SendBCCthisStringCollectionOfEmailAddresses = null;
                requests[0].SendBCCtheEmailAddressesFromThisCollectionOfContacts = null;
				requests[0].SendBCCtheEmailAddressesFromThisCollectionOfUsers = null;
				requests[0].SendBCCtheEmailAddressesFromThisCollectionOfLeads = null;
            }
        }
    }
    // get document image URL
    static String bodyDocument(String bodyHTML) {
        //bodyHTML = bodyHTML.remove('amp;');
          
        String orgName;
        if (!String.isBlank(bodyHTML)) {
            orgName = bodyHTML.substringBetween('src="','/servlet'); 
        }
        List<Blob> urlBlobList;
        urlBlobList = new List<Blob>();
        Integer urlNum = 0;
        // get List Blob with old URL Image and replace them on 'BLOB + urlNum' in bodyHTML
         
        if (!String.isBlank(bodyHTML)) {
            while (bodyHTML.substringBetween('src="','">') != null) {
                PageReference page = new PageReference(bodyHTML.substringBetween('src="','"'));
                urlBlobList.add(page.getContent());
                bodyHTML = bodyHTML.replace('src="' + bodyHTML.substringBetween('src="','">') + '">', 'Blob'+ urlNum);
                urlNum++;
            }
        }

        List<Folder> folderList = [SELECT Id FROM Folder WHERE Name =: folderName];

        List<Document> docList = new List<Document>();
        for (Blob ur : urlBlobList) {
            Document myDocument = new Document(Body = ur, Type = 'jpg', IsPublic = true, Name = 'Email Image', ContentType = 'image/jpg');
			if (folderList != null && !folderList.isEmpty()) {
                myDocument.FolderId = folderList[0].Id;
            }
        	docList.add(myDocument);
        }
        if (docList != null && docList.size() > 0) {
        	insert docList;    
        }

        // replace old Image URL on new from List<Document> docList.
        for (Integer i = 0; i< docList.size(); i++) {
            bodyHTML = bodyHTML.replace('Blob'+i, 'src="' + orgName + '/servlet/servlet.ImageServer?id=' + docList[i].Id + '&oid=' + orgId + '">');
        }

   		System.debug(bodyHTML);     
        return bodyHTML;
    }
    
    @invocableMethod(label='Send HTML Email') 
    public static List<Response> SendEmail(List<Request> requests) {
        
        redirectR23(requests);
        
        Boolean eternallyAvailableImage = requests[0].eternallyAvailableImage;
        String HTMLbody;
        if (eternallyAvailableImage != null && eternallyAvailableImage && eternallyAvailableImage != false ) {
             HTMLbody = bodyDocument(requests[0].HTMLbody);
        } else {
            HTMLbody = requests[0].HTMLbody;
        }
        System.debug('BODY1' +HTMLbody);
        //  String HTMLbody = bodyDocument(requests[0].HTMLbody);
        String plainTextBody = requests[0].plainTextBody;
        String subject = requests[0].subject;
        //String body = requests[0].HTMLBody;
        String replyEmailAddress = requests[0].replyEmailAddress;
        String senderDisplayName = requests[0].senderDisplayName;
        String templateID = requests[0].templateID;
        String templateTargetObjectId = requests[0].templateTargetObjectId;
        String orgWideEmailAddressId = requests[0].orgWideEmailAddressId;    
        Boolean saveAsActivity = requests[0].saveAsActivity;
        Id recordId = requests[0].recordId;

        //from https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_forcecom_email_outbound.htm

        // First, reserve email capacity for the current Apex transaction to ensure
        // that we won't exceed our daily email limits when sending email after
        // the current transaction is committed.
        //Messaging.reserveSingleEmailCapacity(2);

        // Processes and actions involved in the Apex transaction occur next,
        // which conclude with sending a single email.

        // Now create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Strings to hold the email addresses to which you are sending the email.
        //String[] toAddresses = new String[] {oneAddress}; 
        Map<String, Object> m = GenerateMap(requests[0]);
        String[] toAddresses = BuildAddressList('TO',m); 
        System.debug('toAddresses is: ' + toAddresses);
        String[] ccAddresses = BuildAddressList('CC',m); 
        System.debug('ccAddresses is: ' + ccAddresses);
        String[] bccAddresses = BuildAddressList('BCC', m);
        System.debug('bccAddresses is: ' + bccAddresses);
        
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        mail.setBccAddresses(bccAddresses);

        //outgoing email can either use an orgWideEmailAddress or specify it here, but not both
        if (orgWideEmailAddressId != null && orgWideEmailAddressId != '') {
            mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        } else {
            // Specify the address used when the recipients reply to the email. 
            mail.setReplyTo(replyEmailAddress);

            // Specify the name used as the display name.
            mail.setSenderDisplayName(senderDisplayName);
        }

        // Specify the subject line for your email address.
        mail.setSubject(subject);

        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);

        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        // True by default unless the user passes a value in.
        if (requests[0].useSalesforceSignature != null) {
            mail.setUseSignature(requests[0].useSalesforceSignature);
        } else {
            mail.setUseSignature(true);
        }

        mail = AddAttachments(mail, requests[0].contentDocumentAttachments, null);
         
        if (templateID != null && ((HTMLbody != null) || (plainTextBody != null)))
            throw new InvocableActionException('you\'re trying to pass in both a plaintext/html body and a template ID. Gotta pick one or the other. Make sure you\'re not confusing the Text Template resources in Flow, (which you can pass into either the HTMLBody or the plainTextBody) with the templateId, which represents a Salesforce Email Template (either Classic or Lightning).');
           
        if ((templateID != null && templateTargetObjectId == null) || (templateID == null && templateTargetObjectId != null))
            throw new InvocableActionException('templateId and templateTargetObjectId have to be used together. the target recordID determines how to fill in the mergefields in the template.');
        
        if (templateID == null  && HTMLbody == null && plainTextBody == null)
            throw new InvocableActionException(' Body text must be provided to Send HTML Email Action, either via HTMLbody, plainTextBody, or a templateId');
              
        if (saveAsActivity == true && recordId == null) {
            throw new InvocableActionException('In order to log this email send to activity history, you need to pass in a recordId');
        }
        
        mail.setTemplateID(templateID);
        mail.setTargetObjectId(templateTargetObjectId);
        System.debug('templateID is:' + templateID);
        
        // Specify the text content of the email.
        mail.setPlainTextBody(plainTextBody);
		System.debug(HTMLbody);
        mail.setHtmlBody(HTMLbody);
        System.debug('mail is:' + mail);
        Messaging.SendEmailResult[] emailResponse;
        Boolean completed;
        String error;
        
        // Send the email you have created.
        try {
            // Find duplicates
            List<Case> caseList = [SELECT id FROM Case WHERE id =: recordId AND isClosedSending__c = true LIMIT 1];
            if (caseList != null && !caseList.isEmpty() && EmailMessage_Settings__c.getInstance().EmailMessage_closeSending__c) {
                completed = false; 
            } else {
				emailResponse = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            	System.debug('emailResponse is: ' + emailResponse);
            	completed = true;   
            }
        } catch (InvocableActionException e){
            System.debug ('exception occured: ' + e.getMessage());
            completed = false;
            error = e.getMessage();
        } catch (System.EmailException e){
            System.debug ('exception occured: ' + e.getMessage());
            completed = false;
            error = e.getMessage();
        }
       
        //report back the results
        Response response = new Response();
        if (completed == true) {
            if (emailResponse[0].isSuccess()) {
                response.isSuccess = true; 
            }
            //if (emailResponse[0].isSuccess() != true) {
               // Messaging.SendEmailError[] curErrors = emailResponse[0].getErrors();
               // String errorReport = '';
               // for(Messaging.SendEmailError curError : curErrors ) {
               //     errorReport = errorReport + curError.getMessage() + '/n';
               // }
               // response.errors = errorReport;
               // response.isSuccess = false;
             //} else {
                //response.isSuccess = true;
            //}
            if (saveAsActivity == true && recordId != null) {
                try {
                    createActivity(recordId, subject, toAddresses + ',' + ccAddresses + ',' + bccAddresses);
                } catch (Exception ex) {
                    response.errors = ex.getMessage();
                    response.isSuccess = false;
                }
            }
        } else {
            response.errors = error;
            response.isSuccess = false;
        }
        
        List<Response> responseList;
        responseList = new List<Response>();
        responseList.add(response);
        return responseList;
    }

    //credit to https://digitalflask.com/blog/send-email-attachments-salesforce-apex/
    public static Messaging.SingleEmailMessage AddAttachments(Messaging.SingleEmailMessage mail, List<ContentDocumentLink> contentDocumentLinks,
                                                              String staticResourceNames) {
        List<SObject> curAttachments;
        curAttachments = new List<SObject>();
        if (staticResourceNames != null) {
            List<String> staticResourceNamesList = staticResourceNames.replaceAll('[^A-Z0-9]+//ig', ',').split(',');
            curAttachments.addAll([SELECT Id, Body, Name, ContentType FROM StaticResource WHERE Name IN:staticResourceNamesList]);
        }
        if (contentDocumentLinks != null && !contentDocumentLinks.isEmpty()) {
            Set<Id> cdIds = new Set<Id>();
            for (ContentDocumentLink cdl : contentDocumentLinks) {
                cdIds.add(cdl.ContentDocumentId);
            }

            for (ContentVersion cv : [SELECT Id, PathOnClient, VersionData, FileType FROM ContentVersion WHERE ContentDocumentId IN:cdIds]) {
                curAttachments.add(new StaticResource(Name = cv.PathOnClient, Body = cv.VersionData));
            }
        }
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        if (curAttachments != null) {
            for (SObject file : curAttachments) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName((String) file.get('Name'));
                efa.setBody((BLOB) file.get('Body'));
                efa.setContentType((String) file.get('ContentType'));
                attachments.add(efa);
            }
            mail.setFileAttachments(attachments);
        } 
        return mail; 
    }

    public static String[] BuildAddressList(string type, Map<String, Object> m) {
        String[] addressList = new List<String>();
        String curEmail;
        
        //build address list
        //handle individual addresses
        String oneAddress = (String)m.get('Send' + type + 'thisOneEmailAddress');
        if (oneAddress != null) {
            addressList.add(oneAddress);
            System.debug('address list is:' + addressList);
        }

        //handle inputs involving collections of String addresses
        List<String> stringAddresses = (List<String>)m.get('Send' + type + 'thisStringCollectionOfEmailAddresses');
        if (stringAddresses != null) {
            addressList.addAll(stringAddresses);
        }
        
        //handle inputs involving collections of Contacts
        List<Contact> curContacts = (List<Contact>)m.get('Send' + type + 'theEmailAddressesFromThisCollectionOfContacts');        
        if (curContacts != null) {
            List<String> extractedEmailAddresses = new List<String>();
            for (Contact curContact : curContacts) {
                curEmail = curContact.email;
                if (curEmail != null) extractedEmailAddresses.add(curEmail);
            }
            addressList.addAll(extractedEmailAddresses);
            System.debug('address list is now:' + addressList); 
        }
        
        //handle inputs involving collections of Users
        List<User> curUsers = (List<User>)m.get('Send' + type + 'theEmailAddressesFromThisCollectionOfUsers');
        if (curUsers != null) {
            List<String> extractedEmailAddresses = new List<String>();
            for (User curUser : curUsers) {
                curEmail = curUser.email;
                if (curEmail != null) extractedEmailAddresses.add(curEmail);
            }
            addressList.addAll(extractedEmailAddresses);
            System.debug('address list is now:' + addressList);
        }
        
        //handle inputs involving collections of Leads
        List<Lead> curLeads = (List<Lead>)m.get('Send' + type + 'theEmailAddressesFromThisCollectionOfLeads');
        if (curLeads != null) { 
            List<String> extractedEmailAddresses = new List<String>();
            for (Lead curLead : curLeads) {
                curEmail = curLead.email;
                if (curEmail != null) extractedEmailAddresses.add(curEmail);
            }
            addressList.addAll(extractedEmailAddresses);
            System.debug('address list is now:' + addressList);
        }

        return addressList;
    }

    //this map makes it easier to efficiently use the same code to handle To, CC, and BCC.
    //by making the lookup a string, we can composite the string in the m.get lines above
    private static Map<String, Object> GenerateMap(Request request) {
        return new Map<String, Object> {
            'SendTOthisOneEmailAddress' => request.SendTOthisOneEmailAddress,
                'SendTOthisStringCollectionOfEmailAddresses'  => request.SendTOthisStringCollectionOfEmailAddresses,
                'SendTOtheEmailAddressesFromThisCollectionOfContacts' => request.SendTOtheEmailAddressesFromThisCollectionOfContacts,
                'SendTOtheEmailAddressesFromThisCollectionOfUsers' => request.SendTOtheEmailAddressesFromThisCollectionOfUsers,
                'SendTOtheEmailAddressesFromThisCollectionOfLeads' => request.SendTOtheEmailAddressesFromThisCollectionOfLeads,
                'SendCCthisOneEmailAddress' => request.SendCCthisOneEmailAddress,
                'SendCCthisStringCollectionOfEmailAddresses'  => request.SendCCthisStringCollectionOfEmailAddresses,
                'SendCCtheEmailAddressesFromThisCollectionOfContacts' => request.SendCCtheEmailAddressesFromThisCollectionOfContacts,
                'SendCCtheEmailAddressesFromThisCollectionOfUsers' => request.SendCCtheEmailAddressesFromThisCollectionOfUsers,
                'SendCCtheEmailAddressesFromThisCollectionOfLeads' => request.SendCCtheEmailAddressesFromThisCollectionOfLeads,
                'SendBCCthisOneEmailAddress' => request.SendBCCthisOneEmailAddress,
                'SendBCCthisStringCollectionOfEmailAddresses'  => request.SendBCCthisStringCollectionOfEmailAddresses,
                'SendBCCtheEmailAddressesFromThisCollectionOfContacts' => request.SendBCCtheEmailAddressesFromThisCollectionOfContacts,
                'SendBCCtheEmailAddressesFromThisCollectionOfUsers' => request.SendBCCtheEmailAddressesFromThisCollectionOfUsers,
                'SendBCCtheEmailAddressesFromThisCollectionOfLeads' => request.SendBCCtheEmailAddressesFromThisCollectionOfLeads 
                };
                    
    }

    public static void createActivity(Id recordId, String subject, String recipientList) {
        Task t = new Task(OwnerId = UserInfo.getUserId(),
                          Subject = 'Sent Email: ' + subject,
                          Description = 'Sent Email : ' + subject + ' to recipient(s): ' + recipientList.replaceAll('[()]|,\\(\\)+', ''),
                          Status = 'Closed',
                          Priority = 'Normal',
                          WhatId = recordId);
        insert t;
    }

    public class Request {
        @invocableVariable
        public String HTMLbody;

        @invocableVariable
        public String plainTextBody;
        
        @invocableVariable
        public String templateID;
        
        @invocableVariable
        public Boolean eternallyAvailableImage;

        @invocableVariable(label='Template Target Record Id' description='If you are passing in a template Id, you need to also pass in the Id of context record. It can be a Contact, Lead, or User. It will determine which data gets merged into the template')
        public String templateTargetObjectID;
        
        @invocableVariable
        public String subject;
        
        @invocableVariable
        public String replyEmailAddress;
        
        @invocableVariable
        public String senderDisplayName;

        @invocableVariable
        public String orgWideEmailAddressId;

        @invocableVariable
        public String SendTOthisOneEmailAddress;

        @invocableVariable
        public List<String> SendTOthisStringCollectionOfEmailAddresses;

        @invocableVariable
        public List<Contact> SendTOtheEmailAddressesFromThisCollectionOfContacts;

        @invocableVariable
        public List<User> SendTOtheEmailAddressesFromThisCollectionOfUsers;
        
        @invocableVariable
        public List<Lead> SendTOtheEmailAddressesFromThisCollectionOfLeads;

        @invocableVariable
        public String SendCCthisOneEmailAddress;

        @invocableVariable
        public List<String>  SendCCthisStringCollectionOfEmailAddresses;

        @invocableVariable
        public List<Contact> SendCCtheEmailAddressesFromThisCollectionOfContacts;

        @invocableVariable
        public List<User> SendCCtheEmailAddressesFromThisCollectionOfUsers;
        
        @invocableVariable
        public List<Lead> SendCCtheEmailAddressesFromThisCollectionOfLeads;

        @invocableVariable
        public String SendBCCthisOneEmailAddress;

        @invocableVariable
        public List<String>  SendBCCthisStringCollectionOfEmailAddresses;

        @invocableVariable
        public List<Contact> SendBCCtheEmailAddressesFromThisCollectionOfContacts;

        @invocableVariable
        public List<User> SendBCCtheEmailAddressesFromThisCollectionOfUsers;
        
        @invocableVariable
        public List<Lead> SendBCCtheEmailAddressesFromThisCollectionOfLeads;
        
        @invocableVariable
        public Boolean UseSalesforceSignature;

        /*
        Static resources do not store file extensions, thus email attachments will have file names without extensions,
        which is inconvenient for an end user. Disabling this option for now.
        Possible workarounds:
        1. Specify full file name in Description of static resource
        2. Let the user pass file names together with static resource names
         */
//        @invocableVariable
//        public String staticResourceAttachmentNames;

        @invocableVariable
        public List<ContentDocumentLink> contentDocumentAttachments;

        @invocableVariable
        public Boolean saveAsActivity;
        @invocableVariable
        public Id recordId;
    }

    public class Response {
        @invocableVariable
        public Boolean isSuccess; 
        
        @invocableVariable
        public String errors;
    }
            
    public class InvocableActionException extends Exception {}
}