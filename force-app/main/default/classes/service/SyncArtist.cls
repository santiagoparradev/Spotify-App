public class SyncArtist {

    @TestVisible
    private static Database.SaveResult errorEventResult;
    public static void syncArtist(List<ClientCredential__c> credentials) {
        
        try {
            Map<String, Artist__c> recordsToUpsertArtistsMap = new Map<String, Artist__c>();

            for (ClientCredential__c cred : credentials) {

                HttpResponse token = SpotifyApiHttpClient.getToken(
                    cred.ClientId__c,
                    cred.ClientSecret__c
                );

                if (token.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
                continue;

                List<SimplefieldArtistObject> artists = getArtistsList(
                    TokenResponse.parse(token.getBody()).access_token,
                    cred.SpotifyUserId__c);

                for (SimplefieldArtistObject artist : artists) {

                    if (!recordsToUpsertArtistsMap.containsKey(artist.id)) {

                        Artist__c artistRecord = new Artist__c(
                            url__c = artist.external_urls?.spotify,
                            Followers__c = artist.followers?.total,
                            //Genres__c = String.join(artist.genres, ';'),
                            SpotifyId__c = artist.id,
                            Name = artist.name,
                            Popularity__c = artist.popularity
                        );

                        recordsToUpsertArtistsMap.put(artist.id, artistRecord);
                    }
                }
            }

            if (!recordsToUpsertArtistsMap.isEmpty()) {
                upsert recordsToUpsertArtistsMap.values() SpotifyId__c;
            }

        } catch (Exception error) {
            Spotify_Request_Log__e errorEvent = new Spotify_Request_Log__e(
                ApexError__c = error.getMessage()
            );  
            errorEventResult = EventBus.publish(errorEvent);     
        }
    }

    private static List<SimplefieldArtistObject> getArtistsList(String token, String spotifyUserId) {

        List<String> artistIds = getArtistIds(token, spotifyUserId);
        Set<String> artistsToProcess = new Set<String>();
        List<SimplefieldArtistObject> result = new List<SimplefieldArtistObject>();

        for (Integer i = 0; i < artistIds.size(); i ++) {

            artistsToProcess.add(artistIds[i]);

            if (artistsToProcess.size() == SpotifyApiHttpClient.MAXIMUM_ARTIST_REQUEST_SIZE || artistIds.size() == i + 1) {

                HttpResponse response = SpotifyApiHttpClient.getArtist(token, artistsToProcess);

                if (response.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
                continue;

                result.addAll(ArtistResponse.parse(response.getBody()).artists);
                artistsToProcess.clear();
            }
        }

        return result;
    }

    private static List<String> getArtistIds(String token, String spotifyUserId) {

        PlaylistResponse playlists;
        Integer cont = 0;
        List<String> result = new List<String>();

        do {

            HttpResponse playlistsRes = SpotifyApiHttpClient.getPlaylist(token, spotifyUserId, cont);

            if (playlistsRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
            continue;

            playlists = PlaylistResponse.parse(playlistsRes.getBody());

            for (SimplefiedPlaylistObject playlist : playlists.items) {
                //cambiar nombre .getplaylisTracks
                HttpResponse trackRes = SpotifyApiHttpClient.getPlaylistTracks(token, playlist.id);
                
                if (trackRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
                continue;

                TrackResponse tracks = TrackResponse.parse(trackRes.getBody());
                                result.addAll(tracks.getArtistIds());
            }
            cont += playlists.items.size();

        } while (cont < playlists.total);

        return result;
    }
}