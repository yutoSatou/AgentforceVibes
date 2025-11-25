@JsonAccess(serializable='always' deserializable='always')
global class AccountInformation {
    @AuraEnabled
    global Id Id;

    @AuraEnabled
    global String accountName;

    @AuraEnabled
    global String accountNumber;

    @AuraEnabled
    global String type;

    @AuraEnabled
    global String industry;

    @AuraEnabled
    global String rating;

    @AuraEnabled
    global String phone;

    @AuraEnabled
    global String website;

    @AuraEnabled
    global Id ownerId;
    public AccountInformation(Account account) {
        this.Id = account.Id;
        this.accountName = account.Name;
        this.accountNumber = account.AccountNumber;
        this.type = account.Type;
        this.industry = account.Industry;
        this.rating = account.rating;
        this.phone = account.Phone;
        this.website = account.Website;
        this.ownerId = account.OwnerId;
    }
}