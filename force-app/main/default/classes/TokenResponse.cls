public class TokenResponse {
	public String access_token;
    public String token_type;
    public Integer expires_in;
    public static TokenResponse parse(String jsonBody) {
        return (TokenResponse) JSON.deserialize(jsonBody, TokenResponse.class);
    }
}