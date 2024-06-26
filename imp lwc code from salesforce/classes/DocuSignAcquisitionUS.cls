public with sharing class DocuSignAcquisitionUS extends DocuSignAcquisitionBaseCountry{

 
    public override String getFormattedDate(Date dateValue){
        //Write the code to format Date it in US format, example August 12, 2016
        Datetime dt = datetime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
        String formattedDate = dt.format('MMMM dd, yyyy');
        return formattedDate;
    }

    public override String getFormattedCurrency(Decimal amount){
        //Write the code to format currency in US format, example 12,556,875.50
        String formattedAmount = Acquisition_Docusign_Util.convertDecimalToCommaSeparatedString(amount);
        formattedAmount = formattedAmount.removeEnd('.00');
        return formattedAmount;
    }

    public override String getFormattedPercent(Decimal percentValue){
        //Write the code to format percent in US format, example 36.50
        String formattedAmount = Acquisition_Docusign_Util.convertDecimalToCommaSeparatedString(percentValue);
        formattedAmount = formattedAmount.removeEnd('.00');
        return formattedAmount;
        return '';
    }

    public override String getSubject(){
        String subject = Label.Acquisition_US_Email_Subject;
        if(subject == 'NA'){subject='';}
        return subject;
    }

    public override String getEmailBlurb(){
        String USEmailBlurb = Label.Acquisition_US_Email_Blurb;
        if(USEmailBlurb == 'NA'){USEmailBlurb='';}
        return USEmailBlurb;
    }

    public override List<esdsext.DocuSignAPI.TemplateReference> collectAllTemplates(){
        

        //requirement 1a and 1b
        //Offer Letter
        String templateId = null;
        if(acquisitionOffer.Pay_Rate_Type_Salary_Hourly__c == 'Salary'){
            templateId = getTemplateId('ACQ_OFFER_EXEMPT',acquisitionOffer.Office_Country__c);
        }
        else if(acquisitionOffer.Pay_Rate_Type_Salary_Hourly__c == 'Hourly'){
            templateId = getTemplateId('ACQ_OFFER_NONEXEMPT',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        
        //requirement 2a - 2e
        //Bonus Plan
        templateId = null;
        if(acquisitionOffer.Bonus_Plan__c == 'Kokua'){
            templateId = getTemplateId('ACQ_OFFER_KOKUA',acquisitionOffer.Office_Country__c);
        }else if(acquisitionOffer.Bonus_Plan__c == 'Commission - ISV with draw'){
            templateId = getTemplateId('ACQ_OFFER_COMM_ISV_W_DRAW',acquisitionOffer.Office_Country__c);
        }else if(acquisitionOffer.Bonus_Plan__c == 'Commission - ISV without draw'){
            templateId = getTemplateId('ACQ_OFFER_COMM_ISV_WO_DRAW',acquisitionOffer.Office_Country__c);
        }else if(acquisitionOffer.Bonus_Plan__c == 'Commission - without draw'){
            templateId = getTemplateId('ACQ_OFFER_COMM_WO_DRAW',acquisitionOffer.Office_Country__c);
        }else if(acquisitionOffer.Bonus_Plan__c == 'Commission - with draw'){
            templateId = getTemplateId('ACQ_OFFER_COMM_W_DRAW',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}


        //requirement 3
        //Sign On Bonus
        templateId = null;
        if(acquisitionOffer.Sign_On_Bonus__c != null){
            templateId = getTemplateId('ACQ_OFFER_SIGNON_BONUS',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}
        

        //requirement 4
        //Relocation Package Cost
        templateId = null;
        if(acquisitionOffer.Relocation_Package_Cost__c != null){
            templateId = getTemplateId('ACQ_OFFER_RELOCATION',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}
        

        //requirement 5a and 5b
        //RSU Amount
        templateId = null;
        if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.RSU_Amount__c != null) && (acquisitionOffer.Stock_Grant_Amount__c == null)){
            templateId = getTemplateId('ACQ_OFFER_RSU',acquisitionOffer.Office_Country__c);
        }else if((acquisitionOffer.Employee_Type__c == 'Perm/FTE') && (acquisitionOffer.RSU_Amount__c != null) && (acquisitionOffer.Stock_Grant_Amount__c != null)){
            templateID = getTemplateId('ACQ_OFFER_RSU_STOCK',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}


        //requirement 6
        //Remaining Components
        templateId = getTemplateId('ACQ_OFFER_REM_COMPONENTS',acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        //requirement 7
        //Arbitration
        templateId = getTemplateId('ARBITRATION',acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        //requirement 8a-8g
        //Bonus Plan for NY and CA
        templateId = null;
        if(//8a
                   ((acquisitionOffer.Office_State_Province__c!=null) && ((acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('CA')) || (acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('California')))) 
                   && (acquisitionOffer.Pay_Rate_Type_Salary_Hourly__c == 'Hourly') 
                   && ((acquisitionOffer.Bonus_Plan__c == 'Kokua') || (acquisitionOffer.Bonus_Plan__c == null))
          ){
            templateId = getTemplateId('CA_WAGE',acquisitionOffer.Office_Country__c);
        }else if(//8b
                   ((acquisitionOffer.Office_State_Province__c!=null) &&((acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('CA')) || (acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('California'))))
                   && (acquisitionOffer.Pay_Rate_Type_Salary_Hourly__c == 'Hourly') 
                   && ((acquisitionOffer.Bonus_Plan__c == 'Commission - with draw') || (acquisitionOffer.Bonus_Plan__c == 'Commission - ISV with draw'))
                ){
            templateId = getTemplateId('CA_WAGE_COMMISSION',acquisitionOffer.Office_Country__c);
        }else if(//8c
                   ((acquisitionOffer.Office_State_Province__c!=null) &&((acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('CA')) || (acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('California'))))
                   && (acquisitionOffer.Pay_Rate_Type_Salary_Hourly__c == 'Hourly') 
                   && ((acquisitionOffer.Bonus_Plan__c == 'Commission - without draw') || (acquisitionOffer.Bonus_Plan__c == 'Commission - ISV without draw'))
                ){
            templateId = getTemplateId('CA_WAGE_COMMISSION_NO_DRAW',acquisitionOffer.Office_Country__c);
        }else if(//8d
                   ((acquisitionOffer.Office_State_Province__c!=null) &&((acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('NY')) || (acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('New York'))))
                   && (acquisitionOffer.Pay_Rate_Type_Salary_Hourly__c == 'Salary')
                   && ((acquisitionOffer.Bonus_Plan__c == 'Kokua') || (acquisitionOffer.Bonus_Plan__c == null))
                ){
            templateId = getTemplateId('NY_WAGE_EXEMPT',acquisitionOffer.Office_Country__c);
        }else if(//8e
                   ((acquisitionOffer.Office_State_Province__c!=null) && ((acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('NY')) || (acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('New York'))))
                   && (acquisitionOffer.Pay_Rate_Type_Salary_Hourly__c == 'Salary')
                   && ((acquisitionOffer.Bonus_Plan__c == 'Commission - with draw') || (acquisitionOffer.Bonus_Plan__c == 'Commission - ISV with draw'))
                ){
            templateId = getTemplateId('NY_WAGE_EXEMPT_COMMISSION',acquisitionOffer.Office_Country__c);
        }else if(//8f
                   ((acquisitionOffer.Office_State_Province__c!=null) && ((acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('NY')) || (acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('New York'))))
                   && (acquisitionOffer.Pay_Rate_Type_Salary_Hourly__c == 'Hourly')
                   && ((acquisitionOffer.Bonus_Plan__c == 'Kokua') || (acquisitionOffer.Bonus_Plan__c == null))
                ){
            templateId = getTemplateId('NY_WAGE_HOURLY',acquisitionOffer.Office_Country__c);
        }else if(//8g
                   ((acquisitionOffer.Office_State_Province__c!=null) && ((acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('NY')) || (acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('New York'))))
                   && (acquisitionOffer.Pay_Rate_Type_Salary_Hourly__c == 'Hourly')
                   && ((acquisitionOffer.Bonus_Plan__c == 'Commission - with draw') || (acquisitionOffer.Bonus_Plan__c == 'Commission - ISV with draw'))
                ){
            templateId = getTemplateId('NY_WAGE_HOURLY_COMMISSION',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}


        //requirement 9
        //Benefits for CA
        templateId = null;
        if ((acquisitionOffer.Office_State_Province__c!=null) && ((acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('CA')) || (acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('California')))){
            templateId = getTemplateId('CA_WORKERS_COMPENSATION',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 10
        //NY Sick Leave
        templateId = null;
        if((acquisitionOffer.Office_State_Province__c!=null) && ((acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('NY')) || (acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('New York')))){
            templateId = getTemplateId('NY_SICK_LEAVE',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}
        

        //requirement 11
        //NY Employemnt Rights
        templateId = null;
        if ((acquisitionOffer.Office_State_Province__c!=null) && ((acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('NY')) || (acquisitionOffer.Office_State_Province__c.equalsIgnoreCase('New York')))){
            templateId = getTemplateId('NY_EMPLOYMENT_RIGHTS',acquisitionOffer.Office_Country__c);
        }
        if(templateId!=null){addTemplate(templateId);}

        //requirement 12
        //PRA Template
        templateId = getTemplateId('PRA',acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        //requirement 13
        //Outside Activities
        templateId = getTemplateId('GLOBAL_OUTSIDE_ACTIVITIES','ALL');
        if(templateId!=null){addTemplate(templateId);}

        //requirement 14
        //HIPPA
        templateId = getTemplateId('HIPPA',acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        //requirement 15
        //I9
        templateId = getTemplateId('I9',acquisitionOffer.Office_Country__c);
        if(templateId!=null){addTemplate(templateId);}

        //requirement 16
        //Security Ground Rules
        templateId = getTemplateId('GROUND_RULE_SECURITY_SUCCESS','ALL');
        if(templateId!=null){addTemplate(templateId);}

        //requirement 17
        //Employee Handbook
        templateId = getTemplateId('EMPLOYEE_HANDBOOK','ALL');
        if(templateId!=null){addTemplate(templateId);}

        //requirement 18
        //Code of Conduct
        templateId = getTemplateId('GLOBAL_CODE_OF_CONDUCT','ALL');
        if(templateId!=null){addTemplate(templateId);}

        //requirement 19
        //Signature Acknowledgement
        templateId = getTemplateId('SIGN_ACK_ENGLISH','ALL');
        if(templateId!=null){addTemplate(templateId);}

        return templateList;
    }
}