public class ImagesController {

    public static String TOKEN_ENDPOINT = 'https://accounts.spotify.com/api/token';
    public static Integer SUCCESS_STATUS_CODE = 200;

    @AuraEnabled(cacheable=true)
    public static String findUrl(String objectApiNameSpotifyId, String endPoint) {
        
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
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endPoint + objectApiNameSpotifyId); 
                request.setMethod('GET');
                request.setHeader('Authorization', 'Bearer ' + tokenResult.access_token);	
                HttpResponse resultRequest = http.send(request);

                if(resultRequest.getStatusCode() == SUCCESS_STATUS_CODE) {            
                    BaseResponse result = BaseResponse.parse(resultRequest.getBody());
                    String urlImage = result.images[0].url;
                    resultUrl = urlImage;
                }
            }

            return resultUrl;
                 
        } catch (Exception error) {
            throw new AuraHandledException('COULD NOT GET URL: ' + error.getMessage());
        }   
    } 
}
