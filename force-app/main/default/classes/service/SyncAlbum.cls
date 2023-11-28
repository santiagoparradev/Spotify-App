public class SyncAlbum {
    
    public static String TOKEN_ENDPOINT = 'https://accounts.spotify.com/api/token';
    public static Integer SUCCESS_STATUS_CODE = 200;
    private static Integer LIMIT_PLAYLIST = 50;
    private static String PLAYLIST_ENDPOINT = 'https://api.spotify.com/v1/users/{0}/playlists?limit={1}&offset={2}';
    private static String TRACK_ENDPOINT = 'https://api.spotify.com/v1/playlists/{0}/tracks';
    private static String ALBUM_ENDPOINT = 'https://api.spotify.com/v1/albums?ids={0}';


    public static void syncAlbum(List<ClientCredential__c> credentials) {

        List<Playlist__c> forInsert = new List<Playlist__c>();
        List<Album__c> forInsertAlbum = new List<Album__c>();
        List<Track__c> forInsertTracks = new List<Track__c>();
        Map<String, Album__c> recordsToUpsertAlbumsMap = new Map<String, Album__c>();
        Map<String, Track__c> recordsToUpsertTracksMap = new Map<String, Track__c>();
        
        for (ClientCredential__c cred : credentials) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(TOKEN_ENDPOINT);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String payload = 'grant_type=client_credentials'
                + '&client_id=' + cred.ClientId__c 
                + '&client_secret=' + cred.ClientSecret__c; 
            request.setBody(payload);
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() == SUCCESS_STATUS_CODE) {
                
                PlaylistResponse playlistResult;
                Integer cont = 0;
                TokenResponse tokenResult = TokenResponse.parse(response.getBody());
                Set<String>  albumIds = new Set<String>();
                do {

                    HttpRequest playlist = new HttpRequest();
                    playlist.setEndpoint(String.format(PLAYLIST_ENDPOINT, new List<Object>{cred.SpotifyUserId__c, LIMIT_PLAYLIST, cont}));
                    playlist.setMethod('GET');
                    playlist.setHeader('Authorization', 'Bearer ' + tokenResult.access_token);
                    playlist.setHeader('Host', 'api.spotify.com');
                    HttpResponse playlistRes = http.send(playlist);

                    if(playlistRes.getStatusCode() == SUCCESS_STATUS_CODE) {

                        playlistResult = PlaylistResponse.parse(playlistRes.getBody());

                        for (SimplefiedPlaylistObject singlePlaylistResponse : playlistResult.items) {

                            HttpRequest tracks = new HttpRequest();
                            tracks.setEndpoint(String.format(TRACK_ENDPOINT, new List<Object>{singlePlaylistResponse.id}));
                            tracks.setMethod('GET');
                            tracks.setHeader('Authorization', 'Bearer ' + tokenResult.access_token);
                            tracks.setHeader('Host', 'api.spotify.com');
                            HttpResponse tracksRes = http.send(tracks);

                            if(tracksRes.getStatusCode() == SUCCESS_STATUS_CODE) {

                                TrackResponse tracksResult = TrackResponse.parse(tracksRes.getBody());
                                
                                for (ItemsTracks item : tracksResult.items) {
                                    SimplefieldTracksObject track = item.track;

                                    if (!recordsToUpsertTracksMap.containsKey(track.id)) {
                                        albumIds.add(track.album.id);
                                    }
                                }
                            }
                        }
                        cont += playlistResult.items.size();
                    }
                } while (cont < playlistResult.total);
                
                HttpRequest albumRequest = new HttpRequest();
                albumRequest.setEndpoint(String.format(ALBUM_ENDPOINT, new List<Object>{String.join(albumIds, ',')}));
                albumRequest.setMethod('GET');
                albumRequest.setHeader('Authorization', 'Bearer ' + tokenResult.access_token);
                albumRequest.setHeader('Host', 'api.spotify.com');
                HttpResponse albumsRes = http.send(albumRequest);

                if(albumsRes.getStatusCode() == SUCCESS_STATUS_CODE) {
                    
                    AlbumResponse albumsResult = AlbumResponse.parse(albumsRes.getBody());

                    for (SimplefieldAlbumsObject item : albumsResult.albums) {

                        if (!recordsToUpsertAlbumsMap.containsKey(item.id)) {

                            Album__c albumRecord = new Album__c(
                                Name = item.name,
                                Genres__c = String.join(item.genres, ';'),
                                Popularity__c = item.popularity,
                                ReleaseDate__c = item.release_date,
                                SpotifyId__c = item.id,
                                url__c = item.external_urls?.spotify
                            );

                            recordsToUpsertAlbumsMap.put(item.id, albumRecord);
                        }  
                    }
                }
        	}
		}

        upsert recordsToUpsertAlbumsMap.values() SpotifyId__c;
    }    
}