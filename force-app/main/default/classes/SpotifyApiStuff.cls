public class SpotifyApiStuff {

    public static String TOKEN_ENDPOINT = 'https://accounts.spotify.com/api/token';
    public static Integer SUCCESS_STATUS_CODE = 200;
    public static Integer LIMIT_PLAYLIST = 50;
    public static String PLAYLIST_ENDPOINT = 'https://api.spotify.com/v1/users/{0}/playlists?limit={1}&offset={2}';
    public static String TRACK_ENDPOINT = 'https://api.spotify.com/v1/playlists/{0}/tracks';
    public static String ALBUM_ENDPOINT = 'https://api.spotify.com/v1/albums?ids={0}';
}