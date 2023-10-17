public class PlaylistIdResponse {
    public List<ImagesResponse> images;
    public static PlaylistIdResponse parse(String jsonBody) {
        return (PlaylistIdResponse) JSON.deserialize(jsonBody, PlaylistIdResponse.class);
    }
}