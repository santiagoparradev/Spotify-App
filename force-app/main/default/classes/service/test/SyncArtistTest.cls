@IsTest
private class SyncArtistTest {

    @IsTest
    static void syncArtistTest() {
        // prepare data
        List<HttpResponse> responseList = new List<HttpResponse>();

        addResponse(responseList, '{"access_token":"1111"}');
        addResponse(responseList, '{"total":2,"items":[{"id":"0"}]}');
        addResponse(responseList, '{"items":[{"track":{"id":"trackId","artists":[{"id":"artistId"}],"album":null}}]}');
        addResponse(responseList, '{"total":2,"items":[{"id":"1"}]}');
        addResponse(responseList, '{"items":[{"track":{"id":"trackId","artists":[{"id":"artistId"}],"album":null}}]}');
        addResponse(responseList, '{"artists":[{"id":"artistId","name":"artist name"}]}');

        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockFactory(responseList)); 
        List<ClientCredential__c> newCredentials = new List<ClientCredential__c>{
            new ClientCredential__c(
                ClientId__c = 'ClientId__c',
                ClientSecret__c = 'ClientSecret__c',
                SpotifyUserId__c = 'SpotifyUserId__c',
                User__c = UserInfo.getUserId()
            )
        };

        insert newCredentials;
        // test
        Test.startTest();
        ArtistBatch creds = new ArtistBatch();
        DataBase.executeBatch(creds);
        Test.stopTest();
        //assert
        List<Artist__c> artists = [SELECT Name FROM Artist__c WHERE Name = 'artist name'];
        Assert.areEqual(1, artists.size(), 'is should add one artist');
    }

    private static void addResponse(List<HttpResponse> responseList, String body) {
        
        HttpResponse baseResponse = new HttpResponse();
        baseResponse.setStatusCode(SpotifyApiHttpClient.SUCCESS_STATUS_CODE);
        baseResponse.setBody(body);
        responseList.add(baseResponse);
    }
}