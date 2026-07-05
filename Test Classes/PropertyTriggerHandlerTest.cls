@isTest
public class PropertyTriggerHandlerTest {

    @isTest
    static void testTaskCreatedWhenTenantAssignedOnInsert() {
        Tenant__c t = new Tenant__c();
        t.Name = 'Ravi Kumar';
        t.Phone_Number__c = '9876543210';
        t.Email__c = 'ravi@test.com';
        insert t;

        Property__c p = new Property__c();
        p.Name = 'Prop with tenant';
        p.Address__c = 'addr';
        p.City__c = 'Chennai';
        p.State__c = 'TN';
        p.Postal_Code__c = '600001';
        p.Country__c = 'India';
        p.Type__c = 'Residential';
        p.Status__c = 'Occupied';
        p.Rent__c = 15000;
        p.Description__c = 'desc';
        p.Tenant__c = t.Id;

        Test.startTest();
        insert p;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :p.Id];
        System.assertEquals(1, tasks.size());
        System.assertEquals('Generate Lease Agreement', tasks[0].Subject);
    }

    @isTest
    static void testTaskCreatedWhenTenantAssignedOnUpdate() {
        Tenant__c t = new Tenant__c(Name = 'Suresh', Phone_Number__c = '9998887776', Email__c = 'suresh@test.com');
        insert t;

        Property__c p = new Property__c();
        p.Name = 'Prop no tenant yet';
        p.Address__c = 'addr';
        p.City__c = 'Chennai';
        p.State__c = 'TN';
        p.Postal_Code__c = '600001';
        p.Country__c = 'India';
        p.Type__c = 'Residential';
        p.Status__c = 'Available';
        p.Rent__c = 12000;
        p.Description__c = 'desc';
        insert p; 

        List<Task> tasksBefore = [SELECT Id FROM Task WHERE WhatId = :p.Id];
        System.assertEquals(0, tasksBefore.size());

        p.Tenant__c = t.Id;
        Test.startTest();
        update p;
        Test.stopTest();

        List<Task> tasksAfter = [SELECT Id FROM Task WHERE WhatId = :p.Id];
        System.assertEquals(1, tasksAfter.size());
    }

    @isTest
    static void testNoDuplicateTaskOnUnrelatedUpdate() {
        Tenant__c t = new Tenant__c(Name = 'Anita', Phone_Number__c = '9000000000', Email__c = 'anita@test.com');
        insert t;

        Property__c p = new Property__c();
        p.Name = 'Prop existing tenant';
        p.Address__c = 'addr';
        p.City__c = 'Chennai';
        p.State__c = 'TN';
        p.Postal_Code__c = '600001';
        p.Country__c = 'India';
        p.Type__c = 'Residential';
        p.Status__c = 'Occupied';
        p.Rent__c = 18000;
        p.Description__c = 'desc';
        p.Tenant__c = t.Id;
        insert p;

        
        p.Rent__c = 19000;
        Test.startTest();
        update p;
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :p.Id];
        System.assertEquals(1, tasks.size(), 'should still be only 1 task, not 2');
    }
}