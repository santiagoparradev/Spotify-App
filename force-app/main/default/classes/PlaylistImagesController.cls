public class PlaylistImagesController {
    @AuraEnabled(cacheable=true)
    public static String obtenerDatos(String spotifyPlaylistId) {
        String resultUrl;
        ClientCredential__c credentials = [SELECT ClientId__c, ClientSecret__c, SpotifyUserId__c FROM ClientCredential__c WHERE Name = 'nicolas'];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://accounts.spotify.com/api/token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String payload = 'grant_type=client_credentials'
            + '&client_id=' + credentials.ClientId__c
            + '&client_secret=' + credentials.ClientSecret__c; 
        request.setBody(payload);
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200) {

            TokenResponse tokenResult = TokenResponse.parse(response.getBody());
            HttpRequest playlist = new HttpRequest();
            playlist.setEndpoint('https://api.spotify.com/v1/playlists/' + spotifyPlaylistId);
            playlist.setMethod('GET');
            playlist.setHeader('Authorization', 'Bearer ' + tokenResult.access_token);	
            HttpResponse playlistRes = http.send(playlist);
            if(playlistRes.getStatusCode() == 200) {
                    
                PlaylistIdResponse playlistResult = PlaylistIdResponse.parse(playlistRes.getBody());
                String urlImage = playlistResult.images[0].url;
                resultUrl = urlImage;
            }
        }
        return resultUrl;
    }  
}
