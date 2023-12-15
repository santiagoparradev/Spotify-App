public  class SimplefieldArtistObject {

    public ExternalUrls external_urls;
    public Followers followers;
    //public List<String> genres;
    public String id;
    public String name;
    public Integer popularity;

    public static SimplefieldArtistObject parse(String jsonBody) {
        return (SimplefieldArtistObject) JSON.deserialize(jsonBody, SimplefieldArtistObject.class);
    }
}