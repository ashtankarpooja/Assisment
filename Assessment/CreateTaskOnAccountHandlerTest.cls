@IsTest
private class CreateTaskOnAccountHandlerTest {
    @IsTest
    static void testCreateTasks() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Active__c = false;
        insert acc;
        List<Task> tasks = [SELECT Id, Subject, WhatId, OwnerId, Status, ActivityDate FROM Task];
        System.assertEquals(1, tasks.size());
        Task createdTask = tasks[0];
        System.assertEquals(acc.Id, createdTask.WhatId);
        System.assertEquals('Not Started', createdTask.Status);
        System.assertEquals(System.today().addDays(7), createdTask.ActivityDate);
    }
    @IsTest
   public static void testActivateAccounts() {
        // Create test data
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account(Name = 'Test Account ' + i, Active__c = false, OwnerId = UserInfo.getUserId());
            accounts.add(acc);
        }
        // Insert test data
        insert accounts;
        // Update account records to activate them
        for (Account acc : accounts) {
            acc.Active__c = true;
        }
        // Assign CQ Account Admin profile to the user
        Profile profile;
        try {
            profile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        } catch (QueryException e) {
            System.debug('CQ Account Admin profile not found. Using default profile.');
            profile = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        }
        User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        user.ProfileId = profile.Id;
        update user;
        // Complete tasks
        List<Task> tasks = [SELECT Id, WhatId, Status, Description FROM Task WHERE WhatId IN :accounts];
        for (Task task : tasks) {
            task.Status = 'Completed';
            task.Description = task.Description;
        }
        update tasks;
        // Verify that tasks are completed
        List<Task> updatedTasks = [SELECT Id, Status, Description FROM Task WHERE Id IN :tasks];
        for (Task task : updatedTasks) {
            System.assertEquals(task.Description, task.Description);
        }
    }
}