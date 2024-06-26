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
 * @author Mike Fullmore - 4/2/2009
*/

global with sharing class V2MOM_Web_Services {
   
    private static Pattern lt_escape_pattern = Pattern.compile('<');
    private static Pattern gt_escape_pattern = Pattern.compile('>');
    private static Pattern amp_escape_pattern = Pattern.compile('&');
    private static Pattern quot_escape_pattern = Pattern.compile('"');
    private static Pattern apos_escape_pattern = Pattern.compile('\'');
	
    WebService static String generateXMLForV2MOM(Id v2mom_id) {
        V2MOM__c v2mom = [select Id, Effective_Date__c, Name, Vision__c, 
        						(select Id, Name, Tag_Line__c from Values__r order by Priority__c), 
        						(select Id, Name, Description__c, Accountable_Person__r.Name, Value__c from Methods__r order by Priority__c), 
        						(select Id, Name, Description__c, Value__c, Method__r.Name from Obstacles__r order by Priority__c), 
        						(select Id, Name, Description__c, Value__c, Method__r.Name from Measures__r order by Priority__c)  
						  from V2MOM__c 
						  where Id = :v2mom_id]; 
		//-------------------------------------------------------------------
		//------------Object without parent----------------------------------
		//-------------------------------------------------------------------
		List<Method__c> methodsWithoutValue = new List<Method__c>();
		List<Obstacle__c> obstacleWithoutMethod = new List<Obstacle__c>();
		List<Measure__c> measureWithoutMethod = new List<Measure__c>();
		
		//-------------------------------------------------------------------
       
        Map<Id, List<Method__c>> map_value_to_methods = new Map<Id, List<Method__c>>();
        Map<Id, List<Obstacle__c>> map_value_to_obstacles = new Map<Id, List<Obstacle__c>>();
        Map<Id, List<Measure__c>> map_value_to_measures = new Map<Id, List<Measure__c>>();

        for (Value__c value : v2mom.Values__r) {
            map_value_to_methods.put(value.Id, new List<Method__c>());
 			map_value_to_obstacles.put(value.Id, new List<Obstacle__c>());
            map_value_to_measures.put(value.Id, new List<Measure__c>());
        }

        for (Method__c m : v2mom.Methods__r) {
        	if(m.Value__c != null){
            	map_value_to_methods.get(m.Value__c).add(m);
        	}
        	else{
        		methodsWithoutValue.add(m);
        	}
        }
        for (Obstacle__c o : v2mom.Obstacles__r) {
        	if(o.Value__c != null){
        		if(o.Method__c != null){
            		map_value_to_obstacles.get(o.Value__c).add(o);
        		}
        		else{
        			obstacleWithoutMethod.add(o);
        		}
        	}
        	else{
        		obstacleWithoutMethod.add(o);
        	}
        }

        for (Measure__c m : v2mom.Measures__r) {
        	if(m.Value__c != null){
	        	if(m.Method__c != null){
	            	map_value_to_measures.get(m.Value__c).add(m);
	        	} 
	        	else{
        			measureWithoutMethod.add(m);
        		}
        	}      
        	else{
        		measureWithoutMethod.add(m);
        	}
        }

        String xml = '<V2MOM>';
        xml += '<Id>' + v2mom.Id + '</Id>';
        xml += '<Name>' + escapeXML(v2mom.Name) + '</Name>';
        if (v2mom.Effective_Date__c != null) {
            xml += '<EffectiveDate>' + escapeXML(v2mom.Effective_Date__c) + '</EffectiveDate>';
        }
        if (v2mom.Vision__c != null) {
            xml += '<Vision>' + escapeXML(v2mom.Vision__c) + '</Vision>';
        }
        xml += '<Values>';
        for (Value__c value : v2mom.Values__r) {
            xml += '<Value>';
            xml += '<Id>' + value.Id + '</Id>';
            xml += '<Name>' + escapeXML(value.Name) + '</Name>';
            if (value.Tag_Line__c != null) {
                xml += '<TagLine>' + escapeXML(value.Tag_Line__c) + '</TagLine>';
            }
            xml += '<Methods>';
            for (Method__c method : map_value_to_methods.get(value.Id)) {
                xml += '<Method>';
                xml += '<Id>' + method.Id + '</Id>';
                xml += '<Name>' + escapeXML(method.Name) + '</Name>';
                if (method.Description__c != null) {
                    xml += '<Description>' + escapeXML(method.Description__c) + '</Description>';
                }
                if (method.Accountable_Person__c != null) {
                    xml += '<AccountablePerson>' + escapeXML(method.Accountable_Person__r.Name) + '</AccountablePerson>';
                }
                xml += '</Method>';
            }
            xml += '</Methods>';

            xml += '<Obstacles>';
            for (Obstacle__c o : map_value_to_obstacles.get(value.Id)) {
                xml += '<Obstacle>';
                xml += '<Id>' + o.Id + '</Id>';
                xml += '<Name>' + escapeXML(o.Name) + '</Name>';
                xml += '<MethodName>' + escapeXML(o.Method__r.Name) + '</MethodName>';
                if (o.Description__c != null) {
                    xml += '<Description>' + escapeXML(o.Description__c) + '</Description>';
                }
                xml += '</Obstacle>';
            }
            xml += '</Obstacles>';
			
            xml += '<Measures>';
            for (Measure__c m : map_value_to_measures.get(value.Id)) {
                xml += '<Measure>';
                xml += '<Id>' + m.Id + '</Id>';
                xml += '<Name>' + escapeXML(m.Name) + '</Name>';
                xml += '<MethodName>' + escapeXML(m.Method__r.Name) + '</MethodName>';
                if (m.Description__c != null) {
                    xml += '<Description>' + escapeXML(m.Description__c) + '</Description>';
                }
                xml += '</Measure>';
            }
            xml += '</Measures>';

            xml += '</Value>';
        }
        
 //**************************************************************************************************
 //*****************  Method, Obstacles and Metrics without parent***********************************
       
        if(methodsWithoutValue.size()>0 || obstacleWithoutMethod.size()>0 || measureWithoutMethod.size()>0){
	        xml += '<Value>';
	        xml += '<Id></Id>';
	        xml += '<Name></Name>';
	        
	        xml += '<Methods>';
	        for (Method__c method : methodsWithoutValue) {
	        	xml += '<Method>';
	            xml += '<Id>' + method.Id + '</Id>';
	            xml += '<Name>' + escapeXML(method.Name) + '</Name>';
	            if (method.Description__c != null) {
	                xml += '<Description>' + escapeXML(method.Description__c) + '</Description>';
	            }
	            if (method.Accountable_Person__c != null) {
	                xml += '<AccountablePerson>' + escapeXML(method.Accountable_Person__r.Name) + '</AccountablePerson>';
	            }
	            xml += '</Method>';
	        }
	        xml += '</Methods>';
	        
	        xml += '<Obstacles>';
	        for (Obstacle__c o : obstacleWithoutMethod) {
	            xml += '<Obstacle>';
	            xml += '<Id>' + o.Id + '</Id>';
	            xml += '<Name>' + escapeXML(o.Name) + '</Name>';
	            xml += '<MethodName>' + 'Without Method' + '</MethodName>';
	            	
	            if (o.Description__c != null) {
	                xml += '<Description>' + escapeXML(o.Description__c) + '</Description>';
	            }
	            xml += '</Obstacle>';
	        }
	        xml += '</Obstacles>';
	        
	        xml += '<Measures>';
		        for (Measure__c m : measureWithoutMethod) {
		            xml += '<Measure>';
		            xml += '<Id>' + m.Id + '</Id>';
		            xml += '<Name>' + escapeXML(m.Name) + '</Name>';
		            xml += '<MethodName>' + 'Without Method' + '</MethodName>';
		            
		            if (m.Description__c != null) {
		                xml += '<Description>' + escapeXML(m.Description__c) + '</Description>';
		            }
		            xml += '</Measure>';
		        }
		        xml += '</Measures>';
		        
	        	xml += '</Value>';
        }
//*******************************************************************************************
//*******************************************************************************************
        xml += '</Values></V2MOM>';
        //system.debug(xml);
        return xml;
    }

    private static String escapeXML(String s) {
        if (s != null) {
            s = amp_escape_pattern.matcher(s).replaceAll('&amp;');
            s = lt_escape_pattern.matcher(s).replaceAll('&lt;');
            s = gt_escape_pattern.matcher(s).replaceAll('&gt;');
            s = quot_escape_pattern.matcher(s).replaceAll('&quot;');
            s = apos_escape_pattern.matcher(s).replaceAll('&apos;');
        }
        return s;
    }
    
}