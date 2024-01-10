@IsTest
public class DeleteLastRecordsNotUpdatedTest {
    @IsTest
    static void deleteLastRecordsNotUpdatedTest() {
        //Arrange
        Album__c album = new Album__c(
            LastModifiedDate = System.now().addMonths(-2), 
            CreatedDate = System.now().addMonths(-3)
        );
        insert album;
        Track__c track = new Track__c(
            Album__c = album.id, 
            LastModifiedDate = System.now().addMonths(-2),
            CreatedDate = System.now().addMonths(-3)
        );
        insert track;
        Playlist__c playlist = new Playlist__c(
            LastModifiedDate = System.now().addMonths(-2),
            CreatedDate = System.now().addMonths(-3)
        );
        insert playlist;
        Artist__c artist = new Artist__c(
            LastModifiedDate = System.now().addMonths(-2), 
            CreatedDate = System.now().addMonths(-3)
        );
        insert artist;
        //Act
        Test.startTest();
        DeleteLastRecordsNotUpdated batch = new DeleteLastRecordsNotUpdated(); 
        Database.executeBatch(batch);
        Test.stopTest();
        //assert
        
        List<Track__c> TrackAfterBatch = [SELECT Id FROM Track__c WHERE Id =: track.Id];
        List<Playlist__c> PlaylistAfterBatch = [SELECT Id FROM Playlist__c WHERE Id =: playlist.Id];
        List<Artist__c> ArtistAfterBatch = [SELECT Id FROM Artist__c WHERE Id =: artist.Id];
        
        assert.isTrue(TrackAfterBatch.isEmpty(), 'The track list is not empty after the batch is run.');
        assert.isTrue(PlaylistAfterBatch.isEmpty(), 'The playlist list is not empty after the batch is run.');
        assert.isTrue(ArtistAfterBatch.isEmpty(), 'The  artist list is not empty after the batch is run.');
    }
}