@IsTest
private class SyncPlaylistsTest {

    @IsTest
    static void SyncPlaylistsTest() {
        // prepare data
        Test.setMock(HttpCalloutMock.class, new TokenMock());
        List<ClientCredential__c> newCretentials = new List<ClientCredential__c>();
        ClientCredential__c clientId = new ClientCredential__c();
        newCretentials.add(clientId);
        insert newCretentials;
        // test
        Test.startTest();
        SyncPlaylists.syncPlaylist(newCretentials); 
        Test.stopTest();
        //assert
        List<Playlist__c> a = [SELECT Name FROM Playlist__c WHERE Name = 'XD'];
        //Assert.isFalse(a.isEmpty());
        //System.assertEquals(a.size(), 2);
        Assert.areEqual(a.size(), 2);
    }
    private class TokenMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) {

            HttpResponse response = new HttpResponse();
            response.setStatusCode(SyncPlaylists.SUCCESS_STATUS_CODE);
            response.setHeader('Content-Type', 'application/json');

            if(request.getEndpoint().contains(SyncPlaylists.TOKEN_ENDPOINT)) {
                TokenResponse token = new TokenResponse();
                token.access_token = '1111';
                response.setBody(JSON.serialize(token));
              
            } else if(request.getEndpoint().contains('playlist')) {
                  List<SimplefiedPlaylistObject> x = new List<SimplefiedPlaylistObject>();
                  SimplefiedPlaylistObject a = new SimplefiedPlaylistObject();
                  x.add(a);
                  a.Name = 'XD';
                  a.description = 'description';
                  a.publicField = true;
                  PlaylistResponse playlist = new PlaylistResponse();
                  playlist.total = 2;
                  playlist.items = x;
                  response.setBody(JSON.serialize(playlist));
            }
        return response;
        }
    }
}