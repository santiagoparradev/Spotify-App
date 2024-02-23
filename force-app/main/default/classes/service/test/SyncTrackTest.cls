@IsTest
private class SyncTrackTest {

    @IsTest
    static void syncTrackTest() {
        // prepare data
        List<HttpResponse> responseList = new List<HttpResponse>();

        addResponse(responseList, '{"access_token":"1111"}');
        addResponse(responseList, '{"total":2,"items":[{"id":"0"}]}');
        addResponse(responseList, '{"items":[{"track":{' +
            '"name":"track name",' +
            '"id":"trackId",' +
            '"explicit":true,' +
            '"album":{"name":null,"id":"albumId"},' +
            '"artists":[{"id":"artistId"}]}}]}');
        addResponse(responseList, '{"total":2,"items":[{"id":"1"}]}');
        addResponse(responseList, '{"items":[{"track":{' + 
            '"name":"track name",' +
            '"id":"trackId1",' +
            '"explicit":true,' +
            '"album":{"name":null,"id":"albumId1"},' +
            '"artists":[{"id":"artistId1"}]}}]}');
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockFactory(responseList));       
        Album__c album = new Album__c(SpotifyId__c = 'albumId');
        Album__c album1 = new Album__c(SpotifyId__c = 'albumId1');

        insert album;
        insert album1;

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
        TrackBatch creds = new TrackBatch();
        DataBase.executeBatch(creds);
        Test.stopTest();
        //assert
        List<Track__c> tracks = [SELECT Name FROM Track__c WHERE Name = 'track name'];
        Assert.areEqual(2, tracks.size(), 'is should add one track');
    }
    
    private static void addResponse(List<HttpResponse> responseList, String body) {
        
        HttpResponse baseResponse = new HttpResponse();
        baseResponse.setStatusCode(SpotifyApiHttpClient.SUCCESS_STATUS_CODE);
        baseResponse.setBody(body);
        responseList.add(baseResponse);
    }
}