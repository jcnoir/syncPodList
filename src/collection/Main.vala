using Gee;
public class Main : GLib.Object {

    static int main3 (string[] args) {
        string collectionPath;
        Dao dao = new Dao();
        ArrayList<Song> songs;
        //var collectionPath = "/run/media/jcnoir/IPOD160";
        if (args.length > 1) {
            collectionPath = args[1];
        } else {
            collectionPath = "/media/donnees/dev/syncPodList/src/resources/music/original";
        }
        scanCollection(collectionPath);
        dao.getMissingSongs(1,2);
        return 0;
    }
    static int main2 (string[] args) {
        Dao dao = new Dao();
        ArrayList<Song> songs;
        var targetPlayList = new PlayList("/tmp/test-copie-playlist.m3u");
        var collectionPath = "/media/donnees/dev/syncPodList/src/resources/music/original";
        var collectionPath2 = "/media/donnees/dev/syncPodList/src/resources/music/copie";

        scanCollection(collectionPath);
        scanCollection(collectionPath2);

        //        var playlist = new PlayList.Relative("src/resources/music/original/playlist.m3u", "src/resources/music/original/");
        var playlist = new PlayList("/home/jcnoir/mpd/playlists/JamesCarter.m3u");

        playlist.read();
        songs = dao.getMatchingSong(playlist.songs, 2);
        targetPlayList.songs = songs;
        targetPlayList.write();
        return 0;
    }

    public static void scanCollection(string collectionPath) {
        MusicCollection collection;
        Dao dao = new Dao();

        collection = dao.findCollection(collectionPath);
        //collection.checksum_enabled = true;
        collection.update();
        dao.createSongs(collection.updatedSongs, collection.id);
        dao.updateCollection(collection);

    }
}




