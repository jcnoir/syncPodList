public class Utils :  GLib.Object {

    public static string formatDate(int64 date) {
        return  new DateTime.from_unix_local(date).format("%d-%m-%Y %H:%M:%S");
    }

    public static int64 now() {
        TimeVal timeVal;
        timeVal = TimeVal();
        timeVal.get_current_time();
        return timeVal.tv_sec;
    }

}
