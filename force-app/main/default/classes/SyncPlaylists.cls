public class SyncPlaylists {
    
    public static void syncPlaylist(List<ClientCredential__c> credentials) {

        List<Playlist__c> forInsert = new List<Playlist__c>();
        for (ClientCredential__c cred : credentials) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://accounts.spotify.com/api/token');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String payload = 'grant_type=client_credentials'
                + '&client_id=' + cred.ClientId__c 
                + '&client_secret=' + cred.ClientSecret__c; 
            request.setBody(payload);
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() == 200) {

                TokenResponse tokenResult = TokenResponse.parse(response.getBody());
            	HttpRequest playlist = new HttpRequest();
                playlist.setEndpoint('https://api.spotify.com/v1/users/' + cred.SpotifyUserId__c + '/playlists');
            	playlist.setMethod('GET');
            	playlist.setHeader('Authorization', 'Bearer ' + tokenResult.access_token);
                playlist.setHeader('Host', 'api.spotify.com');	
            	HttpResponse playlistRes = http.send(playlist);
                
            	if(playlistRes.getStatusCode() == 200) {
                        
                	PlaylistResponse playlistResult = PlaylistResponse.parse(playlistRes.getBody());
                    for (SimplefiedPlaylistObject singlePlaylistResponse : playlistResult.items) {
                        Playlist__c record = new Playlist__c(
                            SpotifyId__c = singlePlaylistResponse.id,
                            Name = singlePlaylistResponse.name,
                            Description__c = singlePlaylistResponse.description,
                            Collaborative__c = singlePlaylistResponse.collaborative,
                            //Public__c = singlePlaylistResponse.public,
                            //url__c = singlePlaylistResponse.external_urls,
                            followers__c = singlePlaylistResponse.followers
                        );
                        forInsert.add(record);
                    }
            	}
        	}
		}
        insert forInsert;
    }    
}