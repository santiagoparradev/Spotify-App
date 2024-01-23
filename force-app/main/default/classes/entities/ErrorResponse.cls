public class ErrorResponse {

    public SimplefieldError error;

    public static ErrorResponse parse(String jsonBody) {
        return (ErrorResponse) JSON.deserialize(jsonBody, ErrorResponse.class);
    }

}