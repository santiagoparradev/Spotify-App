public class ItemsTrack {
    public SimplefieldTracksObject track;
    public static ItemsTrack parse(String jsonBody) {
        return (ItemsTrack) JSON.deserialize(jsonBody, ItemsTrack.class);
    }
}