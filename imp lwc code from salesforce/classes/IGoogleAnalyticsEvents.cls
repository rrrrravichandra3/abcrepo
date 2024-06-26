public interface IGoogleAnalyticsEvents {
  void validate();
  List<HTTPResponse> sendToGoogleServer(Boolean debugMode);
}