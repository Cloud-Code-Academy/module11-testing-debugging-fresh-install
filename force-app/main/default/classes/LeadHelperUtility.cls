public with sharing class LeadHelperUtility {

    public static void autoConvertLeads(List<Lead> leads) {

        // Put ALL lead emails in a map
        Map<Id, String> leadEmailMap = new Map<Id, String>();
            for (Lead l : leads) {
                // only add leads with not null emails
                if (l.Email != null) { 
                    leadEmailMap.put(l.Id, l.Email);  
                }  
            }
            if (leadEmailMap.isEmpty()) {
                return; // stop if the map is empty
            }
            System.debug('Initial leadEmailMap: ' + leadEmailMap);


        // Query the Contact object for records with emails that match the leads
        Map<String, Contact> contactEmailMap = new Map<String, Contact>();

        for (Contact c : [SELECT Id, Email, AccountId FROM Contact WHERE Email IN :leadEmailMap.values()]) {
            if (!contactEmailMap.containsKey(c.Email)) {
                contactEmailMap.put(c.Email, c);
            } 
            else {
                // Remove Leads matching Contact emails by Lead ID so they don't convert
                contactEmailMap.remove(c.Email);
            }
        }



        // Convert the Leads that made it through

        //Create a list of LeadConvert objects for bulk conversion
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();

        //Query the Lead Status to ensure leads were converted
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];

            for (Id leadId : leadEmailMap.keySet()) {

                // get the email for the current lead
                String leadsEmail = leadEmailMap.get(leadId);

                if (contactEmailMap.containsKey(leadsEmail)) {
                        Database.LeadConvert leadConv = new Database.LeadConvert();
                        leadConv.setLeadId(leadId);
                        //use the contact Id found in the map
                        leadConv.setContactId(contactEmailMap.get(leadsEmail).Id);
                        //use the acct Id found in the map
                        leadConv.setAccountId(contactEmailMap.get(leadsEmail).AccountId);
                        //don't create an opportunity
                        leadConv.setDoNotCreateOpportunity(true);
                        // set the converted status
                        leadConv.setConvertedStatus(convertStatus.MasterLabel);
                        // add the lead to the list for bulk processing
                        leadsToConvert.add(leadConv);  
                }
                
            }

            // preform the bulk conversion if the list is NOT empty
            if (!leadsToConvert.isEmpty()) {
                List<Database.LeadConvertResult> convertResults = Database.convertLead(leadsToConvert);
            }
        
    }

        
    
    
    
    
    
    
    
        /*
        System.debug('contactEmailMap: ' + contactEmailMap);

        // Step 3: Auto-convert items in leadEmailMap
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];

        for (Id leadId : leadEmailMap.keySet()) {
            String leadEmail = leadEmailMap.get(leadId);
            if (!contactEmailMap.containsKey(leadEmail)) {
                System.debug('Preparing LeadConvert for Lead Id: ' + leadId + ' with Email: ' + leadEmail);
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(leadId);
                lc.setDoNotCreateOpportunity(true);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                leadConverts.add(lc);
            }
        }
        System.debug('LeadConverts prepared: ' + leadConverts);

        // Step 4: Perform conversion
        if (!leadConverts.isEmpty()) {
            List<Database.LeadConvertResult> lcrs = Database.convertLead(leadConverts);
            System.debug('LeadConvert Results: ' + lcrs);
        }
        */
}