public class PlaylistResponse {
    public list<SimplefiedPlaylistObject> items;
    public Integer total;
    public static PlaylistResponse parse(String jsonBody) {
        return (PlaylistResponse) JSON.deserialize(jsonBody, PlaylistResponse.class);
    }
}