public class DeleteLastRecordsNotUpdated implements Database.Batchable<SObject>{

    public  Iterable<SObject> start(Database.BatchableContext bc) {

        List<SObject> listObjects = new List<SObject>();
        listObjects.addAll([SELECT Id FROM Track__c WHERE LastModifiedDate < LAST_MONTH]);
        listObjects.addAll([SELECT Id FROM Album__c WHERE LastModifiedDate < LAST_MONTH]);
        listObjects.addAll([SELECT Id FROM Playlist__c WHERE LastModifiedDate < LAST_MONTH]);
        listObjects.addAll([SELECT Id FROM Artist__c WHERE LastModifiedDate < LAST_MONTH]);

        return listObjects;
    }

    public void execute(Database.BatchableContext bc, List<SObject> listObjects) {
        delete listObjects;
    }

    public  void finish(Database.BatchableContext bc) {}
}