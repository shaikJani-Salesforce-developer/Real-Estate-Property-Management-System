@isTest
public class MaintenanceRequestTriggerHandlerTest {

    @isTest
    static void testVendorGetsAssignedWhenNoneAssignedYet() {
        Vendor__c v1 = new Vendor__c(Name = 'ABC Plumbing', Phone__c = '9111111111', Email__c = 'abc@test.com');
        Vendor__c v2 = new Vendor__c(Name = 'XYZ Electric', Phone__c = '9222222222', Email__c = 'xyz@test.com');
        insert new List<Vendor__c>{ v1, v2 };

        Property__c p = new Property__c();
        p.Name = 'Maint Property';
        p.Address__c = 'addr';
        p.City__c = 'Chennai';
        p.State__c = 'TN';
        p.Postal_Code__c = '600001';
        p.Country__c = 'India';
        p.Type__c = 'Residential';
        p.Status__c = 'Occupied';
        p.Rent__c = 10000;
        p.Description__c = 'desc';
        insert p;

        Maintenance_Request__c req = new Maintenance_Request__c();
        req.Property__c = p.Id;
        req.Status__c = 'Open';
        req.Description__c = 'AC not working';

        Test.startTest();
        insert req;
        Test.stopTest();

        Maintenance_Request__c inserted = [SELECT Vendor__c FROM Maintenance_Request__c WHERE Id = :req.Id];
        System.assertNotEquals(null, inserted.Vendor__c, 'a vendor should have been auto assigned');
    }

    @isTest
    static void testVendorWithLeastWorkloadGetsPicked() {
        Vendor__c busyVendor = new Vendor__c(Name = 'Busy Vendor', Phone__c = '9333333333', Email__c = 'busy@test.com');
        Vendor__c freeVendor = new Vendor__c(Name = 'Free Vendor', Phone__c = '9444444444', Email__c = 'free@test.com');
        insert new List<Vendor__c>{ busyVendor, freeVendor };

        Property__c p = new Property__c();
        p.Name = 'Maint Property 2';
        p.Address__c = 'addr';
        p.City__c = 'Chennai';
        p.State__c = 'TN';
        p.Postal_Code__c = '600001';
        p.Country__c = 'India';
        p.Type__c = 'Residential';
        p.Status__c = 'Occupied';
        p.Rent__c = 10000;
        p.Description__c = 'desc';
        insert p;

        
        List<Maintenance_Request__c> existing = new List<Maintenance_Request__c>();
        for (Integer i = 0; i < 3; i++) {
            Maintenance_Request__c r = new Maintenance_Request__c();
            r.Property__c = p.Id;
            r.Vendor__c = busyVendor.Id;
            r.Status__c = 'Open';
            r.Description__c = 'existing issue ' + i;
            existing.add(r);
        }
        insert existing;

        
        Maintenance_Request__c newReq = new Maintenance_Request__c();
        newReq.Property__c = p.Id;
        newReq.Status__c = 'Open';
        newReq.Description__c = 'leaking pipe';

        Test.startTest();
        insert newReq;
        Test.stopTest();

        Maintenance_Request__c result = [SELECT Vendor__c FROM Maintenance_Request__c WHERE Id = :newReq.Id];
        System.assertEquals(freeVendor.Id, result.Vendor__c, 'should assign to vendor with less workload');
    }

    @isTest
    static void testNoVendorAvailableDoesNotBreak() {
       
        Property__c p = new Property__c();
        p.Name = 'Maint Property 3';
        p.Address__c = 'addr';
        p.City__c = 'Chennai';
        p.State__c = 'TN';
        p.Postal_Code__c = '600001';
        p.Country__c = 'India';
        p.Type__c = 'Residential';
        p.Status__c = 'Available';
        p.Rent__c = 8000;
        p.Description__c = 'desc';
        insert p;

        Maintenance_Request__c req = new Maintenance_Request__c();
        req.Property__c = p.Id;
        req.Status__c = 'Open';
        req.Description__c = 'no vendor scenario';

        Test.startTest();
        insert req; 
        Test.stopTest();

        Maintenance_Request__c result = [SELECT Vendor__c FROM Maintenance_Request__c WHERE Id = :req.Id];
        System.assertEquals(null, result.Vendor__c);
    }
}