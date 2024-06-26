public class HRSoapMessageGenerator {
	
	String smBegin = '<soapenv:Envelope xmlns:soapenv= "http://schemas.xmlsoap.org/soap/envelope/" >'+
						'<soapenv:Header>'+
							'<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" soapenv:mustUnderstand="1">'+
								'|||WSS-HEADER|||'+
							'</wsse:Security>'+
						'</soapenv:Header>'+
		     			'<soapenv:Body>';
	String smEnd = 		'</soapenv:Body>'+
					'</soapenv:Envelope>';

	public HRSoapMessageGenerator(){}
	
	public String getStatusScreeningReport(Employment_Application__c rec) {
	    String soapMsg = '<objs:Search xmlns:objs="urn:enterprise.soap.hireright.com/objs">'+
					'<objs:SearchRequest objType="StatusScreeningReport">'+
		            	'<objs:AccountId>WS_SFDC</objs:AccountId>';
			soapMsg +=		'<objs:ClientApplicantId>' + rec.Id + '</objs:ClientApplicantId>'+
							'<objs:ClientRequestId>' + rec.CreatedDate.formatGmt('yyyyMMddHHmmssSSS') + '</objs:ClientRequestId>';
			soapMsg +='</objs:SearchRequest>'+
				'</objs:Search>';
		return smBegin + soapMsg + smEnd;
	}
	
	public String viewApplicantDataWL(Employment_Application__c rec,String uid) {

        // use 'apitest' for sandbox env
     	String soapMsg = '<hr_objs:GenerateWebLink xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:hr_objs="urn:enterprise.soap.hireright.com/objs" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
					'<hr_objs:HRWebLink xsi:type="hr_objs:ViewApplicantDataWL" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
						'<hr_objs:UserRefId>' + uid + '</hr_objs:UserRefId>'+
		            	'<hr_objs:CompanyLogin>SFDC</hr_objs:CompanyLogin>'+
		            	'<hr_objs:AccountId>WS_SFDC</hr_objs:AccountId>'+
						'<!--Either the ClientApplicantId and ClientRequestId or ApplicationId (HireRights) is Required-->'+
						'<!-- <hr_objs:ApplicationId>2392323</hr_objs:ApplicationId> -->';
		soapMsg +=		'<hr_objs:ClientApplicantId>' + rec.Id + '</hr_objs:ClientApplicantId>'+
						'<hr_objs:ClientRequestId>' + rec.CreatedDate.formatGmt('yyyyMMddHHmmssSSS') + '</hr_objs:ClientRequestId>';
		soapMsg +=	'</hr_objs:HRWebLink>'+
				'</hr_objs:GenerateWebLink>';
		return smBegin + soapMsg + smEnd;
	}
	public String orderApplicationWL(Employment_Application__c rec,String uid) {
		DataUtil du = new DataUtil();

//		WSSecurityUtil wss = new WSSecurityUtil('wsapi_sfdc', 'wsapi_SFDC-19', rec.Id, 'SHA1');
//		WSSecurityUtil wss = new WSSecurityUtil('john', 'changeme', rec.Id, 'SHA1');			
//		soapMsg += wss.getFullHeader();

		
		// use 'apitest' for sandbox env
     	String soapMsg = '<hr_objs:GenerateWebLink xmlns:soapenc= "http://schemas.xmlsoap.org/soap/encoding/" xmlns:hr_objs= "urn:enterprise.soap.hireright.com/objs" xmlns:s1="http://ns.hr-xml.org/2006-02-28" xmlns:s2="ext:enterprise.soap.hireright.com" xmlns:s0="urn:enterprise.soap.hireright.com/Application" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
			'<hr_objs:HRWebLink xsi:type="hr_objs:OrderApplicationWL" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
				'<hr_objs:UserRefId>' + uid + '</hr_objs:UserRefId>'+
            	'<hr_objs:CompanyLogin>SFDC</hr_objs:CompanyLogin>'+
            	'<hr_objs:AccountId>WS_SFDC</hr_objs:AccountId>'+
				'<hr_objs:ClientApplicantId>' + rec.Id + '</hr_objs:ClientApplicantId>'+
				'<hr_objs:ClientRequestId>' + rec.CreatedDate.formatGmt('yyyyMMddHHmmssSSS') + '</hr_objs:ClientRequestId>'+
				'<hr_objs:Candidate>'+
				'	<s0:CandidateProfile>'+
				'		<s0:PersonalData>'+
				'			<s1:PersonName>'+
				'				<s1:GivenName>' + rec.First_Name_Contact__c + '</s1:GivenName>';
				if(rec.Middle_Name_Contact__c == null)
				{
					soapMsg += '<s1:MiddleName />';	
				}else{
					soapMsg += '<s1:MiddleName>' + rec.Middle_Name_Contact__c + '</s1:MiddleName>';
				}
				soapMsg += '	<s1:FamilyName>' + rec.Last_Name_Contact__c + '</s1:FamilyName>'+
				'			</s1:PersonName>'+
				'			<s1:ContactMethod>'+
				'				<s1:Location>home</s1:Location>';

				if(rec.Mobile_Phone_Contact__c != null)
				{
	soapMsg +=	'				<s1:Telephone>'+
				'					<s1:FormattedNumber>' + du.formatPhone(rec.Mobile_Phone_Contact__c) + '</s1:FormattedNumber>'+
				'				</s1:Telephone>';
				}
				else if(rec.Home_Phone_Contact__c != null)
				{					
	soapMsg +=	'				<s1:Telephone>'+
				'					<s1:FormattedNumber>' + du.formatPhone(rec.Home_Phone_Contact__c) + '</s1:FormattedNumber>'+
				'				</s1:Telephone>';
				}
				else
				{
	soapMsg +=	'				<s1:Telephone />';
				}

				if(rec.Email_Contact__c != null)
				{					
	soapMsg +=	'				<s1:InternetEmailAddress>' + rec.Email_Contact__c + '</s1:InternetEmailAddress>';
				}else{
	soapMsg +=	'				<s1:InternetEmailAddress />';
				}
	soapMsg +=	'				<s1:PostalAddress>';
	if(rec.Country_Contact__c==null || rec.Country_Contact__c=='')
	{
		soapMsg +=				   '<s1:CountryCode>USA</s1:CountryCode>';
	}else{
		soapMsg +=				   '<s1:CountryCode>' + rec.Country_Contact__c + '</s1:CountryCode>';
	}
	soapMsg +=	'					<s1:PostalCode>' + rec.Zip_Postal_Code_Contact__c + '</s1:PostalCode>'+
				'					<s1:Region>' + rec.State_Contact__c + '</s1:Region>'+
				'					<s1:Municipality>' + rec.City_Contact__c + '</s1:Municipality>' +

				'					<s1:DeliveryAddress>'+
				'						<s1:AddressLine>' + rec.Current_Address_Contact__c + '</s1:AddressLine>'+
				'					</s1:DeliveryAddress>'+
				'				</s1:PostalAddress>'+
				'			</s1:ContactMethod>'+
				'			<s1:PersonDescriptors>'+
								'<s1:BiologicalDescriptors>'+
								'	<s1:DateOfBirth/>'+
								'</s1:BiologicalDescriptors>'+
							'</s1:PersonDescriptors>'+
							'<s1:UserArea>'+
						'		<s2:OtherNames>'+
						'			<s2:OtherName type="" validFrom="" validTo="">'+
						'				<s2:PersonName>'+
						'					<s2:FormattedName />'+
						'					<s2:GivenName />'+
						'					<s2:MiddleName />'+
						'					<s2:FamilyName />'+
						'				</s2:PersonName>'+
						'			</s2:OtherName>'+
						'		</s2:OtherNames>'+
						'	</s1:UserArea>'+
						'</s0:PersonalData>'+
						'<s0:EmploymentHistory>';

		if(rec.Name_of_Company_Job_1__c != null && rec.Name_of_Company_Job_1__c != '')
		{
			soapMsg += '	<s1:EmployerOrg>'+
						'		<s1:EmployerOrgName>' + rec.Name_of_Company_Job_1__c + '</s1:EmployerOrgName>'+						
						'		<s1:EmployerContactInfo>'+
						'			<s1:ContactMethod>'+
						'				<s1:Telephone>'+
						'					<s1:FormattedNumber>' + du.formatPhone(rec.Phone_Job_1__c) + '</s1:FormattedNumber>'+
						'				</s1:Telephone>'+
						'				<s1:PostalAddress>'+
						'					<s1:CountryCode>' + rec.Country_Job_1__c + '</s1:CountryCode>'+
						'					<s1:PostalCode />' +
						'					<s1:Region>' + rec.State_Job_1__c + '</s1:Region>'+
						'					<s1:Municipality>' + rec.City_Job_1__c + '</s1:Municipality>'+
						'					<s1:DeliveryAddress>'+
						'						<s1:AddressLine>'+ rec.Address_Job_1__c + '</s1:AddressLine>'+
						'					</s1:DeliveryAddress>'+
						'				</s1:PostalAddress>'+
						'			</s1:ContactMethod>'+
						'			<s1:LocationSummary>'+
						'				<s1:Municipality />'+
						'				<s1:Region />'+
						'			</s1:LocationSummary>'+
						'		</s1:EmployerContactInfo>'+
						'			<s1:PositionHistory	positionType="directHire" currentEmployer=';
							if(rec.Current_Employer__c == 'Yes')
							{
								soapMsg += '"true">';
							}else{
								soapMsg += '"false">';
							}
								soapMsg +='<s1:Title>' + rec.Job_Title_Job_1__c + '</s1:Title>'+
						'			<s1:OrgName>'+
						'				<s1:OrganizationName>' + rec.Name_of_Company_Job_1__c + '</s1:OrganizationName>'+
						'			</s1:OrgName>'+
						'			<s1:Description>' + rec.Position_and_Duties_Job_1__c + '</s1:Description>'+
									du.formatYearMonth('s1:StartDate',rec.From_Year_Job_1__c,rec.From_Month_Job_1__c) +
									du.formatYearMonth('s1:EndDate',rec.To_Year_Job_1__c,rec.To_Month_Job_1__c) +
						'			<s1:Compensation>'+
						'				<s1:EndingCompensation currency="USD">'+ rec.Ending_Salary_Job_1__c.intValue() + '</s1:EndingCompensation>'+
						'			</s1:Compensation>'+
						'			<s1:Verification>'+
						'				<s1:ContactInfo>'+
						'					<s1:PersonName>'+
						'						<s1:FormattedName>' + rec.Name_of_Supervisor_Job_1__c + '</s1:FormattedName>'+
						'					</s1:PersonName>'+
						'				</s1:ContactInfo>'+
						'				<s1:ReasonForLeaving>' + rec.Reason_for_Leaving_Job_1__c + '</s1:ReasonForLeaving>'+
						'				<s1:PermissionToContact>';
							if(rec.Permission_to_Contact_Employer__c == 'Yes')
							{
							soapMsg += 'true';
							}else{
							soapMsg += 'false';
							}
						soapMsg += '   </s1:PermissionToContact>'+
						'			</s1:Verification>'+
						'		</s1:PositionHistory>'+
						'	</s1:EmployerOrg>';
		}

		if(rec.Name_of_Company_Job_2__c != null && rec.Name_of_Company_Job_2__c != '')
		{
			soapMsg += '	<s1:EmployerOrg>'+
						'		<s1:EmployerOrgName>' + rec.Name_of_Company_Job_2__c + '</s1:EmployerOrgName>'+						
						'		<s1:EmployerContactInfo>'+
						'			<s1:ContactMethod>'+
						'				<s1:Telephone>'+
						'					<s1:FormattedNumber>' + du.formatPhone(rec.Phone_Job_2__c) + '</s1:FormattedNumber>'+
						'				</s1:Telephone>'+
						'				<s1:PostalAddress>'+
						'					<s1:CountryCode>' + rec.Country_Job_2__c + '</s1:CountryCode>'+
						'					<s1:PostalCode />' +
						'					<s1:Region>' + rec.State_Job_2__c + '</s1:Region>'+
						'					<s1:Municipality>' + rec.City_Job_2__c + '</s1:Municipality>'+
						'					<s1:DeliveryAddress>'+
						'						<s1:AddressLine>'+ rec.Address_Job_2__c + '</s1:AddressLine>'+
						'					</s1:DeliveryAddress>'+
						'				</s1:PostalAddress>'+
						'			</s1:ContactMethod>'+
						'			<s1:LocationSummary>'+
						'				<s1:Municipality />'+
						'				<s1:Region />'+
						'			</s1:LocationSummary>'+
						'		</s1:EmployerContactInfo>'+
						'		<s1:PositionHistory	positionType="directHire" currentEmployer="false">' +
						'			<s1:Title>' + rec.Job_Title_Job_2__c + '</s1:Title>'+
						'			<s1:OrgName>'+
						'				<s1:OrganizationName>' + rec.Name_of_Company_Job_2__c + '</s1:OrganizationName>'+
						'			</s1:OrgName>'+
						'			<s1:Description>' + rec.Position_and_Duties_Job_2__c + '</s1:Description>'+
									du.formatYearMonth('s1:StartDate',rec.From_Year_Job_2__c,rec.From_Month_Job_2__c) +
									du.formatYearMonth('s1:EndDate',rec.To_Year_Job_2__c,rec.To_Month_Job_2__c) +
						'			<s1:Compensation>'+
						'				<s1:EndingCompensation currency="USD">'+ rec.Ending_Salary_Job_2__c.intValue() + '</s1:EndingCompensation>'+
						'			</s1:Compensation>'+
						'			<s1:Verification>'+
						'				<s1:ContactInfo>'+
						'					<s1:PersonName>'+
						'						<s1:FormattedName>' + rec.Name_of_Supervisor_Job_2__c + '</s1:FormattedName>'+
						'					</s1:PersonName>'+
						'				</s1:ContactInfo>'+
						'				<s1:ReasonForLeaving>' + rec.Reason_for_Leaving_Job_2__c + '</s1:ReasonForLeaving>'+
						'			</s1:Verification>'+
						'		</s1:PositionHistory>'+
						'	</s1:EmployerOrg>';
		}

		if(rec.Name_of_Company_Job_3__c != null && rec.Name_of_Company_Job_3__c != '')
		{
			soapMsg += '	<s1:EmployerOrg>'+
						'		<s1:EmployerOrgName>' + rec.Name_of_Company_Job_3__c + '</s1:EmployerOrgName>'+						
						'		<s1:EmployerContactInfo>'+
						'			<s1:ContactMethod>'+
						'				<s1:Telephone>'+
						'					<s1:FormattedNumber>' + du.formatPhone(rec.Phone_Job_3__c) + '</s1:FormattedNumber>'+
						'				</s1:Telephone>'+
						'				<s1:PostalAddress>'+
						'					<s1:CountryCode>' + rec.Country_Job_3__c + '</s1:CountryCode>'+
						'					<s1:PostalCode />' +
						'					<s1:Region>' + rec.State_Job_3__c + '</s1:Region>'+
						'					<s1:Municipality>' + rec.City_Job_3__c + '</s1:Municipality>'+
						'					<s1:DeliveryAddress>'+
						'						<s1:AddressLine>'+ rec.Address_Job_3__c + '</s1:AddressLine>'+
						'					</s1:DeliveryAddress>'+
						'				</s1:PostalAddress>'+
						'			</s1:ContactMethod>'+
						'			<s1:LocationSummary>'+
						'				<s1:Municipality />'+
						'				<s1:Region />'+
						'			</s1:LocationSummary>'+
						'		</s1:EmployerContactInfo>'+
						'		<s1:PositionHistory	positionType="directHire" currentEmployer="false">' +
						'			<s1:Title>' + rec.Job_Title_Job_3__c + '</s1:Title>'+
						'			<s1:OrgName>'+
						'				<s1:OrganizationName>' + rec.Name_of_Company_Job_3__c + '</s1:OrganizationName>'+
						'			</s1:OrgName>'+
						'			<s1:Description>' + rec.Position_and_Duties_Job_3__c + '</s1:Description>'+
									du.formatYearMonth('s1:StartDate',rec.From_Year_Job_3__c,rec.From_Month_Job_3__c) +
									du.formatYearMonth('s1:EndDate',rec.To_Year_Job_3__c,rec.To_Month_Job_3__c) +
						'			<s1:Compensation>'+
						'				<s1:EndingCompensation currency="USD">'+ rec.Ending_Salary_Job_3__c.intValue() + '</s1:EndingCompensation>'+
						'			</s1:Compensation>'+
						'			<s1:Verification>'+
						'				<s1:ContactInfo>'+
						'					<s1:PersonName>'+
						'						<s1:FormattedName>' + rec.Name_of_Supervisor_Job_3__c + '</s1:FormattedName>'+
						'					</s1:PersonName>'+
						'				</s1:ContactInfo>'+
						'				<s1:ReasonForLeaving>' + rec.Reason_for_Leaving_Job_3__c + '</s1:ReasonForLeaving>'+
						'			</s1:Verification>'+
						'		</s1:PositionHistory>'+
						'	</s1:EmployerOrg>';
		}

		soapMsg += '   </s0:EmploymentHistory>'+

					'	<s0:EducationHistory>';

		if(rec.School_Name_Graducate__c != null && rec.School_Name_Graducate__c != '')
		{
			soapMsg += '	<s1:SchoolOrInstitution'+
					'			schoolType="College">'+
					'			<s1:School>'+
					'				<s1:SchoolName>' + rec.School_Name_Graducate__c + '</s1:SchoolName>'+
					'			</s1:School>'+
					'			<s1:PostalAddress>'+
					'				<s1:CountryCode>' + rec.Country_Graduate__c + '</s1:CountryCode>'+
					'				<s1:PostalCode />'+
					'				<s1:Region>' + rec.State_Graduate__c + '</s1:Region>'+
					'				<s1:Municipality>' + rec.City_Graduate__c + '</s1:Municipality>'+
					'				<s1:DeliveryAddress>'+
					'					<s1:AddressLine />'+
					'				</s1:DeliveryAddress>'+
					'			</s1:PostalAddress>'+
					'			<s1:Degree>'+
					'				<s1:DegreeName>' + rec.Degree_Earned_Graduate__c + '</s1:DegreeName>'+
									du.formatYearMonth('s1:DegreeDate',rec.Last_Attended_Year_Graduate__c,rec.Last_Attended_Month_Graduate__c) +
					'				<s1:DegreeMajor>'+
					'					<s1:Name>' + rec.Major_Graduate__c + '</s1:Name>'+
					'				</s1:DegreeMajor>'+
					'				<s1:DegreeMinor>'+
					'					<s1:Name>' + rec.Minor_Graduate__c + '</s1:Name>'+
					'				</s1:DegreeMinor>'+
					'				<s1:DatesOfAttendance>'+
										du.formatYearMonth('s1:StartDate',rec.Start_Date_Year_Graduate__c,rec.Start_Date_Graduate__c) +
										du.formatYearMonth('s1:EndDate',rec.Last_Attended_Year_Graduate__c,rec.Last_Attended_Month_Graduate__c) +
					'				</s1:DatesOfAttendance>'+
					'				<s1:UserArea>'+
					'					<s2:NameAtTimeOfAttendence>'+
					'						<s2:GivenName>' + rec.Graduated_First_Name_Graduate__c + '</s2:GivenName>'+
					'						<s2:MiddleName />'+
					'						<s2:FamilyName>' + rec.Graduated_Name_Last_Graduate__c + '</s2:FamilyName>'+
					'					</s2:NameAtTimeOfAttendence>'+
					'				</s1:UserArea>'+
					'			</s1:Degree>'+
					'		</s1:SchoolOrInstitution>';
		}
		else if(rec.School_Name_University__c != null && rec.School_Name_University__c != '')
		{
			soapMsg += '	<s1:SchoolOrInstitution'+
					'			schoolType="College">'+
					'			<s1:School>'+
					'				<s1:SchoolName>' + rec.School_Name_University__c + '</s1:SchoolName>'+
					'			</s1:School>'+
					'			<s1:PostalAddress>'+
					'				<s1:CountryCode>' + rec.Country_University__c + '</s1:CountryCode>'+
					'				<s1:PostalCode />'+
					'				<s1:Region>' + rec.State_University__c + '</s1:Region>'+
					'				<s1:Municipality>' + rec.City_University__c + '</s1:Municipality>'+
					'				<s1:DeliveryAddress>'+
					'					<s1:AddressLine />'+
					'				</s1:DeliveryAddress>'+
					'			</s1:PostalAddress>'+
					'			<s1:Degree>'+
					'				<s1:DegreeName>' + rec.Degree_Earned_University__c + '</s1:DegreeName>'+
									du.formatYearMonth('s1:DegreeDate',rec.Last_Attended_Year_University__c,rec.Last_Attended_Month_University__c) +
					'				<s1:DegreeMajor>'+
					'					<s1:Name>' + rec.Major_University__c + '</s1:Name>'+
					'				</s1:DegreeMajor>'+
					'				<s1:DegreeMinor>'+
					'					<s1:Name>' + rec.Minor_University__c + '</s1:Name>'+
					'				</s1:DegreeMinor>'+
					'				<s1:DatesOfAttendance>'+
										du.formatYearMonth('s1:StartDate',rec.Start_Date_Year_University__c,rec.Start_Date_University__c) +
										du.formatYearMonth('s1:EndDate',rec.Last_Attended_Year_University__c,rec.Last_Attended_Month_University__c) +
					'				</s1:DatesOfAttendance>'+
					'				<s1:UserArea>'+
					'					<s2:NameAtTimeOfAttendence>'+
					'						<s2:GivenName>' + rec.Graduated_First_Name_University__c + '</s2:GivenName>'+
					'						<s2:MiddleName />'+
					'						<s2:FamilyName>' + rec.Graduated_Last_Name_University__c + '</s2:FamilyName>'+
					'					</s2:NameAtTimeOfAttendence>'+
					'				</s1:UserArea>'+
					'			</s1:Degree>'+
					'		</s1:SchoolOrInstitution>';
		}
		else if(rec.School_Name_High_School__c != null && rec.School_Name_High_School__c != '')
		{
/*
			soapMsg += '	<s1:SchoolOrInstitution'+
					'			schoolType="High School">'+
					'			<s1:School>'+
					'				<s1:SchoolName>' + rec.School_Name_High_School__c + '</s1:SchoolName>'+
					'			</s1:School>'+
					'			<s1:PostalAddress>'+
					'				<s1:CountryCode>' + rec.Country_High_School__c + '</s1:CountryCode>'+
					'				<s1:PostalCode />'+
					'				<s1:Region>' + rec.State_High_School__c + '</s1:Region>'+
					'				<s1:Municipality>' + rec.City_High_School__c + '</s1:Municipality>'+
					'				<s1:DeliveryAddress>'+
					'					<s1:AddressLine />'+
					'				</s1:DeliveryAddress>'+
					'			</s1:PostalAddress>'+
					'			<s1:Degree>'+
					'				<s1:DegreeMajor>'+
					'					<s1:Name>N/A</s1:Name>'+
					'				</s1:DegreeMajor>'+
					'				<s1:DegreeMinor>'+
					'					<s1:Name>N/A</s1:Name>'+
					'				</s1:DegreeMinor>'+
					'				<s1:DatesOfAttendance>'+
										du.formatYearMonth('s1:StartDate',rec.Start_Date_Year_High_School__c,rec.Start_Date_Month_High_School__c) +
										du.formatYearMonth('s1:EndDate',rec.Last_Attended_Year_High_School__c,rec.Last_Attended_Month_High_School__c) +
					'				</s1:DatesOfAttendance>'+
					'				<s1:UserArea>'+
					'					<s2:NameAtTimeOfAttendence>'+
					'						<s2:GivenName>' + rec.Graduated_First_Name_High_School__c + '</s2:GivenName>'+
					'						<s2:MiddleName />'+
					'						<s2:FamilyName>' + rec.Graduated_Last_Name_High_School__c + '</s2:FamilyName>'+
					'					</s2:NameAtTimeOfAttendence>'+
					'				</s1:UserArea>'+
					'			</s1:Degree>'+
					'		</s1:SchoolOrInstitution>';
*/
		}
		soapMsg += '	</s0:EducationHistory>'+
					'	<s0:UserArea />'+
				'	</s0:CandidateProfile>'+
				'</hr_objs:Candidate>'+
		'	</hr_objs:HRWebLink>'+
	'	</hr_objs:GenerateWebLink>';
		
		return smBegin + soapMsg + smEnd;
	}
	

}