public class SyncTrack {

    public static void syncTrack(List<ClientCredential__c> credentials) {
         
        Map<String, Track__c> recordsToUpsertTracksMap = new Map<String, Track__c>();

        for (ClientCredential__c cred : credentials) {

            HttpResponse token = SpotifyApiHttpClient.getToken(
                cred.ClientId__c,
                cred.ClientSecret__c
            );

            if (token.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
            continue;

            HttpResponse tracksRes = getTracksResponse(token, cred);

            if (tracksRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
            continue;

            TrackResponse tracksResult = TrackResponse.parse(tracksRes.getBody());

            for (ItemTrack item : tracksResult.items) {

                SimplefieldTracksObject track = item.track;

                if (!recordsToUpsertTracksMap.containsKey(track.id)) {

                    Track__c trackRecord = new Track__c(
                        //Markets__c = String.join(track.available_markets, ';'),
                        Album__r = new Album__c(SpotifyId__c = track.album.id),
                        DiscNumber__c = track.disc_number,
                        DurationMs__c = track.duration_ms,
                        Explicit__c = track.explicit,
                        url__c = track.external_urls?.spotify,
                        SpotifyId__c = track.id,
                        Name = track.name,
                        Popularity__c = track.popularity
                    );

                    recordsToUpsertTracksMap.put(track.id, trackRecord);
                }
            }
        }
        
        if (!recordsToUpsertTracksMap.isEmpty()) {
            upsert recordsToUpsertTracksMap.values() SpotifyId__c;
        }
    }

    private static HttpResponse getTracksResponse(HttpResponse token, ClientCredential__c cred) {

        HttpResponse trackRes;
        PlaylistResponse playlists;
        Integer cont = 0;
        TokenResponse tokenRes = TokenResponse.parse(token.getBody());
        
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

                trackRes = SpotifyApiHttpClient.getTrack(
                    tokenRes.access_token,
                    playlist.id
                );
            }
            cont += playlists.items.size();

        } while (cont < playlists.total);
        
        return trackRes;
    }
}