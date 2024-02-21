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

    public List<SimplefieldTracksObject> getTracks() { 

        List<SimplefieldTracksObject> result = new List<SimplefieldTracksObject>();

        for (ItemTrack item : this.items) {
            result.add(item.track);
        }

        return result;
    }

    public Set<String> getArtistIds() {

        Set<String> result = new Set<String>();

        for (ItemTrack item : this.items) {

            SimplefieldTracksObject track = item.track;

            for (SimplefieldArtistObject artist : track.artists) {

                if (!result.contains(artist.id)) {
                    result.add(artist.id);
                }
            }
        }

        return result;
    }
}