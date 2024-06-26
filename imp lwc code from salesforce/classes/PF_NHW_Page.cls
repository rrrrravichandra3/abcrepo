public with sharing class PF_NHW_Page {

    private static final String STANDARD_TASK_ICON_NAME = 'standard:task';
    
    public static final PF_NHW_Page CASE_PICKER = new PF_NHW_Page('Case Picker', 'PF_NHW_CasePicker', Type.forName('PF_NHW_CasePickerPageService'), new ReviewInformation(null, null, false));
    public static final PF_NHW_Page BASIC_INFORMATION = new PF_NHW_Page('Basic Information', 'PF_NHW_BasicInformation', Type.forName('PF_NHW_BasicInformationPageService'), new ReviewInformation('Basics', 'standard:avatar', true));
    public static final PF_NHW_Page HARDWARE = new PF_NHW_Page('Hardware Information', 'PF_NHW_HardwareProvisionings', Type.forName('PF_NHW_HardwarePageService'), new ReviewInformation('Equipment', 'custom:custom27', true));
    public static final PF_NHW_Page SOFTWARE = new PF_NHW_Page('Software Information', 'PF_NHW_SoftwareProvisionings', Type.forName('PF_NHW_SoftwarePageService'), new ReviewInformation('Access', 'standard:apps_admin', true));
    public static final PF_NHW_Page TRAININGS = new PF_NHW_Page('Trainings', 'PF_NHW_TrainingProvisionings', Type.forName('PF_NHW_TrainingsPageService'), new ReviewInformation('Training', STANDARD_TASK_ICON_NAME, true));
    public static final PF_NHW_Page ADDTNLINFO = new PF_NHW_Page('AdditionalInfo', 'PF_NHW_AdditionalInfo', Type.forName('PF_NHW_AdditionalInfoService'), new ReviewInformation('Additonal Info', STANDARD_TASK_ICON_NAME, true));
    public static final PF_NHW_Page REVIEW = new PF_NHW_Page('Review', 'PF_NHW_Review', Type.forName('PF_NHW_ReviewService'), new ReviewInformation(null, null, false));
    public static final PF_NHW_Page PAST_CASES = new PF_NHW_Page('Past Cases', 'PF_NHW_PastCaseSubmissions', Type.forName('PF_NHW_PastCasePickerPageService'), new ReviewInformation(null, null, false));
    public static final PF_NHW_Page PAST_CASE_DETAIL = new PF_NHW_Page('Past Submission Detail', 'PF_NHW_PastSubmissionDetail', Type.forName('PF_NHW_PastSubmissionDetailPageService'), new ReviewInformation(null, null, false));
    
    
    public static final PF_NHW_Page BASIC_INFORMATION_EMPLOYEEVIEW = new PF_NHW_Page('Basic Information', 'PF_NHW_BasicInformation', Type.forName('PF_NHW_BasicInformationPageService'), new ReviewInformation(null, null, false));
    public static final PF_NHW_Page HARDWARE_EMPLOYEEVIEW = new PF_NHW_Page('Hardware Information', 'PF_NHW_HardwareProvisionings', Type.forName('PF_NHW_HardwarePageService'), new ReviewInformation(null, null, false));
    public static final PF_NHW_Page SOFTWARE_EMPLOYEEVIEW = new PF_NHW_Page('Software Information', 'PF_NHW_SoftwareProvisionings', Type.forName('PF_NHW_SoftwarePageService'), new ReviewInformation(null, null, false));
    public static final PF_NHW_Page TRAININGS_EMPLOYEEVIEW = new PF_NHW_Page('Trainings', 'PF_NHW_TrainingProvisionings', Type.forName('PF_NHW_TrainingsPageService'), new ReviewInformation('Training', STANDARD_TASK_ICON_NAME, true));
    public static final PF_NHW_Page ADDTNLINFO_EMPLOYEEVIEW = new PF_NHW_Page('AdditionalInfo', 'PF_NHW_AdditionalInfo', Type.forName('PF_NHW_AdditionalInfoService'), new ReviewInformation(null, null, false));
    
    private static List<PF_NHW_Page> instances = new List<PF_NHW_Page>{CASE_PICKER, BASIC_INFORMATION, HARDWARE, SOFTWARE, TRAININGS,ADDTNLINFO, REVIEW, PAST_CASES, PAST_CASE_DETAIL};
    
	@AuraEnabled
    public String name{get; private set;}
    @AuraEnabled
    public String lightningComponent{get; private set;}
    
    public ReviewInformation reviewInfo;

    private Type pageServiceType;
    
    private PF_NHW_Page(String name, String lightningComponent, Type pageServiceType,
                       ReviewInformation reviewInfo){
        this.name = name;
        this.lightningComponent = lightningComponent;
        this.pageServiceType = pageServiceType;
		this.reviewInfo = reviewInfo;
    }
    
    public static PF_NHW_Page getPageNameByName(String pageName){
        if(pageName != null){
            for(PF_NHW_Page instance:instances){
                if(pageName == instance.name){
                    return instance;
                }
            }
        }
        return null;
    }
    
    public PF_NHW_PageService createService(){
		return (PF_NHW_PageService) pageServiceType.newInstance();
    }
    
    public class ReviewInformation{
        
        public String title{get; private set;}
        public String icon{get; private set;}
	    public Boolean includedInReview{get; private set;}
        
        public ReviewInformation(String title, String icon, Boolean includedInReview){
            this.title = title;
            this.icon = icon;
            this.includedInReview = includedInReview;
        }
    }
}