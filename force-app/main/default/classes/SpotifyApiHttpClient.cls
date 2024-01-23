public class SpotifyApiHttpClient extends HttpClient {
    
    public static Integer SUCCESS_STATUS_CODE = 200;
    public static Integer LIMIT_PLAYLIST = 50;
    public static String SPOTIFY_HTTPS = 'https://api.spotify.com/v1';
    public static String BASE_TOKEN_ENDPOINT = 'https://accounts.spotify.com/api';                                                
                                                          
    public static HttpResponse getToken(String clientId, String clientSecret) {
    	HttpResponse response = new HttpClient()
            .setEndpoint(BASE_TOKEN_ENDPOINT, '/token')
            .setMethod(HttpClient.Method.POST)
            .setHeader('Content-Type', 'application/x-www-form-urlencoded')
            .setBody(
                String.format(
                    'grant_type=client_credentials&client_id={0}&client_secret={1}',
                    new List<Object>{clientId, clientSecret}
                )
            )
            .send()
            .getResponse();

            if (response.getStatusCode() != SUCCESS_STATUS_CODE) {
                logError(response.getBody());
            }
    
            return response;
    }

    public static HttpResponse getPlaylist(String token, String SpotifyUserId, Integer cont) {
    	HttpResponse response = new HttpClient()
            .setEndpoint(
                SPOTIFY_HTTPS, 
                String.format(
                    '/users/{0}/playlists?limit={1}&offset={2}', 
                    new List<Object>{SpotifyUserId, LIMIT_PLAYLIST, cont}
                )
            )
            .setMethod(HttpClient.Method.GET)
            .setHeader('Authorization', 'Bearer ' + token)
            .setHeader('Host', 'api.spotify.com')
            .send()
            .getResponse();

            if (response.getStatusCode() != SUCCESS_STATUS_CODE) {
                logError(response.getBody());
            }
    
            return response;
    }

    public static HttpResponse getTrack(String token, String id) {
    	HttpResponse response = new HttpClient()
            .setEndpoint(
                SPOTIFY_HTTPS, 
                String.format('/playlists/{0}/tracks', new List<Object>{id})
            )
            .setMethod(HttpClient.Method.GET)
            .setHeader('Authorization', 'Bearer ' + token)
            .setHeader('Host', 'api.spotify.com')
            .send()
            .getResponse();

            if (response.getStatusCode() != SUCCESS_STATUS_CODE) {
                logError(response.getBody());
            }
    
            return response;
    }

    public static HttpResponse getAlbum(String token, Set<String> albumIds) {
    	HttpResponse response = new HttpClient()
            .setEndpoint(
                SPOTIFY_HTTPS, 
                String.format('/albums?ids={0}', new List<Object>{String.join(albumIds, ',')})
            )
            .setMethod(HttpClient.Method.GET)
            .setHeader('Authorization', 'Bearer ' + token)
            .setHeader('Host', 'api.spotify.com')
            .send()
            .getResponse();

            if (response.getStatusCode() != SUCCESS_STATUS_CODE) {
                logError(response.getBody());
            }
    
            return response;
    }

    public static HttpResponse getArtist(String token, Set<String> artistIds) {
    	HttpResponse response = new HttpClient()
            .setEndpoint(
                SPOTIFY_HTTPS, 
                String.format('/artists?ids={0}', new List<Object>{String.join(artistIds, ',')})
            )
            .setMethod(HttpClient.Method.GET)
            .setHeader('Authorization', 'Bearer ' + token)
            .setHeader('Host', 'api.spotify.com')
            .send()
            .getResponse();

        if (response.getStatusCode() != SUCCESS_STATUS_CODE) {
            logError(response.getBody());
        }

        return response;
    }

    public static HttpResponse requestBase(String endPoint, String recordSpotifyId, String token) {
    	HttpResponse response = new HttpClient()
            .setEndpoint(endPoint, recordSpotifyId)
            .setMethod(HttpClient.Method.GET)
            .setHeader('Authorization', 'Bearer ' + token)
            .setHeader('Host', 'api.spotify.com')
            .send()
            .getResponse();

        if (response.getStatusCode() != SUCCESS_STATUS_CODE) {
            logError(response.getBody());
        }

        return response;
    }
    private static void logError(String body) {

        ErrorResponse errorResult = ErrorResponse.parse(body);
        Spotify_Request_Log__e requestImagesError = new Spotify_Request_Log__e(
            Message__c = errorResult?.error?.message,
            Status__c = errorResult?.error?.status
            //guardar infirmacion del request que fallo
        );
        EventBus.publish(requestImagesError);
    }
}