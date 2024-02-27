@IsTest
private class SyncPlaylistTest {

    @IsTest
    static void SyncPlaylistTest() {
        // prepare data
        List<HttpResponse> responseList = new List<HttpResponse>();
        addResponse(responseList, '{"access_token":"1111"}');
        addResponse(responseList, '{"total":2,"items":[{"id":"0","name":"name","publicField":true}]}');
        addResponse(responseList, '{"items":[{"track":{"id":"trackId"}}]}');
        addResponse(responseList, '{"total":2,"items":[{"id":"1","name":"name","publicField":true}]}');
        addResponse(responseList, '{"items":[{"track":{"id":"trackId1"}}]}');
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
        PlaylistBatch creds = new PlaylistBatch();
        DataBase.executeBatch(creds);
        Test.stopTest();
        //assert
        List<Playlist__c> playlist = [SELECT Name FROM Playlist__c WHERE Name = 'name'];
        Assert.areEqual(2, playlist.size(), 'is should add two playlist');
    }

    private static void addResponse(List<HttpResponse> responseList, String body) {
        
        HttpResponse baseResponse = new HttpResponse();
        baseResponse.setStatusCode(SpotifyApiHttpClient.SUCCESS_STATUS_CODE);
        baseResponse.setBody(body);
        responseList.add(baseResponse);
    }
}