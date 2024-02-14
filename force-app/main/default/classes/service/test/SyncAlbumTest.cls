@IsTest
private class SyncAlbumTest {
    @IsTest
    static void syncAlbumTest() {
        // prepare data
        List<HttpResponse> responseList = new List<HttpResponse>();
        addResponse(responseList, '{"access_token":"1111"}');
        addResponse(responseList, '{"total":2,"items":[{"id":"0"}]}');
        addResponse(responseList, '{"items":[{"track":{"id":"trackId","album":{"id":"albumId"}}}]}');
        addResponse(responseList, '{"albums":[{"name":"album name","id":"albumId","genres":[]}]}');
        addResponse(responseList, '{"total":2,"items":[{"id":"1"}]}');
        addResponse(responseList, '{"items":[{"track":{"id":"trackId","album":{"id":"albumId"}}}]}');
        addResponse(responseList, '{"albums":[{"name":"album name","id":"albumId","genres":[]}]}');
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
            AlbumBatch creds = new AlbumBatch();
            DataBase.executeBatch(creds);
        Test.stopTest();
        //assert
        List<Album__c> albumss = [SELECT Name FROM Album__c WHERE Name = 'album name'];
        Assert.areEqual(1, albumss.size(), 'is should add one album');
    }

    private static void addResponse(List<HttpResponse> responseList, String body) {
        
        HttpResponse baseResponse = new HttpResponse();
        baseResponse.setStatusCode(SpotifyApiHttpClient.SUCCESS_STATUS_CODE);
        baseResponse.setBody(body);
        responseList.add(baseResponse);
    } 
}