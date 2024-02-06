@isTest
private class ShowErrosInObjectTest {
    @isTest static void showErrosInObjectTest() {
        // prepare data
        Spotify_Request_Log__e errorEvent = new Spotify_Request_Log__e(
            ApexError__c = 'error'
		);
        // test
        Test.startTest();
            EventBus.publish(errorEvent);
        Test.stopTest();
        //assert
        List<Log__c> error = [SELECT ApexError__c FROM Log__c WHERE ApexError__c = 'error'];
        Assert.isFalse(error.isEmpty());
    }
}