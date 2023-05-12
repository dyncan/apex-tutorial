trigger AccountTrigger on Account(
  before insert,
  before update,
  after insert,
  after update,
  before delete,
  after delete,
  after undelete
) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      for (Account acc : Trigger.new) {
        //check annual revenue if less than 5000
        if (acc.AnnualRevenue <= 5000) {
          acc.addError('Annual Revenue cannot be less than 5000');
        }

        //populate shipping address with billing address values
        acc.ShippingStreet = acc.BillingStreet;
        acc.ShippingCity = acc.BillingCity;
        acc.ShippingState = acc.BillingState;
        acc.ShippingPostalCode = acc.BillingPostalCode;
        acc.ShippingCountry = acc.BillingCountry;
      }
    }

    if (Trigger.isUpdate) {
      for (Account acc : Trigger.new) {
        if (acc.Name != Trigger.oldMap.get(acc.Id).Name) {
          acc.addError('Account Name cannot be changed once it is created.');
        }
      }
    }

    if (Trigger.isDelete) {
      for (Account acc : Trigger.old) {
        if (acc.Active__c == 'Yes') {
          acc.addError('You cannot delete an active Account.');
        }
      }
    }
  } else {
    if (Trigger.isInsert) {
      // store new contact data
      List<Contact> toInsertContacts = new List<Contact>();

      for (Account acc : Trigger.new) {
        Contact con = new Contact();
        con.LastName = acc.Name;
        con.AccountId = acc.Id;
        toInsertContacts.add(con);
      }

      if (toInsertContacts.size() > 0) {
        insert toInsertContacts;
      }
    }

    if (Trigger.isUpdate) {
      Set<Id> accountIdsToUpdate = new Set<Id>();

      for (Account acc : Trigger.new) {
        Account oldAcc = Trigger.oldMap.get(acc.Id);

        //check if Billing Address has been changed
        if (
          oldAcc.BillingStreet != acc.BillingStreet ||
          oldAcc.BillingCity != acc.BillingCity ||
          oldAcc.BillingState != acc.BillingState ||
          oldAcc.BillingPostalCode != acc.BillingPostalCode ||
          oldAcc.BillingCountry != acc.BillingCountry
        ) {
          //add account id to set for updating related contacts
          accountIdsToUpdate.add(acc.Id);
        }
      }

      if (accountIdsToUpdate.size() == 0) {
        return;
      }

      Map<Id, Account> accountMap = new Map<Id, Account>(
        [
          SELECT
            Id,
            BillingStreet,
            BillingCity,
            BillingState,
            BillingPostalCode,
            BillingCountry
          FROM Account
          WHERE ID IN :accountIdsToUpdate
        ]
      );

      List<Contact> contactsToUpdate = new List<Contact>();

      for (Contact con : [
        SELECT
          Id,
          AccountId,
          MailingStreet,
          MailingCity,
          MailingState,
          MailingPostalCode,
          MailingCountry
        FROM Contact
        WHERE AccountId IN :accountIdsToUpdate
      ]) {
        Account acc = accountMap.get(con.AccountId);
        con.MailingStreet = acc.BillingStreet;
        con.MailingCity = acc.BillingCity;
        con.MailingState = acc.BillingState;
        con.MailingPostalCode = acc.BillingPostalCode;
        con.MailingCountry = acc.BillingCountry;
        contactsToUpdate.add(con);
      }

      //update all the related contact
      if (contactsToUpdate.size() > 0) {
        update contactsToUpdate;
      }
    }

    if (Trigger.isDelete) {
      // get the id for custom notification type
      CustomNotificationType notificationType = [
        SELECT Id, DeveloperName
        FROM CustomNotificationType
        WHERE DeveloperName = 'Account_Notification'
      ];

      for (Account acc : Trigger.old) {
        // create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('An account has been deleted');
        notification.setBody(
          String.format(' Account Name: {0}', new List<String>{ acc.Name })
        );
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(acc.Id);
        notification.send(new Set<String>{ UserInfo.getUserId() });
      }
    }

    if (Trigger.isUndelete) {
      List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

      for (Account acc : Trigger.new) {
        // send email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ 'dynckm@gmail.com' });
        mail.setSubject(
          String.format(
            'Account {0} has been restored',
            new List<String>{ acc.Name }
          )
        );
        mail.setPlainTextBody('FYI.');
        messages.add(mail);
      }

      Messaging.sendEmail(messages);
    }
  }

}
