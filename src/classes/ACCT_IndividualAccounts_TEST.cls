/*
    Copyright (c) 2011, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2011 (1.x)
* @group Accounts
* @group-content ../../ApexDocContent/Accounts.htm
* @description Tests for ACCT_IndividualAccounts_TDTM.
*/
@isTest
private class ACCT_IndividualAccounts_TEST {

    /*********************************************************************************************************
    * @description Create a Contact with TDTM triggers off
    */
    @isTest
    public static void insertContactTriggerOff() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID()));

        // turn off all TDTM triggers for this component
        ACCT_IndividualAccounts_TDTM.turnOff();

        Contact con = new Contact(
            FirstName='Test',
            LastName='Contact_forTests',
            WorkEmail__c = 'junk@test.net',
            Preferred_Email__c = 'Work',
            WorkPhone__c = '206-777-8888',
            PreferredPhone__c = 'Work'
        );
        Test.startTest();
        insert con;
        Test.stopTest();

        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:con.id];

        //contact should have no AccountId
        system.assertEquals(null,insertedContacts[0].AccountId);
    }

    /*********************************************************************************************************
    * @description Test Method for a new Contact
    */
    @isTest
    public static void newContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID()));

        Contact con = UTIL_UnitTestData_TEST.getContact();

        Test.startTest();
        insert con;
        Test.stopTest();

        Contact insertedContact = [Select Account.Name, AccountId from Contact where id=:con.id];

        //the contact should have the right type
        system.assertEquals(con.LastName + ' ' + Label.DefaultAdminName, insertedcontact.Account.Name);
    }

    /*********************************************************************************************************
    * @description Test Method for inserting and updating a Contact
    */
    @isTest
    public static void insertUpdateContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID()));

        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName='Test',
            LastName='Contact_forTests',
            MailingStreet = newContactMailingStreet,
            WorkEmail__c = 'junk@test.net',
            Preferred_Email__c = 'Work',
            WorkPhone__c = '206-777-8888',
            PreferredPhone__c = 'Work'
        );
        insert con;

        Contact[] insertedContacts = [Select FirstName, LastName, AccountId, Account.Name,Account.Primary_Contact__c,MailingStreet,
        				Account.BillingStreet from Contact where id=:con.id];

        //one contact should have been created
        system.assertEquals(1,insertedContacts.size());

        //relationship should be bi-directional
        system.assertEquals(insertedcontacts[0].id,insertedcontacts[0].Account.Primary_Contact__c);

        String updatedContactLastName = 'Contact_forTestsChange';
        String updatedOtherCity = 'Seattle';
        con.LastName=updatedContactLastName;
        con.OtherCity = updatedOtherCity;
        con.AccountId = insertedContacts[0].AccountId;
        update con;

        Contact[] updatedContacts = [Select FirstName, LastName, AccountId, Account.Name,Account.Primary_Contact__c
                                     from Contact where id=:con.id];

        //relationship should be bi-directional
        system.assertEquals(updatedContacts[0].id,updatedContacts[0].Account.Primary_Contact__c);
    }

    /*********************************************************************************************************
    * @description Add a contact to an existing Account
    */
    @isTest
    public static void contactAddedToExistingAcc() {
       UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID()));

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
        insert mappings;

        Contact con = new Contact(
            FirstName='Test',
            LastName='Contact_forTests',
            WorkEmail__c = 'junk@test.net',
            Preferred_Email__c = 'Work',
            WorkPhone__c = '206-777-8888',
            PreferredPhone__c = 'Work'
        );
        insert con;

        con = [select AccountId from Contact where id=:con.id];
        Id accountId = con.AccountId;

        Contact con2 = new Contact(FirstName='John', LastName='Smith', AccountId = accountId);

        Test.startTest();
        AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
        insert con2;
        Test.stopTest();

        con2 = [select AccountId, Primary_Household__c from Contact where id=:con2.id];
        system.assertEquals(accountId, con2.AccountId);

        //system.assertEquals(accountId, con2.Primary_Household__c); In this case the field is not populated because we are dealing with Administrative accounts.
    }

    /*********************************************************************************************************
    * @description Update a contact to an existing Account
    */
    @isTest
    public static void contactUpdatedToExistingAcc() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID()));

        Contact con = new Contact(
            FirstName='Test',
            LastName='Contact_forTests',
            WorkEmail__c = 'junk@test.net',
            Preferred_Email__c = 'Work',
            WorkPhone__c = '206-777-8888',
            PreferredPhone__c = 'Work'
        );
        insert con;

        Contact[] insertedContacts = [Select Account.Name, AccountId from Contact where id=:con.id];
        Id accountId = insertedContacts[0].AccountId;

        Contact con2 = new Contact(FirstName='John', LastName='Smith',AccountId=null);
        insert con2;

        // now update the contact to the existing account from contact 1
        con2.AccountId = accountId;
        update con2;

        Contact[] insertedContact = [Select Account.Name,AccountId from Contact where id=:con2.id];

        system.assertEquals(accountId,insertedContact[0].AccountId);
    }

    /*********************************************************************************************************
    * @description Update a contact's Lastname in the Account
    */
    @isTest
    public static void contactInNormalOrgNameChangem() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID()));

        String acctName = 'Test Account 876';
        Account acct = new Account(Name=acctName);
        insert acct;

        Contact con = new Contact(
            FirstName='Test',
            LastName='Contact_forTests',
            AccountId = acct.id,
            WorkEmail__c = 'junk@test.net',
            Preferred_Email__c = 'Work',
            WorkPhone__c = '206-777-8888',
            PreferredPhone__c = 'Work'
        );
        insert con;

        Contact[] insertedContacts = [Select Account.Name, AccountId from Contact where id=:con.id];

        //the contact should be connected to the account
        system.assertEquals(acct.id,insertedContacts[0].AccountId);
        system.assertEquals(acctName,insertedContacts[0].Account.Name);

        Contact con2 = new Contact(id=con.id, LastName='Smith');
        update con2;

        Contact[] updatedContacts = [Select Account.Name, AccountId from Contact where id=:con.id];
        system.assertEquals(acctName,updatedContacts[0].Account.Name);
    }

    /*********************************************************************************************************
    * @description Test Method for detaching a Contact from an org account. It should land in Administrative account.
    */
    @isTest
    public static void detachFromNormalAccountToAdministrative() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID()));

        Account acct = new Account(Name='Test Account 876');
        insert acct;

        Contact con = new Contact(
            FirstName='Test',
            LastName='Contact_forTests',
            AccountId = acct.id,
            WorkEmail__c = 'junk@test.net',
            Preferred_Email__c = 'Work',
            WorkPhone__c = '206-777-8888',
            PreferredPhone__c = 'Work'
        );
        insert con;

        Contact[] insertedContacts = [Select Account.Name, AccountId from Contact where id=:con.id];
        //the contact should be connected to the account
        system.assertEquals(acct.id,insertedContacts[0].AccountId);

        con.AccountId = null;
        Test.startTest();
        update con;
        Test.stopTest();

        Contact[] updatedContacts = [Select Account.Name,AccountId from Contact where id=:con.id];

        //the account should not be the one we started with
        system.assertNotEquals(acct.id,updatedContacts[0].AccountId);
    }

    /*********************************************************************************************************
    * @description Delete a Contact and verify its parent Account is deleted.
    */
     @isTest
     public static void deleteContactNoOpps() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
                    Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(),
                    Accounts_to_Delete__c = UTIL_Describe.getAdminAccRecTypeID()));

        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName='Test',
            LastName='Contact_forTests',
            MailingStreet = newContactMailingStreet,
            WorkEmail__c = 'junk@test.net',
            Preferred_Email__c = 'Work',
            WorkPhone__c = '206-777-8888',
            PreferredPhone__c = 'Work'
        );
        insert con;
        Id contactId;
        contactId = con.id;

        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:contactId];
        Id createdAccountId = insertedContacts[0].AccountId;

        Test.startTest();
        delete con;
        Test.stopTest();

        insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:contactId];
        system.assertEquals(0,insertedContacts.size());

        Account[] missingAccount = [select id from Account where id=:createdAccountId];
        system.assertEquals(0,missingAccount.size());
    }

    /*********************************************************************************************************
    * @description Delete a Contact with Opps and verify its parent Account is not deleted.
    */
    @isTest
    public static void deleteContactWithOppAdm() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
                                    Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(),
                                    Accounts_to_Delete__c = UTIL_Describe.getAdminAccRecTypeID()));

        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName='Test',
            LastName='Contact_forTests',
            MailingStreet = newContactMailingStreet,
            WorkEmail__c = 'junk@test.net',
            Preferred_Email__c = 'Work',
            WorkPhone__c = '206-777-8888',
            PreferredPhone__c = 'Work'
        );
        insert con;
        Id contactId;
        contactId = con.id;
        Id accountId;
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:contactId];

        Id createdAccountId = insertedContacts[0].AccountId;

       Opportunity opp = new Opportunity(
            Amount=500,
            AccountId=createdAccountId,
            Name='test',
            StageName='Closed/Won',
            CloseDate=System.today()
        );
        insert opp;

        Test.startTest();
        delete con;
        Test.stopTest();

        Account[] missingAccount = [select id from Account where id=:createdAccountId];
        system.assertEquals(1,missingAccount.size());
    }

    /*********************************************************************************************************
    * @description Specify only admin accounts with all child contacts deleted will be automatically deleted,
    * and delete a Contact from an Account without type. Make sure the Account is not deleted.
    */
    @isTest
    public static void deleteContactNormalAccount() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
                                    Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(),
                                    Accounts_to_Delete__c = UTIL_Describe.getAdminAccRecTypeID()));

        Account orgAccount = new Account(Name='Fake account', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        insert orgAccount;

        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName='Test',
            LastName='Contact_forTests',
            MailingStreet = newContactMailingStreet,
            AccountId = orgAccount.id,
            WorkEmail__c = 'junk@test.net',
            Preferred_Email__c = 'Work',
            WorkPhone__c = '206-777-8888',
            PreferredPhone__c = 'Work'
        );
        insert con;

        Contact[] insertedContacts = [Select FirstName, LastName, AccountId from Contact where id=:con.id];
        Id createdAccountId = insertedContacts[0].AccountId;

        Test.startTest();
        delete con;
        Test.stopTest();

        Account[] missingAccount = [select id from Account where id=:createdAccountId];
        system.assertEquals(1, missingAccount.size());
    }

    /*********************************************************************************************************
    * @description Rename a Contact's firstname to null and make sure the Account's name doesn't change.
    */
    @isTest
    public static void firstNameToNullAdm() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID()));

        Contact con = new Contact(
            FirstName='Test',
            LastName='Contact_forTests',
            WorkEmail__c = 'junk@test.net',
            Preferred_Email__c = 'Work',
            WorkPhone__c = '206-777-8888',
            PreferredPhone__c = 'Work'
        );
        insert con;

        con = [select AccountId from Contact where id = :con.Id];
        Account newAcc = [select id,Name from Account where id = :con.AccountId limit 1];

        system.assertEquals(newAcc.Name, 'Contact_forTests' + ' ' + Label.DefaultAdminName);

        //set name to null
        con.FirstName = null;

        Test.startTest();
        update con;
        Test.stopTest();

        newAcc = [select id,Name from Account where id = :con.AccountId limit 1];
        system.assertEquals(newAcc.Name, 'Contact_forTests' + ' ' + Label.DefaultAdminName);
    }
}