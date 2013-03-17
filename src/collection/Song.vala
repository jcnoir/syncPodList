using TagInfo;

public class Song :  GLib.Object {

    public Song () {
    }

    public bool is_compilation {get; set;}
    public int bitrate {get; set;}
    public int channels {get; set;}
    public int length {get; set;}
    public int samplerate {get; set;}
    public int tracknumber {get; set;}
    public int year {get; set;}
    public string album {get; set;}
    public string albumartist {get; set;}
    public string artist {get; set;}
    public string comment {get; set;}
    public string disk_string {get; set;}
    public string genre {get; set;}
    public string title {get; set;}
    public string filePath {get;set;}
    public TimeVal modificationTime{get;set;}
    public string getFormattedTime() {
        return  new DateTime.from_timeval_local(modificationTime).format("%d-%m-%Y %H:%M:%S");
    }

    public string to_string() {
        return artist + " - " + album + " - " + tracknumber.to_string() + " - " +title +
            " - " + getFormattedTime();
    }
}
