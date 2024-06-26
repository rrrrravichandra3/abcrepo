/**
 * @author Angel Abrego Ramirez <aabrego@salesforce.com>
 * @date 2017-09-22
 * @description Controller of the TalentforceRedirect Visualforce component.
 *              It is a wrapper that exposes all the configurations needed
 *              in the redirect logic via "getter" methods. Configuration
 *              is read from aTalentforce_Redirect__mdt Custom Metadata 
 *              record.
 */
public class TalentforceRedirectController {
  
  // Custom Metadata record that we use as source of all configurations
  @TestVisible private Talentforce_Redirect__mdt config;
  
  /**
   * @description configuration getter. Required by an <apex:attribute> in the
   *              Talenforce Redirect component
   */
   public String configuration {get;} 

  /**
   * @description Queries and sets the redirect configuration. 
   * @param configurationName DeveloperName of Talentforce_Redirect__mdt 
   *        record to query. In the Talenforce Redirect component,
   *        value is provided via an <apex:attribute>      
   */
  public void setConfiguration(String configurationName) {

    List<Talentforce_Redirect__mdt> configs;
    configs = [select Redirect_Url__c,
                      Disable_Client_Side_Redirect__c,
                      Fallback_Type__c,
                      Fallback_Delay__c,
                      Fallback_Message_Logo__c,
                      Fallback_Message_Title__c,
                      Fallback_Message_Before_Clickable_Text__c,
                      Fallback_Message_Clickable_Text__c,
                      Fallback_Message_After_Clickable_Text__c,
                      Fallback_Banner__c, 
                      Fallback_Banner_Clickable__c,
                (select Querystring_Parameter__c, 
                        Querystring_Parameter_Regex_Validation__c 
                from Talentforce_Redirect_Parameters__r)
              from Talentforce_Redirect__mdt
              where DeveloperName = :configurationName];

    if (configs.size() == 0) {
      throw new TalentforceRedirectException('No redirect configurations were found');
    } else {
      this.config = configs[0];
    }
  }

  // -------------------- Talentforce Redirect Details ------------------------

  /**
   * @description Gets the destination PageReference of the redirection.
   * @return A PageReference to the redirection destination page, including
   *         the parameters indicated in the configuration (if present in 
   *         current page, and valid)
   */
  public PageReference getRedirectPageReference() {
    PageReference pr;

    if (config != null && !String.isEmpty(config.Redirect_Url__c)) {
      // The redirect Url is coming from the configuration.
      pr = new PageReference(config.Redirect_Url__c);

      // From the configuration, we get the querystring parameters that we
      // are interested on carryover to the redirect Url
      String paramValue;
      for (Talentforce_Redirect_Parameter__mdt param : config.Talentforce_Redirect_Parameters__r) {
        if (!String.isEmpty(param.Querystring_Parameter__c)) {

          // Getting the parameter value of the currrent page.
          paramValue = ApexPages.currentPage().getParameters().get(param.Querystring_Parameter__c);

          if (!String.isEmpty(paramValue)) {
            // If Regex expression to validate the parameter value is provided,
            // we make sure the value matches before we included in the destination
            // page (redirect Url)
            if (!String.isEmpty(param.Querystring_Parameter_Regex_Validation__c)) {
              if (!Pattern.matches(param.Querystring_Parameter_Regex_Validation__c, paramValue)) {
                continue;
              }
            }
            // The querystring parameter indicated in the redirect configuration, 
            // is here included in the destination page (redirect Url)
            pr.getParameters().put(param.Querystring_Parameter__c, paramValue);
          }
        }       
      }
      pr.setRedirect(true);
    }
    return pr;
  }

  /**
   * @description Gets the complete redirect URL string
   * @return A String with the complete URL for the redirection as generated
   *         in the getRedirectPageReference() method
   */
  public String getRedirectUrl() {
    String redirectUrl;
    
    PageReference pr;
    pr = this.getRedirectPageReference();
    if (pr != null) {
      redirectUrl = pr.getUrl();
    }
    return redirectUrl;
  }
  
  /**
   * @description When automatic redirect fails it indicates the type of 
   *              fallback to be used.
   * @return "Message" - We display logo, title and a text message
   *         "Banner"  - We display an image(banner)
   */
  public String getFallbackType() {
    String fallBackType;
    if (config != null) {
      fallBackType = config.Fallback_Type__c;
    }
    return fallBackType;
  }

  /**
   * @description It is used to disable the execution of the Javascript code 
   *              the executes the client side redirection.
   * @return If TRUE Javascript redirect is meant to disabled, if FALSE it is 
   *         not
   */
  public Boolean getIsClientSideRedirectDisabled() {
    Boolean isDisabled = false;
    if (config != null) {
      isDisabled = config.Disable_Client_Side_Redirect__c;
    }
    return isDisabled;
  }

  /**
   * @description This is the time we'll wait for the client side redirect to be
   *              completed. This is used to prevent the "page flicker during 
   *              client side redirection". 
   *              IE browsers: 10+ is required. This is a pure CSS solution, 
   *              given that if client side redirect failed, there is likely a 
   *              problem with Javascript.
   * @return A String representing the numbers of seconds to wait before 
   *         displaying the fallback message/banner.
   */
  public String getFallbackDelay() {
    String fallbackDelay = '0';
    if (config != null && config.Fallback_Delay__c != null) {
      fallbackDelay = String.valueOf(config.Fallback_Delay__c);
    }
    return fallbackDelay;
  }

  // ------------------------ Fallback Message --------------------------------
  // Getters of the configuration used when the "Fallback Type" is "Message"
  // Description to all the configuration properties is detailed in the
  // description of the Talentforce_Redirect__mdt fields themselves.

  public String getFallbackMessageLogoStaticResourceName(){
    String logoStaticResourceName;
    if (config != null && !String.isEmpty(config.Fallback_Message_Logo__c)) {
        logoStaticResourceName = config.Fallback_Message_Logo__c;  
    }
    return logoStaticResourceName;
  }
  public String getFallbackMessageTitle() {
    String title;
    if (config != null) {
      title = config.Fallback_Message_Title__c;
    }
    return title;
  }
  public String getFallbackMessageBeforeClickableText() {
    String beforeClickableText;
    if (config != null) {
      beforeClickableText = config.Fallback_Message_Before_Clickable_Text__c;
    }
    return beforeClickableText;
  }
  public String getFallbackMessageClickableText() {
    String clickableText;
    if (config != null) {
      clickableText = config.Fallback_Message_Clickable_Text__c;
    }
    return clickableText;
  }

  public String getFallbackMessageAfterClickableText() {
    String afterClickableText;
    if (config != null) {
      afterClickableText = config.Fallback_Message_After_Clickable_Text__c;
    }
    return afterClickableText;
  }
  
  // ------------------------ Fallback Banner -------------------------------- 
  // Getters of the configuration used when the "Fallback Type" is "Banner"
  // Description to all the configuration properties is detailed in the
  // description of the Talentforce_Redirect__mdt fields themselves.

  public String getFallbackBannerStaticResourceName(){
    String bannerStaticResourceName;
    if (config != null && !String.isEmpty(config.Fallback_Banner__c)) {
        bannerStaticResourceName = config.Fallback_Banner__c;  
    }
    return bannerStaticResourceName;
  }

  public Boolean getIsFallbackBannerClickable(){
    Boolean clickable = false;
    if (config != null) {
      clickable = config.Fallback_Banner_Clickable__c;
    }
    return clickable;
  }
}