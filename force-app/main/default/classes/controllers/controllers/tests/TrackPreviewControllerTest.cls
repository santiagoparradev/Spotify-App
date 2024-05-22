@IsTest
private class TrackPreviewControllerTest {
  @IsTest
	static void itShouldReturnSpotifyTrackPreviewUrl() {

		// DATA
		List<HttpResponse> responseList = new List<HttpResponse>();
        addResponse(responseList, '{"access_token":"1111"}');
        addResponse(responseList, '{"preview_url":"this is the url"}');
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockFactory(responseList));

		// mock credentials
		CredentialTestDataFactory testDataFactory = new CredentialTestDataFactory();
		testDataFactory.createCreds();
		ClientCredential__c creds = testDataFactory.creds;
		insert creds;

		// TEST
		Test.startTest();
		String url = trackPreviewController.findTrackPreviewUrl('123456'); 
		Test.stopTest();

		// ASSERT
        String.isNotBlank(url);
	}

	private static void addResponse(List<HttpResponse> responseList, String body) {
        
        HttpResponse baseResponse = new HttpResponse();
        baseResponse.setStatusCode(SpotifyApiHttpClient.SUCCESS_STATUS_CODE);
        baseResponse.setBody(body);
        responseList.add(baseResponse);
    }
}
