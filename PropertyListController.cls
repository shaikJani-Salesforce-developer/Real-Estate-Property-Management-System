public with sharing class PropertyListController {

    @AuraEnabled
    public static PagedResult getProperties(Integer pageNumber, Integer pageSize,Decimal minRent, Decimal maxRent,String availabilityStatus, String furnishingStatus) {

        
        if (pageNumber == null || pageNumber < 1) pageNumber = 1;
        if (pageSize == null || pageSize < 1) pageSize = 25;
        Integer offsetVal = (pageNumber - 1) * pageSize;

        
        String whereClause = 'WHERE Id != null';

        if (minRent != null) {
            whereClause += ' AND Rent__c >= ' + minRent;
        }
        if (maxRent != null) {
            whereClause += ' AND Rent__c <= ' + maxRent;
        }
        if (String.isNotBlank(availabilityStatus)) {
            whereClause += ' AND Status__c = \'' + String.escapeSingleQuotes(availabilityStatus) + '\'';
        }
        if (String.isNotBlank(furnishingStatus)) {
            whereClause += ' AND Furnishing_Status__c = \'' + String.escapeSingleQuotes(furnishingStatus) + '\'';
        }

    
        Integer totalRecords = Database.countQuery('SELECT COUNT() FROM Property__c ' + whereClause);

        
        String dataQuery = 'SELECT Id, Name, City__c, Type__c, Status__c, Furnishing_Status__c, Rent__c ' +'FROM Property__c ' + whereClause +
                            ' ORDER BY CreatedDate DESC LIMIT ' + pageSize + ' OFFSET ' + offsetVal;

        List<Property__c> records = Database.query(dataQuery);

        PagedResult result = new PagedResult();
        result.records = records;
        result.totalRecords = totalRecords;
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;
        return result;
    }

    
    public class PagedResult {
        @AuraEnabled public List<Property__c> records;
        @AuraEnabled public Integer totalRecords;
        @AuraEnabled public Integer pageSize;
        @AuraEnabled public Integer pageNumber;
    }
}