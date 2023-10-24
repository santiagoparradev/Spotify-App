@IsTest
private class ImagesControllerTest {

  @IsTest
  static void itShouldReturnSpotifyImageUrl() {
    // prepare data
    Test.setMock(HttpCalloutMock.class, new TokenMock());
    ClientCredential__c newCretentials = new ClientCredential__c(Name = 'nicolas');
    insert newCretentials;
    // test
    Test.startTest();
    String url = ImagesController.findUrl('123456', 'https://api.spotify.com/v1/albums/'); 
    Test.stopTest();
    // assert
    Assert.isTrue(String.isNotBlank(url), 'url can not be blank');
  }

  private class TokenMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest request) {
 
      HttpResponse response = new HttpResponse();
      response.setStatusCode(ImagesController.SUCCESS_STATUS_CODE);
      response.setHeader('Content-Type', 'application/json');

      if(request.getEndpoint().contains(ImagesController.TOKEN_ENDPOINT)) {
        TokenResponse token = new TokenResponse();
        token.access_token = '1111';
        response.setBody(JSON.serialize(token));

      } else {
        response.setBody('{"images":[{"url":"this is the url"}]}');
      }

      return response;  
    }
  }
}
