public class SyncAlbum {

    @TestVisible
    private static Database.SaveResult errorEventResult;
    public static void syncAlbum(List<ClientCredential__c> credentials) {

        try {
            Map<String, Album__c> recordsToUpsertAlbumsMap = new Map<String, Album__c>();
            Map<String, AlbumArtist__c> albumArtistMap = new Map<String, AlbumArtist__c>();
            Set<String> artistIds = new Set<String>();
            List<SimplefieldAlbumsObject> albums = new List<SimplefieldAlbumsObject>();
            Set<String> artisInDB = new Set<String>();

            for (ClientCredential__c cred : credentials) {

                HttpResponse token = SpotifyApiHttpClient.getToken(
                    cred.ClientId__c,
                    cred.ClientSecret__c
                );

                if (token.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
                continue;

                albums.addAll(getAlbumsList(
                    TokenResponse.parse(token.getBody()).access_token,
                    cred.SpotifyUserId__c));

                for (SimplefieldAlbumsObject album : albums) {

                    for (SimplefieldArtistObject artist : album.artists) {
                        artistIds.add(artist.id);
                    }
                }
            }

            for (Artist__c artist : [SELECT SpotifyId__c FROM Artist__c WHERE SpotifyId__c IN :artistIds]) {
                if (!artisInDB.contains(artist.SpotifyId__c)) {
                    artisInDB.add(artist.SpotifyId__c);
                }
            }

            for (SimplefieldAlbumsObject album : albums) {
                albumArtistMap.putAll(getAlbumArtist(album.artists, album.id, artisInDB));

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

            if (!recordsToUpsertAlbumsMap.isEmpty()) {
                upsert recordsToUpsertAlbumsMap.values() SpotifyId__c;
            }

            upsert albumArtistMap.values() AlbumArtist__c;

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

                HttpResponse trackRes = SpotifyApiHttpClient.getPlaylistTracks(token, playlist.id);

                if (trackRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE) 
                continue;

                TrackResponse tracks = TrackResponse.parse(trackRes.getBody());
                result.addAll(tracks.getAlbumIds());
            }
            cont += playlists.items.size();

        } while (cont < playlists.total);

        return result;
    }

    private static Map<String, AlbumArtist__c> getAlbumArtist(List<SimplefieldArtistObject> artists, String albumId, Set<String> artisInDB) {

        Map<String, AlbumArtist__c> result = new Map<String, AlbumArtist__c>();

        for (SimplefieldArtistObject artist : artists) {

            String key = artist.id + albumId;
            AlbumArtist__c albumArtistRecord = new AlbumArtist__c(
                AlbumArtist__c = key,
                Album__r = new Album__c(SpotifyId__c = albumId),
                Artist__r = new Artist__c(SpotifyId__c = artist.id));

            if (artisInDB.contains(artist.id)) {
                result.put(key, albumArtistRecord);
            }
        }

        return result;
    }
}