public interface IHttpRequestService {
    HTTPResponse doPost(String namedCredential, String relativePath, Map<String,String> queryStringParams);
}