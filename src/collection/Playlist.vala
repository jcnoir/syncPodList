using Gee;
public class PlayList : GLib.Object {

    public ArrayList<Song> songs {get; set;}
    public string relativeRoot {get; set;}
    public string playlistPath {get; set;}

    public PlayList(string playlistPath) {
        PlayList.Relative(playlistPath, "");
    }

    public PlayList.Relative(string playlistPath, string relativeRoot) {
        this.playlistPath = playlistPath;
        this.relativeRoot = relativeRoot;

        message("Playlist created from file : %s, relative entry root : %s ", this.playlistPath,this.relativeRoot );
    }

    public void read() {

        try {
            songs = new ArrayList<Song>();

            message("Parsing playlist file : %s", playlistPath);

            // A reference to our file
            var file = File.new_for_path (playlistPath);

            if (!file.query_exists ()) {
                error ("File '%s' doesn't exist.", file.get_path ());
            }

            // Open file for reading and wrap returned FileInputStream into a
            // DataInputStream, so we can read line by line
            var dis = new DataInputStream (file.read ());
            string line;
            // Read lines until end of file (null) is reached
            while ((line = dis.read_line (null)) != null) {

                File entryFile;

                if (isValidLine(line)) {

                    entryFile = File.new_for_path (relativeRoot + line);

                    if (entryFile.query_exists ()) {                   
                        var song = MusicCollection.getSong(entryFile.get_path());
                        this.songs.add(song);
                    }
                    else {
                        warning("Playlist entry file not found : %s",
                                entryFile.get_path());
                    }

                }

                else {
                    message("Ignore playlist line : %s" , line);
                }
            }
        } catch (GLib.Error e) {
            error ("Playlist read failure:  %s", e.message);
        }
    }

    private bool isValidLine(string line) {
        return !GLib.Regex.match_simple("(^)(.*)(#)(.*)($)", line);
    }

    public void  write() {
        try {

            // Reference a local file name
            var file = File.new_for_path (playlistPath);

            {
                // delete if file already exists
                if (file.query_exists ()) {
                    message("Target playlist file already exists, replacing it ...");
                    file.delete ();
                }
                // Create a new file with this name
                var file_stream = file.create(FileCreateFlags.REPLACE_DESTINATION);

                // Test for the existence of file
                if (file.query_exists ()) {
                    message ("File successfully created.");
                }

                // Write text data to file
                var data_stream = new DataOutputStream (file_stream);

                foreach (Song song in songs) {
                    var text = song.filePath.replace(this.relativeRoot,"");
                    data_stream.put_string (text +"\n");

                }
            } // Streams closed at this point

        } catch (Error e) {
            warning  ("Error: %s", e.message);
        }

    }

}
