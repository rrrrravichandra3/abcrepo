public class LinkedLearningCatalogueAPI {

    // Replace these values with your actual API endpoint, client ID, and client secret
    private static final String API_ENDPOINT = 'https://api.example.com/linked-learning-catalogue';
    private static final String CLIENT_ID = '86bbvdlvezu1gr';
    private static final String CLIENT_SECRET = '60QMB0cKFANrhTIF';

    public static void callApi() {
        HttpRequest request = new HttpRequest();
        HttpResponse response;

        // Set the endpoint URL
        request.setEndpoint(API_ENDPOINT);

        // Set the HTTP method
        request.setMethod('GET');

        // Set the request headers
        request.setHeader('Content-Type', 'application/json');

        // Set the OAuth 2.0 authentication headers
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(CLIENT_ID + ':' + CLIENT_SECRET));
        request.setHeader('Authorization', authHeader);

        try {
            // Send the HTTP request
            Http http = new Http();
            response = http.send(request);

            // Check the response status
            if (response.getStatusCode() == 200) {
                // Parse and process the response
                String responseBody = response.getBody();
                // Process the responseBody as needed
                System.debug('API Response: ' + responseBody);
            } else {
                System.debug('API Request failed with status code: ' + response.getStatusCode());
                System.debug('Response Body: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
        }
    }
}