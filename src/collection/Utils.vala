public class Utils :  GLib.Object {

    public static string formatDate(long date) {
        return  new DateTime.from_unix_local(date).format("%d-%m-%Y %H:%M:%S");
    }

    public static long now() {
        TimeVal timeVal;
        timeVal = new TimeVal();
        timeVal.get_current_time();
        return timeVal.tv_sec;
    }
}
