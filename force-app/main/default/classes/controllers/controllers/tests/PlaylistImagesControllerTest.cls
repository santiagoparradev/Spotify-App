@IsTest
private class PlaylistImagesControllerTest {

  @IsTest
  static void itShouldReturnSpotifyImageUrl() {
    // prepare data
    Test.setMock(HttpCalloutMock.class, new TokenMock());
    ClientCredential__c newCretentials = new ClientCredential__c(Name = 'nicolas');
    insert newCretentials;
    // test
    Test.startTest();
    String url = PlaylistImagesController.obtenerDatos('123456'); 
    Test.stopTest();
    // assert
    Assert.isTrue(String.isNotBlank(url), 'url can not be blank');
  }

  private class TokenMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest request) {
 
      HttpResponse response = new HttpResponse();
      response.setStatusCode(PlaylistImagesController.SUCCESS_STATUS_CODE);
      response.setHeader('Content-Type', 'application/json');

      if(request.getEndpoint().contains(PlaylistImagesController.TOKEN_ENDPOINT)) {
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
