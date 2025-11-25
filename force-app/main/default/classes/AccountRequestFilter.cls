@JsonAccess(serializable='always' deserializable='always')
global with sharing class AccountRequestFilter {
    @AuraEnabled
    global String accountNameLike;

    @AuraEnabled
    global Integer maxSize;
}