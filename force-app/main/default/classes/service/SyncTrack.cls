public class SyncTrack {

    @TestVisible
    private static Database.SaveResult errorEventResult;
    public static void syncTrack(List<ClientCredential__c> credentials) {

        try {
            Map<String, Track__c> recordsToUpsertTracksMap = new Map<String, Track__c>();
            List<TrackArtist__c> trackArtistList = new List<TrackArtist__c>();

            for (ClientCredential__c cred : credentials) {

                HttpResponse token = SpotifyApiHttpClient.getToken(
                    cred.ClientId__c,
                    cred.ClientSecret__c
                );

                if (token.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
                continue;

                List<SimplefieldTracksObject> tracks = getTracksList(
                    TokenResponse.parse(token.getBody()).access_token,
                    cred.SpotifyUserId__c);

                for (SimplefieldTracksObject track : tracks) {

                    trackArtistList.addAll(track.getTrackArtist());

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

            if (!trackArtistList.isEmpty()) {
                insert trackArtistList;
            }

        } catch (Exception error) {
            Spotify_Request_Log__e errorEvent = new Spotify_Request_Log__e(
                ApexError__c = error.getMessage()
            );
            errorEventResult = EventBus.publish(errorEvent);
        }
    }

    private static List<SimplefieldTracksObject> getTracksList(String token, String spotifyUserId) {

        List<SimplefieldTracksObject> result = new List<SimplefieldTracksObject>();
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

                HttpResponse trackRes = SpotifyApiHttpClient.getTrack(token, playlist.id);

                if (trackRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
                continue;

                TrackResponse tracks = TrackResponse.parse(trackRes.getBody());
                result.addAll(tracks.getTracks());
            }

            cont += playlists.items.size();

        } while (cont < playlists.total);

        return result;
    }
}