public class AlbumResponse {
    public List<SimplefieldAlbumsObject> albums;
    public static AlbumResponse parse(String jsonBody) {
        return (AlbumResponse) JSON.deserialize(jsonBody, AlbumResponse.class);
    }
}