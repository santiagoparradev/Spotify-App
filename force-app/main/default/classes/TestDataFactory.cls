public class TestDataFactory {

    public ClientCredential__c creds;

    public void createCreds() {
        
        creds = new ClientCredential__c(
			User__c = UserInfo.getUserId(),
			ClientId__c = 'ClientId__c',
			ClientSecret__c = 'ClientSecret__c',
			SpotifyUserId__c = 'SpotifyUserId__c'
		);
    } 
}