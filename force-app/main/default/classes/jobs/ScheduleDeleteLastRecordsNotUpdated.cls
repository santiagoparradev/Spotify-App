public class ScheduleDeleteLastRecordsNotUpdated  implements Schedulable {    

    public void execute(SchedulableContext sc) {

        DeleteLastRecordsNotUpdated Batch = new DeleteLastRecordsNotUpdated();
        Database.executeBatch(Batch);
    }

    public static void SchedulerMethod() {

        System.schedule('00 hours', '0 0 0 1 * ?', new ScheduleBatch());
    }
}