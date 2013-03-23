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
        this.relativeRoot = relativeRoot +"/";

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
}
