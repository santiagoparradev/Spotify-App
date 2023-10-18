public class PlaylistImagesController {

    public static String TOKEN_ENDPOINT = 'https://accounts.spotify.com/api/token';
    private static String PLAYLIST_ENDPOINT = 'https://api.spotify.com/v1/playlists/';
    public static Integer SUCCESS_STATUS_CODE = 200;

    @AuraEnabled(cacheable=true)
    public static String obtenerDatos(String spotifyPlaylistId) {
        
        try {  
            String resultUrl;
            ClientCredential__c credentials = [SELECT ClientId__c, ClientSecret__c, SpotifyUserId__c 
                                                FROM ClientCredential__c 
                                                WHERE Name = 'nicolas'];
            Http http = new Http();
            HttpRequest tokenRequest = new HttpRequest();
            tokenRequest.setEndpoint(TOKEN_ENDPOINT);
            tokenRequest.setMethod('POST');
            tokenRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String payload = 'grant_type=client_credentials'
                + '&client_id=' + credentials.ClientId__c
                + '&client_secret=' + credentials.ClientSecret__c; 
            tokenRequest.setBody(payload);
            HttpResponse response = http.send(tokenRequest);
            
            if(response.getStatusCode() == SUCCESS_STATUS_CODE) {
                TokenResponse tokenResult = TokenResponse.parse(response.getBody());
                HttpRequest playlistRequest = new HttpRequest();
                playlistRequest.setEndpoint(PLAYLIST_ENDPOINT + spotifyPlaylistId);
                playlistRequest.setMethod('GET');
                playlistRequest.setHeader('Authorization', 'Bearer ' + tokenResult.access_token);	
                HttpResponse playlistRes = http.send(playlistRequest);

                if(playlistRes.getStatusCode() == SUCCESS_STATUS_CODE) {            
                    PlaylistResponse playlistResult = PlaylistResponse.parse(playlistRes.getBody());
                    String urlImage = playlistResult.images[0].url;
                    resultUrl = urlImage;
                }
            }

            return resultUrl;
                 
        } catch (Exception error) {
            throw new AuraHandledException('COULD NOT GET URL: ' + error.getMessage());
        }   
    } 
}
