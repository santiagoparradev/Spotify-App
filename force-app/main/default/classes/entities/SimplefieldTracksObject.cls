public class SimplefieldTracksObject {
    public SimplefieldAlbumsObject album;
    public List<String> available_markets;
    public Integer disc_number;
    public Integer duration_ms;
    public Boolean explicit;
    public ExternalUrls external_urls;
    public String id;
    public String name;
    public Integer popularity;
    public static SimplefieldTracksObject parse(String jsonBody) {
        return (SimplefieldTracksObject) JSON.deserialize(jsonBody, SimplefieldTracksObject.class);
    }
}