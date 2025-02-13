public class ArtistBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT
                ClientId__c,
                ClientSecret__c,
                SpotifyUserId__c
            FROM
                ClientCredential__c
            WHERE
                ClientId__c != NULL
                AND ClientSecret__c != NULL
                AND SpotifyUserId__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext bc, List<ClientCredential__c> creds) {
        SyncArtist.syncArtist(creds);
    }

    public void finish(Database.BatchableContext bc) {}
}