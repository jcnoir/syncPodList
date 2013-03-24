using TagInfo;
using Gee;

public class MusicCollection : GLib.Object {

    public string rootPath {get;set;}
    public ArrayList<Song> songs {get; set;}
    public ArrayList<Song> updatedSongs {get; set;}
    public int64 lastUpdateTime {get; set;}
    public int64 id {get; set;}
    public int version = 1;


    public MusicCollection(string rootPath) {
        this.rootPath = rootPath;
        this.songs = new ArrayList<Song>();
        this.updatedSongs = new ArrayList<Song>();
    }

    public void update() {
        this.listFiles(this.rootPath);
        message("Total songs found : %u", this.songs.size);
        message("New/Updated songs found : %u", this.updatedSongs.size);
        this.lastUpdateTime = Utils.now();
    }

    public void listFiles(string rootFolderPath) {

        try {
            var directory = File.new_for_path (rootFolderPath);
            var enumerator = directory.enumerate_children ("*", 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                if (file_info.get_file_type() == FileType.REGULAR ) {
                    if (isCompatibleExtension( file_info.get_name() )) {
                        processSong( directory.get_child(file_info.get_name()).get_path() );
                    }}
                else if (file_info.get_file_type() == FileType.DIRECTORY) {
                    this.listFiles(directory.get_child(file_info.get_name()).get_path());
                }
            }

        } catch (Error e) {
            message("Error: %s", e.message);
        }
    }

    private void processSong(string filename) {

        Song song;
        long modificationTime;

        try {
            song = MusicCollection.getSong(filename);
            modificationTime = File.new_for_path(filename).query_info("*", FileQueryInfoFlags.NONE).get_modification_time().tv_sec;

            this.songs.add(song);
            if (modificationTime > this.lastUpdateTime) {
                message("Updated song detected ! ");
                this.updatedSongs.add(song);
            }}
        catch (Error e) {
            warning("Song process failure for %s : %s" , filename, e.message);
        }
    }
    public static bool isCompatibleExtension (string filename) {

        return GLib.Regex.match_simple("(^)(.*)(AAC|AIF|APE|ASF|FLAC|M4A|M4B|M4P|MP3|MP4|MPC|OGA|OGG|TTA|WAV|WMA|WV|SPEEX|WMV)($)",filename.up());
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
            message(@"Song metadata : $song");
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
        sb.append("rootPath=" +rootPath + ", ");
        sb.append("version=" +version.to_string() + ", ");
        return sb.str;
    }
}
