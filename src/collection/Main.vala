public class Main : GLib.Object {
    /**
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
      dao.createSongs(collection.updatedSongs, collection.id);
      dao.updateCollection(collection);
      return 0;
      }
     **/
    static int main (string[] args) {

        var playlist = new PlayList.Relative("src/resources/music/playlist.m3u", "src/resources/music/");
        //var playlist = new PlayList.Relative("/home/jcnoir/mpd/playlists/random.m3u", "");
        
        playlist.read();
        return 1;


    }
}

