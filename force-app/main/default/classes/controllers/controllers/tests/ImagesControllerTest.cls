@IsTest
private class ImagesControllerTest {

  @IsTest
	static void itShouldReturnSpotifyImageUrl() {
		// prepare data
		Test.setMock(HttpCalloutMock.class, new Mock());
		ClientCredential__c newCretentials = new ClientCredential__c(
			User__c = UserInfo.getUserId(),
			ClientId__c = 'ClientId__c',
			ClientSecret__c = 'ClientSecret__c',
			SpotifyUserId__c = 'SpotifyUserId__c'
		);
		insert newCretentials;
		// test
		Test.startTest();
		List<String> url = ImagesController.findUrl('123456', 'https://api.spotify.com/v1/albums/'); 
		Test.stopTest();
		// assert
		System.assert(!url.isEmpty(), 'url can not be blank');
	}

	private class Mock implements HttpCalloutMock {

		public HTTPResponse respond(HTTPRequest request) {
 
			HttpResponse response = new HttpResponse();
			response.setStatusCode(SpotifyApiHttpClient.SUCCESS_STATUS_CODE);
			response.setHeader('Content-Type', 'application/json');

			if (request.getEndpoint().contains(SpotifyApiHttpClient.BASE_TOKEN_ENDPOINT + '/token')) {
				TokenResponse token = new TokenResponse();
				token.access_token = '1111';
				response.setBody(JSON.serialize(token));

			} else {
				response.setBody('{"images":[' +
					'{"url":"this is the url"},' +
					'{"url":"this is the url2"},' +
					'{"url":"this is the url3"}]}');
			}

			return response;  
		}
	}
}
