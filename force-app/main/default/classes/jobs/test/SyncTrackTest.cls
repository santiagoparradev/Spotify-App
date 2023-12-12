@IsTest
private class SyncTrackTest {

    @IsTest
    static void syncTrackTest() {
        // prepare data
        Test.setMock(HttpCalloutMock.class, new Mock());
        Album__c album = new Album__c(SpotifyId__c = 'albumId');

        insert album;

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
        TrackBatch creds = new TrackBatch();
        DataBase.executeBatch(creds);
        Test.stopTest();
        //assert
        List<Track__c> tracks = [SELECT Name FROM Track__c WHERE Name = 'track name'];
        Assert.areEqual(1, tracks.size(), 'is should add one track');
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
                PlaylistResponse playlistRes = new PlaylistResponse();
                playlistRes.total = 2;
                playlistRes.items = playlistList;
                response.setBody(JSON.serialize(playlistRes));

            } else if (request.contains('tracks')) {
                List<ItemTrack> itemsTracksList = new List<ItemTrack>();
                ItemTrack itemtrack = new ItemTrack();
                SimplefieldTracksObject track = new SimplefieldTracksObject();
                track.name = 'track name';
                track.id = 'trackId';
                track.explicit = true;
                itemtrack.track = track;
                SimplefieldAlbumsObject album = new SimplefieldAlbumsObject();
                album.id = 'albumId';
                track.album = album;
                itemsTracksList.add(itemtrack);
                TrackResponse tracksRes = new TrackResponse();
                tracksRes.items = itemsTracksList;
                response.setBody(JSON.serialize(tracksRes));
            }
            return response;
        }
    }
}