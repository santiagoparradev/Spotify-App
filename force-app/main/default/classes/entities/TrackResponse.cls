public class TrackResponse {

    public List<ItemTrack> items;
    public Integer total;
    
    public static TrackResponse parse(String jsonBody) {
        return (TrackResponse) JSON.deserialize(jsonBody, TrackResponse.class);
    }

    public Set<String> getAlbumIds() {

        Set<String> result = new Set<String>();

        for (ItemTrack item : this.items) {
            if (!result.contains(item.track.album.id)) {
                result.add(item.track.album.id);
            }
        }

        return result;
    }
}