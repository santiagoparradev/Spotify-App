public class TrackPreviewController {

    @TestVisible
    private static Database.SaveResult errorEventResult;
    @AuraEnabled(cacheable=true)
    public static String findTrackPreviewUrl(String recordSpotifyId) {

        try { 
            String resultUrl;
            ClientCredential__c cred = [
                SELECT 
                    ClientId__c, 
                    ClientSecret__c, 
                    SpotifyUserId__c
                FROM 
                    ClientCredential__c 
                WHERE 
                    User__c =:UserInfo.getUserId()
            ];

            HttpResponse token = SpotifyApiHttpClient.getToken(
                cred.ClientId__c,
                cred.ClientSecret__c
            );

            if (token.getStatusCode() == SpotifyApiHttpClient.SUCCESS_STATUS_CODE) {

                TokenResponse tokenResult = TokenResponse.parse(token.getBody());

                HttpResponse response = SpotifyApiHttpClient.requestBase(
                    'https://api.spotify.com/v1/tracks/',
                    recordSpotifyId,
                    tokenResult.access_token
                );

                if (response.getStatusCode() == SpotifyApiHttpClient.SUCCESS_STATUS_CODE) {

                    SimplefieldTracksObject trackResult = SimplefieldTracksObject.parse(response.getBody());
                    resultUrl = trackResult.preview_url;
                }
            }

            return resultUrl;

        } catch (Exception error) {
            Spotify_Request_Log__e errorEvent = new Spotify_Request_Log__e(
                ApexError__c = error.getMessage()
		    );  
            errorEventResult = EventBus.publish(errorEvent);
            
            throw new AuraHandledException('COULD NOT GET URL: ' + error.getMessage());
        }
    }
}