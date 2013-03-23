using SQLHeavy;
using Gee;

public class Dao : GLib.Object {

    private const string databaseName = "syncpodlist.db";

    private SQLHeavy.Database db;

    private SQLHeavy.Query createSongQuery; 

    public Dao() {
        try {

            bool dbExist;
            dbExist = FileUtils.test(databaseName, FileTest.IS_REGULAR);
            this.db = new SQLHeavy.Database (databaseName);
            if (!dbExist) {
                message(@"Database not found : $databaseName, creating it ...");
                this.createDb();
            }
        }
        catch (SQLHeavy.Error e) {
            GLib.error ("Query creation failure: %s", e.message);
        }
    }

    public void createDb() {
        try {
            SQLHeavy.Transaction trans = db.begin_transaction ();
            trans.execute ("CREATE TABLE `song` (`id` INTEGER PRIMARY KEY, `bitrate` INTEGER, `channels` INTEGER, `length` INTEGER, `samplerate` INTEGER, `tracknumber` INTEGER, `year` INTEGER, `album` TEXT, `albumartist` TEXT, `artist` TEXT, `comment` TEXT, `disk_string` TEXT, `file_path` TEXT, `genre` TEXT, `title` TEXT, UNIQUE (`file_path`));");

            trans.execute ("CREATE TABLE `collection` (`id` INTEGER PRIMARY KEY, `path` TEXT, `lastupate` INTEGER, UNIQUE(`path`));");

            trans.commit ();
        } catch ( SQLHeavy.Error e ) {
            GLib.error ("Database creation failure: %s", e.message);
        }
    }

    public void createSong(Song song) {
        try {

            message("Creating song in db ...");

            SQLHeavy.Transaction trans = db.begin_transaction ();

            createSongQuery = trans.prepare ("INSERT OR REPLACE INTO `song` (`bitrate`, `channels`, `length`, `samplerate`, `tracknumber`, `year`, `album`, `albumartist`, `artist`, `comment`, `disk_string`, `file_path`, `genre`, `title`) VALUES (:bitrate, :channels, :length, :samplerate, :tracknumber, :year, :album, :albumartist, :artist, :comment, :disk_string, :file_path, :genre, :title);");

            // Bind an int
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

    public void createSongs( ArrayList<Song> songs) {
        try {

            message("Updating songs in db ...");
            SQLHeavy.Transaction trans = db.begin_transaction ();

            createSongQuery = trans.prepare ("INSERT OR REPLACE INTO `song` (`bitrate`, `channels`, `length`, `samplerate`, `tracknumber`, `year`, `album`, `albumartist`, `artist`, `comment`, `disk_string`, `file_path`, `genre`, `title`) VALUES (:bitrate, :channels, :length, :samplerate, :tracknumber, :year, :album, :albumartist, :artist, :comment, :disk_string, :file_path, :genre, :title);");

            foreach (Song song in songs) {
                // Bind an int
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
            }

            trans.commit ();
        } catch ( SQLHeavy.Error e ) {
            GLib.error ("Song creation failure: %s", e.message);
        }
    }

    public long findLastUpdateTime(string path) {
        long lastUpdateTime;
        SQLHeavy.Query query = db.prepare ("SELECT `lastupate` FROM `collection` WHERE `path` = :path;");
        query.set_string(":path",path);
        lastUpdateTime = query.execute().fetch_int(0);
        message("Collection last update time : %s", Utils.formatDate(lastUpdateTime));
        return lastUpdateTime;
    }

    public void updateLastUpdateTime(long lastupate, string path) {
        message("Updated collection last update time : %s", Utils.formatDate(lastupate));
        SQLHeavy.Query query = db.prepare ("INSERT OR REPLACE INTO `collection` (`lastupate`, `path`) VALUES (:lastupate, :path);");
        query.set_string(":path",path);
        query.set_double(":lastupate",lastupate);
        query.execute();
    }

    public MusicCollection findCollection(string rootPath) {
        MusicCollection collection;
        long lastUpdateTime;

        collection = new MusicCollection(rootPath);
        lastUpdateTime = findLastUpdateTime(rootPath);
        collection.lastUpdateTime = lastUpdateTime;

        return collection;
    }
}
