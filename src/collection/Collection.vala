using TagInfo;

public class MusicCollection : GLib.Object {

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
            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                if (file_info.get_file_type() != FileType.DIRECTORY) {
                    stdout.printf("File : %s \n", file_info.get_name());
                    if (isCompatibleExtension( file_info.get_name() )) {
                        displaySongTags( directory.get_child(file_info.get_name()).get_path() );
                    }
                    else {
                        stdout.printf ("Extension is NOT compatible.\n" );
                    }
                }
                else {
                    this.listFiles(directory.get_child(file_info.get_name()).get_path());
                }
            }

        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }

    }

    private void displaySongTags(string filename) {

        Info info;

        try {
            info = TagInfo.Info.factory_make(filename);
            if ( info.read() ) {
                stdout.printf( "==> %s - %u - %s - %u - %s \n", info.artist,       
                               info.year, info.album, info.tracknumber, info.title );
            }
            else {

                stdout.printf("Parsing failure !   \n");
            }
        }
        catch (Error e) {
            stderr.printf("Cannot read the tag infos : %s \n", e.message);
        }
    }

    public static bool isCompatibleExtension (string filename) {

        return GLib.Regex.match_simple("(^)(.*)(AAC|AIF|APE|ASF|FLAC|M4A|M4B|M4P|MP3|MP4|MPC|OGA|OGG|TTA|WAV|WMA|WV|SPEEX|WMV)($)",filename.up());

    }
}
