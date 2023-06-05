public class CreateTaskOnAccountHandler {
    public static void createTasks(List<Account> newAccounts) {
        List<Task> taskList = new List<Task>();
        for (Account acc : newAccounts) {
            if (!acc.Active__c) {
                Task newTask = new Task();
                newTask.Subject = 'Review Account - ' +acc.AccountNumber;
                newTask.WhatId = acc.Id;
                newTask.OwnerId = acc.OwnerId;
                newTask.Status = 'Not Started';
                newTask.ActivityDate = System.today().addDays(7);
                taskList.add(newTask);
            }
        }
        if (!taskList.isEmpty()) {
            insert taskList;
        }
    }
    public static void activateAccounts(List<Account> updatedAccounts, Map<Id, Account> oldMapAccounts) {
        List<Account> accountList = new List<Account>();
        for (Account acc : updatedAccounts) {
            Account oldAcc = oldMapAccounts.get(acc.Id);
            if (oldAcc.Active__c == false && acc.Active__c == true) {
                accountList.add(acc);
            }
        }
        if (!accountList.isEmpty()) {
            List<Task> completedTasks = new List<Task>();
            for (Account acc : accountList) {
                if (acc.OwnerId != null && acc.OwnerId.getSObjectType() == User.SObjectType) {
                    User owner = (User)acc.OwnerId.getSObjectType().newSObject(acc.OwnerId);
                    if (owner.ProfileId != null && owner.ProfileId.getSObjectType() == Profile.SObjectType) {
                        Profile profile = (Profile)owner.ProfileId.getSObjectType().newSObject(owner.ProfileId);
                        if (profile.Name == 'CQ Account Admin') {
                            Task relatedTask = [SELECT Id, Description FROM Task WHERE WhatId = :acc.Id AND Status = 'Not Started' LIMIT 1];
                            if (relatedTask != null) {
                                relatedTask.Status = 'Completed';
                                relatedTask.Description = relatedTask.Description;
                                completedTasks.add(relatedTask);
                            }
                        }
                    }
                }
            }
            if (!completedTasks.isEmpty()) {
                update completedTasks;
            }
        }
    }
}