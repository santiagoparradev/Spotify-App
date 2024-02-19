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

                List<SimplefieldAlbumsObject> albums = getAlbumsList(
                    TokenResponse.parse(token.getBody()).access_token,
                    cred.SpotifyUserId__c);

                for (SimplefieldAlbumsObject album : albums) {

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

    private static List<SimplefieldAlbumsObject> getAlbumsList(String token, String spotifyUserId) {

        List<String> albumIds = getAlbumIds(token, spotifyUserId);
        Set<String> albumsToProcess = new Set<String>();
        List<SimplefieldAlbumsObject> result = new List<SimplefieldAlbumsObject>();

        for (Integer i = 0; i < albumIds.size(); i ++) {

            albumsToProcess.add(albumIds[i]);

            if (albumsToProcess.size() == SpotifyApiHttpClient.MAXIMUM_ALBUM_REQUEST_SIZE || albumIds.size() == i + 1) {

                HttpResponse response = SpotifyApiHttpClient.getAlbum(token, albumsToProcess);

                if (response.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
                continue;

                result.addAll(AlbumResponse.parse(response.getBody()).albums);
                albumsToProcess.clear();
            }
        }

        return result;
    }

    private static List<String> getAlbumIds(String token, String spotifyUserId) {

        List<String> result = new List<String>();
        PlaylistResponse playlists;
        Integer cont = 0;

        do {

            HttpResponse playlistsRes = SpotifyApiHttpClient.getPlaylist(
                token,
                spotifyUserId,
                cont 
            );

            if (playlistsRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE) 
            continue;

            playlists = PlaylistResponse.parse(playlistsRes.getBody());

            for (SimplefiedPlaylistObject playlist : playlists.items) {

                HttpResponse trackRes = SpotifyApiHttpClient.getTrack(
                    token,
                    playlist.id
                );

                if (trackRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE) 
                continue;

                TrackResponse tracks = TrackResponse.parse(trackRes.getBody());
                result.addAll(tracks.getAlbumIds());
            }
            cont += playlists.items.size();

        } while (cont < playlists.total);

        return result;
    }
}