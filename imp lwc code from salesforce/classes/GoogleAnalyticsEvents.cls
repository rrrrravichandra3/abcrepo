public with sharing class GoogleAnalyticsEvents implements IGoogleAnalyticsEvents{

    public with sharing class CommonParameters {
      public String protocolVersion;
      public String trackingId;
      public String clientId;
      public String hitType;
    }

    private List<GoogleAnalyticsEvent> events;
    private GoogleAnalyticsEvents.CommonParameters commonParams;

    public GoogleAnalyticsEvents(GoogleAnalyticsEvents.CommonParameters commonParams,
                                 List<GoogleAnalyticsEvent> events) {
      this.commonParams = commonParams;
      // TODO - Implement validation of 'this.commonParams'. Throw exception if invalid data
      this.events = events;
    }
    
    public void validate() {
      // TODO - Implement validation of 'this.events'. Throw exception if invalid data
    }

    private Map<String, String> convertEventToParamsMap(GoogleAnalyticsEvent event) {
      Map<String, String> m = new Map<String, String>();
      
      // Common parameters
      if (String.isNotEmpty(this.commonParams.protocolVersion)) m.put('v', this.commonParams.protocolVersion);
      if (String.isNotEmpty(this.commonParams.trackingId)) m.put('tid', this.commonParams.trackingId);
      if (String.isNotEmpty(this.commonParams.clientId)) m.put('cid', this.commonParams.clientId);
      if (String.isNotEmpty(this.commonParams.hitType)) m.put('t', this.commonParams.hitType);

      // Event specific parameters
      if (String.isNotEmpty(event.category)) m.put('ec', event.category);
      if (String.isNotEmpty(event.action)) m.put('ea', event.action);
      if (String.isNotEmpty(event.label)) m.put('el', event.label);
      if (String.isNotEmpty(event.value)) m.put('ev', event.value);

      return m;
    }

    public List<HttpResponse> sendToGoogleServer(Boolean debugMode) {
      this.validate();

      List<HttpResponse> responses = new List<HttpResponse>();
      for (GoogleAnalyticsEvent event : this.events) {
        HttpRequestService service = new HttpRequestService();
        Map<String, String> params = this.convertEventToParamsMap(event);
        
        String relativePath = '/collect';
        if (debugMode) relativePath = ('/debug' + relativePath);

        HttpResponse r = service.doPost('GoogleAnalytics', relativePath, params);
        responses.add(r);
      }

      return responses;    
    }
}