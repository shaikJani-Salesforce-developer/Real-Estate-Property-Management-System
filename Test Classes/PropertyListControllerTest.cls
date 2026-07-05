@isTest
public class PropertyListControllerTest {

    @testSetup
    static void setup() {
        List<Property__c> props = new List<Property__c>();
        for (Integer i = 0; i < 30; i++) {
            Property__c p = new Property__c();
            p.Name = 'Prop ' + i;
            p.Address__c = 'Addr ' + i;
            p.City__c = 'Chennai';
            p.State__c = 'TN';
            p.Postal_Code__c = '600001';
            p.Country__c = 'India';
            p.Type__c = 'Residential';
            p.Furnishing_Status__c = 'Furnished';
            
            p.Status__c = Math.mod(i, 2) == 0 ? 'Available' : 'Occupied';
            p.Rent__c = 10000 + (i * 500);
            p.Description__c = 'test property';
            props.add(p);
        }
        insert props;
    }

    @isTest
    static void testPaginationFirstPage() {
        PropertyListController.PagedResult result = PropertyListController.getProperties(1, 25, null, null, null, null);
        System.assertEquals(25, result.records.size());
        System.assertEquals(30, result.totalRecords);
    }

    @isTest
    static void testPaginationSecondPage() {
        PropertyListController.PagedResult result = PropertyListController.getProperties(2, 25, null, null, null, null);
        
        System.assertEquals(5, result.records.size());
    }

    @isTest
    static void testFilterByStatus() {
        PropertyListController.PagedResult result = PropertyListController.getProperties(1, 25, null, null, 'Available', null);
        for (Property__c p : result.records) {
            System.assertEquals('Available', p.Status__c);
        }
    }

    @isTest
    static void testFilterByRentRange() {
        PropertyListController.PagedResult result = PropertyListController.getProperties(1, 25, 10000, 12000, null, null);
        for (Property__c p : result.records) {
            System.assert(p.Rent__c >= 10000 && p.Rent__c <= 12000);
        }
    }
}