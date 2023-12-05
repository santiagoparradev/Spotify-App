public class SyncAlbum {

    public static void syncAlbum(List<ClientCredential__c> credentials) {

        Map<String, Album__c> recordsToUpsertAlbumsMap = new Map<String, Album__c>();
        Map<String, Track__c> recordsToUpsertTracksMap = new Map<String, Track__c>();
        
        for (ClientCredential__c cred : credentials) {

            HttpResponse token = SpotifyApiHttpClient.getToken(
                cred.ClientId__c , 
                cred.ClientSecret__c
            );

            if (token.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE) 
            continue;
            
            PlaylistResponse playlistResult;
            Integer cont = 0;
            TokenResponse tokenResult = TokenResponse.parse(token.getBody());
            Set<String>  albumIds = new Set<String>();
            do {

                HttpResponse playlist = SpotifyApiHttpClient.getPlaylist(
                    tokenResult.access_token, 
                    cred.SpotifyUserId__c, 
                    cont 
                );

                if (playlist.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE) 
                continue;

                playlistResult = PlaylistResponse.parse(playlist.getBody());

                for (SimplefiedPlaylistObject singlePlaylistResponse : playlistResult.items) {

                    HttpResponse trackRes = SpotifyApiHttpClient.getTrack(
                        tokenResult.access_token,
                        singlePlaylistResponse.id
                    );

                    if (trackRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE) 
                    continue;
                    
                    TrackResponse tracksResult = TrackResponse.parse(trackRes.getBody());

                    for (ItemTrack item : tracksResult.items) {
                        SimplefieldTracksObject track = item.track;

                        if (recordsToUpsertTracksMap.containsKey(track.id)) continue;

                        albumIds.add(track.album.id);  
                    }  
                }
                cont += playlistResult.items.size();
                
            } while (cont < playlistResult.total);
            
            HttpResponse albumsRes = SpotifyApiHttpClient.getAlbum( 
                tokenResult.access_token, 
                albumIds
            );

            if (albumsRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE) 
            continue;
                
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
        
        if (!recordsToUpsertAlbumsMap.isEmpty()) {
            upsert recordsToUpsertAlbumsMap.values() SpotifyId__c;
        }
    }
}