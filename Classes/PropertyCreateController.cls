public with sharing class PropertyCreateController {

    @AuraEnabled
    public static Id createPropertyWithImages(Property__c prop, List<String> base64Images, List<String> fileNames) {

        if (base64Images == null || base64Images.isEmpty()) {
            throw new AuraHandledException('Please upload at least one image.');
        }

        Savepoint sp = Database.setSavepoint();
        try {
            insert prop;

            List<ContentVersion> versions = new List<ContentVersion>();
            for (Integer i = 0; i < base64Images.size(); i++) {
                ContentVersion cv = new ContentVersion();
                cv.Title = fileNames[i];
                cv.PathOnClient = fileNames[i];
                cv.VersionData = EncodingUtil.base64Decode(base64Images[i]);
                cv.FirstPublishLocationId = prop.Id;
                versions.add(cv);
            }
            insert versions;

            return prop.Id;

        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException('Failed to save property: ' + e.getMessage());
        }
    }
}