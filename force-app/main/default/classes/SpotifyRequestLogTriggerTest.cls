@isTest
private class SpotifyRequestLogTrigger {
    @isTest static void spotifyRequestLogTrigger() {
        // prepare data
        Spotify_Request_Log__e errorEvent = new Spotify_Request_Log__e(
            ApexError__c = 'error'
		);
        // test
        Test.startTest();
        EventBus.publish(errorEvent);
        Test.stopTest();
        //assert
        List<Log__c> error = [SELECT ApexError__c FROM Log__c WHERE ApexError__c =: errorEvent.ApexError__c];
        Assert.isFalse(error.isEmpty());
    }
}