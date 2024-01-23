public class SyncAlbum {

    @TestVisible
    private static Database.SaveResult errorEventResult;
    public static void syncAlbum(List<ClientCredential__c> credentials) {

        try {
            Map<String, Album__c> recordsToUpsertAlbumsMap = new Map<String, Album__c>();

            for (ClientCredential__c cred : credentials) {

                HttpResponse token = SpotifyApiHttpClient.getToken(
                    cred.ClientId__c,
                    cred.ClientSecret__c
                );

                if (token.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
                continue;

                HttpResponse albumsRes = getAlbumsResponse(token, cred);

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
        } catch (Exception error) {
            Spotify_Request_Log__e errorEvent = new Spotify_Request_Log__e(
                ApexError__c = error.getMessage()
            ); 
            errorEventResult = EventBus.publish(errorEvent);
        } 
    }

    private static HttpResponse getAlbumsResponse(HttpResponse token, ClientCredential__c cred) {

        PlaylistResponse playlists;
        Integer cont = 0;
        TokenResponse tokenRes = TokenResponse.parse(token.getBody());
        Set<String>  albumIds = new Set<String>();
        
        do {

            HttpResponse playlistsRes = SpotifyApiHttpClient.getPlaylist(
                tokenRes.access_token,
                cred.SpotifyUserId__c,
                cont 
            );

            if (playlistsRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE) 
            continue;

            playlists = PlaylistResponse.parse(playlistsRes.getBody());

            for (SimplefiedPlaylistObject playlist : playlists.items) {

                HttpResponse trackRes = SpotifyApiHttpClient.getTrack(
                    tokenRes.access_token,
                    playlist.id
                );

                if (trackRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE) 
                continue;
                
                TrackResponse tracks = TrackResponse.parse(trackRes.getBody());

                for (ItemTrack item : tracks.items) {
                    albumIds.add(item.track.album.id);
                }
            }
            cont += playlists.items.size();

        } while (cont < playlists.total);

        return SpotifyApiHttpClient.getAlbum(tokenRes.access_token, albumIds);
    }
}