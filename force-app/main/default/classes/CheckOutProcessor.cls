public without sharing class CheckOutProcessor {
    
    @InvocableMethod(label='Process Checkout and Generate Final Bills' description='Performs Check out and Give a Sumamry of all food bills for a customer')
    public static List<String> processFoodBills(List<String> customerIds) {
        List<String> results = new List<String>();
        
        if (customerIds == null || customerIds.isEmpty()) {
            results.add('No customer ID provided');
            return results;
        }
        
        String customerId = customerIds[0];
        
        // Query all food bills for the customer
        List<Food_Bill__c> foodBills = [
            SELECT Id, Name, Total_Amount__c, Customer__c,
                   (SELECT Food_Option__r.Name, Quantity__c, Amount__c 
                    FROM Food_Items__r)
            FROM Food_Bill__c 
            WHERE Customer__r.Customer_ID__c = :customerId
        ];
        // Calculate total amount
        Decimal totalAmount = 0;
        String breakdown = '';
        
        for (Food_Bill__c bill : foodBills) {
            totalAmount += bill.Total_Amount__c;
            
            breakdown += '\nBill: ' + bill.Name + '\n';
            breakdown += 'Items:\n';
            
            for (Food_Item__c item : bill.Food_Items__r) {
                breakdown += '- ' + item.Food_Option__r.Name + 
                           ' (Quantity: ' + item.Quantity__c + 
                           ', Amount: ' + item.Amount__c + ')\n';
            }
            breakdown += 'Bill Total: ' + bill.Total_Amount__c + '\n';
        }
        
        // Prepare final response
        String response = 'Customer ID: ' + customerId + '\n' +
                         'Total Amount: ' + totalAmount + '\n' +
                         'Bill Breakdown:' + breakdown;
        
        // Update customer status
        List<Customer__c> customers = [
            SELECT Id 
            FROM Customer__c 
            WHERE Customer_ID__c = :customerId
        ];
        
        if (!customers.isEmpty()) {
            customers[0].Status__c = 'Checked Out';
            try {
                update customers[0];
            } catch (Exception e) {
                response += '\nError updating customer status: ' + e.getMessage();
            }
        }
        
        results.add(response);
        return results;
    }
}