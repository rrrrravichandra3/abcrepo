public with sharing class GoogleAnalyticsService implements IGoogleAnalyticsService {
    
    private String trackingId;
    private Boolean includeClientId;

    public Boolean debugMode {get; set;}

    public GoogleAnalyticsService(String trackingId, Boolean includeClientId) {
      this.trackingId = trackingId;
      this.includeClientId = includeClientId;
      this.debugMode = false;
    }

    public List<HttpResponse> sendEvents(List<GoogleAnalyticsEvent> events) {
      GoogleAnalyticsEvents.CommonParameters commonParams = new GoogleAnalyticsEvents.CommonParameters();
      commonParams.protocolVersion = '1';
      commonParams.hitType = 'event';
      commonParams.trackingId = this.trackingId;

      if(this.includeClientId == true) {
        // TODO - Provide actual clientId (encrypted?)
        // WARNING - Do not send any PII. Encrypt Salesforce User record id?
        // NOTE - Although in the documenation says that the 'cid' parameter is optional. I got
        //        an error saying: "A value is required for parameter 'cid'. Please see http://goo.gl/a8d4RP#cid for details."
        commonParams.clientId = 'sampleClientId';
      }

      GoogleAnalyticsEvents gaEvents = new GoogleAnalyticsEvents(commonParams, events);
      return (gaEvents.sendToGoogleServer(this.debugMode));

    }
}