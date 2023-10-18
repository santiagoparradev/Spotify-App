public class PlaylistResponse {

    public List<ImagesResponse> images;
    public static PlaylistResponse parse(String jsonBody) {
        return (PlaylistResponse) JSON.deserialize(jsonBody, PlaylistResponse.class);
    }
}