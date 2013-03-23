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
            db.execute("PRAGMA foreign_keys = ON;");
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
            trans.run_script("/donnees/dev/syncPodList/src/collection/sql/create.sql");

            trans.commit ();
        } catch ( SQLHeavy.Error e ) {
            GLib.error ("Database creation failure: %s", e.message);
        }
    }

    public void createSongs( ArrayList<Song> songs, int64 collectionId) {
        try {

            message("Updating songs in db with collecion ID : %s", collectionId.to_string());
            SQLHeavy.Transaction trans = db.begin_transaction ();

            createSongQuery = trans.prepare ("INSERT OR REPLACE INTO `song` ( `bitrate`, `channels`, `length`, `samplerate`, `tracknumber`, `year`, `album`, `albumartist`, `artist`, `comment`, `disk_string`, `file_path`, `genre`, `title`, `song_collection` ) VALUES ( :bitrate, :channels, :length, :samplerate, :tracknumber, :year, :album, :albumartist, :artist, :comment, :disk_string, :file_path, :genre, :title, :collectionId ) ;");

            foreach (Song song in songs) {
                // Bind an int
                createSongQuery.set_int (":bitrate", song.bitrate);
                createSongQuery.set_int (":channels", song.channels);
                createSongQuery.set_int (":length", song.length);
                createSongQuery.set_int (":samplerate", song.samplerate);
                createSongQuery.set_int (":tracknumber", song.tracknumber);
                createSongQuery.set_int (":year", song.year);
                createSongQuery.set_int64(":collectionId", collectionId);

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

    public MusicCollection findCollection(string path) {
        QueryResult results;
        MusicCollection collection = new MusicCollection(path);
        try {
            SQLHeavy.Query query = db.prepare ("SELECT collection_id, lastupdate, version FROM `collection` WHERE `path` = :path;");
            query.set_string(":path",path);
            results = query.execute();


            if (!results.finished ) {
                message("Collection found in db");
                collection.id = results.fetch_int(0) ;
                collection.lastUpdateTime = results.fetch_int(1);
                collection.version = results.fetch_int(2);
                collection.rootPath = path;
            }
            else {
                message("Collection missing in db, building it ...");
                this.createCollection(collection);
            }
            message (@"Collection : $collection");

        }
        catch (SQLHeavy.Error e) {
            error("Find collection request failure : %s", e.message);
        }
        return collection;
    }

    public void createCollection(MusicCollection  collection) {
        try {
            int64 collectionId;
            SQLHeavy.Query insertQuery = db.prepare("INSERT INTO collection (`path`,`lastupdate`,`version`) VALUES (:path, :lastupdate, :version) ;");
            SQLHeavy.Query selectQuery = db.prepare("SELECT `collection_id` FROM `collection` WHERE `path` = :path ;");

            insertQuery.set_string(":path", collection.rootPath);
            insertQuery.set_int64(":lastupdate", collection.lastUpdateTime);
            insertQuery.set_int(":version", collection.version);
            insertQuery.execute();

            selectQuery.set_string(":path", collection.rootPath);
            collectionId = selectQuery.execute().fetch_int64(0);
            collection.id = collectionId;

            message("New ID for the collection : %s", collectionId.to_string());

        }
        catch (SQLHeavy.Error e) {
            error("Collection creation failure : %s", e.message);
        }
    }
    public void updateCollection(MusicCollection  collection) {
        try {
            SQLHeavy.Query insertQuery = db.prepare("UPDATE `collection` SET `lastupdate` = :lastupdate ;");
            insertQuery.set_int64(":lastupdate", collection.lastUpdateTime);
            insertQuery.execute();
        }
        catch (SQLHeavy.Error e) {
            error("Collection update failure : %s", e.message);
        }
    }

    public ArrayList<Song> getMatchingSong(ArrayList<Song> songs, int64 collectionId) {
        QueryResult results;
        var matchingSongs = new ArrayList<Song>();
        foreach (Song song in songs) {
            try {
                string filePath;

                message("Looking for matching song in collection %s for title %s", collectionId.to_string(), song.title);

                SQLHeavy.Query query = db.prepare ("Select `file_path` FROM `song` WHERE `song_collection` = :collectionId AND `length` = :length AND `title` = :title AND `artist` = :artist AND `album` = :album ;");
                query.set_int64(":collectionId",collectionId);
                query.set_int(":length",song.length);
                query.set_string(":title",song.title);
                query.set_string(":artist",song.artist);
                query.set_string(":album",song.album);
                results = query.execute();

                if (!results.finished) {
                    filePath = results.fetch_string(0);
                    message("Matching song found : %s", filePath);
                    matchingSongs.add(MusicCollection.getSong(filePath));
                }
                else {
                    message("No matching song found");
                }
            }
            catch (SQLHeavy.Error e) {
                warning("Matching song find failure : %s", e.message);
            }
        }
        return matchingSongs;
    }
}
