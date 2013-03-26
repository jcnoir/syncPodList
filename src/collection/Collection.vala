// modules: gio-2.0 gee-1.0 libtaginfo_c .
using TagInfo;
using Gee;

public class MusicCollection : GLib.Object {

    public string root_path {get;set;}
    public ArrayList<Song> updatedSongs {get; set;}
    public int64 lastUpdateTime {get; set;}
    public int64 id {get; set;}
    public int version = 1;
    public bool checksum_enabled {get;set;default = false;}


    public MusicCollection(string root_path) {
        this.root_path = root_path;
        this.updatedSongs = new ArrayList<Song>();
        this.checksum_enabled = checksum_enabled;
    }

    public MusicCollection.CHECKSUM(string root_path) {
        base(root_path);
        this.checksum_enabled = true;
    }

    public void update() {
        var timer = new Timer();
        double elpasedSecs;

        this.updatePath(this.root_path);
        timer.stop ();
        message("Updating collection : %s", root_path );
        elpasedSecs  = timer.elapsed ();
        message("Update duration : %s secs", elpasedSecs.to_string());
        message("New/Updated songs found : %u", this.updatedSongs.size);
        this.lastUpdateTime = Utils.now();
        message("End of updating collection : %s", root_path );
    }

    public void updatePath(string rootFolderPath) {

        try {
            var directory = File.new_for_path (rootFolderPath);
            var enumerator = directory.enumerate_children ("*", 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                if (file_info.get_file_type() == FileType.REGULAR ) {
                    if (isCompatibleExtension( file_info.get_name() ) && file_info.get_modification_time().tv_sec > lastUpdateTime) {
                        processSong( directory.get_child(file_info.get_name()).get_path() );
                    }}
                else if (file_info.get_file_type() == FileType.DIRECTORY) {
                    this.updatePath(directory.get_child(file_info.get_name()).get_path());
                }
            }

        } catch (Error e) {
            message("Error: %s", e.message);
        }
    }

    private void processSong(string filename) {

        Song song;
        try {
            song = findSong(filename);
            this.updatedSongs.add(song);
        }
        catch (Error e) {
            warning("Song process failure for %s : %s" , filename, e.message);
        }
    }
    public static bool isCompatibleExtension (string filename) {

        return GLib.Regex.match_simple("(^)(.*)(AAC|AIF|APE|ASF|FLAC|M4A|M4B|M4P|MP3|MP4|MPC|OGA|OGG|TTA|WAV|WMA|WV|SPEEX|WMV)($)",filename.up());
    }

    public Song findSong (string filePath) {

        var song = getSong(filePath);

        if (this.checksum_enabled) {
            song.checksum = Utils.computeChecksum(filePath);
        }

        message(@"Song metadata : $song");
        return song;
    }

    public static Song getSong (string filePath) {

        Song song = null;
        TagInfo.Info info;

        info = TagInfo.Info.factory_make(filePath);

        if ( info.read() ) {

            song = new Song();
            song.artist=info.artist ?? "";        
            song.albumartist=info.albumartist ?? "";
            song.album=info.album ?? "";
            song.title=info.title ?? "";
            song.genre=info.genre ?? "";
            song.comment=info.comment ?? "";
            song.disk_string=info.disk_string ?? "";
            song.bitrate = info.bitrate ;
            song.channels = info.channels ;
            song.length = info.length  ;
            song.samplerate = info.samplerate ;
            song.tracknumber = info.tracknumber;
            song.year = info.year ;
            song.filePath = filePath;

        }
        else {
            warning("Parsing failure !");
        }


        return song; 

    }
    public string getFormattedLastUpdateTime() {
        return Utils.formatDate(this.lastUpdateTime);
    }
    public string to_string() {
        var sb = new StringBuilder();
        sb.append("id=" +id.to_string() + ", ");
        sb.append("lastUpdateTime=" +Utils.formatDate(lastUpdateTime) + ", ");
        sb.append("root_path=" +root_path + ", ");
        sb.append("version=" +version.to_string() + ", ");
        return sb.str;
    }
}
