public class BaseResponse {

    public List<ImagesResponse> images;
    public static BaseResponse parse(String jsonBody) {
        return (BaseResponse) JSON.deserialize(jsonBody, BaseResponse.class);
    }
}