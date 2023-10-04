public class syncPlaylists {
    
    public static void syncPlaylist(List<ClientCredential__c> credentials) {

        for (ClientCredential__c cred : credentials) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://accounts.spotify.com/api/token');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Content-Length','119');
            request.setHeader('Host','accounts.spotify.com');
            String payload = 'grant_type=client_credentials'
                + '&client_id='+ cred.ClientId__c 
                + '&client_secret=' + cred.ClientSecret__c; 
            system.debug('esto es payload ' + payload);
            request.setBody(payload);
            HttpResponse response = http.send(request);
            System.debug(response);
            
            if(response.getStatusCode() == 200) {
                
                System.debug(response);
                // Deserialize the JSON string into collections of primitive data types.
                Map<String, Object> tokenResult = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String token = (String) tokenResult.get('access_token');
                system.debug(token);
                
            	HttpRequest playlist = new HttpRequest();
                playlist.setEndpoint('https://api.spotify.com/v1/users/'+cred.SpotifyUserId__c+'/playlists');
            	playlist.setMethod('GET');
            	playlist.setHeader('Authorization','Bearer ' + token);
                playlist.setHeader('Host','api.spotify.com');
            	HttpResponse playlistResponse = http.send(playlist);
            	System.debug(playlistResponse);
                
            	if(playlistResponse.getStatusCode() == 200) {
                        
                	Map<String, Object> InfoResult = (Map<String, Object>) JSON.deserializeUntyped(playlistResponse.getBody());
               		list<Object> InfoPlaylist = (list<Object>) InfoResult.get('items');
                    Map<String, Object> Primero = (Map<String, Object>)InfoPlaylist[0];
                    system.debug(InfoPlaylist[0]);
                    system.debug(Primero);
                    system.debug(Primero.get('name'));
                       
            	}
        	}
		}
    }    
}