using SQLHeavy;
public class Dao : GLib.Object {


    private void createDb() {
    var db = new SQLHeavy.Database ("foobar.db",SQLHeavy.FileMode.CREATE);
    }


}


