public with sharing class DocuSignAcquisitionUK extends DocuSignAcquisitionBaseCountry{

    public override String getFormattedDate(Date dateValue){
        //Write the code to format Date it in UK format, example 12 August 2016
        Datetime dt = datetime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
        String formattedDate = dt.format('dd MMMM yyyy');
        return formattedDate;
    }

    public override String getFormattedCurrency(Decimal amount){
        //Write the code to format currency in UK format, example 12.556.875,50
        String formattedAmount = Acquisition_Docusign_Util.convertDecimalToCommaSeparatedString(amount);
        formattedAmount = formattedAmount.removeEnd('.00');
        formattedAmount = Acquisition_Docusign_Util.interchangeDotsAndCommas(formattedAmount);
        return formattedAmount;
    }

    public override String getFormattedPercent(Decimal percentValue){
        //Write the code to format percen in UK format, example 36,50
        String formattedAmount = Acquisition_Docusign_Util.convertDecimalToCommaSeparatedString(percentValue);
        formattedAmount = formattedAmount.removeEnd('.00');
        formattedAmount = Acquisition_Docusign_Util.interchangeDotsAndCommas(formattedAmount);
        return formattedAmount;
    }

    public override String getSubject(){
        String subject = Label.Acquisition_UK_Email_Subject;
        if(subject == 'NA'){subject='';}
        return subject;
    }

    public override String getEmailBlurb(){
        String EmailBlurb = Label.Acquisition_UK_Email_Blurb;
        if(EmailBlurb == 'NA'){EmailBlurb='';}
        return EmailBlurb;
    }

    public override List<esdsext.DocuSignAPI.TemplateReference> collectAllTemplates(){


        //requirement 1a and 1b
        //Offer Letter
        String templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')||(acquisitionOffer.Employee_Type__c == 'Intern')){
            templateId = getTemplateId('UK_INTERN_OFFER', acquisitionOffer.Office_Country__c);
        }else if(acquisitionOffer.Employee_Type__c == 'Perm/FTE'){
            templateId = getTemplateId('UK_FTE_OFFER', acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 2
        //Authorization for Background Investigation
        templateId = getTemplateId('UK_BI',acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        //requirement 3a and 3b
        //Contract Commencement date
        templateId = null;
        if(((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')||(acquisitionOffer.Employee_Type__c == 'Intern')) && (acquisitionOffer.Continuous_Service_Date__c != null)){
            templateId = getTemplateId('UK_INTERN_CONTRACT_WO_CSD', acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.Continuous_Service_Date__c != null)){
            templateId = getTemplateId('UK_FTE_CONTRACT_WO_CSD', acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 4
        //UK wrking hours
        templateId = getTemplateId('UK_WORKING_HOURS',acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        //requirement 5a - 5c
        //location based templates
        templateId = null;
        if((acquisitionOffer.Office_City__c!=null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('London'))){
            templateId = getTemplateId('UK_LONDON',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Office_City__c!=null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('Staines'))){
            templateId = getTemplateId('UK_STAINES',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Office_City__c!=null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('Remote'))){
            templateId = getTemplateId('UK_REMOTE',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 6a and 6b
        //Salary Templates
        templateId = null;
        if(((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')||(acquisitionOffer.Employee_Type__c == 'Intern')) && (acquisitionOffer.Base_Salary__c != null)){
            templateId = getTemplateId('UK_INTERN_SALARY',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.Base_Salary__c != null)){
            templateId = getTemplateId('UK_FTE_SALARY',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirements 7a - 7f
        //Bonus Plan and Variable pay
        templateId = null;
        if(//7a
            ((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')||(acquisitionOffer.Employee_Type__c == 'Intern'))
            && (acquisitionOffer.Bonus_Plan__c == null)
            && (acquisitionOffer.Target_Variable_Amount__c != null)
          ){
            templateId = getTemplateId('UK_INTERN_VARIABLE',acquisitionOffer.Office_Country__c);
        }else if(//7b
            (acquisitionOffer.Employee_Type__c == 'Perm/FTE')
            && (acquisitionOffer.Bonus_Plan__c == 'Commission - with draw')
            && ((acquisitionOffer.Variable_Payment_Frequency__c == 'Monthly') || (acquisitionOffer.Variable_Payment_Frequency__c == 'Quarterly') || (acquisitionOffer.Variable_Payment_Frequency__c == 'Annually'))
          ){
            templateId = getTemplateId('UK_COMMISSION_WITH_DRAW',acquisitionOffer.Office_Country__c);
        }else if(//7c
            (acquisitionOffer.Employee_Type__c == 'Perm/FTE')
            && (acquisitionOffer.Bonus_Plan__c == 'Commission - without draw')
            && ((acquisitionOffer.Variable_Payment_Frequency__c == 'Monthly') || (acquisitionOffer.Variable_Payment_Frequency__c == 'Quarterly') || (acquisitionOffer.Variable_Payment_Frequency__c == 'Annually'))
          ){
            templateId = getTemplateId('UK_COMMISSION_WO_DRAW',acquisitionOffer.Office_Country__c);
        }else if(//7d
            (acquisitionOffer.Employee_Type__c == 'Perm/FTE')
            && (acquisitionOffer.Bonus_Plan__c == 'Commission - ISV with draw')
            && ((acquisitionOffer.Variable_Payment_Frequency__c == 'Monthly') || (acquisitionOffer.Variable_Payment_Frequency__c == 'Quarterly') || (acquisitionOffer.Variable_Payment_Frequency__c == 'Annually'))
          ){
            templateId = getTemplateId('UK_COMMISSION_ISV_WITH_DRAW',acquisitionOffer.Office_Country__c);
        }else if(//7e
            (acquisitionOffer.Employee_Type__c == 'Perm/FTE')
            && (acquisitionOffer.Bonus_Plan__c == 'Commission - ISV without draw')
            && ((acquisitionOffer.Variable_Payment_Frequency__c == 'Monthly') || (acquisitionOffer.Variable_Payment_Frequency__c == 'Quarterly') || (acquisitionOffer.Variable_Payment_Frequency__c == 'Annually'))
          ){
            templateId = getTemplateId('UK_COMMISSION_ISV_WO_DRAW',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.Bonus_Plan__c == 'Kokua')){
            templateId = getTemplateId('UK_KOKUA',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 8
        //Car Allowance
        templateId = null;
        if(acquisitionOffer.Car_Allowance_Amount__c != null){
            templateId = getTemplateId('UK_CAR_ALLOWANCE',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 9
        //Sign on Bonus
        templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.Sign_On_Bonus__c != null)){
            templateId = getTemplateId('UK_SIGN_ON_BONUS',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 10a and 10b
        //Relocation
        templateId = null;
        if(acquisitionOffer.Relocation_Package_Cost__c != null){
            templateId = getTemplateId('UK_RELOCATION_PLUS',acquisitionOffer.Office_Country__c);
        }else if(acquisitionOffer.Relocation_Allowance__c != null){
            templateId = getTemplateId('UK_RELOCATION_ALLOWANCE',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 11
        //completion bonus
        templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee') && (acquisitionOffer.Bonus_Plan__c == 'Completion')){
            templateId = getTemplateId('UK_INTERN_COMPLETION_BONUS',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 12
        //Benefits Pension
        templateId = getTemplateId('UK_BENEFITS_PENSION',acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        //requirement 13a and 13b
        //Annual leave
        templateId = null;
        if(acquisitionOffer.Employee_Type__c == 'Perm/FTE'){
            templateId = getTemplateId('UK_FTE_ANNUAL_LEAVE',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')||(acquisitionOffer.Employee_Type__c == 'Intern')){
            templateId = getTemplateId('UK_INTERN_ANNUAL_LEAVE',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 14a and 14b
        //Exclusive Service
        templateId = null;
        if(acquisitionOffer.Employee_Type__c == 'Perm/FTE'){
            templateId = getTemplateId('UK_FTE_EXCLUSIVE_SERVICE',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')||(acquisitionOffer.Employee_Type__c == 'Intern')){
            templateId = getTemplateId('UK_INTERN_EXCLUSIVE_SERVICE',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 15a and 15b
        //Compensation Grade
        templateId = null;
        if(
            (acquisitionOffer.Compensation_Grade__c == '9') 
            || (acquisitionOffer.Compensation_Grade__c == '10') 
            || (acquisitionOffer.Compensation_Grade__c == '11') 
            || (acquisitionOffer.Compensation_Grade__c == '12')
            || (acquisitionOffer.Compensation_Grade__c == '13')
          ){
            templateId = getTemplateId('UK_FTE_NON_COMPETE',acquisitionOffer.Office_Country__c);
        }else if( // cover scenarios where compensation grade is 8 or below
                   (acquisitionOffer.Compensation_Grade__c == '0')
                   || (acquisitionOffer.Compensation_Grade__c == '1')
                   || (acquisitionOffer.Compensation_Grade__c == '2')
                   || (acquisitionOffer.Compensation_Grade__c == '3')
                   || (acquisitionOffer.Compensation_Grade__c == '4')
                   || (acquisitionOffer.Compensation_Grade__c == '5')
                   || (acquisitionOffer.Compensation_Grade__c == '6')
                   || (acquisitionOffer.Compensation_Grade__c == '7')
                   || (acquisitionOffer.Compensation_Grade__c == '8')
                ){
            templateId = getTemplateId('UK_POST_TERM_RESTRICTION',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 16a and 16b
        //EMEA Miscellaneous clause
        templateId = null;
        if(acquisitionOffer.EMEA_Misc_Contractual_Clause__c == null){
            templateId = getTemplateId('UK_REM_COMPONENT_WITHOUT_CLAUSE',acquisitionOffer.Office_Country__c);
        }else if(acquisitionOffer.EMEA_Misc_Contractual_Clause__c != null){
            templateId = getTemplateId('UK_REM_COMPONENT_WITH_CLAUSE',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 17
        //RSU Amount
        templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.RSU_Amount__c != null)){
            templateId = getTemplateId('UK_RSU',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}


        //requirement 18
        //IT Ground rules for security success
        templateId = getTemplateId('GROUND_RULE_SECURITY_SUCCESS','ALL');
        if(templateId!=null){addTemplate(templateId);}

        //requirement 19
        //Employee Handbook
        templateId = getTemplateId('EMPLOYEE_HANDBOOK','ALL');
        if(templateId!=null){addTemplate(templateId);}

        //requirement 20
        //Global Code of Conduct
        templateId = getTemplateId('GLOBAL_CODE_OF_CONDUCT','ALL');
        if(templateId!=null){addTemplate(templateId);}

        //requirement 21
        //Signature Acknowledgement
        templateId = getTemplateId('SIGN_ACK_ENGLISH','ALL');
        if(templateId!=null){addTemplate(templateId);}

        return templateList;
    }
}