@IsTest
private class SyncPlaylistsTest {

    @IsTest
    static void SyncPlaylistsTest() {
        // prepare data
        Test.setMock(HttpCalloutMock.class, new TokenMock());
        List<ClientCredential__c> newCredentials = new List<ClientCredential__c>{new ClientCredential__c(ClientId__c = 'ClientId__c', ClientSecret__c = 'ClientSecret__c', SpotifyUserId__c = 'SpotifyUserId__c')};

        insert newCredentials;
        // test
        Test.startTest();
        PlaylistBatch creds = new PlaylistBatch();
        DataBase.executeBatch(creds);
        Test.stopTest();
        //assert
        List<Playlist__c> playlist = [SELECT Name FROM Playlist__c WHERE Name = 'name'];
        Assert.areEqual(playlist.size(), 2, 'is should add two playlist');
    }

    private class TokenMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) {

            HttpResponse response = new HttpResponse();
            response.setStatusCode(SyncPlaylists.SUCCESS_STATUS_CODE);
            response.setHeader('Content-Type', 'application/json');

            if(request.getEndpoint().contains(SyncPlaylists.TOKEN_ENDPOINT)) {
                TokenResponse token = new TokenResponse();
                token.access_token = '1111';
                response.setBody(JSON.serialize(token));  
            } else if(request.getEndpoint().contains('playlist')) {
                List<SimplefiedPlaylistObject> playlistList = new List<SimplefiedPlaylistObject>();
                SimplefiedPlaylistObject playlist = new SimplefiedPlaylistObject();
                playlistList.add(playlist);
                playlist.Name = 'name';
                playlist.description = 'description';
                playlist.publicField = true;
                String playlistId = request.getEndpoint().substringAfter('offset=');               
                playlist.id = playlistId;

                PlaylistResponse playlistRes = new PlaylistResponse();
                playlistRes.total = 2;
                playlistRes.items = playlistList;
                response.setBody(JSON.serialize(playlistRes));
            }

            return response;
        }
    }
}