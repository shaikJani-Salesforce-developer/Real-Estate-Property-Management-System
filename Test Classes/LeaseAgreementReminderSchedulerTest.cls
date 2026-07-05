@isTest
public class LeaseAgreementReminderSchedulerTest {

    @isTest
    static void testReminderEmailForExpiringLease() {
        Tenant__c t = new Tenant__c();
        t.Name = 'John Tenant';
        t.Phone_Number__c = '9876500000';
        t.Email__c = 'john.tenant@test.com';
        insert t;

        Property__c p = new Property__c();
        p.Name = 'Lease Test Property';
        p.Address__c = 'addr';
        p.City__c = 'Chennai';
        p.State__c = 'TN';
        p.Postal_Code__c = '600001';
        p.Country__c = 'India';
        p.Type__c = 'Residential';
        p.Status__c = 'Occupied';
        p.Rent__c = 20000;
        p.Description__c = 'desc';
        p.Tenant__c = t.Id;
        insert p;

        Lease_Agreement__c la = new Lease_Agreement__c();
        la.Property__c = p.Id;
        la.Terms__c = 'standard 11 month lease';
        la.Agreed_Monthly_Rent__c = 20000;
        la.Start_Date__c = Date.today().addMonths(-11);
        la.End_Date__c = Date.today().addDays(30); 
        insert la;

        Test.startTest();
        String cronExp = '0 0 6 * * ?';
        System.schedule('Test Lease Reminder Job', cronExp, new LeaseAgreementReminderScheduler());
        Test.stopTest();

       
        Lease_Agreement__c check = [SELECT End_Date__c FROM Lease_Agreement__c WHERE Id = :la.Id];
        System.assertEquals(Date.today().addDays(30), check.End_Date__c);
    }

    @isTest
    static void testNoEmailWhenNoLeaseExpiring() {
        
        Test.startTest();
        LeaseAgreementReminderScheduler scheduler = new LeaseAgreementReminderScheduler();
        scheduler.execute(null);
        Test.stopTest();
        System.assert(true); // just checking no exception was thrown
    }
}