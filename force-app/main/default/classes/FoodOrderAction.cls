public without sharing class FoodOrderAction {
    
    /**
     * Wrapper class to deserialize the JSON input
     */
    public class FoodOrderRequest {
        public String id;
        public Integer quantity;
    }
    
    /**
     * Wrapper class to return the result
     */
    public class FoodOrderResult {
        @InvocableVariable public String foodBillId;
        @InvocableVariable public String debugInfo;
    }
    
    /**
     * Method to handle the food order request from the Agent
     * @param jsonInput JSON string containing list of FoodOrderRequest objects
     * @return List<FoodOrderResult> containing the Food Bill ID and debug information
     */
    @InvocableMethod(label='Process Food Order' description='Process food order request from Agent')
    public static List<FoodOrderResult> processFoodOrder(List<String> jsonInput) {
        List<FoodOrderResult> results = new List<FoodOrderResult>();
        FoodOrderResult result = new FoodOrderResult();
        
        try {
            // Parse the JSON input
            List<FoodOrderRequest> orders = (List<FoodOrderRequest>)JSON.deserialize(
                jsonInput[0], 
                List<FoodOrderRequest>.class
            );
            
            // Get all Food Option IDs from the orders
            Set<String> foodOptionIds = new Set<String>();
            for(FoodOrderRequest order : orders) {
                foodOptionIds.add(order.id);
            }
            
            // Query Food Options to get their prices
            Map<String, Food_Option__c> foodOptionsMap = new Map<String, Food_Option__c>([
                SELECT Id, Price__c 
                FROM Food_Option__c 
                WHERE Id IN :foodOptionIds
            ]);
            
            // Create Food Bill record
            Food_Bill__c foodBill = new Food_Bill__c();
            insert foodBill;
            
            System.debug(foodBill);
            
            // Store the Food Bill ID
            result.foodBillId = foodBill.Id;
            
            // Create Food Item records
            List<Food_Item__c> foodItems = new List<Food_Item__c>();
            for(FoodOrderRequest order : orders) {
                Food_Option__c foodOption = foodOptionsMap.get(order.id);
                if(foodOption != null) {
                    Food_Item__c item = new Food_Item__c(
                        Food_Bill__c = foodBill.Id,
                        Food_Option__c = order.id,
                        Quantity__c = order.quantity,
                        Amount__c = foodOption.Price__c * order.quantity
                    );
                    foodItems.add(item);
                }
            }
            
            // Insert all food items
            insert foodItems;
            
            // Prepare debug information
            String debugInfo = 'Successfully processed food order:\n';
            debugInfo += 'Created Food Bill with ID: ' + foodBill.Id + '\n';
            debugInfo += 'Created ' + foodItems.size() + ' Food Item(s):\n';
            
            for(Food_Item__c item : foodItems) {
                Food_Option__c foodOption = foodOptionsMap.get(item.Food_Option__c);
                debugInfo += 'Food Item ID: ' + item.Id + 
                           ', Food Option: ' + item.Food_Option__c + 
                           ', Quantity: ' + item.Quantity__c + 
                           ', Price: ' + foodOption.Price__c + 
                           ', Amount: ' + item.Amount__c + '\n';
            }
            
            result.debugInfo = debugInfo;
            
        } catch(Exception e) {
            result.foodBillId = null;
            result.debugInfo = 'Error processing food order: ' + e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        results.add(result);
        return results;
    }
}