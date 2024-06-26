/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 */

/*
 * this class will take an account and assign it to a user.
 * @author 
*/
public class PAMUtil {

    private static Id employeeservicesqueueId;
    private static Id esadminqueueId;
    private static List<SelectOption> options;
    private static List<SelectOption> optionsStatus;

    public static Id getEmployeeServicesQueue() {

        if(employeeservicesqueueId == null) {

            List<Group> empservices = [SELECT Id
                                       FROM Group
                                       WHERE Name =: 'Employee Services'];

            if(empservices.size() != 0)
                employeeservicesqueueId = empservices[0].Id;

        }

        return employeeservicesqueueId;
    }

    public static Id getESAdminQueue() {

        if(esadminqueueId== null) {

            List<Group> empservices = [SELECT Id
                                       FROM Group
                                       WHERE Name =: 'ES Admin'];

            if(empservices.size() != 0)
                esadminqueueId = empservices[0].Id;

        }

        return esadminqueueId;
    }

    public static List<SelectOption> getRatingSelectOptions() {

        if(options != null) return options;

        options = new List<SelectOption>();

        options.add(new SelectOption('0',Label.Scorecards_Metric_Rating_Value0));
        options.add(new SelectOption('1',Label.Scorecards_Metric_Rating_Value1));
        options.add(new SelectOption('2',Label.Scorecards_Metric_Rating_Value2));
        options.add(new SelectOption('3',Label.Scorecards_Metric_Rating_Value3));
        options.add(new SelectOption('4',Label.Scorecards_Metric_Rating_Value4));
        options.add(new SelectOption('5',Label.Scorecards_Metric_Rating_Value5));
		
        return options;
    } 
	
	public static List<SelectOption> getRatingSelectOptionsToMethods() {

        if(options != null) return options;

        options = new List<SelectOption>();

        options.add(new SelectOption('0',Label.Scorecards_Metric_Rating_Value0));
        options.add(new SelectOption('1',Label.Scorecards_Metric_Rating_Value1));
        options.add(new SelectOption('2',Label.Scorecards_Metric_Rating_Value2));
        options.add(new SelectOption('3',Label.Scorecards_Metric_Rating_Value3));
        options.add(new SelectOption('4',Label.Scorecards_Metric_Rating_Value4));
        options.add(new SelectOption('5',Label.Scorecards_Metric_Rating_Value5));
		options.add(new SelectOption('-1',Label.Status_NA_Label));
		
        return options;
    }
    
    public static List<SelectOption> getStatusSelectOptions() {

        if(optionsStatus != null) return optionsStatus;

        optionsStatus = new List<SelectOption>();

        optionsStatus.add(new SelectOption('', Label.Scorecards_Metric_Rating_Value0));
        optionsStatus.add(new SelectOption('In Progress', Label.Status_In_Progress_Label));
        optionsStatus.add(new SelectOption('Completed', Label.Status_Completed_Label));
        optionsStatus.add(new SelectOption('N/A', Label.Status_NA_Label));

        return optionsStatus;
    }


    public static void setOptions(List<SelectOption> newOptions){
        options = newOptions;
    }

    public static List<SelectOption> getAdjustedRatingSelectOptions() {

        if(options != null) return options;

        options = new List<SelectOption>();

        options.add(new SelectOption('1','1'));
        options.add(new SelectOption('2','2'));
        options.add(new SelectOption('3','3'));
        options.add(new SelectOption('4','4'));
        options.add(new SelectOption('5','5'));

        return options;
    }
    
    public static String getRatingLabel(Integer num) {
		
        List<SelectOption> opts = getRatingSelectOptions();
        return opts[num].getLabel();
    }
    
    public static String getRatingLabelToMethods(Integer num) {
		
        List<SelectOption> opts = getRatingSelectOptionsToMethods();
        return opts[num].getLabel();
    }
    
     public static Long getRatingFromActualTarget(Double actual)
    {
        //This function calculate rating based in actual individual and team target rating.
        
        //Be carefull with 0.xxxx values may not fit in any of this ifs.......
        
        Long calculatedRating = 0;
    
        Decimal theNumber = 0;
        theNumber =  actual;
        
        theNumber = theNumber.divide(1, 1);
        
        
        if (theNumber > 115)
        {
            calculatedRating =  5;
        }
    
        if (theNumber > 100 && theNumber <= 115)
        {
            calculatedRating =  4;
        }
        
        if (theNumber > 94 && theNumber <= 100)
        {
            calculatedRating =  3;
        }
        
        if (theNumber >= 85 && theNumber <= 94)
        {
            calculatedRating =  2;
        }
        
        if (theNumber < 85 )
        {
            calculatedRating =  1;
        }
   
        
        return calculatedRating;
    }
    
}