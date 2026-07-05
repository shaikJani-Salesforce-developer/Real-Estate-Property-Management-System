trigger PropertyTrigger on Property__c (after insert, after update) {

    List<Property__c> propertiesNeedingTask = new List<Property__c>();

    for (Property__c prop : Trigger.new) {

        if (Trigger.isInsert) {
        
            if (prop.Tenant__c != null) {
                propertiesNeedingTask.add(prop);
            }
        }

        if (Trigger.isUpdate) {
            Property__c oldProp = Trigger.oldMap.get(prop.Id);
            
            if (prop.Tenant__c != null && oldProp.Tenant__c == null) {
                propertiesNeedingTask.add(prop);
            }
        }
    }

    if (!propertiesNeedingTask.isEmpty()) {
        PropertyTriggerHandler.createLeaseAgreementTasks(propertiesNeedingTask);
    }
}
