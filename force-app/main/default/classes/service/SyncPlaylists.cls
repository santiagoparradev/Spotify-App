public class SyncPlaylists {
    
    public static String TOKEN_ENDPOINT = 'https://accounts.spotify.com/api/token';
    public static Integer SUCCESS_STATUS_CODE = 200;
    private static Integer LIMIT_PLAYLIST = 50;
    private static String PLAYLIST_ENDPOINT = 'https://api.spotify.com/v1/users/{0}/playlists?limit={1}&offset={2}';

    public static void syncPlaylist(List<ClientCredential__c> credentials) {

        List<Playlist__c> forInsert = new List<Playlist__c>();
        for (ClientCredential__c cred : credentials) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(TOKEN_ENDPOINT);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String payload = 'grant_type=client_credentials'
                + '&client_id=' + cred.ClientId__c 
                + '&client_secret=' + cred.ClientSecret__c; 
            request.setBody(payload);
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() == SUCCESS_STATUS_CODE) {

                PlaylistResponse playlistResult;
                Integer cont = 0;
                do {

                    TokenResponse tokenResult = TokenResponse.parse(response.getBody());
                    HttpRequest playlist = new HttpRequest();
                    playlist.setEndpoint(String.format(PLAYLIST_ENDPOINT, new List<Object>{cred.SpotifyUserId__c, LIMIT_PLAYLIST, cont}));
                    playlist.setMethod('GET');
                    playlist.setHeader('Authorization', 'Bearer ' + tokenResult.access_token);
                    playlist.setHeader('Host', 'api.spotify.com');
                    HttpResponse playlistRes = http.send(playlist);

                    if(playlistRes.getStatusCode() == SUCCESS_STATUS_CODE) {

                        playlistResult = PlaylistResponse.parse(playlistRes.getBody().replaceAll('"public" :', '"publicField" :'));

                        for (SimplefiedPlaylistObject singlePlaylistResponse : playlistResult.items) {
                            Playlist__c record = new Playlist__c(
                                SpotifyId__c = singlePlaylistResponse.id,
                                Name = singlePlaylistResponse.name,
                                Description__c = singlePlaylistResponse.description,
                                Public__c =  singlePlaylistResponse.publicField,
                                url__c = singlePlaylistResponse.external_urls?.spotify,
                                followers__c = singlePlaylistResponse.followers
                            );
                            forInsert.add(record);
                        }
                        cont += playlistResult.items.size();
                    }
                } while (cont < playlistResult.total);
        	}
		}
        
        upsert forInsert SpotifyId__c;
    }    
}