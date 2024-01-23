public class ImagesController {

    @TestVisible
    private static Database.SaveResult errorEventResult;
    @AuraEnabled(cacheable=true)
    public static List<String> findUrl(String recordSpotifyId, String endPoint) {

        try { 
            List<String> resultUrl = new List<String>();
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
                HttpResponse resultRequest = SpotifyApiHttpClient.requestBase(
                    endPoint,
                    recordSpotifyId,
                    tokenResult.access_token
                );

                if (resultRequest.getStatusCode() == SpotifyApiHttpClient.SUCCESS_STATUS_CODE) {

                    BaseResponse result = BaseResponse.parse(resultRequest.getBody());

                    for (ImagesResponse urlImage : result.images) {
                        resultUrl.add(urlImage.url);
                    }
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
