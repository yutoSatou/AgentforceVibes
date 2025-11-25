global with sharing class AccountSearchAgent {

    @InvocableMethod(label='Find Accounts By Name' description='Search Accounts by (partial) Account Name and return basic info')
    global static List<AccountSearchResponse> findAccounts(List<AccountSearchRequest> requests) {
        List<AccountSearchResponse> responses = new List<AccountSearchResponse>();
        if (requests == null || requests.isEmpty()) {
            responses.add(new AccountSearchResponse());
            return responses;
        }

        // 単一リクエスト前提（Flow/Invocableの慣例に合わせる）
        AccountSearchRequest req = requests[0];

        // ガード節: 入力未指定時は空配列を返す
        if (req == null || String.isBlank(req.filters.accountNameLike)) {
            AccountSearchResponse emptyRes = new AccountSearchResponse();
            emptyRes.results = new AccountResults();
            responses.add(emptyRes);
            return responses;
        }

        Integer limitSize = (req.filters.maxSize != null && req.filters.maxSize > 0 && req.filters.maxSize <= 2000) ? req.filters.maxSize : 200;
        String likeExpr = '%' + String.escapeSingleQuotes(req.filters.accountNameLike.trim()) + '%';

        List<Account> accList = [
            SELECT Id, Name, AccountNumber, Type, Industry, Rating, Phone, Website, OwnerId
            FROM Account
            WHERE Name LIKE :likeExpr
            ORDER BY Name
            LIMIT :limitSize
        ];
        AccountSearchResponse res = new AccountSearchResponse();
        AccountResults result = new AccountResults();
        result.accounts = new List<AccountInformation>();
        for (Account a : accList) {
            result.accounts.add(new AccountInformation(a));
        }
        res.results = result;
        responses.add(res);
        return responses;
    }

    @JsonAccess(serializable='always' deserializable='always')
    global class AccountSearchRequest {
        @InvocableVariable(required=true)
        global AccountRequestFilter filters;
    }

    @JsonAccess(serializable='always' deserializable='always')
    global class AccountSearchResponse {
        @InvocableVariable
        global AccountResults results;
    }
}