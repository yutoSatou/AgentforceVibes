public with sharing class AccountBulkContactsController {
  public class ContactInput {
    @AuraEnabled
    public String FirstName;
    @AuraEnabled
    public String LastName;
    @AuraEnabled
    public String Email;
    @AuraEnabled
    public String Title;
    @AuraEnabled
    public String Phone;
    @AuraEnabled
    public String Department;
  }

  public class Result {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<Id> createdIds;
    public Result(Boolean success, String message, List<Id> ids) {
      this.success = success;
      this.message = message;
      this.createdIds = ids;
    }
  }

  @AuraEnabled
  public static Result insertContacts(
    Id accountId,
    List<ContactInput> contacts
  ) {
    System.debug('Received accountId: ' + accountId);
    System.debug(
      'Received contacts count: ' +
      (contacts != null ? String.valueOf(contacts.size()) : 'null')
    );
    if (contacts != null) {
      for (Integer i = 0; i < contacts.size(); i++) {
        System.debug('Contact ' + i + ': ' + contacts[i]);
      }
    }

    if (accountId == null) {
      return new Result(false, 'AccountId is required.', null);
    }
    if (contacts == null || contacts.isEmpty()) {
      return new Result(false, 'At least one contact row is required.', null);
    }
    if (contacts.size() > 50) {
      return new Result(
        false,
        'You can create up to 50 contacts at once.',
        null
      );
    }

    List<Contact> toInsert = new List<Contact>();
    Integer rowNum = 0;
    for (ContactInput ci : contacts) {
      System.debug('Processing contact input: ' + ci);
      rowNum++;
      if (ci == null)
        continue;
      if (String.isBlank(ci.LastName)) {
        return new Result(
          false,
          'Row ' + rowNum + ': LastName is required.',
          null
        );
      }
      Contact c = new Contact();
      c.AccountId = accountId;
      c.FirstName = ci.FirstName;
      c.LastName = ci.LastName;
      c.Email = ci.Email;
      c.Title = ci.Title;
      c.Phone = ci.Phone;
      c.Department = ci.Department;
      toInsert.add(c);
    }

    try {
      insert toInsert;
      List<Id> ids = new List<Id>();
      for (Contact c : toInsert) {
        ids.add(c.Id);
      }
      return new Result(
        true,
        'Created ' + toInsert.size() + ' contact(s).',
        ids
      );
    } catch (DmlException e) {
      return new Result(false, e.getDmlMessage(0), null);
    } catch (Exception e) {
      return new Result(false, e.getMessage(), null);
    }
  }
}