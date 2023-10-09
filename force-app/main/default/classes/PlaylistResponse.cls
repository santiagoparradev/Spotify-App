public class PlaylistResponse {
    public list<SimplefiedPlaylistObject> items;
    public static PlaylistResponse parse(String jsonBody) {
        return (PlaylistResponse) JSON.deserialize(jsonBody, PlaylistResponse.class);
    }
}