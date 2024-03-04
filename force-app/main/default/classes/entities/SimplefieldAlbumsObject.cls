public class SimplefieldAlbumsObject {
    
    public String name;
    public List<SimplefieldArtistObject> artists;
    public List<String> genres;
    public Integer popularity;
    public Date release_date;
    public String id;
    public Integer total_tracks;
    public ExternalUrls external_urls;

    public static SimplefieldAlbumsObject parse(String jsonBody) {
        return (SimplefieldAlbumsObject) JSON.deserialize(jsonBody, SimplefieldAlbumsObject.class);
    }
}