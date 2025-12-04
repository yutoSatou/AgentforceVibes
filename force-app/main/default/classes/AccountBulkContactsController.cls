public with sharing class AccountBulkContactsController {
  // Security helper: check user can create Contact records
  private static Boolean userHasCreateOnContact() {
    return Schema.sObjectType.Contact.isCreateable();
  }

  // Validate top-level inputs; return a Result on error, or null if valid
  private static Result validateInputs(Id accountId, List<ContactInput> contacts) {
    if (accountId == null) {
      return new Result(false, 'AccountId is required.', null);
    }
    if (contacts == null || contacts.isEmpty()) {
      return new Result(false, 'At least one contact row is required.', null);
    }
    if (contacts.size() > 50) {
      return new Result(false, 'You can create up to 50 contacts at once.', null);
    }
    return null;
  }

  // Build Contact sObjects from inputs; throws with row context for invalid rows
  private static List<Contact> buildContacts(Id accountId, List<ContactInput> contacts) {
    List<Contact> toInsert = new List<Contact>();
    Integer rowNum = 0;
    for (ContactInput ci : contacts) {
      rowNum++;
      if (ci == null) continue;
      if (String.isBlank(ci.LastName)) {
        // Surface validation error with row number
        throw new AuraHandledException('Row ' + rowNum + ': LastName is required.');
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
    return toInsert;
  }

  // Collect created Ids
  private static List<Id> collectIds(List<Contact> records) {
    List<Id> ids = new List<Id>();
    for (Contact c : records) {
      ids.add(c.Id);
    }
    return ids;
  }
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

    // Input validation (reduces complexity in main method)
    Result inputError = validateInputs(accountId, contacts);
    if (inputError != null) {
      return inputError;
    }

    // CRUD/FLS guard before DML to address Security-ApexCRUDViolation
    if (!userHasCreateOnContact()) {
      return new Result(false, 'Insufficient permissions to create Contact records.', null);
    }

    // Build records from inputs; catch row-level validation surfaced by buildContacts
    List<Contact> toInsert;
    try {
      toInsert = buildContacts(accountId, contacts);
    } catch (AuraHandledException vex) {
      return new Result(false, vex.getMessage(), null);
    }

    // Perform DML
    try {
      insert toInsert;
      List<Id> ids = collectIds(toInsert);
      return new Result(true, 'Created ' + toInsert.size() + ' contact(s).', ids);
    } catch (DmlException e) {
      return new Result(false, e.getDmlMessage(0), null);
    } catch (Exception e) {
      return new Result(false, e.getMessage(), null);
    }
  }
}
