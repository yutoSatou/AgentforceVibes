/**
 * Invocable Apex class to query Food_Option__c records
 * Used by AgentForce agents to retrieve food options data
 */
public without sharing class FoodOptionService {
    
    /**
     * Invocable method to get all Food_Option__c records with specified fields
     * @return List of Food_Option__c records
     */
    @InvocableMethod(label='Get Food Options' description='Retrieves all Food Options with Name, Price and Size')
    public static List<Food_Option__c> getFoodOptions(LIST<String> foodPreferances) {
        return [
            SELECT Name, Price__c, Size__c 
            FROM Food_Option__c 
            
        ];
    }
}