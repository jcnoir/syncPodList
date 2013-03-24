using GPod;

public class IPodDevice : GLib.Object {

    const string REPLACE_PATTERN = "ZZ_";

    static int main (string[] args) {
        string ipodMountpoint; 
        GPod.iTunesDB db;
        uint plistNb;
        unowned GLib.List<GPod.Playlist> playlists;

        ipodMountpoint = Environment.get_variable("IPOD_MOUNTPOINT");        
        message (@"Ipod path (from the IPOD_MOUNTPOINT environment variable) : $ipodMountpoint \n" );
        try {
            db = GPod.iTunesDB.parse(ipodMountpoint);
            plistNb = db.playlists_number();
            message (@"Playlist number : $plistNb \n");
            playlists = db.playlists;
            playlists.foreach ((playlist) => {


                               unowned GPod.Playlist matchingPlaylist;

                               playlist.spl_update();

                               message ("Playlist %s (%u)\n", playlist.name,playlist.num);

                               if (playlist.is_spl) {
                               message("==> Smart Playlist detected\n");
                               string matchingPlaylistName;
                               matchingPlaylistName = playlist.name.replace(IPodDevice.REPLACE_PATTERN,"");
                               matchingPlaylist = db.playlist_by_name(matchingPlaylistName) ;
                               if ( matchingPlaylist != null ) {
                               message("Matching normal playlist found %s\n", matchingPlaylist.name);
                               IPodDevice.cleanPlaylist(matchingPlaylist);
                               IPodDevice.copyPlayList(playlist,matchingPlaylist);
                               }
                               }
                               });
            message("Writing ipod database ...\n");
            db.write();

        }catch (Error e) {
            stderr.printf("Cannot read the ipod database : %s\n",
                          e.message);
        }

        return 0;
    }

    static void cleanPlaylist(GPod.Playlist playlist) {
        unowned GLib.List<unowned GPod.Track> plSongs;

        message("Cleaning playlist  : %s\n", playlist.name);

        plSongs = playlist.members;
        plSongs.foreach ((song) => {
                         message("\t - Removing track : %s \n", song.title);
                         playlist.remove_track(song);
                         });
    }

    static void copyPlayList(GPod.Playlist sourcePlaylist, GPod.Playlist
                             targetPlaylist) {

        unowned GLib.List<unowned GPod.Track> plSongs;

        message("Copying playlist : %s ==> %s \n", sourcePlaylist.name, targetPlaylist.name);
        plSongs = sourcePlaylist.members;
        plSongs.foreach ((song) => {

                         message("\t + Copying track %s-%s-%s\n", song.artist, song.album, song.title);
                         //-1 to add the song at the end of the playlist
                         targetPlaylist.add_track(song,-1);
                         });

    }
}
