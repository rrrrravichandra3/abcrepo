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

public class New_XML_Controller {
	private static Pattern lt_escape_pattern = Pattern.compile('<');
    private static Pattern gt_escape_pattern = Pattern.compile('>');
    private static Pattern amp_escape_pattern = Pattern.compile('&');
    private static Pattern quot_escape_pattern = Pattern.compile('"');
    private static Pattern apos_escape_pattern = Pattern.compile('\'');
	
    public static String generateXMLForV2MOM(Id v2mom_id) {
    	
	   
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
		List<Method__c> allMethods = new List<Method__c>();
		List<Obstacle__c> allObstacles = new List<Obstacle__c>();
		List<Measure__c> allMeasures = new List<Measure__c>();
		//-------------------------------------------------------------------
       
        Map<Id, List<Method__c>> map_value_to_methods = new Map<Id, List<Method__c>>();
        Map<Id, List<Obstacle__c>> map_value_to_obstacles = new Map<Id, List<Obstacle__c>>();
        Map<Id, List<Measure__c>> map_value_to_measures = new Map<Id, List<Measure__c>>();

        for (Value__c value : v2mom.Values__r) {
            map_value_to_methods.put(value.Id, new List<Method__c>());
 			map_value_to_obstacles.put(value.Id, new List<Obstacle__c>());
            map_value_to_measures.put(value.Id, new List<Measure__c>());
        }

        for (Method__c m : [select Id, Name, Description__c, Accountable_Person__r.Name, Value__c from Method__c Where V2MOM__c =: v2mom_id order by Priority__c ]) {
        	allMethods.add(m);
        	
        }
        
        for (Obstacle__c o : [select Id, Name, Description__c, Value__c, Method__r.Name from Obstacle__c Where V2MOM__c =: v2mom_id order by Priority__c ]) {
        	
        	allObstacles.add(o);
        }

        for (Measure__c m : [select Id, Name, Description__c, Value__c, Method__r.Name from Measure__c  Where V2MOM__c =: v2mom_id order by Priority__c ]) {
    		allMeasures.add(m);
        }
        
      
        String xml = '<V2MOM>';
        xml += '<V2MOM>';
        xml += '<Id>' + v2mom.Id + '</Id>';
        xml += '<Name>' + escapeXML(v2mom.Name) + '</Name>';
        if (v2mom.Effective_Date__c != null) {
            xml += '<EffectiveDate>' + escapeXML(v2mom.Effective_Date__c) + '</EffectiveDate>';
        }
        if (v2mom.Vision__c != null) {
            xml += '<Vision>' + escapeXML(v2mom.Vision__c) + '</Vision>';
        }
        xml += '<Values>';
        Integer countValues = 1;
        System.debug('\n\n\n\n valuessss  \n\n\n ' + v2mom.Values__r.size() + '\n\n\n');
        for (Value__c value : v2mom.Values__r) {
            xml += '<Value>';
            xml += '<Id>' + value.Id + '</Id>';
            xml += '<Label>Value ' + countValues + '</Label>';
            xml += '<Name>' + escapeXML(value.Name) + '</Name>';
            if (value.Tag_Line__c != null) {
                xml += '<TagLine>' + escapeXML(value.Tag_Line__c) + '</TagLine>';
            }		
            xml += '</Value>';
            countValues += 1;
        }
        xml += '</Values>';
        xml += '<Methods>';
        System.debug('\n\n\n\n methodssss  \n\n\n ' + allMethods.size() + '\n\n\n');
        Integer countMethods = 1;
            for (Method__c method : allMethods) {
                xml += '<Method>';
                xml += '<Id>' + method.Id + '</Id>';
                xml += '<Label>Method ' + countMethods +'</Label>';
                xml += '<Name>' + escapeXML(method.Name) + '</Name>';
                if (method.Description__c != null) {
                    xml += '<Description>' + escapeXML(method.Description__c) + '</Description>';
                    
                    System.debug('\n\n\n\n desccccccccc \n\n\n\n  ' + escapeXML(method.Description__c) + '\n\n\n\n\n');
                }
                if (method.Accountable_Person__c != null) {
                    xml += '<AccountablePerson>' + escapeXML(method.Accountable_Person__r.Name) + '</AccountablePerson>';
                }
                xml += '</Method>';
                countMethods += 1;
            }
        xml += '</Methods>';
			
        xml += '<Obstacles>';
        Integer countObstacles = 1;
        System.debug('\n\n\n\n obstaclesss  \n\n\n ' + allObstacles.size() + '\n\n\n');
            for (Obstacle__c o : allObstacles) {
                xml += '<Obs>';
                xml += '<Id>' + o.Id + '</Id>';
                xml += '<Label>Obstacle ' + countObstacles + '</Label>';
                xml += '<Name>' + escapeXML(o.Name) + '</Name>';
                xml += '<MethodName>' + escapeXML(o.Method__r.Name) + '</MethodName>';
                if (o.Description__c != null) {
                    xml += '<Description>' + escapeXML(o.Description__c) + '</Description>';
                }
                xml += '</Obs>';
                countObstacles += 1;
            }
        xml += '</Obstacles>';
			
        xml += '<Metrics>';
        Integer countMetrics = 1;
        System.debug('\n\n\n\n metricssss  \n\n\n ' + allMeasures.size() + '\n\n\n');
            for (Measure__c m : allMeasures) {
                xml += '<Metric>';
                xml += '<Id>' + m.Id + '</Id>';
                xml += '<Label>Metric ' + countMetrics + '</Label>';
                xml += '<Name>' + escapeXML(m.Name) + '</Name>';
                xml += '<MethodName>' + escapeXML(m.Method__r.Name) + '</MethodName>';
                if (m.Description__c != null) {
                    xml += '<Description>' + escapeXML(m.Description__c) + '</Description>';          
                }
                xml += '</Metric>';
                countMetrics += 1;
            }
        xml += '</Metrics>';
               
        xml+='</V2MOM>';
        xml+='</V2MOM>';
        
 
        return xml; 
    }

    private static String escapeXML(String s) {
        if (s != null) {
           
          	s = lt_escape_pattern.matcher(s).replaceAll('less');
            s = gt_escape_pattern.matcher(s).replaceAll('%3E');
            s = amp_escape_pattern.matcher(s).replaceAll('%26');
         
            
            /*
            s = lt_escape_pattern.matcher(s).replaceAll('&lt;');
            s = gt_escape_pattern.matcher(s).replaceAll('&gt;');
            s = quot_escape_pattern.matcher(s).replaceAll('&quot;');
            
            s = apos_escape_pattern.matcher(s).replaceAll('&apos;');
            */
        }
        return s;
    }
}