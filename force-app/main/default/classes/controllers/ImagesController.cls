public class ImagesController {

    @AuraEnabled(cacheable=true)
    public static List<String> findUrl(String objectApiNameSpotifyId, String endPoint) {

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

                HttpResponse resultRequest = SpotifyApiHttpClient.getImages(
                    endPoint,
                    objectApiNameSpotifyId,
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
            throw new AuraHandledException('COULD NOT GET URL: ' + error.getMessage());
        }
    } 
}
