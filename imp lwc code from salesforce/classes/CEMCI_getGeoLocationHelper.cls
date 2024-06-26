public with sharing class CEMCI_getGeoLocationHelper {
  public static Map<String, Object> getGeoLocation(String addressString) {
    Map<string, object> options = new Map<String, Object>{
      'version' => '1', // Required. Version of the API endpoint. Must be '1'.
      'address' => addressString
    };

    // Call the Geocode() method with the address.
    Map<String, Object> response = maps.API.Geocode(options);

    // Log the resulting geographical coordinates and formatted address.
    system.debug(response);

    system.debug(response.get('data'));
    Map<String, Object> data = (Map<String, Object>) response.get('data');
    return (Map<String, Object>) data.get('position');
  }
}