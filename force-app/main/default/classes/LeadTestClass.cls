/*

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact existingContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            AccountId = testAccount.Id
        );
        insert existingContact;

        // Step 2: Use TestDataFactory to get Leads for Insert Test
        List<Lead> newLeads = TestDataFactory.leadTestData();

        // Update specific leads for insert testing
        newLeads[0].Email = 'john.doe@example.com'; // Matches the existing Contact
        newLeads[0].Status = 'Open - Not Contacted';

        newLeads[1].Email = 'unique.lead@example.com'; // Unique email
        newLeads[1].Status = 'Open - Not Contacted'; // Ensure correct Status

        newLeads[2].Email = 'john.doe@example.com'; // Duplicate email for testing
        newLeads[2].Status = 'Open - Not Contacted';

        insert newLeads;

        // Debug the test data before calling the method
        for (Lead lead : newLeads) {
            System.debug('Lead: ' + lead);
        }

        // Step 3: Call the method under test for Insert
        Test.startTest();
        LeadHelperUtility.autoConvertLeads(
            [SELECT Id, Email, Status FROM Lead WHERE Status = 'Open - Not Contacted']
        );
        Test.stopTest();

        // Assertions for Insert
        // Lead with matching email should NOT be converted
        Lead matchingLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :newLeads[0].Id];
        System.assert(!matchingLead.IsConverted, 'The lead with a matching email should NOT be converted.');

        // Unique lead should be converted
        Lead convertedUniqueLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :newLeads[1].Id];
        System.assert(convertedUniqueLead.IsConverted, 'The unique lead should be converted.');

        // Lead with duplicate email should NOT be converted
        Lead duplicateNonConvertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :newLeads[2].Id];
        System.assert(!duplicateNonConvertedLead.IsConverted, 'The lead with a duplicate email should NOT be converted.');

*/





/*
 * Test trigger functionality when Leads are created or updated. 
 * Three actions should happen in each case:
 * Lead Title should be normalized,
 * Lead Score should be calculated, 
 * If exactly 1 Contact exists which matches the Lead's email address, 
 * the Lead should be automatically converted
 * 
 */

@isTest
private class LeadTestClass {

    @isTest
    static void testHandleTitleNormalization(){
        /* 
        * Question 1
        * Requirement Lead Title Normalization - handleTitleNormalization
        * Occasionally, users input titles in a variety of ways. Streamline these titles for consistency:
        *
        * Criteria:
        * - If the title contains terms such as 'vp', 'v.p.', or 'vice president',
        *   change the title to 'Vice President'.
        * - If the title contains terms like 'mgr', 'manage', or 'head of department',
        *   change the title to 'Manager'.
        * - Should the title include words like 'exec', 'chief', or 'head',
        *   change the title to 'Executive'.
        * - If the title contains terms like 'assist', 'deputy', or 'jr',
        *   change the title to 'Assistant'.
        */

    	// Create new Leads and add them to a list

        List<Lead> newLeads = TestDataFactory.leadTestData();

    	// Insert the Leads
    	Test.startTest();
        insert newLeads;
        Test.stopTest();


        //query to make sure lead was inserted
        List<Lead> insertedLeads = new List<Lead>([SELECT Id, Title FROM Lead]);

        System.debug(insertedLeads + '+++++++');

       Assert.areEqual(newLeads.size(), insertedLeads.size(), 'Incorrect number of created Leads.');
    
    	// Ensure that Title was correctly normalized for each record
        for (Integer i=0; i < newLeads.size(); i++) {
            // Check if Title is null
			if (newLeads[i].Title == null) {
                Assert.areEqual(null, insertedLeads[i].Title, 'No title should be given to a null value');

			// Check update VP Title
			} else if (newLeads[i].Title.containsIgnoreCase('vp') || newLeads[i].Title.containsIgnoreCase('v.p.') || newLeads[i].Title.containsIgnoreCase('vice president')) {
				Assert.areEqual('Vice President', insertedLeads[i].Title, 'VP Title was not normalized');

			// Check update Manager Title
			} else if (newLeads[i].Title.containsIgnoreCase('mgr') || newLeads[i].Title.containsIgnoreCase('manage') || newLeads[i].Title.containsIgnoreCase('head of department')) {
				Assert.areEqual('Manager', insertedLeads[i].Title, 'Manager Title was not normalized');

			// Check update Executive Title
			} else if (newLeads[i].Title.containsIgnoreCase('exec') || newLeads[i].Title.containsIgnoreCase('chief') || newLeads[i].Title.containsIgnoreCase('head')) {
				Assert.areEqual('Executive', insertedLeads[i].Title, 'Executive Title was not normalized');

			// Check update Assistant Title
			} else if (newLeads[i].Title.containsIgnoreCase('assist') || newLeads[i].Title.containsIgnoreCase('deputy') || newLeads[i].Title.containsIgnoreCase('jr')) {
				Assert.areEqual('Assistant', insertedLeads[i].Title, 'Assistant Title was not normalized');

			// Assure no other Lead had Title changed
			} else {
                Assert.areEqual(newLeads[i].Title, insertedLeads[i].Title, 'Lead Title should remain the same.');
            }

        }

    }

    @isTest
    static void testHandleAutoLeadScoring() {
        /* 
         * Question 2
         * Requirement Auto Lead Scoring - handleAutoLeadScoring
         * Implement logic to automatically assign scores to leads based on specific criteria.
         * 18 should be highest possible score a lead can have.
         *
         * Criteria:
         * - If the lead source is from the website and an email exists, increment score by 3 points.
         * - If the lead provides a phone number, increment score by 5 points.
         * - If the lead belongs to the 'Technology' industry, increment score by another 10 points.
         */


        // Create new Leads and add them to a list
         List<Lead> newLeads = TestDataFactory.leadTestData();

         // Insert the Leads
		Test.startTest();
		insert newLeads;
		Test.stopTest();


        // Query the new Leads to assess changes made
		List<Lead> createdLeads = [SELECT Id, FirstName, LastName, Lead_Score__c, Email, Phone, LeadSource, Industry FROM Lead];


        // Ensure that the correct number of records were created
		Assert.areEqual(newLeads.size(), createdLeads.size(), 'Incorrect number of created Leads.');


		// Calculate the correct score for each Lead
		for (Lead loopThroughLeads : createdLeads) {
			Integer leadScore = 0;
			if (loopThroughLeads.Email != null && loopThroughLeads.LeadSource == 'Website') {
				leadScore += 3;
			}
			if (loopThroughLeads.Phone != null) {
				leadScore +=5;
			}
			if (loopThroughLeads.Industry == 'Technology') {
				leadScore += 10;
			}

			//Ensure the correct Lead Score was calculated
			Assert.areEqual(leadScore, loopThroughLeads.Lead_Score__c, 'The Score of this Lead was not calculated properly. Lead: ' + loopThroughLeads.FirstName + ' ' + loopThroughLeads.LastName);
		}
    }




    /* 
    * Question 3
    * Requirement Automatic Lead Conversion Based on Email Match - handleLeadAutoConvert
    * Whenever a new Lead is created or an existing Lead's email address is updated,
    * check for a matching Contact based on the email address. If a single matching
    * Contact is identified, auto-convert the Lead.
    * Use the Salesforce report Converted Lead to verify that the Lead was converted to 
        the correct Contact.
    *
    * Criteria:
    * - Monitor the "Email" field on the Lead object for creation or updates.
    * - On Lead creation or email update, search the Contact object for records with the
    *   same email address.
    * - If a single matching Contact is identified:
    *     - Auto-convert the Lead.
    *     - Merge the Lead details with the existing Contact, ensuring that crucial
    *       Contact information is preserved.
    * - If multiple Contacts with the same email are found or no match is identified,
    *   leave the Lead unconverted.
    */

    /* this test verifies that 

    @isTest
    static void handleLeadAutoConvertUponInsert() {

        // Create new Leads and add them to a list
        List<Lead> newLeads = TestDataFactory.leadTestData();

        // Insert the Leads
    	Test.startTest();
        insert newLeads;
        Test.stopTest();

        // ensure it works correctly
        List<Lead> insertedLeadList = new List<Lead>([SELECT Id, LastName, isConverted, ConvertedContactId From Lead]);

        for (Lead l : insertedLeadList){
            if (l.LastName == '1'){
                // lead should convert with Contact with LastName '1'
                Assert.isTrue(l.isConverted, 'The lead was not converted properly');
                Assert.areEqual(l.ConvertedContactId, contactMap.get('1').Id, 'Lead not converted to correct contact');

            } else if (l.LastName == '2'){
                // Lead's email matches email of multiple contacts, so shouldn't convert
                Assert.isFalse(l.IsConverted, 'The lead should not have been converted');

            } else if (l.LastName == '3'){
                // Lead's email matches no contacts, so shouldn't convert
                Assert.isFalse(l.IsConverted, 'The lead should not have been converted');

            } else {
                // Leads without emails shouldn't convert
                Assert.isFalse(l.isConverted, 'A lead must have an email address to auto convert');
            }
        */
        
    @isTest
    static void testAutoConvertLeads_Insert() {
        
        // retrieve Test Contacts from DataFactory
        Map<String, Contact> contactMap = TestDataFactory.createTestContacts();
        // retrieve Test Leads from DataFactory
        List<Lead> leadList = TestDataFactory.leadTestDataUpdate();

        Test.startTest();
        insert leadList;
        Test.stopTest();


        // verify that it worked
        //query the inserted leads
        List<Lead> insertedLeads = new List<Lead> ([ SELECT Id, LastName, Email, isConverted, ConvertedContactId FROM Lead]);

        //loop through insertedLeads
        for (Lead l : insertedLeads) {

            //confirms lead is marked as Converted and it's converted to the correct Contact record
            if (l.lastName = 'Lead1') {
                Assert.isTrue(l.IsConverted, 'Lead was NOT converted');
                Assert.areEqual(l.ConvertedContactId, contactMap.get('Lead1').Id, 'Lead was NOT converted to the right Contact');
            }    
            else if (l.LastName = 'Lead2') {
                Assert.isFalse(l.IsConverted, 'Lead should NOT have been converted');
            }
            else if (l.LastName = 'Lead3') {
                Assert.isFalse(l.IsConverted, 'Lead should NOT have been converted');
            }    
            else {
                Assert.isFalse(l.IsConverted, 'Leads MUST have an email to convert');
            }
        }
    }           
}  