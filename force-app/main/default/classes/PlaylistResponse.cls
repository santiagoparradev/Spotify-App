public class PlaylistResponse {
    public List<SimplefiedPlaylistObject> items;
    public static PlaylistResponse parse(String jsonBody) {
        return (PlaylistResponse) JSON.deserialize(jsonBody, PlaylistResponse.class);
    }
}