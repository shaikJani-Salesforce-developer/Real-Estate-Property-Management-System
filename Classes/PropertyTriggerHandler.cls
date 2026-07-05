public with sharing class PropertyTriggerHandler {

    public static void createLeaseAgreementTasks(List<Property__c> properties) {

        List<Task> tasksToInsert = new List<Task>();

        for (Property__c prop : properties) {
            tasksToInsert.add(new Task(
                Subject = 'Generate Lease Agreement',
                WhatId = prop.Id,              // links the task to this Property record
                ActivityDate = Date.today().addDays(3),
                Status = 'Not Started',
                Priority = 'High',
                Description = 'A tenant has been assigned to this property. Please prepare the lease agreement.'
            ));
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}