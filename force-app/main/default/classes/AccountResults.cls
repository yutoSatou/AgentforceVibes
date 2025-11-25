@JsonAccess(serializable='always' deserializable='always')
global class AccountResults {
    @AuraEnabled
    global List<AccountInformation> accounts;
}