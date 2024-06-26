/*W-10468854 [Tech Debt] Shore up NHW core unit test coverage - Hardware
 * Unit tests coverage for outer layer service class - PF_NHW_HardwarePageService
 */
@istest
public class Test_PF_NHW_HardwarePageService {
  private static final String REGULAR_EMPLOYEE = 'regular employee';
  private static final String DELL_PC = 'Dell PC';

  @testSetup
  static void createProvsAndLightningComponents() {
    Test_PF_NHW_ProvisioningTypeTestFactory.createNHWProvisionings();
    Test_PF_NHW_ProvisioningTypeTestFactory.createNHWLightningComponents();
    NHW_Lightning_Component__c lc1 = [
      SELECT id
      FROM NHW_Lightning_Component__c
      WHERE id__c = 'pf_nhw_hardware_delivery_city'
    ];
    NHW_Lightning_Component__c lc2 = [
      SELECT id
      FROM NHW_Lightning_Component__c
      WHERE id__c = 'pf_nhw_hardware_desktop_type'
    ];
    NHW_Lightning_Component__c lc3 = [SELECT id FROM NHW_Lightning_Component__c WHERE id__c = 'pf_nhw_hardware_vdi'];
    NHW_Lightning_Component__c lc4 = [
      SELECT id
      FROM NHW_Lightning_Component__c
      WHERE id__c = 'pf_nhw_hardware_deskphone'
    ];
    NHW_Lightning_Component__c lc5 = [SELECT id FROM NHW_Lightning_Component__c WHERE id__c = 'pf_nhw_hardware_phone'];
    NHW_Lightning_Component_Configuration__c lcc1 = new NHW_Lightning_Component_Configuration__c();
    lcc1.Attribute__c = 'visible';
    lcc1.CurrencyIsoCode = 'USD';
    lcc1.Criteria__c = 'Laptop_Type__c != null && Laptop_Type__c != Not Required && Laptop_Type__c != None  || Computer_Type__c != null && Computer_Type__c != Not Required && Computer_Type__c != None ||Mobile_Phone_Required__c != null && Mobile_Phone_Required__c == Yes || Desk_and_VoiceMail__c != null && Desk_and_VoiceMail__c == Yes';
    lcc1.NHW_Lightning_Component__c = lc1.id;
    insert lcc1;
    NHW_Lightning_Component_Configuration__c lcc2 = new NHW_Lightning_Component_Configuration__c();
    lcc2.Attribute__c = 'visible';
    lcc2.CurrencyIsoCode = 'USD';
    lcc2.Criteria__c = 'NHW_organization__c ==DummyValue && Office_Country__c != Brazil && Business_Unit_NHW__c != 1660-Tableau && Business_Unit_NHW__c != 1661-Tableau M&A Transfers';
    lcc2.NHW_Lightning_Component__c = lc2.id;
    insert lcc2;
    NHW_Lightning_Component_Configuration__c lcc3 = new NHW_Lightning_Component_Configuration__c();
    lcc3.Attribute__c = 'visible';
    lcc3.CurrencyIsoCode = 'USD';
    lcc3.Criteria__c = 'true';
    lcc3.NHW_Lightning_Component__c = lc2.id;
    insert lcc3;
    NHW_Lightning_Component_Configuration__c lcc4 = new NHW_Lightning_Component_Configuration__c();
    lcc4.Attribute__c = 'visible';
    lcc4.CurrencyIsoCode = 'USD';
    lcc4.Criteria__c = 'NHW_Employee_Type__c == Dummy';
    lcc4.NHW_Lightning_Component__c = lc3.id;
    insert lcc4;
    NHW_Lightning_Component_Configuration__c lcc5 = new NHW_Lightning_Component_Configuration__c();
    lcc5.Attribute__c = 'visible';
    lcc5.CurrencyIsoCode = 'USD';
    lcc5.Criteria__c = 'NH_Business_Site__r.name !% Remote && Business_Unit_NHW__c != 1660-Tableau && Business_Unit_NHW__c != 1661-Tableau M&A Transfers';
    lcc5.NHW_Lightning_Component__c = lc4.id;
    insert lcc5;
    NHW_Lightning_Component_Configuration__c lcc6 = new NHW_Lightning_Component_Configuration__c();
    lcc6.Attribute__c = 'resetWhenHidden';
    lcc6.CurrencyIsoCode = 'USD';
    lcc6.Criteria__c = 'TRUE';
    lcc6.NHW_Lightning_Component__c = lc4.id;
    insert lcc6;
    NHW_Lightning_Component_Configuration__c lcc7 = new NHW_Lightning_Component_Configuration__c();
    lcc7.Attribute__c = 'visible';
    lcc7.CurrencyIsoCode = 'USD';
    lcc7.Criteria__c = 'NHW_Organization__c == Marketing Cloud && NHW_Role__c != Support || NHW_Organization__c != Marketing Cloud';
    lcc7.NHW_Lightning_Component__c = lc4.id;
    insert lcc7;
    NHW_Lightning_Component_Configuration__c lcc8 = new NHW_Lightning_Component_Configuration__c();
    lcc8.Attribute__c = 'visible';
    lcc8.CurrencyIsoCode = 'USD';
    lcc8.Criteria__c = 'NHW_Employee_Type__c != Contractor && NHW_Job_Application__r.Job__r.Job_Code__c !IN 110A00|200A00|260A00|187C00|126C00|518C00|502C00|540A00|160A00| 150A00|140A00|340A00|170A00|240A00|130A00|230A00|190A00|250A00| 440A00|370A00|270A00|180A00|120A00|501C00|510C00&& Office_Country__c != Thailand && Office_Country__c != Austria && Office_Country__c != Portugal||NHW_Employee_Type__c != Contractor && NHW_Job_Application__r.Job__r.Job_Code__c !IN 110A00|200A00|260A00|187C00|126C00|518C00|502C00|540A00|160A00| 150A00|140A00|340A00|170A00|240A00|130A00|230A00|190A00|250A00| 440A00|370A00|270A00|180A00|120A00|501C00|510C00&& Office_Country__c != Thailand && Office_Country__c != Austria && Office_Country__c != Portugal';
    lcc8.NHW_Lightning_Component__c = lc5.id;
    insert lcc8;

    TF2_Business_Site__c buSite = new TF2_Business_Site__c(
      name = 'California - San Francisco',
      City__c = 'California',
      Country__c = 'Unites States',
      Street_Address__c = '350 Mission St',
      Type__c = 'Regional Site'
    );
    insert buSite;
  }

  //validate hardware provisionings available for a new hire - laptop,desktop,vdi
  @istest
  public static void Validate_HardwareOptionsAvailable_HMView_FTEHire() {
    TF2_Business_Site__c buSite = new TF2_Business_Site__c(
      name = 'California - San Francisco',
      City__c = 'California',
      Country__c = 'Unites States',
      Street_Address__c = '350 Mission St',
      Type__c = 'City'
    );
    insert buSite;
    Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
    TF2_Business_Site__c buSite1 = [SELECT Id FROM TF2_Business_Site__c LIMIT 1];
    provisioningCase.NHW_Page_Number__c = 2;
    provisioningCase.NHW_Organization__c = 'DummyValue';
    provisioningCase.NHW_Employee_Type__c = 'Dummy';
    provisioningCase.NH_Business_Site__c = buSite1.id;
    insert provisioningCase;

    Test.startTest();
    provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.id);
    //set base PF_NHW_PageService base class attributes
    PF_NHW_PageService pageService = new PF_NHW_HardwarePageService();
    Map<String, Object> pageinfo = pageService.getPageInformation(REGULAR_EMPLOYEE, provisioningCase.id);
    Object compConfigList = pageinfo.get('COMP_CONFIG');
    System.debug('compConfigList = ' + compConfigList);
    Test.stopTest();
    for (PF_NHW_LightningComponentConfiguration value : (List<PF_NHW_LightningComponentConfiguration>) compConfigList) {
      //assert desktop options are visible and provisionings are correct
      if (value.id == 'pf_nhw_hardware_desktop_type') {
        System.assert(value.attributes[0].name == 'visible' && value.attributes[0].value == true);
        System.assert(
          value.provisionings.toString().contains('Linux') &&
          value.provisionings.toString().contains('Mac') &&
          value.provisionings.toString().contains('Windows')
        );
      }
      //assert laptop provisionings are correct
      if (value.id == 'pf_nhw_hardware_laptop_type') {
        System.assert(
          value.provisionings.toString().contains('Mac') && value.provisionings.toString().contains('Dell')
        );
      }
      //assert vdi options are visible and provisionings are correct
      if (value.id == 'pf_nhw_hardware_vdi') {
        System.assert(value.attributes[0].name == 'visible' && value.attributes[0].value == true);
        System.assert(value.provisionings.toString().contains('Accenture'));
      }
    }
  }
  //validate desktop and vdi hardware provisionings are not available for new hire
  @istest
  public static void Validate_HardwareOptionsNotAvailable_HMView_FTE() {
    Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
    provisioningCase.Office_Country__c = 'Austria';
    provisioningCase.NHW_Organization__c = 'Marketing Cloud';
    insert provisioningCase;

    Test.startTest();
    provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.id);
    PF_NHW_PageService pageService = new PF_NHW_HardwarePageService();
    Map<String, Object> pageinfo = pageService.getPageInformation(REGULAR_EMPLOYEE, provisioningCase.id);
    Object compConfigList = pageinfo.get('COMP_CONFIG');
      System.debug(compConfigList);
    Test.stopTest();
    for (PF_NHW_LightningComponentConfiguration value : (List<PF_NHW_LightningComponentConfiguration>) compConfigList) {
      //asert vdi component is invisible
      if (value.id == 'pf_nhw_hardware_vdi') {
        System.assert(value.attributes[0].name == 'visible' && value.attributes[0].value == false);
      }
    }
  }

  //validare correct shipping details when hardware is choosen for non-remote hire
  @istest
  public static void Validate_ShippingOptions_HMView_NonRemoteFTE() {
    Contact cntOncase = new Contact(
      RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),
      LastName = 'Test contact',
      MailingCity = 'New York'
    );
    insert cntOnCase;
    TF2_Business_Site__c buSite = new TF2_Business_Site__c(
      name = 'California - San Francisco',
      City__c = 'California',
      Country__c = 'Unites States',
      Street_Address__c = '350 Mission St',
      Type__c = 'City'
    );
    insert buSite;
    TF2_Business_Site__c buSite1 = [SELECT Id FROM TF2_Business_Site__c LIMIT 1];
    Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
    provisioningCase.NHW_Page_Number__c = 2;
    provisioningCase.NH_Business_Site__c = buSite1.id;
    provisioningCase.NHW_Employee__c = cntOnCase.id;
    provisioningCase.Laptop_Type__c = DELL_PC;
    insert provisioningCase;

    Test.startTest();
    provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.id);
    PF_NHW_PageService pageService = new PF_NHW_HardwarePageService();
    Map<String, Object> pageinfo = pageService.getPageInformation(REGULAR_EMPLOYEE, provisioningCase.id);
    Object compConfigList = pageinfo.get('COMP_CONFIG');
    //get fields which are auto filled in aura component when hardware is choosen
    Map<String, Object> buRelatedFields = PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(
      buSite.id,
      provisioningCase.id
    );
    Test.stopTest();

    provisioningCase = [SELECT id, NH_Business_Site__r.City__c FROM Case WHERE id = :provisioningCase.id];
    //assert business site address is filled in non-remote hire
    System.assert(buRelatedFields.get('City') == provisioningCase.NH_Business_Site__r.City__c);
    for (PF_NHW_LightningComponentConfiguration value : (List<PF_NHW_LightningComponentConfiguration>) compConfigList) {
      //assert shipping options are visible
      if (value.id == 'pf_nhw_hardware_delivery_city') {
        System.assert(value.attributes[0].name == 'visible' && value.attributes[0].value == true);
      }
    }
  }

  //validare correct shipping details when hardware is choosen for remote hire
  @istest
  public static void Validate_ShippingOptions_HMView_RemoteFTE() {
    Contact cntOncase = new Contact(
      RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),
      LastName = 'Test contact',
      MailingCity = 'New York'
    );
    insert cntOnCase;
    TF2_Business_Site__c buSite = new TF2_Business_Site__c(
      name = 'Remote -California - San Francisco',
      City__c = 'CA',
      Country__c = 'Unites States',
      Street_Address__c = '350 Mission St',
      Type__c = 'City'
    );
    insert buSite;
    TF2_Business_Site__c buSite1 = [SELECT Id, Name FROM TF2_Business_Site__c LIMIT 1];
    buSite.Name = 'Remote ' + buSite.Name;
    update buSite;
    Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
    provisioningCase.NHW_Page_Number__c = 2;
    provisioningCase.NH_Business_Site__c = buSite1.id;
    provisioningCase.NHW_Employee__c = cntOnCase.id;
    provisioningCase.Laptop_Type__c = DELL_PC;
    insert provisioningCase;
    Test.startTest();
    provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.id);
    PF_NHW_PageService pageService = new PF_NHW_HardwarePageService();
    Map<String, Object> pageinfo = pageService.getPageInformation(REGULAR_EMPLOYEE, provisioningCase.id);
    Object compConfigList = pageinfo.get('COMP_CONFIG');
    Map<String, Object> buRelatedFields = PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(
      buSite.id,
      provisioningCase.id
    );
    Test.stopTest();
    provisioningCase = [SELECT id, NHW_Employee__r.MailingCity FROM Case WHERE id = :provisioningCase.id];
    //iassert address from contact is filled when hardware s choosen
    System.assert(buRelatedFields.get('City') == provisioningCase.NHW_Employee__r.MailingCity);
    for (PF_NHW_LightningComponentConfiguration value : (List<PF_NHW_LightningComponentConfiguration>) compConfigList) {
      //assert shipping options are visible
      if (value.id == 'pf_nhw_hardware_delivery_city') {
        System.assert(value.attributes[0].name == 'visible' && value.attributes[0].value == true);
      }
    }
  }

  //validate review items when page is processed and hardware is selected
  @istest
  public static void Validate_ProcessPageWithHardware_HMView_FTEHire() {
    Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
    provisioningCase.Laptop_Type__c = DELL_PC;
    provisioningCase.NHW_Page_Number__c = 2;
    provisioningCase.Shipping_Address__c = '350 Mission St';
    provisioningCase.Shipping_City__c = 'California';
    provisioningCase.Shipping_State__c = 'San Francisco';
    provisioningCase.Shipping_Country__c = 'United States';
    insert provisioningCase;
    Test.startTest();
    provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.id);
    PF_NHW_PageService pageService = new PF_NHW_HardwarePageService();
    Map<String, Object> pageinfo = pageService.getPageInformation(REGULAR_EMPLOYEE, provisioningCase.id);
    Object compConfigList = pageinfo.get('COMP_CONFIG');
    Map<String, String> additionalInfo = new Map<String, String>();
    additionalInfo.put('LOCALCONTACTNAME', 'testLocalContactName');
    additionalInfo.put('LOCALCONTACTEMAIL', 'testLocalContact@Email.com');
    additionalInfo.put('LOCALCONTACTPHONE', '12345');
    Id caseid = pageService.processInformation(provisioningCase, additionalInfo, true);
    List<PF_NHW_PageService.ReviewItem> reviewList = pageService.getReviewList(
      provisioningCase,
      PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c)
    );
    Test.stopTest();
    for (PF_NHW_PageService.ReviewItem ri : reviewList) {
      if (ri.label == 'Local Contact Info') {
        System.assert(ri.value.contains('testLocalContactName'));
      }
      if (ri.label == 'State') {
        System.assert(ri.value.contains('San Francisco'));
      }
      if (ri.label == 'City') {
        System.assert(ri.value.contains('California'));
      }
      if (ri.label == 'Laptop Type') {
        System.assert(ri.value == DELL_PC);
      }
    }
  }
  //validate review items when page is processed and no hardware is selected
  @istest
  public static void Validate_ProcessPageWithNoHardware_HMView_FTEHire() {
    Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
    provisioningCase.NHW_Page_Number__c = 2;
    insert provisioningCase;
    Test.startTest();
    provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.id);
    PF_NHW_PageService pageService = new PF_NHW_HardwarePageService();
    Map<String, Object> pageinfo = pageService.getPageInformation(REGULAR_EMPLOYEE, provisioningCase.id);
    Object compConfigList = pageinfo.get('COMP_CONFIG');
    Map<String, String> additionalInfo = new Map<String, String>();
    additionalInfo.put('LOCALCONTACTNAME', 'testLocalContactName');
    additionalInfo.put('LOCALCONTACTEMAIL', 'testLocalContact@Email.com');
    additionalInfo.put('LOCALCONTACTPHONE', '12345');
    Id caseid = pageService.processInformation(provisioningCase, additionalInfo, true);
    List<PF_NHW_PageService.ReviewItem> reviewList = pageService.getReviewList(
      provisioningCase,
      PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c)
    );
    Test.stopTest();
    for (PF_NHW_PageService.ReviewItem ri : reviewList) {
      if (ri.label == 'Laptop Type') {
        System.assert(ri.value == 'Not needed');
      }
    }
  }
  
  //W-15302981 - Putting Provision case status to on hold if contact is Deactive/inactive
  @istest
  public static void ProcessSubmitPageWithDeactiveContact() {
    Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
    provisioningCase.NHW_Page_Number__c = 6;
    insert provisioningCase;
    Test.startTest();
    provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.id);
    PF_NHW_PageService pageService = new PF_NHW_HardwarePageService();
    Map<String, Object> pageinfo = pageService.getPageInformation(REGULAR_EMPLOYEE, provisioningCase.id);
    Object compConfigList = pageinfo.get('Review');
    Map<String, String> additionalInfo = new Map<String, String>();
    Id caseid = pageService.processInformation(provisioningCase, null, false);
    List<PF_NHW_PageService.ReviewItem> reviewList = pageService.getReviewList(
      provisioningCase,
      PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c)
    );
    Test.stopTest();
    for (PF_NHW_PageService.ReviewItem ri : reviewList) {
      if (ri.label == 'Laptop Type') {
        System.assert(ri.value == 'Not needed');
      }
    }
  }

  //validate fields when page is Skipped
  @istest
  public static void Validate_ResetFieldsOnPageSkip_HMView_FTEHire() {
    Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
    provisioningCase.Laptop_Type__c = DELL_PC;
    provisioningCase.Shipping_Address__c = '350 misison st';
    provisioningCase.Shipping_Zip_Postal__c = '1908';
    provisioningCase.Shipping_State__c = 'San Fransico';
    insert provisioningCase;
    Test.startTest();
    provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.id);
    PF_NHW_PageService pageService = new PF_NHW_HardwarePageService();
    pageService.getPageInformation(REGULAR_EMPLOYEE, provisioningCase.id);
    pageService.resetFieldsOnPageSkip(provisioningCase);
    Test.stopTest();
    System.assert(provisioningCase.Laptop_Type__c == null);
    System.assert(provisioningCase.Shipping_Address__c == null);
    System.assert(provisioningCase.Shipping_Zip_Postal__c == null);
    System.assert(provisioningCase.Shipping_State__c == null);
  }
}