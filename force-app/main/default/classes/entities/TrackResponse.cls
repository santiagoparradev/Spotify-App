public class TrackResponse {
    public List<ItemTrack> items;
    public Integer total;
    public static TrackResponse parse(String jsonBody) {
        return (TrackResponse) JSON.deserialize(jsonBody, TrackResponse.class);
    }
}