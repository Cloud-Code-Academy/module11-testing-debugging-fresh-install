/*
This is my Data Factory for generating test data. 

@return 'dataFactoryLeadList' will return 12 leads with varying data
@return 'contactMap' will return 3 Contacts and two of them will have matching email addresses
*/

public with sharing class TestDataFactory{

    @TestVisible
    public static List<Lead> leadTestData(){

        List<Lead> dataFactoryLeadList = new List<Lead>();

        List<String> titlesLead = new List<String>{
            'vp of Sales', 'V.P. Marketing', 'vice president', 'Mgr of Operations', 'manage consultants',
            'head of department', 'exec dir', 'chief Analyst', 'Deputy Advisor', ' assist consultant', 
            'deputy financial officer', 'jr cookie baker' };

        List<String> industriesLead = new List<String>{
            'Media', 'Technology', null, null, 'Technology',
            'Technology', null, 'Unemployed', 'Arts', null,
            'Other', null};

        List<String> phonesLead = new List<String>{
            '215-123-4567', null, '215-234-5678', null, '215-345-6789',
            '215-456-7890', null, '215-567-8901', null, '215-678-9012',
            null, null};

        List<String> emailsLead = new List<String>{
            'example1@gmail.com', 'example2@yahoo.com', 'example0987@domain.org', 'example3@hotmail.com', 
            'example4@outlook.com', 'example5@icloud.com', 'example456@domain.org', 'example6@aol.com', 
            'example7@company.com', 'example87@domain.org', 'example8@domain.org', 'example128@domain.org'};

        List<String> sourceLead = new List<String>{
            'Phone Inquiry','Website',null,'Other', null,
            'Website',null,'Website', null, 'Website','',
            'Website',null,null,'Other',null};    


    // loop returns 12 leads and add them to the list

        for (Integer i=0; i<12; i++) {
            Lead loopThroughLeads = new Lead();
            loopThroughLeads.LastName ='Lead' + (i+1);
            loopThroughLeads.Company = 'Super Leads';
            loopThroughLeads.Title = titlesLead[i];
            loopThroughLeads.Industry = industriesLead[i];
            loopThroughLeads.Status = 'Open - Not Contacted';
            loopThroughLeads.Email = emailsLead[i];
            loopThroughLeads.Phone = phonesLead[i];
            loopThroughLeads.LeadSource = sourceLead[i];

            //add each iteration to the list
            dataFactoryLeadList.add(loopThroughLeads);
        }

        //return the list of leads just created
        return dataFactoryLeadList;
    }


    
    // Method to alter the leadTestData so 'handleAutoConvert' can be tested with INSERTS
    public static List<Lead> leadTestDataInsert(){
        List<Lead> leadListForInserts = leadTestData();

        leadListForInserts[2].Email = 'randomEmail999@domain.org';

        return leadListForInserts;
        
    }    

    // Method to alter the leadTestData so 'handleAutoConvert' can be tested with UPDATES
    public static List<Lead> leadTestDataUpdate(){
        List<Lead> leadListForUpdates = leadTestData();


        // Reverse loop starting at 11 and working down to ensure the safe 
        // removal of elements from the lead list. Decrements by 1 after each
        // iteration
        for (Integer i = 11; i >= 0; i--) {
            if (i > 2) {
                // only keep the first 3 leads
                leadListForUpdates.remove(i);
            }
            // update leads 0,1,2 to have email = 'not.a.match@domain.org'
            else {
                leadListForUpdates[i].Email = 'not.a.match@domain.org';
            }
            
        }

        return leadListForUpdates;

    }



    //Method to create Test Contact data for duplicate checking etc
    public static Map<String, Contact> createTestContacts(){

        //Create an account to link the Contacts to
        Account acct = new Account(Name = 'Data Factory Account');
        insert acct;

        //create the map
        Map<String,Contact> contactMap = new Map<String,Contact>();

        //create 3 contacts
        for (Integer i = 1; i < 4; i++) {
            Contact cont = new Contact(
                AccountId = acct.Id,
                LastName = String.valueOf(i),
                Email = 'dataFactory' + i + '@awesomeTest.com'
            );
        // create a duplicate email address to check assertion
        // this takes the first contact and gives it the email of the 3rd contact    
        if (i == 1) {
            cont.Email = 'dataFactory3@awesomeTest.com';
        }  

        // add the contacts to the map
        // key = last name, value = contact obj
        contactMap.put(cont.LastName, cont);
        }
        
        // retrieve and insert all values in the map
        insert contactMap.values();

        return contactMap;
    }
}