@IsTest
private class TrackPreviewControllerTest {
  @IsTest
	static void itShouldReturnSpotifyTrackPreviewUrl() {
		// prepare data
		List<HttpResponse> responseList = new List<HttpResponse>();
        addResponse(responseList, '{"access_token":"1111"}');
        addResponse(responseList, '{"preview_url":"this is the url"}');
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockFactory(responseList));

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

	private static void addResponse(List<HttpResponse> responseList, String body) {
        
        HttpResponse baseResponse = new HttpResponse();
        baseResponse.setStatusCode(SpotifyApiHttpClient.SUCCESS_STATUS_CODE);
        baseResponse.setBody(body);
        responseList.add(baseResponse);
    } 
}
