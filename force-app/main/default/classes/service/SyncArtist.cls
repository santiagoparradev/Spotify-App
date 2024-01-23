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

                HttpResponse artistsRes = getArtistsResponse(token, cred);

                if (artistsRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
                continue;

                ArtistResponse artistsResult = ArtistResponse.parse(artistsRes.getBody());

                for (SimplefieldArtistObject artist : artistsResult.artists) {

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

    private static HttpResponse getArtistsResponse(HttpResponse token, ClientCredential__c cred) {

        PlaylistResponse playlists;
        Integer cont = 0;
        TokenResponse tokenRes = TokenResponse.parse(token.getBody());
        Set<String>  artistIds = new Set<String>();

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
                    SimplefieldTracksObject itemTrack = item.track;

                    for (SimplefieldArtistObject artist : itemTrack.artists) {
                        artistIds.add(artist.id);
                    }
                }
            }
            cont += playlists.items.size();

        } while (cont < playlists.total);

        return SpotifyApiHttpClient.getArtist(tokenRes.access_token, artistIds);
    }
}