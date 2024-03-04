// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
List<ClientCredential__c> listName1 = [SELECT ClientId__c, ClientSecret__c, SpotifyUserId__c FROM ClientCredential__c];
SyncAlbum.syncAlbum(listName1);
List<ClientCredential__c> listName = [SELECT ClientId__c, ClientSecret__c, SpotifyUserId__c FROM ClientCredential__c];
SyncArtist.syncArtist(listName);

//System.debug(SyncArtist.getArtistIds('BQCIoohGpbaUvvP1TIGLZD0J45OjIQ7cN_3YxWZi-5BvnNbpETsDFvL-W_jZr5WWQsgiRZwRukhLOrQVHdczAuRtWk3iuiJfZJ-nn6TvIWk9mW-rLzo', '31hhirrwpiydkqjve3ryytkukkcy'));
List<ClientCredential__c> listName2 = [SELECT ClientId__c, ClientSecret__c, SpotifyUserId__c FROM ClientCredential__c];
SyncPlaylist.syncPlaylist(listName2);
List<ClientCredential__c> listName3 = [SELECT ClientId__c, ClientSecret__c, SpotifyUserId__c FROM ClientCredential__c];
SyncTrack.syncTrack(listName3);

List<AlbumArtist__c> listName = [SELECT Id FROM AlbumArtist__c];
for (AlbumArtist__c id : listName) {
    System.debug(id);
}

///////////////////////////////////////////////
List<Album__c> deletee = [SELECT Id FROM Album__c ];
delete deletee;	
///////////////////////////////////////////////////
trackPreviewController.findTrackPreviewUrl('7ovUcF5uHTBRzUpB6ZOmvt');
/////////////////////////////////////////////////

Spotify_Request_Log__e errorEvent = new Spotify_Request_Log__e(
                ApexError__c = 'adssad'
		    );  
            Database.SaveResult errorEventResult = EventBus.publish(errorEvent);
            System.debug(errorEvent);
SELECT Name, Position, Retries, LastError, Type
FROM EventBusSubscriber 
WHERE Topic='Spotify_Request_Log__e' 


/////////////////////////////////////////////////////////////////////
List<String> listaPrincipal = new List<String>{'6yOptGxZiGjAYownFPeMV7','2MNgEC6n6jPbKxNeIghkrW','4TURBwPQTJsJA4LVQiiHT7','0rxIQEIM9GkmhegoOORAJy','7vowTD5xDgYuBSEm242RAL','3127A3CU7WRzZwv5vfqMKP','2fLMujV4ewriJ7fgvvZ1yu','5iExtveqj1otLYflaFdHAe','6CX95AR2aAuJbByiQycxGA','3euL5ADirJFFXvoX9OlIfA','6TIBa4yqhBXdrcbui3TGzt','5eSuy3Rr40DI0qcPOMFgX0','3JmsMqb8TqftbCTAQXAexJ','4Wcp7Z67RyIbAYl6jmOkLL','48CT8I4ImScM4TySzxyBUP','22mBVLZToKGQ2Qc4DN6pPP','3LCFnbLjqO5qTbX23ZXaPI','6Wop7Hk2r89DysfUe0USkh','334dtoC0dImpN25UZ62DMD','5orTbWsJiKdiKYivCwZz2Y','6Wop7Hk2r89DysfUe0USkh'};
Integer maximunSize = 20;
List<List<String>> listAlbumLists = new List<List<String>>();

for (Integer i = 0; i < listaPrincipal.size(); i += maximunSize) {
    List<String> list = new List<String>();
    System.debug(listAlbumLists);
    for (Integer j = i; j < Math.min(i + maximunSize, listaPrincipal.size()); j++) {
        list.add(listaPrincipal[j]);
    }
    listAlbumLists.add(list);
}

System.debug(listAlbumLists);
/////////////////////////////////////////////////////////////////////////
Set<String> listAlbum = new Set<String>(); 
for (Integer i = 0; i < albumIds.size(); i++) { 
    listAlbum.add(albumIds[i]); 
    if (listAlbum.size() == 20 || i == albumIds.size()) { 
        albumListResponse.add(SpotifyApiHttpClient.getAlbum(tokenRes.access_token, listAlbum)); 
        listAlbum = new Set<String>() 
    } 
}
//comandd 