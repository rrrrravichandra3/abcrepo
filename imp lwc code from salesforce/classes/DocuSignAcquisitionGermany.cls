public with sharing class DocuSignAcquisitionGermany extends DocuSignAcquisitionBaseCountry{

    public override String getFormattedDate(Date dateValue){
        //Write the code to format Date it in Germany format, example 12 August 2016
        Datetime dt = datetime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
        String formattedDate = dt.format('dd MMMM yyyy');
        return formattedDate;
    }

    public override String getFormattedCurrency(Decimal amount){
        //Write the code to format currency in Germany format, example 12.556.875,50
        String formattedAmount = Acquisition_Docusign_Util.convertDecimalToCommaSeparatedString(amount);
        formattedAmount = formattedAmount.removeEnd('.00');
        formattedAmount = Acquisition_Docusign_Util.interchangeDotsAndCommas(formattedAmount);
        return formattedAmount;
    }

    public override String getFormattedPercent(Decimal percentValue){
        //Write the code to format percen in Germany format, example 36,50
        String formattedAmount = Acquisition_Docusign_Util.convertDecimalToCommaSeparatedString(percentValue);
        formattedAmount = formattedAmount.removeEnd('.00');
        formattedAmount = Acquisition_Docusign_Util.interchangeDotsAndCommas(formattedAmount);
        return formattedAmount;
    }

    public override String getSubject(){
        String subject = Label.Acquisition_Germany_Email_Subject;
        if(subject == 'NA'){subject='';}
        return subject;
    }

    public override String getEmailBlurb(){
        String GermanyEmailBlurb = Label.Acquisition_Germany_Email_Blurb;
        if(GermanyEmailBlurb == 'NA'){GermanyEmailBlurb='';}
        return GermanyEmailBlurb;
    }

    public override List<esdsext.DocuSignAPI.TemplateReference> collectAllTemplates(){
        

        //requirement 1a and 1b
        //Offer leter for Full-Time/Perm and Fixed-Term/Intern
        String templateId = null;
        if(acquisitionOffer.Employee_Type__c == 'Perm/FTE'){
            templateId = getTemplateId('GER_OFFER_FTE',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')||(acquisitionOffer.Employee_Type__c == 'Intern')){
            templateId = getTemplateId('GER_OFFER_INTERN',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}


        //requirement 2a-2d
        //Details of position type, job duties and start date
        templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.Continuous_Service_Date__c != null) && (acquisitionOffer.Probation_Start_Date__c == null) && (acquisitionOffer.Position_Type__c != 'Part-time')){
            templateId = getTemplateId('GER_FTE_NO_PROB_W_CSD', acquisitionOffer.Office_Country__c); 
        }else if(((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee') || (acquisitionOffer.Employee_Type__c == 'Intern')) && (acquisitionOffer.Position_Type__c != 'Part-time')){
            templateId = getTemplateId('GER_INTERN_NOT_PT', acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && ((acquisitionOffer.Position_Type__c == 'Part-time'))){
            templateId = getTemplateId('GER_FTE_PT', acquisitionOffer.Office_Country__c);
        }else if(((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee') || (acquisitionOffer.Employee_Type__c == 'Intern')) && (acquisitionOffer.Position_Type__c == 'Part-time')){
            templateId = getTemplateId('GER_INTERN_PT', acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 3a - 3e
        //Templates based on Work Location
        templateId = null;
        if((acquisitionOffer.Office_City__c != null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('Munich'))){
            templateId = getTemplateId('GER_MUNICH', acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Office_City__c != null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('Dusseldorf'))){
            templateId = getTemplateId('GER_DUSSELDORF', acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Office_City__c != null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('Frankfurt'))){
            templateId = getTemplateId('GER_FRANKFURT', acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Office_City__c != null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('Berlin'))){
            templateId = getTemplateId('GER_BERLIN', acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Office_City__c != null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('Remote'))){
            templateId = getTemplateId('GER_REMOTE', acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Office_City__c != null) && (acquisitionOffer.Office_City__c.equalsIgnoreCase('Jena'))){
            templateId = getTemplateId('GER_JENA', acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 4a - 4c
        //Base Salary, bonus plans and variables
        templateId = null;
        if(//4a
            (acquisitionOffer.Employee_Type__c == 'Perm/FTE') 
            && (acquisitionOffer.Base_Salary__c != null) 
            && ((acquisitionOffer.Bonus_Plan__c != null) && ((acquisitionOffer.Bonus_Plan__c.equalsIgnoreCase('Commission - with draw')) || (acquisitionOffer.Bonus_Plan__c.equalsIgnoreCase('Commission - ISV with draw'))))
            && (acquisitionOffer.Draw_Amount__c != null)
          ){
            templateId = getTemplateId('GER_COMM_WITH_DRAW', acquisitionOffer.Office_Country__c);
        }else if(//4b
            (acquisitionOffer.Employee_Type__c == 'Perm/FTE') 
            && (acquisitionOffer.Base_Salary__c != null) 
            && ((acquisitionOffer.Bonus_Plan__c != null) && ((acquisitionOffer.Bonus_Plan__c.equalsIgnoreCase('Commission - without draw')) || (acquisitionOffer.Bonus_Plan__c.equalsIgnoreCase('Commission - ISV without draw'))))
            && (acquisitionOffer.Draw_Amount__c == null))
          {
            templateId = getTemplateId('GER_COMM_WITHOUT_DRAW', acquisitionOffer.Office_Country__c);
        }else if(//4c
            (acquisitionOffer.Employee_Type__c == 'Perm/FTE')
            && (acquisitionOffer.Base_Salary__c != null) 
            && ((acquisitionOffer.Bonus_Plan__c != null) && (acquisitionOffer.Bonus_Plan__c.equalsIgnoreCase('Kokua')))
            && (acquisitionOffer.Draw_Amount__c == null)
          ){
            templateId = getTemplateId('GER_KOKUA', acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 5
        //Compeltion Bonus
        templateId = null;
        if(
            ((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')||(acquisitionOffer.Employee_Type__c == 'Intern'))
            && (acquisitionOffer.Target_Variable_Amount__c != null)
            && (acquisitionOffer.Bonus_Plan__c == 'Completion')
          ){
            templateId = getTemplateId('GER_COMPLETION_BONUS', acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 6
        //Car Allowance
        templateId = null;
        if(
            ((acquisitionOffer.Employee_Type__c == 'Perm/FTE')||(acquisitionOffer.Employee_Type__c == 'Fixed Term Employee') || (acquisitionOffer.Employee_Type__c == 'Intern'))
            && (acquisitionOffer.Car_Allowance_Amount__c != null)
          ){
            templateId = getTemplateId('GER_CAR_ALLOWANCE', acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 7
        //Sign On Bonus
        templateId = null;
        if(
            ((acquisitionOffer.Employee_Type__c == 'Perm/FTE')||(acquisitionOffer.Employee_Type__c == 'Fixed Term Employee') || (acquisitionOffer.Employee_Type__c == 'Intern'))
            && (acquisitionOffer.Sign_On_Bonus__c != null)
          ){
            templateId = getTemplateId('GER_SIGNON_BONUS', acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 8a, 8b
        //Relocation Assistance and Allowance
        templateId = null;
        if(//8a
            ((acquisitionOffer.Employee_Type__c == 'Perm/FTE')||(acquisitionOffer.Employee_Type__c == 'Fixed Term Employee') || (acquisitionOffer.Employee_Type__c == 'Intern'))
            && (acquisitionOffer.Relocation_Package_Cost__c  != null)
          ){
            templateId = getTemplateId('GER_RELOCATION_ASSIST', acquisitionOffer.Office_Country__c);
        }else if(//8b
            ((acquisitionOffer.Employee_Type__c == 'Perm/FTE')||(acquisitionOffer.Employee_Type__c == 'Fixed Term Employee') || (acquisitionOffer.Employee_Type__c == 'Intern'))
            && (acquisitionOffer.Relocation_Allowance__c  != null)
          ){
            templateId = getTemplateId('GER_RELOCATION_ALL', acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 9a-9d
        //Remaining COmponents and Data Clause
        templateId = null;
        if(//9a
            (acquisitionOffer.Employee_Type__c == 'Perm/FTE')
            && (acquisitionOffer.EMEA_Misc_Contractual_Clause__c != null)
          ){
            templateId = getTemplateId('GER_FTE_CONT_CLAUSE', acquisitionOffer.Office_Country__c);
        }else if(//9b
            (acquisitionOffer.Employee_Type__c == 'Perm/FTE')
            && (acquisitionOffer.EMEA_Misc_Contractual_Clause__c == null)
          ){
            templateId = getTemplateId('GER_FTE_CONT_CLAUSE_NULL', acquisitionOffer.Office_Country__c);
        }else if(//9c
            ((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')||(acquisitionOffer.Employee_Type__c == 'Intern'))
            && (acquisitionOffer.EMEA_Misc_Contractual_Clause__c != null)
          ){
            templateId = getTemplateId('GER_INTERN_CONT_CLAUSE', acquisitionOffer.Office_Country__c);
        }else if(//9d
            ((acquisitionOffer.Employee_Type__c == 'Fixed Term Employee')||(acquisitionOffer.Employee_Type__c == 'Intern'))
            && (acquisitionOffer.EMEA_Misc_Contractual_Clause__c == null)
          ){
            templateId = getTemplateId('GER_INTERN_CONT_CLAUSE_NULL', acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 10
        //RSU Letter
        templateId = null;
        if(
            (acquisitionOffer.Employee_Type__c == 'Perm/FTE')
            && (acquisitionOffer.RSU_Amount__c != null)
            && (acquisitionOffer.Stock_Grant_Amount__c == null)
          ){
            templateId = getTemplateId('GER_RSU_LETTER', acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 11a and 11b were crossed out

        //requirement 12
        //Security Ground Rule
        templateId = getTemplateId('GROUND_RULE_SECURITY_SUCCESS', 'ALL');
        if(templateId!=null){addTemplate(templateId);}

        //requirement 13
        //Employee Handbook
        templateId = getTemplateId('GER_EMPLOYEE_HANDBOOK', acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        //requirement 14
        //Code of Conduct
        templateId = getTemplateId('GER_CODE_OF_CONDUCT', acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        //requirement 15
        //Signature Acknowledgement
        templateId = getTemplateId('SIGN_ACK_ENGLISH', 'ALL');
        if(templateId!=null){addTemplate(templateId);}

        return templateList;
    }
}