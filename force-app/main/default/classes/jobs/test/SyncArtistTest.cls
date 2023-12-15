@IsTest
private class SyncArtistTest {

    @IsTest
    static void syncArtistTest() {
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
        ArtistBatch creds = new ArtistBatch();
        DataBase.executeBatch(creds);
        Test.stopTest();
        //assert
        List<Artist__c> artists = [SELECT Name FROM Artist__c WHERE Name = 'artist name'];
        Assert.areEqual(1, artists.size(), 'is should add one artist');
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
                track.id = 'trackId';
                itemtrack.track = track;
                List<SimplefieldArtistObject> artistsList = new List<SimplefieldArtistObject>();
                SimplefieldArtistObject itemArtist = new SimplefieldArtistObject();
                itemArtist.id = 'artistId';
                artistsList.add(itemArtist);
                track.artists = artistsList;
                itemsTracksList.add(itemtrack);
                TrackResponse tracksRes = new TrackResponse();
                tracksRes.items = itemsTracksList;
                response.setBody(JSON.serialize(tracksRes));

            } else if (request.contains('artists')) {
                List<SimplefieldArtistObject> artistsList = new List<SimplefieldArtistObject>();
                SimplefieldArtistObject itemArtist = new SimplefieldArtistObject();
                itemArtist.name = 'artist name';
                itemArtist.id = 'artistId';
                artistsList.add(itemArtist);
                ArtistResponse artistRes = new ArtistResponse();
                artistRes.artists = artistsList;        
                response.setBody(JSON.serialize(artistRes));
            }

            return response;
        }
    }
}