using SQLHeavy;
public class Dao : GLib.Object {

    private const string databaseName = "syncpodlist.db";

    private SQLHeavy.Database db;

    private SQLHeavy.Query createSongQuery; 

    public Dao() {
        try {
            this.db = new SQLHeavy.Database (databaseName);

            this.createDb();

        }
        catch (SQLHeavy.Error e) {
            GLib.error ("Query creation failure: %s", e.message);
        }
    }

    public void createDb() {
        try {
            SQLHeavy.Transaction trans = db.begin_transaction ();
            trans.execute ("CREATE TABLE `song` (`id` INTEGER PRIMARY KEY, `modificationTime` INTEGER , `bitrate` INTEGER, `channels` INTEGER, `length` INTEGER, `samplerate` INTEGER, `tracknumber` INTEGER, `year` INTEGER, `album` TEXT, `albumartist` TEXT, `artist` TEXT, `comment` TEXT, `disk_string` TEXT, `file_path` TEXT, `genre` TEXT, `title` TEXT);");
            trans.commit ();
        } catch ( SQLHeavy.Error e ) {
            GLib.error ("Database creation failure: %s", e.message);
        }
    }

    public void createSong(Song song) {
        try {

            stdout.printf("Creating song in db ... \n");

            SQLHeavy.Transaction trans = db.begin_transaction ();

            createSongQuery = trans.prepare ("INSERT INTO `song` (`modificationTime`, `bitrate`, `channels`, `length`, `samplerate`, `tracknumber`, `year`, `album`, `albumartist`, `artist`, `comment`, `disk_string`, `file_path`, `genre`, `title`) VALUES (:modificationTime, :bitrate, :channels, :length, :samplerate, :tracknumber, :year, :album, :albumartist, :artist, :comment, :disk_string, :file_path, :genre, :title);");

            // Bind an int
            createSongQuery.set_double (":modificationTime", song.modificationTime.tv_sec);
            createSongQuery.set_int (":bitrate", song.bitrate);
            createSongQuery.set_int (":channels", song.channels);
            createSongQuery.set_int (":length", song.length);
            createSongQuery.set_int (":samplerate", song.samplerate);
            createSongQuery.set_int (":tracknumber", song.tracknumber);
            createSongQuery.set_int (":year", song.year);

            // Bind a string
            createSongQuery.set_string (":album", song.album);
            createSongQuery.set_string (":albumartist", song.albumartist);
            createSongQuery.set_string (":artist", song.artist);
            createSongQuery.set_string (":comment", song.comment);
            createSongQuery.set_string (":disk_string", song.disk_string);
            createSongQuery.set_string (":file_path", song.filePath);
            createSongQuery.set_string (":genre", song.genre);
            createSongQuery.set_string (":title", song.title);

            createSongQuery.execute_insert();

            trans.commit ();
        } catch ( SQLHeavy.Error e ) {
            GLib.error ("Song creation failure: %s", e.message);
        }
    }
}
