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
        DeleteLastRecordsNotUpdated Batch = new DeleteLastRecordsNotUpdated(); 
        Database.executeBatch(Batch);
        Test.stopTest();
        //assert
        
        List<Track__c> albumsAfterBatchTrack = [SELECT id FROM Track__c WHERE id =: track.id];
        List<Playlist__c> albumsAfterBatchPlaylist = [SELECT id FROM Playlist__c WHERE id =: playlist.id];
        List<Artist__c> albumsAfterBatchArtist = [SELECT id FROM Artist__c WHERE id =: artist.id];
        
        assert.isTrue(albumsAfterBatchTrack.isEmpty(), 'The track list is not empty after the batch is run.');
        assert.isTrue(albumsAfterBatchPlaylist.isEmpty(), 'The playlist list is not empty after the batch is run.');
        assert.isTrue(albumsAfterBatchArtist.isEmpty(), 'The  artist list is not empty after the batch is run.');
    }
}