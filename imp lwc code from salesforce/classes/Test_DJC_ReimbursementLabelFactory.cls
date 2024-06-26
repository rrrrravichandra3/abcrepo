@isTest
public class Test_DJC_ReimbursementLabelFactory {

    public static testMethod void getConfirmationLabelsEMEATest(){
        
        DJC_WellnessLabelFactory labelFactory = new DJC_WellnessLabelFactory(DJC_Region.EMEA);
        
        String expected = System.Label.DJC_Wellness_Agreement_EMEA;
        List<String> result = labelFactory.getConfirmationLabels();
        
        System.assert(result != null && result.size() == 1);
        System.assertEquals(expected, result[0]);
    }
    
    public static testMethod void getConfirmationLabelsAPACTest(){
        
        DJC_WellnessLabelFactory labelFactory = new DJC_WellnessLabelFactory(DJC_Region.APAC);
        
        String expected = System.Label.DJC_Wellness_Agreement_APAC;
        List<String> result = labelFactory.getConfirmationLabels();
        
        System.assert(result != null && result.size() == 1);
        System.assertEquals(expected, result[0]);
    }
    
    public static testMethod void getConfirmationLabelsLACATest(){
        
        DJC_WellnessLabelFactory labelFactory = new DJC_WellnessLabelFactory(DJC_Region.LACA);
        
        String expected = System.Label.DJC_Wellness_Agreement_LACA;
        List<String> result = labelFactory.getConfirmationLabels();
        
        System.assert(result != null && result.size() == 1);
        System.assertEquals(expected, result[0]);
    }
}