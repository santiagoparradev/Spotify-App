@IsTest
private class ImagesControllerTest {
  @IsTest
	static void itShouldReturnSpotifyImageUrl() {
		// prepare data
		List<HttpResponse> responseList = new List<HttpResponse>();
        addResponse(responseList, '{"access_token":"1111"}');
        addResponse(responseList, '{"images":[{"url":"this is the url"},{"url":"this is the url2"},{"url":"this is the url3"}]}');
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
		List<String> url = ImagesController.findUrl('123456', 'https://api.spotify.com/v1/albums/'); 
		Test.stopTest();
		// assert
		System.assert(!url.isEmpty(), 'url can not be blank');
	}

	private static void addResponse(List<HttpResponse> responseList, String body) {
        
        HttpResponse baseResponse = new HttpResponse();
        baseResponse.setStatusCode(SpotifyApiHttpClient.SUCCESS_STATUS_CODE);
        baseResponse.setBody(body);
        responseList.add(baseResponse);
    } 
}
