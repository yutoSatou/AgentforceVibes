public with sharing class ContactAction {
  public ContactAction() {
  }

  public void setAccountName() {
    // This method referenced a non-existent custom field AccountName__c on Contact
    // and caused deployment failures. Commenting out to keep the class compilable.
    // If needed, re-implement with an existing field or create the field before using.
    /*
    Map<Id, Account> accountMap = new Map<Id, Account>(
      [SELECT Id, Name FROM Account]
    );

    List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
    for (Contact c : contactList) {
      c.AccountName__c = accountMap.get(c.AccountId).Name;
    }
    */
  }
}