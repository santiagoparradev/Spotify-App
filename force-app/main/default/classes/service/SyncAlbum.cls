public class SyncAlbum {

    public static void syncAlbum(List<ClientCredential__c> credentials) {

        Map<String, Album__c> recordsToUpsertAlbumsMap = new Map<String, Album__c>();
        Map<String, Track__c> recordsToUpsertTracksMap = new Map<String, Track__c>();
        
        for (ClientCredential__c cred : credentials) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(SpotifyApiStuff.TOKEN_ENDPOINT);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String payload = 'grant_type=client_credentials'
                + '&client_id=' + cred.ClientId__c 
                + '&client_secret=' + cred.ClientSecret__c; 
            request.setBody(payload);
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() != SpotifyApiStuff.SUCCESS_STATUS_CODE) continue;
            
            PlaylistResponse playlistResult;
            Integer cont = 0;
            TokenResponse tokenResult = TokenResponse.parse(response.getBody());
            Set<String>  albumIds = new Set<String>();
            do {

                HttpRequest playlist = new HttpRequest();
                playlist.setEndpoint(String.format(SpotifyApiStuff.PLAYLIST_ENDPOINT, new List<Object>{cred.SpotifyUserId__c, SpotifyApiStuff.LIMIT_PLAYLIST, cont}));
                playlist.setMethod('GET');
                playlist.setHeader('Authorization', 'Bearer ' + tokenResult.access_token);
                playlist.setHeader('Host', 'api.spotify.com');
                HttpResponse playlistRes = http.send(playlist);

                if(playlistRes.getStatusCode() != SpotifyApiStuff.SUCCESS_STATUS_CODE) continue;

                playlistResult = PlaylistResponse.parse(playlistRes.getBody());

                for (SimplefiedPlaylistObject singlePlaylistResponse : playlistResult.items) {

                    HttpRequest tracks = new HttpRequest();
                    tracks.setEndpoint(String.format(SpotifyApiStuff.TRACK_ENDPOINT, new List<Object>{singlePlaylistResponse.id}));
                    tracks.setMethod('GET');
                    tracks.setHeader('Authorization', 'Bearer ' + tokenResult.access_token);
                    tracks.setHeader('Host', 'api.spotify.com');
                    HttpResponse tracksRes = http.send(tracks);
                    

                    if(tracksRes.getStatusCode() != SpotifyApiStuff.SUCCESS_STATUS_CODE) continue;
                    
                    TrackResponse tracksResult = TrackResponse.parse(tracksRes.getBody());

                    for (ItemTrack item : tracksResult.items) {
                        SimplefieldTracksObject track = item.track;

                        if (recordsToUpsertTracksMap.containsKey(track.id)) continue;

                        albumIds.add(track.album.id);  
                    }  
                }
                cont += playlistResult.items.size();
                
            } while (cont < playlistResult.total);
            
            HttpRequest albumRequest = new HttpRequest();
            albumRequest.setEndpoint(String.format(SpotifyApiStuff.ALBUM_ENDPOINT, new List<Object>{String.join(albumIds, ',')}));
            albumRequest.setMethod('GET');
            albumRequest.setHeader('Authorization', 'Bearer ' + tokenResult.access_token);
            albumRequest.setHeader('Host', 'api.spotify.com');
            HttpResponse albumsRes = http.send(albumRequest);

            if(albumsRes.getStatusCode() != SpotifyApiStuff.SUCCESS_STATUS_CODE) continue;
                
            AlbumResponse albumsResult = AlbumResponse.parse(albumsRes.getBody());

            for (SimplefieldAlbumsObject album : albumsResult.albums) {

                if (!recordsToUpsertAlbumsMap.containsKey(album.id)) {

                    Album__c albumRecord = new Album__c(
                        Name = album.name,
                        Genres__c = String.join(album.genres, ';'),
                        Popularity__c = album.popularity,
                        ReleaseDate__c = album.release_date,
                        SpotifyId__c = album.id,
                        url__c = album.external_urls?.spotify
                    );

                    recordsToUpsertAlbumsMap.put(album.id, albumRecord);
                }  
            }
		}
        if(recordsToUpsertAlbumsMap.isEmpty()) {
        upsert recordsToUpsertAlbumsMap.values() SpotifyId__c;
        }
    }
}