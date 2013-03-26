// modules: gio-2.0 gee-1.0 libtaginfo_c .
using TagInfo;

public class Song :  GLib.Object {

    public Song () {
    }

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
    public string filePath {get;set;}
    public string genre {get; set;}
    public string title {get; set;}
    public string checksum {get; set;default = "";}

    public string to_string() {
        var sb = new StringBuilder();
        sb.append("album=");
        sb.append(album);
        sb.append(", ");
        sb.append("artist=");
        sb.append(artist);
        sb.append(", ");
        sb.append("albumartist=");
        sb.append(albumartist);
        sb.append(", ");
        sb.append("bitrate=");
        sb.append(bitrate.to_string());
        sb.append(", ");
        sb.append("channels=");
        sb.append(channels.to_string());
        sb.append(", ");
        sb.append("comment=");
        sb.append(comment);
        sb.append(", ");
        sb.append("disk_string=");
        sb.append(disk_string);
        sb.append(", ");
        sb.append("filePath=");
        sb.append(filePath);
        sb.append(", ");
        sb.append("genre=");
        sb.append(genre);
        sb.append(", ");
        sb.append("length=");
        sb.append(length.to_string());
        sb.append(", ");
        sb.append("samplerate=");
        sb.append(samplerate.to_string());
        sb.append(", ");
        sb.append("title=");
        sb.append(title);
        sb.append(", ");
        sb.append("tracknumber=");
        sb.append(tracknumber.to_string());
        sb.append(", ");
        sb.append("year=");
        sb.append(year.to_string());
        sb.append(", ");
        sb.append("checksum=");
        sb.append(checksum);
        return sb.str;
    }
}
