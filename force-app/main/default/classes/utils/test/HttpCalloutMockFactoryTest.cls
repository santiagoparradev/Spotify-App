@IsTest
private class HttpCalloutMockFactoryTest {
    @IsTest
    static void mockResponseTest() {
        //prepare date
        Integer statusCode = 200;
        String status = 'status';
        String body = 'bodyAsString';
        Map<String, String> headers = new Map<String, String>();
        HttpRequest request = new HttpRequest();
        //test
        Test.startTest();
        HttpCalloutMockFactory mock = new HttpCalloutMockFactory(statusCode, status, body, headers);
        HttpResponse response = mock.respond(request);
        Test.stopTest();
        //assert 
        Assert.areEqual(body, response.getBody());
    }
    @IsTest
    static void mockListResponseTest() {
        //prepare date
        List<HttpResponse> responseQueue = new List<HttpResponse>();
        HttpResponse token = new HttpResponse();
        responseQueue.add(token);
        HttpResponse playlist = new HttpResponse();
        responseQueue.add(playlist);
        HttpRequest request = new HttpRequest();
        //test
        Test.startTest();
        HttpCalloutMockFactory mock = new HttpCalloutMockFactory(responseQueue);
        HttpResponse responseToken = mock.respond(request);
        HttpResponse responsePlaylist = mock.respond(request);
        Test.stopTest();
        //assert    
        Assert.areEqual(token, responseToken);
        Assert.areEqual(playlist, responsePlaylist);
    }
    @IsTest
    static void mockMapTest() {
         //prepare date
        HttpResponse token = new HttpResponse();
        HttpResponse playlist = new HttpResponse();
        HttpRequest requestToken = new HttpRequest();
        requestToken.setEndpoint('endpointToken');
        HttpRequest requestPlaylist = new HttpRequest();
        requestPlaylist.setEndpoint('endpointPlaylist');
        Map<String, HttpResponse> endpointByResponse = new Map<String, HttpResponse>();
        endpointByResponse.put('endpointToken', token);
        endpointByResponse.put('endpointPlaylist', playlist);
         //test
        Test.startTest();
        HttpCalloutMockFactory mock = new HttpCalloutMockFactory(endpointByResponse);
        HttpResponse responseToken = mock.respond(requestToken);
        HttpResponse responsePlaylist = mock.respond(requestPlaylist);
        Test.stopTest();
        //assert    
        Assert.areEqual(token, responseToken);
        Assert.areEqual(playlist, responsePlaylist);
    }
}