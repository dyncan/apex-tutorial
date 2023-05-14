public with sharing class ContactTriggerHandler {
  private static Boolean alreadyRunOnce = false;
  private static Set<Id> alreadyProcessed = new Set<Id>();

  public static void handlerTrigger(List<Contact> newContacts) {
    // no flag
    // List<Contact> toUpdate = new List<Contact>();
    // for (Contact con : newContacts) {
    //   toUpdate.add(
    //     new Contact(
    //       Id = con.Id,
    //       Last_Modified_Date__c = con.LastModifiedDate.date()
    //     )
    //   );
    // }
    // update toUpdate;

    // static flag
    // System.debug(alreadyRunOnce);
    // if (!alreadyRunOnce) {
    //   alreadyRunOnce = true;
    //   List<Contact> toUpdate = new List<Contact>();
    //   for (Contact con : newContacts) {
    //     toUpdate.add(
    //       new Contact(
    //         Id = con.Id,
    //         Last_Modified_Date__c = con.LastModifiedDate.date()
    //       )
    //     );
    //   }
    //   update toUpdate;
    // }

    // set collection
    // List<Contact> toUpdate = new List<Contact>();
    // for (Contact con : newContacts) {
    //   if (!alreadyProcessed.contains(con.Id)) {
    //     toUpdate.add(
    //       new Contact(
    //         Id = con.Id,
    //         Last_Modified_Date__c = con.LastModifiedDate.date()
    //       )
    //     );
    //     alreadyProcessed.add(con.Id);
    //   }
    // }
    // update toUpdate;
  }
}
