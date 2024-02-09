trigger SpotifyRequestLogTrigger on Spotify_Request_Log__e(after insert) {
  List<Log__c> logListErrors = new List<Log__c>();

  for (Spotify_Request_Log__e eventError : Trigger.new) {
    Log__c error = new Log__c(
      Message__c = eventError?.Message__c,
      Status__c = eventError?.Status__c,
      Endpoint__c = eventError?.Endpoint__c,
      ApexError__c = eventError?.ApexError__c
    );
    logListErrors.add(error);
  }

  if (!logListErrors.isEmpty()) {
    insert logListErrors;
  }
}
