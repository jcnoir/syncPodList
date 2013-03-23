public class Main : GLib.Object {

    static int main (string[] args) {

        MusicCollection collection;
        string collectionPath;
        Dao dao = new Dao();

        if ( args.length > 1 ) {
            collectionPath = args[1];
        }
        else {
            collectionPath = "/media/donnees/dev/syncPodList/src/resources/music";
        }

        message("Music collection is starting");
        collection = dao.findCollection(collectionPath); 
        collection.update();
        dao.createSongs(collection.updatedSongs);
        dao.updateLastUpdateTime(Utils.now(),collectionPath);
        return 0;
    }
}

