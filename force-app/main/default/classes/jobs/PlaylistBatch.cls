public class PlaylistBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT ClientId__c, ClientSecret__c, SpotifyUserId__c FROM ClientCredential__c]);
    }

    public void execute(Database.BatchableContext bc, List<ClientCredential__c> BatchCred) {
        SyncPlaylists.syncPlaylist(BatchCred);
    }

    public void finish(Database.BatchableContext bc) {}
}