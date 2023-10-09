public class External_urls {
    String spotify;
    public static External_urls parse(String jsonBody) {
        return (External_urls) JSON.deserialize(jsonBody, External_urls.class);
    }
}