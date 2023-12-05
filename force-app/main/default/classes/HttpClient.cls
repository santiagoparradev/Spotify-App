public virtual class HttpClient {

    public enum Method { GET, POST, PUT, PATCH }
    public static final String DELETE_METHOD = 'DELETE';
  
    public HttpClient() {}
  
    @testVisible protected HttpRequest request = new HttpRequest();
    @testVisible protected HttpResponse response;
    protected String endPoint;
    protected String method;
  
    private static final String END_POINT_REQUIRED_ERROR_MESSAGE = 'Endpoint is required.';
  
    public virtual HttpClient setEndpoint(String endPoint, String path) {
  
      if (String.isBlank(endpoint)) {
        throw new HttpClientException(END_POINT_REQUIRED_ERROR_MESSAGE);
      }
  
      this.endPoint = endpoint + (String.isNotBlank(path) ? path : '');
      request.setEndpoint(this.endPoint);
      return this;
    }
  
    public virtual HttpClient setMethod(Method value) {
      return setMethod(value.name());
    }
  
    public virtual HttpClient setMethod(String value) {
      request.setMethod(value);
      method = value;
      return this;
    }
  
    public virtual HttpClient setBody(String body) {
  
      if (String.isNotBlank(body)) {
        request.setBody(body);
      }
  
      return this;
    }
  
    public virtual HttpClient setBody(Blob body) {
  
      if (body != null) {
        request.setBodyAsBlob(body);
      }
  
      return this;
    }
  
    public virtual HttpClient send() {
  
      if (String.isBlank(method)) {
        throw new HttpClientException('Method is required.');
      }
  
      if (String.isBlank(endPoint)) {
        throw new HttpClientException(END_POINT_REQUIRED_ERROR_MESSAGE);
      }
  
      response = new Http().send(request);
      return this;
    }
  
    public virtual HttpResponse getResponse() {
      return response;
    }
  
    public virtual HttpClient setHeader(String key, String value) {
  
      if (String.isNotBlank(key)) {
        request.setHeader(key, value);
      }
  
      return this;
    }
  
    public virtual HttpClient setTimeOut(Integer timeOut) {
      request.setTimeout(timeOut);
      return this;
    }
  
    public class HttpClientException extends Exception {}
  }