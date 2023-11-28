@IsTest
private class SyncAlbumTest {
    @IsTest
    static void syncAlbumTest() {
        // prepare data
        Test.setMock(HttpCalloutMock.class, new TokenMock());
        List<ClientCredential__c> newCredentials = new List<ClientCredential__c>{new ClientCredential__c(ClientId__c = 'ClientId__c', ClientSecret__c = 'ClientSecret__c', SpotifyUserId__c = 'SpotifyUserId__c', User__c =	'0057i00000BMXZgAAP')};

        insert newCredentials;
        // test
        Test.startTest();
        AlbumBatch creds = new AlbumBatch();
        DataBase.executeBatch(creds);
        Test.stopTest();
        //assert
        List<Album__c> albums = [SELECT Name FROM Album__c WHERE Name = 'album name'];
        Assert.areEqual(1, albums.size(), 'is should add one album');
    }

    private class TokenMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) {

            HttpResponse response = new HttpResponse();
            response.setStatusCode(SyncAlbum.SUCCESS_STATUS_CODE);
            response.setHeader('Content-Type', 'application/json');

            if(request.getEndpoint().contains(SyncAlbum.TOKEN_ENDPOINT)) {
                TokenResponse token = new TokenResponse();
                token.access_token = '1111';
                response.setBody(JSON.serialize(token));

            } else if(request.getEndpoint().contains('playlists?limit=')) {
                List<SimplefiedPlaylistObject> playlistList = new List<SimplefiedPlaylistObject>();
                SimplefiedPlaylistObject playlist = new SimplefiedPlaylistObject();
                String playlistId = request.getEndpoint().substringAfter('offset=');               
                playlist.id = playlistId;
                playlistList.add(playlist);
                PlaylistResponse playlistRes = new PlaylistResponse();
                playlistRes.total = 2;
                playlistRes.items = playlistList;
                response.setBody(JSON.serialize(playlistRes));
                
                
            } else if(request.getEndpoint().contains('tracks')) {
                List<ItemsTracks> itemsTracksList = new List<ItemsTracks>();
                ItemsTracks itemtrack = new ItemsTracks();
                SimplefieldTracksObject track = new SimplefieldTracksObject();
                track.id = 'trackId';
                itemtrack.track = track;
                SimplefieldAlbumsObject album = new SimplefieldAlbumsObject();
                album.id = 'albumId';
                track.album = album;
                itemsTracksList.add(itemtrack);
                TrackResponse tracksRes = new TrackResponse(); 
                tracksRes.items = itemsTracksList;
                response.setBody(JSON.serialize(tracksRes));

            } else if(request.getEndpoint().contains('albums')) {
                List<SimplefieldAlbumsObject> albumstList = new List<SimplefieldAlbumsObject>();
                SimplefieldAlbumsObject albums = new SimplefieldAlbumsObject();
                list<String> genres = new list<String>();
                albums.name = 'album name';
                albums.genres = genres;
                albums.id = 'albumId';
                albumstList.add(albums);
                AlbumResponse AlbumRes = new AlbumResponse();
                AlbumRes.albums = albumstList;
                response.setBody(JSON.serialize(AlbumRes));
            }
            
            return response;
        }
    }
}