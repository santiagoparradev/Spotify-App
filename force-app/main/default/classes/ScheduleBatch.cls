public class ScheduleBatch  implements Schedulable {    

    public void execute(SchedulableContext sc) {
        PlaylistBatch batch = new PlaylistBatch(); 
        Database.executeBatch(batch);
        AlbumBatch albumbatch = new AlbumBatch(); 
        Database.executeBatch(albumbatch);
    }

    public static void SchedulerMethod() {
        System.schedule('00 minutes','0 0 * * * ?', new ScheduleBatch());
        System.schedule('30 minutes','0 30 * * * ?', new ScheduleBatch());
    }
}