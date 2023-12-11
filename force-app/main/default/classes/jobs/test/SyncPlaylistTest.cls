@IsTest
private class SyncPlaylistTest {

    @IsTest
    static void SyncPlaylistTest() {
        // prepare data
        Test.setMock(HttpCalloutMock.class, new Mock());
        List<ClientCredential__c> newCredentials = new List<ClientCredential__c>{
            new ClientCredential__c(
                ClientId__c = 'ClientId__c', 
                ClientSecret__c = 'ClientSecret__c', 
                SpotifyUserId__c = 'SpotifyUserId__c',
                User__c = UserInfo.getUserId()
            )
        };

        insert newCredentials;
        // test
        Test.startTest();
        PlaylistBatch creds = new PlaylistBatch();
        DataBase.executeBatch(creds);
        Test.stopTest();
        //assert
        List<Playlist__c> playlist = [SELECT Name FROM Playlist__c WHERE Name = 'name'];
        Assert.areEqual(2, playlist.size(), 'is should add two playlist');
    }

    private class Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest httpRequest) {

            HttpResponse response = new HttpResponse();
            response.setStatusCode(SpotifyApiHttpClient.SUCCESS_STATUS_CODE);
            response.setHeader('Content-Type', 'application/json');
            String request = httpRequest.getEndpoint();

            if (request.contains(SpotifyApiHttpClient.BASE_TOKEN_ENDPOINT + '/token')) {
                TokenResponse token = new TokenResponse();
                token.access_token = '1111';
                response.setBody(JSON.serialize(token)); 
                 
            } else if (request.contains('playlists?limit=')) {
                List<SimplefiedPlaylistObject> playlistList = new List<SimplefiedPlaylistObject>();
                SimplefiedPlaylistObject playlist = new SimplefiedPlaylistObject();
                playlist.id = request.substringAfter('offset='); 
                playlistList.add(playlist);
                playlist.Name = 'name';
                playlist.description = 'description';
                playlist.publicField = true;
                PlaylistResponse playlistRes = new PlaylistResponse();
                playlistRes.total = 2;
                playlistRes.items = playlistList;
                response.setBody(JSON.serialize(playlistRes));
            }

            return response;
        }
    }
}