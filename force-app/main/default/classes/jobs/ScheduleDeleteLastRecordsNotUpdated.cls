public class ScheduleDeleteLastRecordsNotUpdated  implements Schedulable {    

    public void execute(SchedulableContext sc) {

        DeleteLastRecordsNotUpdated batch = new DeleteLastRecordsNotUpdated();
        Database.executeBatch(batch);
    }

    public static void SchedulerMethod() {

        System.schedule('00 hours', '0 0 0 1 * ?', new ScheduleBatch());
    }
}