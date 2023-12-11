public class SimplefiedPlaylistObject {

    public Boolean collaborative;
    public String description;
    public ExternalUrls external_urls;
    public String id;
    public String name;
    public Boolean publicField;
    public Integer followers;
    
    public static SimplefiedPlaylistObject parse(String jsonBody) {
        return (SimplefiedPlaylistObject) JSON.deserialize(jsonBody, SimplefiedPlaylistObject.class);
    }
}