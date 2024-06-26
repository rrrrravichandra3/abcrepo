public interface IGoogleAnalyticsService {
  List<HttpResponse> sendEvents(List<GoogleAnalyticsEvent> events);
}