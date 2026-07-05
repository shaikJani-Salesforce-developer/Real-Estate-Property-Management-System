@isTest
public class PropertyCreateControllerTest {

    
    @isTest static void testCreatePropertySuccessWithImage() {
        Property__c p = new Property__c();
        p.Name = 'Green Villa';
        p.Address__c = '12 MG Road';
        p.City__c = 'Chennai';
        p.State__c = 'TN';
        p.Postal_Code__c = '600002';
        p.Country__c = 'India';
        p.Type__c = 'Residential';
        p.Status__c = 'Available';
        p.Rent__c = 20000;
        p.Description__c = 'Nice place near the market';

        List<String> images = new List<String>();
        images.add(EncodingUtil.base64Encode(Blob.valueOf('fake image data 1')));
        images.add(EncodingUtil.base64Encode(Blob.valueOf('fake image data 2')));

        List<String> names = new List<String>{ 'pic1.jpg', 'pic2.jpg' };

        Test.startTest();
        Id result = PropertyCreateController.createPropertyWithImages(p, images, names);
        Test.stopTest();

        System.assertNotEquals(null, result, 'property should have been created');

        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :result];
        System.assertEquals(2, links.size());
    }

    @isTest
    static void testCreatePropertyFailsWithoutImage() {
        Property__c p = new Property__c();
        p.Name = 'Test Prop No Image';
        p.Address__c = 'Some address';
        p.City__c = 'Chennai';
        p.State__c = 'TN';
        p.Postal_Code__c = '600003';
        p.Country__c = 'India';
        p.Type__c = 'Commercial';
        p.Status__c = 'Available';
        p.Rent__c = 5000;
        p.Description__c = 'desc';

        Boolean errorThrown = false;
        try {
            PropertyCreateController.createPropertyWithImages(p, new List<String>(), new List<String>());
        } catch (AuraHandledException e) {
            errorThrown = true;
        }
        System.assertEquals(true, errorThrown, 'should not allow save without image');

        
        Integer count = [SELECT COUNT() FROM Property__c WHERE Name = 'Test Prop No Image'];
        System.assertEquals(0, count);
    }
}