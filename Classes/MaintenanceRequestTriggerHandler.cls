public with sharing class MaintenanceRequestTriggerHandler {

    public static void assignVendor(List<Maintenance_Request__c> requests) {

        
        List<Vendor__c> vendors = [ SELECT Id FROM Vendor__c ];

        if(vendors.isEmpty()){
            return;
        }

        
        Map<Id,Integer> vendorWorkload = new Map<Id,Integer>();

        AggregateResult[] results = [

            SELECT Vendor__c vendorId, COUNT(Id) total FROM Maintenance_Request__c WHERE Vendor__c != null AND Status__c IN ('Open','In Progress')GROUP BY Vendor__c ];

        for(AggregateResult ar : results){

            vendorWorkload.put((Id)ar.get('vendorId'),(Integer)ar.get('total'));
        }

        
        Id selectedVendorId;
        Integer leastWorkload = 999999;

        for(Vendor__c vendor : vendors){

            Integer workload = 0;

            if(vendorWorkload.containsKey(vendor.Id)){
                workload = vendorWorkload.get(vendor.Id);
            }

            if(workload < leastWorkload){
                leastWorkload = workload;
                selectedVendorId = vendor.Id;
            }

        }

        
        for(Maintenance_Request__c req : requests){

            req.Vendor__c = selectedVendorId;

        }

    }

}