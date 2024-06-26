global class HRStatusResponseParser {

	static String soapResp = '';
	static List<HRStatusResponse> allHRSR;
	static HRStatusResponse thisHRSR;
			
	public HRStatusResponseParser(){}

	private static String updateStatuses()
	{
		List<Employment_Application__c> empApps = new List<Employment_Application__c>();
		
		System.debug('in updateStatuses');
		System.debug('num screens: ' + thisHRSR.Screenings.size());
		
		for(HRStatusResponse hrsr : allHRSR)
		{
			Employment_Application__c ea = new Employment_Application__c(Id=hrsr.ApplicantId);
			Boolean crimInReview = false;
			Boolean crimFailed = false;
//			Boolean crimPassed = false;
			Boolean eduInReview = false;
			Boolean eduFailed = false;
//			Boolean eduPassed = false;
			Boolean empInReview = false;
			Boolean empFailed = false;
//			Boolean empPassed = false;
									
			for(Screening s : hrsr.Screenings)
			{
				System.debug('screening loop');
				System.debug('screentype: ' + s.ScreenType);
				
				if(s.ScreenType == 'criminal' || s.ScreenName.indexOf('Criminal')>-1)
				{
					if(s.ResultStatus == 'Fail')
					{ 
						crimFailed = true;
						ea.Criminal_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;					
					}
					else if(s.ResultStatus == 'Review' && !crimFailed)
					{
						crimInReview = true;
						ea.Criminal_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;											
					}
					else if(s.ResultStatus == 'Pass' && !crimFailed && !crimInReview)
					{
						ea.Criminal_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;					
					}
					else
					{
						ea.Criminal_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;					
					}
				}
				if(s.ScreenType == 'education')
				{
					if(s.ResultStatus == 'Fail')
					{ 
						eduFailed = true;
						ea.Education_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;					
					}
					else if(s.ResultStatus == 'Review' && !eduFailed)
					{
						eduInReview = true;
						ea.Education_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;											
					}
					else if(s.ResultStatus == 'Pass' && !eduFailed && !eduInReview)
					{
						ea.Education_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;					
					}
					else
					{
						ea.Education_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;					
					}
				}
				if(s.ScreenType == 'employment')
				{
					if(s.ResultStatus == 'Fail')
					{ 
						empFailed = true;
						ea.Employment_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;					
					}
					else if(s.ResultStatus == 'Review' && !empFailed)
					{
						empInReview = true;
						ea.Employment_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;											
					}
					else if(s.ResultStatus == 'Pass' && !empFailed && !empInReview)
					{
						ea.Employment_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;					
					}
					else
					{
						ea.Employment_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;					
					}
				}

/*				
				if(s.ScreenType == 'education')
				{
					ea.Education_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;
				}
				if(!empFailed && s.ScreenType == 'employment')
				{
					ea.Employment_Screen__c = s.OrderStatus + ' - ' + s.ResultStatus;
					if(s.ResultStatus == 'Fail'){ empFailed = true; } // once one fails, we ignore others
				}
*/				
			}
			if(thisHRSR.SummaryStatus != null)
			{
				ea.BI_Summary_Status__c = thisHRSR.SummaryStatus;
			}
			ea.Discrepancies__c = thisHRSR.Discrepancies;
			ea.BI_Percent_Complete__c = thisHRSR.PercentComplete;
//			ea.Raw_Status_Response__c = soapResp;
			empApps.add(ea);
		}
		try{
			update empApps;
			return 'success';
		}catch(DMLException ex){
			System.debug('CASA 2 - dml ex: ' + ex.getMessage());
			return ex.getMessage();
		}
	}

	public String processResponse(ID eaid, String resp){
		allHRSR = new List<HRStatusResponse>();
		thisHRSR = new HRStatusResponse(eaid);
		
		String parsedResponse = null;
		XmlStreamReader xsr = new XmlStreamReader(resp);
		parsedResponse = parseHRResponse(xsr);
		allHRSR.add(thisHRSR);

		soapResp = resp;
		updateStatuses();
		
		return eaid;
	}

/*	
	webservice static String testWS(ID eaid){
		allHRSR = new List<HRStatusResponse>();
		thisHRSR = new HRStatusResponse(eaid);
		
		Employment_Application__c empappl = [select id, Raw_Status_Response__c,  from Employment_Application__c where id=:eaid limit 1];
		System.debug('The EmpApp name is --> '+eaid);
		
		// get the Raw_Status_Response__c, parse it, and stick it in 
		if(empappl!=null)
		{
			String parsedResponse = null;
//			empappl. = empappl.Raw_Status_Response__c;
			// crete an XMLStreamReader to process the reponse from HR
			XmlStreamReader xsr = new XmlStreamReader(empappl.Raw_Status_Response__c);
			parsedResponse = parseHRResponse(xsr);
			allHRSR.add(thisHRSR);

//			updateStatuses();

			empappl.Status_Response_Log__c = parsedResponse;

			update empappl;	
		}				
		
		return eaid;
	}
*/

	global static String parseHRResponse(XmlStreamReader xsr){
		
		String response = null;
		Map<Integer,String> logMap = new Map<Integer,String>();
		Integer j=3;
		while(xsr.hasNext())
		{
			if(xsr.getEventType()==XmlTag.START_ELEMENT)
			{
				if('NoOfReports' == xsr.getLocalName()) 
				{
					System.debug('NoOfReports Cursor Location--> '+xsr.getLocation());
					logMap.put(1,'Number of Reports:'+ getXmlNodeChars(xsr));
				}
					
				if('ProviderReferenceId' == xsr.getLocalName()) 
				{
					System.debug('epka 1 provider ref id');
					logMap.put(2, 'Provider Reference Ids:\n'+getProviderReferenceIds(xsr));
				}
				if('BackgroundReportPackage' == xsr.getLocalName())
				{
					
					logMap.put(j,'BackgroundReportPackage \n'+getBackgroundReportPackage(xsr));
					j++;
				}
			}
			xsr.next();
		}
		
		for(Integer i=1; i<=logMap.size(); i++)
		{
			String logEntry = logMap.get(i);
			System.debug('Log entry --> '+logEntry);
			if(response==null)
				response=logEntry+'\n\n';
			else
				response=response+logEntry+'\n\n';
		}	
	
		return response;
	}

	

	global static String getProviderReferenceIds(XmlStreamReader reader)
	{
		String response = null;
		Map<String,String> logMap = new Map<String,String>();

		reader.next();
		while(reader.hasNext())
		{
			if(reader.getEventType() == XmlTag.END_ELEMENT && 'ProviderReferenceId'==reader.getLocalName())
				break;
			if(reader.getEventType()==XmlTag.START_ELEMENT)
			{
				if(0==reader.getAttributeCount() && 'IdValue'==reader.getLocalName())
						{logMap.put('Provider Ref. Id: ',getXmlNodeChars(reader));continue;}	
				if(0<reader.getAttributeCount())
				{
					if('order#'==reader.getAttributeValueAt(0) && 'IdValue'==reader.getLocalName())
							{logMap.put('order#: ',getXmlNodeChars(reader));continue;}	
					if('requestID'==reader.getAttributeValueAt(0) && 'IdValue'==reader.getLocalName())
							{logMap.put('requestID: ',getXmlNodeChars(reader));continue;}	
					if('customerID'==reader.getAttributeValueAt(0) && 'IdValue'==reader.getLocalName())
							{logMap.put('customerID: ',getXmlNodeChars(reader));continue;}	
					if('viewResultLinkText'==reader.getAttributeValueAt(0) && 'IdValue'==reader.getLocalName())
							{logMap.put('viewResultLinkText: ',getXmlNodeChars(reader));continue;}	
					if('accountName'==reader.getAttributeValueAt(0) && 'IdValue'==reader.getLocalName())
							{logMap.put('accountName: ',getXmlNodeChars(reader));continue;}	
					if('companyLogin'==reader.getAttributeValueAt(0) && 'IdValue'==reader.getLocalName())
							{logMap.put('companyLogin: ',getXmlNodeChars(reader));continue;}
					if('OrderServiceNo'==reader.getAttributeValueAt(0) && 'IdValue'==reader.getLocalName())
							{logMap.put('OrderServiceNo: ',getXmlNodeChars(reader));continue;}
				}	
					
//				System.debug('Cursor Location--> '+reader.getLocation()+'localName --> '+reader.getLocalName()+' Attribute Type --> '+reader.getAttributeType(0)+' Attribute local name --> '+reader.getAttributeLocalName(0)+ ' Attribute value -->'+reader.getAttributeValueAt(0));
			}
			reader.next();
		}
		
		Set<String> logLabels = new Set<String>();
		logLabels = logMap.keySet();
		for(String label : logLabels)
		{
			if(response==null)
				response=label+logMap.get(label)+'\n';
			else
				response=response+label+logMap.get(label)+'\n';
		}	
		return response;		
		
	}

	global static String getBackgroundReportPackage(XmlStreamReader reader)
	{
		String response = null;
		Map<Integer,String> logMap = new Map<Integer,String>();

		reader.next();
		while(reader.hasNext())
		{
			if(reader.getEventType() == XmlTag.END_ELEMENT && 'BackgroundReportPackage'==reader.getLocalName())
				break;
			if(reader.getEventType()==XmlTag.START_ELEMENT)
			{
				if('PackageId'==reader.getLocalName()) 
						{logMap.put(1,'Package Id: '+getBackgroundReportPackageId(reader));continue;}	
				if('ScreeningStatus'==reader.getLocalName()) 
				{
					Screening s = new Screening();
					s = getScreeningStatus(reader,s);
					thisHRSR.SummaryStatus = s.OrderStatus + ' - ' + s.ResultStatus;
//					logMap.put(2,'ScreeningStatus: \n'+getScreeningStatus(reader));continue;
					logMap.put(2,'ScreeningStatus: \n'+s.OrderStatus+'-'+s.ResultStatus);continue;
				}	
				if('ScreeningsSummary'==reader.getLocalName()) 
						{logMap.put(3,'ScreeningsSummary: \n'+getScreeningSummary(reader));continue;}	
				if('Screenings'==reader.getLocalName()) 
						{logMap.put(4,'Screenings: \n'+getScreenings(reader));continue;}	
			}
			reader.next();
		}
		
		for(Integer i=1; i<=logMap.size(); i++)
		{
			String logEntry = logMap.get(i);
			if(response==null)
				response=logEntry+'\n';
			else
				response=response+logEntry+'\n';
		}	
		return response;		
	}

	global static String getBackgroundReportPackageId(XmlStreamReader reader)
	{
		String response = null;
		Map<String,String> logMap = new Map<String,String>();

		reader.next();
		while(reader.hasNext())
		{
			if(reader.getEventType() == XmlTag.END_ELEMENT && 'PackageId'==reader.getLocalName())
				break;
			if(reader.getEventType()==XmlTag.START_ELEMENT)
			{
				if('PackageId'==reader.getLocalName()) {System.debug('PackageId start element');reader.next();}	
				if('IdValue'==reader.getLocalName())
						{logMap.put('Package Id: ',getXmlNodeChars(reader));System.debug('IdValue start element');continue;}	
			}
			reader.next();
		}
		
		Set<String> logLabels = new Set<String>();
		logLabels = logMap.keySet();
		for(String label : logLabels)
		{
			if(response==null)
				response=label+logMap.get(label)+'\n';
			else
				response=response+label+logMap.get(label)+'\n';
		}	
		return response;		
	}

	global static String getScreeningSummary(XmlStreamReader reader)
	{
		String response = null;
		Map<Integer,String> logMap = new Map<Integer,String>();

		reader.next();
		Integer j=2;
		while(reader.hasNext())
		{
			if(reader.getEventType() == XmlTag.END_ELEMENT && 'ScreeningsSummary'==reader.getLocalName())
				break;
			if(reader.getEventType()==XmlTag.START_ELEMENT)
			{
				if('ClientReferences'==reader.getLocalName()) 
					{logMap.put(1,'Client References: \n'+getClientReferences(reader));continue;}	
				if('AdditionalItems'==reader.getLocalName()) 
					{logMap.put(j,getAdditionalItems(reader));j++;continue;}	
			}
			reader.next();
			
		}
		
		for(Integer i=1; i<=logMap.size(); i++)
		{
			String logEntry = logMap.get(i);
			if(response==null)
				response=logEntry+'\n\n';
			else
				response=response+logEntry+'\n\n';
		}	
		return response;		
	}


	global static String getClientReferences(XmlStreamReader reader)
	{
		String response = null;
		Map<String,String> logMap = new Map<String,String>();

		reader.next();
		while(reader.hasNext())
		{
			if(reader.getEventType() == XmlTag.END_ELEMENT && 'ClientReferences'==reader.getLocalName())
				break;
			if(reader.getEventType()==XmlTag.START_ELEMENT)
			{
				if(0<reader.getAttributeCount())
				{
					if('ClientRequestId'==reader.getAttributeValueAt(0) && 'IdValue'==reader.getLocalName())
							{logMap.put('ClientRequestId: ',getXmlNodeChars(reader));continue;}	
					if('ClientApplicantId'==reader.getAttributeValueAt(0) && 'IdValue'==reader.getLocalName())
							{logMap.put('ClientApplicantId: ',getXmlNodeChars(reader));continue;}	
				}	
					
				System.debug('Cursor Location--> '+reader.getLocation()+'localName --> '+reader.getLocalName()+' Attribute Type --> '+reader.getAttributeType(0)+' Attribute local name --> '+reader.getAttributeLocalName(0)+ ' Attribute value -->'+reader.getAttributeValueAt(0));
			}
			reader.next();
		}
		
		Set<String> logLabels = new Set<String>();
		logLabels = logMap.keySet();
		for(String label : logLabels)
		{
			if(response==null)
				response='\t'+label+logMap.get(label)+'\n';
			else
				response=response+'\t'+label+logMap.get(label)+'\n';
		}	
		return response;		
		
	}


	global static String getAdditionalItems(XmlStreamReader reader)
	{
		String response = null;
		Map<String,String> logMap = new Map<String,String>();

//		reader.next();
		while(reader.hasNext())
		{
			if(reader.getEventType() == XmlTag.END_ELEMENT && 'AdditionalItems'==reader.getLocalName())
				break;
			if(reader.getEventType()==XmlTag.START_ELEMENT)
			{
				if(0<reader.getAttributeCount())
				{
					if('x:Adjudication'==reader.getAttributeValueAt(0) && 'AdditionalItems'==reader.getLocalName())
							{logMap.put('Additional Item : x:Adjudication: ',getAdditionalItem(reader));continue;}	
					if('x:PercentComplete'==reader.getAttributeValueAt(0) && 'AdditionalItems'==reader.getLocalName())
							{
								String percent = getAdditionalItem(reader).replace('%','');
								System.debug('CASA 1: ' + percent);
								thisHRSR.PercentComplete = Double.valueOf(percent);
								logMap.put('Additional Item : x:PercentComplete: ',percent);
								continue;
							}	
					if('x:Screenings'==reader.getAttributeValueAt(0) && 'AdditionalItems'==reader.getLocalName())
					{logMap.put('Additional Item : x:Screenings: ',getAdditionalItem(reader));continue;}	
					if('x:Discrepancies'==reader.getAttributeValueAt(0) && 'AdditionalItems'==reader.getLocalName())
					{
						thisHRSR.Discrepancies = getAdditionalItem(reader);
						logMap.put('Additional Item : x:Discrepancies: ',getAdditionalItem(reader));
						continue;
					}	
					if('x:DateOfBirth'==reader.getAttributeValueAt(0) && 'AdditionalItems'==reader.getLocalName())
							{logMap.put('Additional Item : x:DateOfBirth: ',getAdditionalItem(reader));continue;}	
				}	
					
				System.debug('Cursor Location--> '+reader.getLocation()+'localName --> '+reader.getLocalName()+' Attribute Type --> '+reader.getAttributeType(0)+' Attribute local name --> '+reader.getAttributeLocalName(0)+ ' Attribute value -->'+reader.getAttributeValueAt(0));
			}
			reader.next();
		}
		Set<String> logLabels = new Set<String>();
		logLabels = logMap.keySet();
		for(String label : logLabels)
		{
			if(response==null)
				response=label+logMap.get(label)+'\n';
			else
				response=response+label+logMap.get(label)+'\n';
		}	
		return response;		
	}

	global static String getAdditionalItem(XmlStreamReader reader)
	{
		String chars = '';
		while(reader.hasNext())
		{
			
			if(reader.getEventType() == XmlTag.END_ELEMENT)
				break;
			if(reader.getEventType() == XmlTag.START_ELEMENT)
			{
				if('Text'==reader.getLocalName())
					chars =getXmlNodeChars(reader);
					
			}
			reader.next();
		}
		return chars;
	}


	global static String getScreenings(XmlStreamReader reader)
	{
		
		String response = null;
		Map<String,String> logMap = new Map<String,String>();

		reader.next();
		Integer n = 0;
		Screening s;
				
		while(reader.hasNext())
		{
			if(reader.getEventType() == XmlTag.END_ELEMENT && 'Screenings'==reader.getLocalName())
				break;
			if(reader.getEventType()==XmlTag.START_ELEMENT)
			{
				if('Screening'==reader.getLocalName()) 
				{
					n++;
					s = new Screening();

					s.ScreenName = reader.getAttributeValueAt(0).replace('x:','');
					s.ScreenType = reader.getAttributeValueAt(1);
					
					System.debug('Screening found ' + n + ': ' + reader.getAttributeValueAt(1));
					reader.next();
				}	
				if('ProviderReferenceId'==reader.getLocalName())
				{
					System.debug('ProviderReferenceId found ' + n);
					reader.next();
				}	
				if('ScreeningStatus'==reader.getLocalName())
				{
					System.debug('ScreeningStatus found ' + n);
					s = getScreeningStatus(reader,s);
					System.debug('OrderStatus ' + n + ' = ' + s.OrderStatus);
					System.debug('ResultStatus ' + n + ' = ' + s.ResultStatus);
					reader.next();
				}	
				thisHRSR.Screenings.add(s);						
			}
			reader.next();
		}
		
		System.debug('Total Screens Added: ' + thisHRSR.Screenings.size());
		
		Set<String> logLabels = new Set<String>();
		logLabels = logMap.keySet();
		for(String label : logLabels)
		{
			if(response==null)
				response=label+logMap.get(label)+'\n';
			else
				response=response+label+logMap.get(label)+'\n';
		}	
		return response;		
	}

	global static Screening getScreeningStatus(XmlStreamReader reader, Screening s)
	{
		String response = null;
		Map<String,String> logMap = new Map<String,String>();

		reader.next();
		while(reader.hasNext())
		{
			if(reader.getEventType() == XmlTag.END_ELEMENT && 'ScreeningStatus'==reader.getLocalName())
				break;
			if(reader.getEventType()==XmlTag.START_ELEMENT)
			{
				if('OrderStatus'==reader.getLocalName()) 
				{
					s.OrderStatus = getXmlNodeChars(reader);
					logMap.put('OrderStatus: ',getXmlNodeChars(reader));
					System.debug('IdValue start element');
					continue;
				}	
				if('ResultStatus'==reader.getLocalName())
				{
					s.ResultStatus = getXmlNodeChars(reader);
					logMap.put('ResultStatus: ',getXmlNodeChars(reader));
					System.debug('IdValue start element');
					continue;
					}	
				if('DateOrderReceived'==reader.getLocalName())
					{logMap.put('DateOrderReceived: ',getXmlNodeChars(reader));System.debug('IdValue start element');continue;}	
			}
			reader.next();
		}
		
		Set<String> logLabels = new Set<String>();
		logLabels = logMap.keySet();
		for(String label : logLabels)
		{
			if(response==null)
				response=label+logMap.get(label)+'\n';
			else
				response=response+label+logMap.get(label)+'\n';
		}	
//		return response;		
		return s;
	}


	global static String getXmlNodeChars(XmlStreamReader reader)
	{
		String chars = '';
		while(reader.hasNext())
		{
			if(reader.getEventType() == XmlTag.END_ELEMENT)
			{
				return chars;
			}
			else if (reader.getEventType() == XmlTag.CHARACTERS)
			{
				chars = reader.getText();
			}
			reader.next();
		}
		return chars;
	}

}