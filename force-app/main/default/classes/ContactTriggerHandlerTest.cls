@isTest
private class ContactTriggerHandlerTest {
  @TestSetup
  static void createContacts() {
    // creating 400 contact records
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < 400; i++) {
      Contact contact = new Contact();
      contact.LastName = 'LastName' + i;
      contacts.add(contact);
    }

    insert contacts;
  }

  @isTest
  static void testRecursionHandling() {
    List<Contact> contactlst = [
      SELECT Id, LastModifiedDate, Last_Modified_Date__c
      FROM Contact
      ORDER BY Last_Modified_Date__c NULLS LAST
    ];

    for (Integer i = 0; i < contactlst.size(); i++) {
      Assert.areEqual(
        contactlst[i].LastModifiedDate.date(),
        contactlst[i].Last_Modified_Date__c,
        'Failed on row ' + i
      );
    }
  }
}
