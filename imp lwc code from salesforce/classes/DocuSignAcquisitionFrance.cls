public with sharing class DocuSignAcquisitionFrance extends DocuSignAcquisitionBaseCountry{

    public override String getFormattedDate(Date dateValue){
        //Write the code to format Date it in France format, example 12 August 2016
        Datetime dt = datetime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
        String formattedDate = dt.format('dd MMMM yyyy');
        return formattedDate;
    }

    public override String getFormattedCurrency(Decimal amount){
        //Write the code to format currency in France format, example 12.556.875,50
        String formattedAmount = Acquisition_Docusign_Util.convertDecimalToCommaSeparatedString(amount);
        formattedAmount = formattedAmount.removeEnd('.00');
        formattedAmount = Acquisition_Docusign_Util.interchangeDotsAndCommas(formattedAmount);
        return formattedAmount;
    }

    public override String getFormattedPercent(Decimal percentValue){
        //Write the code to format percent in France format, example 36.50% is written as 36,50%
        String formattedAmount = Acquisition_Docusign_Util.convertDecimalToCommaSeparatedString(percentValue);
        formattedAmount = formattedAmount.removeEnd('.00');
        formattedAmount = Acquisition_Docusign_Util.interchangeDotsAndCommas(formattedAmount);
        return formattedAmount;
    }

    public override String getSubject(){
        String subject = Label.Acquisition_France_Email_Subject;
        if(subject == 'NA'){subject='';}
        return subject;
    }

    public override String getEmailBlurb(){
        String EmailBlurb = Label.Acquisition_France_Email_Blurb;
        if(EmailBlurb == 'NA'){EmailBlurb='';}
        return EmailBlurb;
    }

    public override List<esdsext.DocuSignAPI.TemplateReference> collectAllTemplates(){

        //requirement 1
        //Contract commencement with CSD
        String templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.Continuous_Service_Date__c != null)){
            templateId = getTemplateId('FR_CONT_WITH_CSD',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 2
        //Backgrount Investigation Authorization
        templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') || (acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')){
            templateId = getTemplateId('FR_BI',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 3
        //job duties
        templateId = null;
        if(acquisitionOffer.Employee_Type__c == 'Perm/FTE'){
            templateId = getTemplateId('FR_FTE_DUTIES_8_BELOW',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 4a - 4d
        //Location Templates
        templateId = null;
        if((acquisitionOffer.Office_City__c != null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('Paris'))){
            templateId = getTemplateId('FR_PARIS',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Office_City__c != null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('Grenoble'))){
            templateId = getTemplateId('FR_GRENOBLE',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Office_City__c != null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('Remote'))){
            templateId = getTemplateId('FR_REMOTE',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Office_City__c != null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('Lyon'))){
            templateId = getTemplateId('FR_LYON',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 5a and 5b
        //salary
        templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.Base_Salary__c != null)){
            templateId = getTemplateId('FR_FTE_SALARY',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee') && (acquisitionOffer.Base_Salary__c != null)){
            templateId = getTemplateId('FR_INTERN_SALARY',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 6a, 6b, 6c
        //Target variable amount
        templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.Bonus_Plan__c.equalsIgnoreCase('Kokua'))){
            templateId = getTemplateId('FR_FTE_KOKUA',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') 
                      && ((acquisitionOffer.Bonus_Plan__c != null) && ((acquisitionOffer.Bonus_Plan__c.equalsIgnoreCase('Commission - without draw'))))
                      && (acquisitionOffer.Draw_Amount__c == null)){
            templateId = getTemplateId('FR_FTE_COMM_WO_DRAW',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') 
                      && ((acquisitionOffer.Bonus_Plan__c != null) && ((acquisitionOffer.Bonus_Plan__c.equalsIgnoreCase('Commission - with draw'))))
                      && (acquisitionOffer.Draw_Amount__c != null)){
            templateId = getTemplateId('FR_FTE_COMM_WITH_DRAW',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 7
        //Car Allowance
        templateId = null;
        if(((acquisitionOffer.Employee_Type__c == 'Perm/FTE') || (acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')) && (acquisitionOffer.Car_Allowance_Amount__c != null)){
            templateId = getTemplateId('FR_CAR_ALLOWANCE',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 8
        //Sign on Bonus
        templateId = null;
        if(((acquisitionOffer.Employee_Type__c == 'Perm/FTE')||(acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')) && (acquisitionOffer.Sign_On_Bonus__c != null)){
            templateId = getTemplateId('FR_SIGN_ON_BONUS',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 9
        //relocation assistance
        templateId = null;
        if(((acquisitionOffer.Employee_Type__c == 'Perm/FTE')||(acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')) && (acquisitionOffer.Relocation_Package_Cost__c != null)){
            templateId = getTemplateId('FR_RELOCATION_ASST',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 10
        //relocation allowance
        templateId = null;
        if(((acquisitionOffer.Employee_Type__c == 'Perm/FTE')||(acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')) && (acquisitionOffer.Relocation_Allowance__c != null)){
            templateId = getTemplateId('FR_RELOCATION_ALLOWANCE',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 11
        templateId = null;
        if((acquisitionOffer.Compensation_Grade__c == '9') 
            || (acquisitionOffer.Compensation_Grade__c == '10') 
            || (acquisitionOffer.Compensation_Grade__c == '11') 
            || (acquisitionOffer.Compensation_Grade__c == '12')
            || (acquisitionOffer.Compensation_Grade__c == '13')){
            templateId = getTemplateId('FR_NON_COMPETE',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 12a - 12d
        //EMEA contractual clause
        templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.EMEA_Misc_Contractual_Clause__c != null)){
            templateId = getTemplateId('FR_FTE_CONT_CLAUSE',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.EMEA_Misc_Contractual_Clause__c == null)){
            templateId = getTemplateId('FR_FTE_NO_CONT_CLAUSE',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee') && (acquisitionOffer.EMEA_Misc_Contractual_Clause__c != null)){
            templateId = getTemplateId('FR_INTERN_CONT_CLAUSE',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee') && (acquisitionOffer.EMEA_Misc_Contractual_Clause__c == null)){
            templateId = getTemplateId('FR_INTERN_NO_CONT_CLAUE',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 13
        //RSU
        templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.RSU_Amount__c!=null) && (acquisitionOffer.Stock_Grant_Amount__c == null)){
            templateId = getTemplateId('FR_RSU',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 14
        //company rules
        templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') || (acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')){
            templateId = getTemplateId('FR_COMPANY_RULES',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 15
        //Ground Rule Security Success
        templateId = getTemplateId('GROUND_RULE_SECURITY_SUCCESS','ALL');
        if(templateId!=null){addTemplate(templateId);}

        //requirement 16
        //Employee Handbook
        templateId = getTemplateId('FR_EMPLOYEE_HANDBOOK',acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        //requirement 17
        //code of conduct
        templateId = getTemplateId('FR_CODE_OF_CONDUCT',acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        //requirement 18
        //Signature Acknowledgement
        templateId = getTemplateId('FR_SIGN_ACK',acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        return templateList;
    }
}