public class ItemTrack {
    
    public SimplefieldTracksObject track;
    public static ItemTrack parse(String jsonBody) {
        return (ItemTrack) JSON.deserialize(jsonBody, ItemTrack.class);
    }
}