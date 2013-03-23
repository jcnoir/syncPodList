public class Main : GLib.Object {

    static int main (string[] args) {
        Dao dao = new Dao();
        var collectionPath = "/media/donnees/dev/syncPodList/src/resources/music/original";
        var collectionPath2 = "/media/donnees/dev/syncPodList/src/resources/music/copie";

        scanCollection(collectionPath);
        scanCollection(collectionPath2);

        var playlist = new PlayList.Relative("src/resources/music/original/playlist.m3u", "src/resources/music/original");

        playlist.read();
        dao.getMatchingSong(playlist.songs, 2);
        return 1;
    }

    public static void scanCollection(string collectionPath) {
        MusicCollection collection;
        Dao dao = new Dao();

        message("Music collection is starting");
        collection = dao.findCollection(collectionPath); 
        collection.update();
        dao.createSongs(collection.updatedSongs, collection.id);
        dao.updateCollection(collection);

    }
}
