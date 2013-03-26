// modules: gio-2.0 gee-1.0 libtaginfo_c .
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

    public static  string computeChecksum(string filePath) {
        var checksum = new Checksum (ChecksumType.MD5);
        var stream = FileStream.open (filePath, "rb");
        uint8 fbuf[100];
        size_t size;

        while ((size = stream.read (fbuf)) > 0) {
            checksum.update (fbuf, size);
        }

        unowned string digest = checksum.get_string ();
        message("checksum is %s for %s",digest,filePath);
        return digest;
    }

}
