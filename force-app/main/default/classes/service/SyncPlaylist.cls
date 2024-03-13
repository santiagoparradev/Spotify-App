public class SyncPlaylist {

    @TestVisible
    private static Database.SaveResult errorEventResult;
    public static void syncPlaylist(List<ClientCredential__c> credentials) {

        try {
            List<Playlist__c> forInsert = new List<Playlist__c>();
            Map<String, PlaylistTrack__c> playlistTrackMap = new Map<String, PlaylistTrack__c>();

            for (ClientCredential__c cred : credentials) {

                HttpResponse token = SpotifyApiHttpClient.getToken(
                    cred.ClientId__c, 
                    cred.ClientSecret__c
                );

                if (token.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
                continue;

                TokenResponse tokenRes = TokenResponse.parse(token.getBody());
                PlaylistResponse playlists;
                Integer cont = 0;

                do {

                    HttpResponse playlistsRes = SpotifyApiHttpClient.getPlaylist(
                        tokenRes.access_token, 
                        cred.SpotifyUserId__c, 
                        cont 
                    );

                    if (playlistsRes.getStatusCode() != SpotifyApiHttpClient.SUCCESS_STATUS_CODE)
                    continue; 

                    playlists = PlaylistResponse.parse(playlistsRes.getBody()
                    .replaceAll('"public" :', '"publicField" :'));

                    for (SimplefiedPlaylistObject playlist : playlists.items) {
                        Integer duration = 0;

                        for (SimplefieldTracksObject track : getPlaylistTrack(tokenRes.access_token, playlist.id)) {

                            duration += track.duration_ms;
                            String key = track.id + playlist.id;
                            PlaylistTrack__c playlistTrackRecord = new PlaylistTrack__c(
                                PlaylistTrack__c = key,
                                Playlist__r = new Playlist__c(SpotifyId__c = playlist.id),
                                Track__r = new Track__c(SpotifyId__c = track.id));
                            playlistTrackMap.put(key, playlistTrackRecord);
                        }

                        Playlist__c record = new Playlist__c(
                            SpotifyId__c = playlist.id,
                            Name = playlist.name,
                            Description__c = playlist.description,
                            Public__c =  playlist.publicField,
                            url__c = playlist.external_urls?.spotify,
                            followers__c = playlist.followers,
                            Duration__c = duration
                        );
                        forInsert.add(record);
                    }
                    cont += playlists.items.size();

                } while (cont < playlists.total);
            }
            if (!forInsert.isEmpty()) {
                upsert forInsert SpotifyId__c;
            }

            upsert playlistTrackMap.values() PlaylistTrack__c;

        } catch (Exception error) {
            Spotify_Request_Log__e errorEvent = new Spotify_Request_Log__e(
                ApexError__c = error.getMessage()
            );
            errorEventResult = EventBus.publish(errorEvent);
        }
    }

    private static List<SimplefieldTracksObject> getPlaylistTrack(String token,String playlistId) {

        List<SimplefieldTracksObject> result = new List<SimplefieldTracksObject>();
        HttpResponse trackRes = SpotifyApiHttpClient.getPlaylistTracks(token, playlistId);

        if (trackRes.getStatusCode() == SpotifyApiHttpClient.SUCCESS_STATUS_CODE) {

            TrackResponse tracks = TrackResponse.parse(trackRes.getBody());
            result.addAll(tracks.getTracks());
        }

        return result;
    }  
}