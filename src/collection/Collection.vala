using TagInfo;
using Gee;

public class MusicCollection : GLib.Object {

    private int processedSongCounter = 0 ;
    private string rootPath;
    public ArrayList<Song> songs {get; set;}
    public ArrayList<Song> updatedSongs {get; set;}
    public long lastUpdateTime {get; set;}

    public MusicCollection(string rootPath) {
        this.rootPath = rootPath;
        this.songs = new ArrayList<Song>();
        this.updatedSongs = new ArrayList<Song>();
    }

    public void update() {
        this.listFiles(this.rootPath);
        message("Total songs found : %u", this.songs.size);
        message("New/Updated songs found : %u", this.updatedSongs.size);
    }

    public void listFiles(string rootFolderPath) {

        try {
            long modificationTime;
            message(@"Folder : $rootFolderPath");

            var directory = File.new_for_path (rootFolderPath);
            var enumerator = directory.enumerate_children ("*", 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                if (file_info.get_file_type() == FileType.REGULAR ) {
                    if (isCompatibleExtension( file_info.get_name() )) {
                        message("File : %s" , file_info.get_name());
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

        Info info;
        Song song;
        long modificationTime;

        try {
            info = TagInfo.Info.factory_make(filename);
            if ( info.read() ) {
                song = this.getSong(info,filename);
                modificationTime = File.new_for_path(filename).query_info("*", FileQueryInfoFlags.NONE).get_modification_time().tv_sec;

                this.songs.add(song);
                if (modificationTime > this.lastUpdateTime) {
                    message("Updated song detected ! ");
                    this.updatedSongs.add(song);
                }
            }
            else {
                error("Parsing failure !");
            }
        }
        catch (Error e) {
            error("Cannot read the tag infos : %s", e.message);
        }
    }

    public static bool isCompatibleExtension (string filename) {

        return GLib.Regex.match_simple("(^)(.*)(AAC|AIF|APE|ASF|FLAC|M4A|M4B|M4P|MP3|MP4|MPC|OGA|OGG|TTA|WAV|WMA|WV|SPEEX|WMV)($)",filename.up());
    }

    private Song getSong (Info info, string filePath) {

        Song song;

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
        return song; 

    }
    public string getFormattedLastUpdateTime() {
        return Utils.formatDate(lastUpdateTime);
    }
}
