using TagInfo;

public class MusicCollection : GLib.Object {

    private int processedSongCounter = 0 ;

    private Timer timer = new Timer();

    private Dao dao;


    public MusicCollection() {
        this.dao = new Dao();
    }

    static int main (string[] args) {


        MusicCollection collection;
        string collectionPath;

        if ( args.length > 1 ) {
            collectionPath = args[1];
        }
        else {
            collectionPath = "/media/donnees/dev/syncPodList/src/resources/music";
        }

        stdout.printf("Music collection is starting \n");
        collection = new MusicCollection();
        collection.listFiles(collectionPath);
        return 0;
    }

    private void listFiles(string rootFolderPath) {

        try {

            stdout.printf(@"\nFolder : $rootFolderPath \n");

            var directory = File.new_for_path (rootFolderPath);
            var enumerator = directory.enumerate_children ("*", 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {

                if (file_info.get_file_type() == FileType.REGULAR ) {
                    stdout.printf("File : %s \n", file_info.get_name());
                    if (isCompatibleExtension( file_info.get_name() )) {
                        displaySongTags( directory.get_child(file_info.get_name()).get_path() );
                    }
                }
                else if (file_info.get_file_type() == FileType.DIRECTORY) {
                    this.listFiles(directory.get_child(file_info.get_name()).get_path());
                }
            }

        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }

    }

    private void displaySongTags(string filename) {

        Info info;
        ulong microseconds;
        double seconds;

        try {
            info = TagInfo.Info.factory_make(filename);
            if ( info.read() ) {
                this.getSong(info,filename,File.new_for_path
                             (filename).query_info("*", FileQueryInfoFlags.NONE).get_modification_time());
                stdout.printf("Processed song counter : %u, ", this.processedSongCounter++);
                seconds = timer.elapsed (out microseconds);
                stdout.printf ("Elapsed time : %s seconds, ", seconds.to_string ());
                stdout.printf ("Average speed : %s seconds/ 1000 songs \n", (1000 * seconds/processedSongCounter).to_string());

            }
            else {

                stderr.printf("Parsing failure !   \n");
            }
        }
        catch (Error e) {
            stderr.printf("Cannot read the tag infos : %s \n", e.message);
        }
    }

    public static bool isCompatibleExtension (string filename) {

        return GLib.Regex.match_simple("(^)(.*)(AAC|AIF|APE|ASF|FLAC|M4A|M4B|M4P|MP3|MP4|MPC|OGA|OGG|TTA|WAV|WMA|WV|SPEEX|WMV)($)",filename.up());

    }

    private Song getSong (Info info, string filePath, TimeVal modificationTime) {

        Song song;
        string[] DEFAULT_STRINGS = new string[0];
        uint8[] DEFAULT_US = new uint8[0];

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
        song.modificationTime = modificationTime;

        stdout.printf(@"New song created : $song \n");
        this.dao.createSong(song);
        return song; 

    }

}
