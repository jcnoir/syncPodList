// modules: libgpod-1.0 .
using GPod;

public class IPodDevice : GLib.Object {

    const string REPLACE_PATTERN="ZZ_";
    public string ipodMountpoint {get; set;}

    static int main (string[] args) {

        var ipodMountPoint = Environment.get_variable("IPOD_MOUNTPOINT");
        message (@"Ipod path (from the IPOD_MOUNTPOINT environment variable) : $ipodMountPoint " );
        var ipodDevice = new IPodDevice(ipodMountPoint);
        ipodDevice.syncPlaylists();
        return 0;
    }

    public IPodDevice(string ipodMountPoint) {
        this.ipodMountpoint = ipodMountPoint;
    }

    public void syncPlaylists() {

        GPod.iTunesDB db;
        uint plistNb ;
        unowned GLib.List<GPod.Playlist> playlists;

        try {
            db = GPod.iTunesDB.parse(ipodMountpoint);
            plistNb = db.playlists_number();
            message (@"Playlist number : $plistNb ");
            playlists = db.playlists;
            playlists.foreach ((playlist) => {


                    unowned GPod.Playlist matchingPlaylist;

                    playlist.spl_update();

                    message ("Playlist %s (%u)", playlist.name,playlist.num);

                    if (playlist.is_spl) {
                    message("==> Smart Playlist detected");
                    string matchingPlaylistName;
                    matchingPlaylistName = playlist.name.replace(IPodDevice.REPLACE_PATTERN,"");
                    matchingPlaylist = db.playlist_by_name(matchingPlaylistName) ;
                    if ( matchingPlaylist != null ) {
                    message("Matching normal playlist found %s", matchingPlaylist.name);
                    cleanPlaylist(matchingPlaylist);
                    copyPlayList(playlist,matchingPlaylist);
                    }
                    }
                    });
            message("Writing ipod database ...");
            db.write();

        }catch (Error e) {
            error("Cannot read the ipod database : %s",
                    e.message);
        }

    }

    public void cleanPlaylist(GPod.Playlist playlist) {
        unowned GLib.List<unowned GPod.Track> plSongs;

        message("Cleaning playlist  : %s", playlist.name);

        plSongs = playlist.members;
        plSongs.foreach ((song) => {
                message("- Removing track : %s ", song.title);
                playlist.remove_track(song);
                });
    }

    public void copyPlayList(GPod.Playlist sourcePlaylist, GPod.Playlist
            targetPlaylist) {

        unowned GLib.List<unowned GPod.Track> plSongs;

        message("Copying playlist : %s ==> %s ", sourcePlaylist.name, targetPlaylist.name);
        plSongs = sourcePlaylist.members;
        plSongs.foreach ((song) => {

                message("+ Copying track %s-%s-%s", song.artist, song.album, song.title);
                //-1 to add the song at the end of the playlist
                targetPlaylist.add_track(song,-1);
                });

    }
}
