using GPod;

public class IPodDevice : GLib.Object {

    const string REPLACE_PATTERN = "ZZ_";

    static int main (string[] args) {
        string ipodMountpoint; 
        GPod.iTunesDB db;
        uint plistNb;
        unowned GLib.List<GPod.Playlist> playlists;

        print ("IPodDevice is starting ... \n");
        ipodMountpoint = Environment.get_variable("IPOD_MOUNTPOINT");        
        stdout.printf ("Ipod mount point %s\n", ipodMountpoint);
        try {
            db = GPod.iTunesDB.parse(ipodMountpoint);
            plistNb = db.playlists_number();
            stdout.printf ("Playlist number : %u\n", plistNb);
            playlists = db.playlists;
            playlists.foreach ((playlist) => {


                               unowned GPod.Playlist matchingPlaylist;
                               unowned GLib.List<unowned GPod.Track> plSongs;

                               playlist.spl_update();

                               stdout.printf ("Playlist %s (%u)\n", playlist.name,playlist.num);

                               if (playlist.is_spl) {
                               stdout.printf("==> Smart Playlist detected\n");
                               string matchingPlaylistName;
                               matchingPlaylistName = playlist.name.replace(IPodDevice.REPLACE_PATTERN,"");
                               matchingPlaylist = db.playlist_by_name(matchingPlaylistName) ;
                               if ( matchingPlaylist != null ) {
                               stdout.printf("Matching normal playlist found %s\n", matchingPlaylist.name);
                               IPodDevice.cleanPlaylist(matchingPlaylist);
                               IPodDevice.copyPlayList(playlist,matchingPlaylist);

                               }

                               }

            });
            stdout.printf("Writing ipod database ...\n");
            db.write();

        }catch (Error e) {
            stderr.printf("Cannot read the ipod database : %s\n",
                          e.message);
        }

        return 0;
    }

    static void cleanPlaylist(GPod.Playlist playlist) {
        unowned GLib.List<unowned GPod.Track> plSongs;

        stdout.printf("Cleaning playlist  : %s\n", playlist.name);

        plSongs = playlist.members;
        plSongs.foreach ((song) => {
                         stdout.printf("\t - Removing track : %s \n", song.title);
                         playlist.remove_track(song);
                         });

    }

    static void copyPlayList(GPod.Playlist sourcePlaylist, GPod.Playlist
                             targetPlaylist) {

        unowned GLib.List<unowned GPod.Track> plSongs;

        stdout.printf("Copying playlist : %s ==> %s \n", sourcePlaylist.name, targetPlaylist.name);
        plSongs = sourcePlaylist.members;
        plSongs.foreach ((song) => {

                         stdout.printf("\t + Copying track %s-%s-%s\n", song.artist, song.album, song.title);
                         //-1 to add the song at the end of the playlist
                         targetPlaylist.add_track(song,-1);
                         });

    }





}
