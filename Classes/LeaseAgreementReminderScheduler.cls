global class LeaseAgreementReminderScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {

        Date reminderDate = Date.today().addDays(30);

        List<Lease_Agreement__c> agreements = [

            SELECT Id,
                   Name,
                   End_Date__c,
                   Property__r.Name,
                   Property__r.Tenant__r.Name,
                   Property__r.Tenant__r.Email__c

            FROM Lease_Agreement__c

            WHERE End_Date__c = :reminderDate
            AND Property__c != null
            AND Property__r.Tenant__c != null
            AND Property__r.Tenant__r.Email__c != null
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(Lease_Agreement__c agreement : agreements){

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(
                new String[]{
                    agreement.Property__r.Tenant__r.Email__c
                }
            );

            mail.setSubject('Lease Agreement Expiry Reminder');

            mail.setPlainTextBody(
                'Dear ' +
                agreement.Property__r.Tenant__r.Name +
                ',\n\n' +
                'Your lease agreement for property "' +
                agreement.Property__r.Name +
                '" will expire on ' +
                String.valueOf(agreement.End_Date__c) +
                '.\n\n' +
                'Please contact us if you wish to renew your lease.\n\n' +
                'Thank You.'
            );

            emails.add(mail);
        }

        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
}