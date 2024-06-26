public with sharing class HireRightUtility {
	private static final String COMMA =',';
	private static final String NEW_LINE='\n';
	private static final String TEST_ORDER_SOAP_MSG='<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header/><SOAP-ENV:Body><hr_objs:GenerateWebLinkResponse xmlns:hr_objs="urn:enterprise.soap.hireright.com/objs"><hr_objs:URL>https://ows01.hireright.com/in.html?key=748CBBACDFBF22C05E7CF5EF24C7B354</hr_objs:URL></hr_objs:GenerateWebLinkResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
	
	 /**
     * Method to submit the request for Background check to Hire Right.
     * @param recordId is a String.
     * @param userId is a String.
     * @return us a URL to Hire Right Sight.
     */
	public static String orderBackGroundCheck(String recordId, String userId, boolean isTest) {
		String retValue =null;
		List<Schema.DescribeFieldResult> fieldList = new List<Schema.DescribeFieldResult>();
		Employment_Application__c emplymentApplicationDetails = getEmploymentApplicationDetails(recordId,fieldList);
		
		formatData(emplymentApplicationDetails,fieldList);
		String soapMsg = null;
		try	{
            HRSoapMessageGenerator hrSoap = new HRSoapMessageGenerator();
			// getting the userId based on the profile, that is authorised with Hire Right application.
			soapMsg = hrSoap.orderApplicationWL(emplymentApplicationDetails,userId);
			System.debug('$$$$$$$$ soapMessage = ' + soapMsg);
			String resBody ='';
			resBody =postData(soapMsg,isTest);
			if (isTest) {
				resBody =TEST_ORDER_SOAP_MSG;
			}
			System.debug('resBody----------------->'+ resBody);
			// updating the employment application with the response.
		    updateEmploymentApplication(recordId,resBody,soapMsg,true);
			retValue = getURL(resBody);			
		} catch(Exception e) {
			System.debug('Exception calling HR -->'+e.getMessage());
			updateEmploymentApplication(recordId,e.getMessage(),soapMsg);
			sendEmail(recordId,e.getMessage());
			return null;		
		}  	
     	return retValue;
	}
	
	
	/**
     * Method to view the back ground information submitted to Hire Right by the user .
     * @param recordId is a String.
     * @return us a URL to Hire Right Sight.
     */
	public static String viewBackGroundCheckDetails(String recordId, String userId,boolean isTest) {
		
		Employment_Application__c emplymentApplicationDetails =[Select id, createdDate FROM Employment_Application__c WHERE Id = : recordId];
		HRSoapMessageGenerator hrSoap = new HRSoapMessageGenerator();
		String retValue = null;
		String soapMsg;
		
		try {
			// building the soap message.
			soapMsg = hrSoap.viewApplicantDataWL(emplymentApplicationDetails,userId);
			String resBody = '';
			resBody =postData(soapMsg,isTest);
			retValue = getURL(resBody);
	    	return retValue;
		}
		catch(Exception e) {
			System.debug('Exception calling HR -->'+e.getMessage());
			sendEmail(recordId,e.getMessage());
			return null;	
		}  	
	}
	
    /**
     * Method to get the screening the report .
     * @param recordId is a String.
     * @return us a URL to Hire Right Sight.
     */
	public static String getScreeningReportStatus(String recordId, boolean isTest) {
		
		Employment_Application__c emplymentApplicationDetails =[Select id, createdDate FROM Employment_Application__c WHERE Id = : recordId];
		HRSoapMessageGenerator hrSoap = new HRSoapMessageGenerator();
		String retValue = null;
		String soapMsg;
		String resBody='';
		try	{
			// building the soap message.
			soapMsg = hrSoap.getStatusScreeningReport(emplymentApplicationDetails);
			// sending the data soap packed to Hire Right server.
			resBody =postData(soapMsg,isTest);
			// updating the employment application record with the response from Hire Right.
			updateEmploymentApplication(recordId,resBody,soapMsg);
			retValue = resBody;  
			System.debug('retValue--------------->'+ retValue);
			HRStatusResponseParser parser = new HRStatusResponseParser();
			return parser.processResponse(recordId,retValue);
		} catch(Exception e) {
			System.debug('Exception calling HR -->'+e.getMessage());
			sendEmail(recordId,e.getMessage()+ ' Soap Message From HR Server::'+ retValue);
			return null;		
		}  	
		return retValue;
	}	
	
	/** 
	 * Method given the emplyment id retrieve the complete emplyment application details.
	 * @param employmentId is a String.
	 * @return Employment_Application__c.
	 */
	public static Employment_Application__c getEmploymentApplicationDetails(String employmentId,List<Schema.DescribeFieldResult> fieldList) {
		Map<String, Schema.SObjectField> employmentApplicationFieldsMap = Schema.SObjectType.Employment_Application__c.fields.getMap();
		Schema.DescribeFieldResult fieldResult = null;
		String soqlQuery = 'SELECT ';
		for(Schema.SObjectField empFieldDetails : employmentApplicationFieldsMap.values()) {
			fieldResult = empFieldDetails.getDescribe();
			if (fieldResult.isCreateable()) {
			    soqlQuery = soqlQuery + fieldResult.getName();
				soqlQuery = soqlQuery + COMMA;
				fieldList.add(fieldResult);
			}
		}
		soqlQuery =  soqlQuery + 'CreatedDate  FROM Employment_Application__c WHERE Id=\'' + employmentId + '\'';
		System.debug('Soql Query ---------->'+ soqlQuery);
		
		return Database.query(soqlQuery);
	}
	
	/**
	 * Method to format the data that was retrieved from the database, to make sure there are no xml/special characters.
	 * As it will break the soap message.
	 */
	private static void formatData(Employment_Application__c emplymentApplicationDetails,List<Schema.DescribeFieldResult> fieldList) {
		String fieldValue = null;
		
		for(Schema.DescribeFieldResult fieldResult : fieldList) {
			if (emplymentApplicationDetails.get(fieldResult.getName()) instanceOf String) {
				fieldValue =(String)emplymentApplicationDetails.get(fieldResult.getName()); 
				if (fieldValue != null && fieldValue.trim().length() > 0) {
					emplymentApplicationDetails.put(fieldResult.getName(),String.escapeSingleQuotes(fieldValue.replaceAll('["*^/;&<>()]','')));		
				} 
			}
			
		}
	}
	
    /**
	 * Method to send the soap message to Hire Right.
	 * @param String message.
	 * @return String resBody.
	 */
	private static String postData(String  message, boolean isTest) {
		// create the HTTP Request
		String resBody = '';
		HttpRequest req = new HttpRequest();		
     	req.setEndpoint('https://casasaas.com/hrproxy/hrproxy.aspx'); 
     	req.setMethod('POST');
	    String hireRightURL = getHRURL();
	    hireRightURL = EncodingUtil.urlEncode(hireRightURL,'UTF-8');
		message = EncodingUtil.urlEncode(message,'UTF-8');
		req.setBody('hrurl=' + hireRightURL + '&soapaction=GenerateWebLink&reqxml=' + message);
			
		// create an HTTP object and use it to send the request
	    Http http = new Http();
	    if (!isTest) {
	        HTTPResponse res = http.send(req);
	        resBody = getSoapMsg(res.getBody());
	    }
	    
	    return  resBody;
	}
	
	private static void updateEmploymentApplication(String recordId, String response, String message) {
		updateEmploymentApplication(recordId,response,message, false);
	}
	
	/**
	 * Method to update the employment application with the response from hire right.
	 * @param String recordId.
	 * @param String response.
	 * @param String message.
	 */
	private static void updateEmploymentApplication(String recordId, String response, String message,boolean updateSentDetails) {
		Employment_Application__c ea = new Employment_Application__c(Id=recordId);
		ea.Raw_Status_Response__c = 'RESPONSE:\n\n' + response + '\n\n\nORIGINAL SOAP MESSAGE:\n\n' + EncodingUtil.urlDecode(message,'UTF-8');
		if (updateSentDetails) {
			ea.BI_Summary_Status__c = 'Sent';
	    	ea.Criminal_Screen__c = 'Sent';
	    	ea.Education_Screen__c = 'Sent';
	    	ea.Employment_Screen__c = 'Sent';
		}
		try{
			update ea;
		}catch(DMLException ex){
			sendEmail(recordId,ex.getMessage());
		}
	}	
	
	/**
	 * Method to parse the soap message.
	 * @param soapMsg is a String.
	 * @return url is a String.
	 */
	private static String getURL(String soapMsg) {
		String url = null;
		if (soapMsg != null && soapMsg.trim().length() > 0) {
	        XmlStreamReader xsr = new XmlStreamReader(soapMsg);
			//extract the URL sent by HR
			while(xsr.hasNext()) {
			    if (xsr.getEventType() == XmlTag.START_ELEMENT) {
		            if ('URL' == xsr.getLocalName()) {
	  		            while(xsr.hasNext()) {
					        if (xsr.getEventType() == XmlTag.END_ELEMENT) {
					           break;
					        } else if (xsr.getEventType() == XmlTag.CHARACTERS) {
					           url = xsr.getText();
					        }
					        xsr.next();
					    }
		            }
			    }
			    xsr.next();
			}
		}
		return url;
	}
	
    /**
	 * Method to get the Hire Right Url
	 * @return String hireRightURL.
	 */
	private static String getHRURL() {
		TF2Settings__c configurations = TF2Settings__c.getInstance();
		String hireRightURL = null;
		hireRightURL = configurations.HR_URL__c;
		
		return hireRightURL;
	}
	
    /**
     * Method to parse the response from the Hire Right server.
     * @param httpResp is a String.
     * @return is a String.
     */
	private static String getSoapMsg(String httpResp) {
    	Integer startResp = httpResp.indexOf('---BEGINRESPONSE---') + 19;
    	Integer endResp = httpResp.indexOf('---ENDRESPONSE---');
    	httpResp = httpResp.substring(startResp,endResp);		    	
    	return EncodingUtil.base64Decode(httpResp).toString();
	}
	
	
	private static void sendEmail(String recordId, String message) {
		
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSubject('Error in Hire Right Integration');
		String emailBody='Employment Application Id::'+ recordId;
		emailBody = emailBody + NEW_LINE;
		emailBody = emailBody + ' Date ::'+ System.today();
		emailBody = emailBody + NEW_LINE;
		emailBody = emailBody + ' Exception ::'+ message;
		mail.setPlainTextBody(emailBody);
		List<String> toAddressList = new List<String>();
		toAddressList.add(getNotifyingEmail()); 
		mail.setToAddresses(toAddressList);
		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>(); 
		mailList.add(mail);
		Messaging.sendEmail(mailList);		
		
	}
	
	 /**
	 * Method to get the Hire Right Integration exception email from the custom setting.
	 * @return String notificationEmail.
	 */
	private static String getNotifyingEmail() {
		TF2Settings__c configurations = TF2Settings__c.getInstance();
		String notificationEmail = null;
		notificationEmail = configurations.HR_Integration_Exception_Notification__c;
		
		return notificationEmail;
	}
		
	
	

}