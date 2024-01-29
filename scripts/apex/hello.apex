// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
List<ClientCredential__c> listName1 = [SELECT ClientId__c, ClientSecret__c, SpotifyUserId__c FROM ClientCredential__c];
SyncAlbum.syncAlbum(listName1);
List<ClientCredential__c> listName2 = [SELECT ClientId__c, ClientSecret__c, SpotifyUserId__c FROM ClientCredential__c];
SyncPlaylist.syncPlaylist(listName2);
List<ClientCredential__c> listName3 = [SELECT ClientId__c, ClientSecret__c, SpotifyUserId__c FROM ClientCredential__c];
SyncTrack.syncTrack(listName3);
List<ClientCredential__c> listName = [SELECT ClientId__c, ClientSecret__c, SpotifyUserId__c FROM ClientCredential__c];
SyncArtist.syncArtist(listName);

trackPreviewController.findTrackPreviewUrl('7ovUcF5uHTBRzUpB6ZOmvt');


Spotify_Request_Log__e errorEvent = new Spotify_Request_Log__e(
                ApexError__c = 'adssad'
		    );  
            Database.SaveResult errorEventResult = EventBus.publish(errorEvent);
            System.debug(errorEvent);
SELECT Name, Position, Retries, LastError, Type
FROM EventBusSubscriber 
WHERE Topic='Spotify_Request_Log__e' 
