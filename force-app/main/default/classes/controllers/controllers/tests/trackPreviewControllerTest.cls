@IsTest
private class trackPreviewControllerTest {

  @IsTest
	static void itShouldReturnSpotifyTrackPreviewUrl() {
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
		String url = trackPreviewController.findTrackPreviewUrl('123456'); 
		Test.stopTest();
		// assert
        String.isNotBlank(url);
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
				response.setBody('{"preview_url":"this is the url"}');
            }

			return response;  
		}
	}
}
