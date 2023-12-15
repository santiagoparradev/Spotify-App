public class ArtistResponse {
    
    public List<SimplefieldArtistObject> artists;
    public static ArtistResponse parse(String jsonBody) {
        return (ArtistResponse) JSON.deserialize(jsonBody, ArtistResponse.class);
    }
}