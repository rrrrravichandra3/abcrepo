public with sharing class te_LightCastApiService {
    public static string access_token;
    
    public static string doAuth (){
        String payLoad = 'grant_type=client_credentials' 
        + '&client_id=' + EncodingUtil.urlEncode('yw5g1kyc8vohrstc','UTF-8') 
        + '&client_secret=' + EncodingUtil.urlEncode('JjqJMS58', 'UTF-8') 
        + '&scope=emsi_open';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://auth.emsicloud.com/connect/token');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody(payLoad);
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 200){
            Map<String, Object> m =  (Map<String, Object>)System.JSON.deserializeUntyped(res.getBody());
            access_token = String.valueOf(m.get('access_token'));
            System.debug(access_token);
        }
        return res.getBody();
    }
    @AuraEnabled
    public static string extractSkills(String text, Decimal confidenceThreshold){
        return string.join(parseSkills(text,confidenceThreshold),',');
    }

    public static Set<String> parseSkills(String text, Decimal confidenceThreshold){
        if(access_token == null){
            doAuth();
        }
        String payLoad = '{ "text": "' +text+ '", "confidenceThreshold": ' + confidenceThreshold + '}';
        System.debug(payLoad);
        Set<String> skillList = new set<String>();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://emsiservices.com/skills/versions/latest/extract');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','Bearer ' + access_token);
        req.setBody(payLoad);
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 200){
            skillList = parseOutSkills(res.getBody());
        }
        return skillList;
    }

    public static Set<String> parseOutSkills(String json){
        Set<String> skillList = new set<String>();

        lightCastSkills lcs = (lightCastSkills)System.JSON.deserialize(json,lightCastSkills.class);
        System.debug(lcs);
        for(lightCastSkills.data s: lcs.data){
            skillList.add(s.skill.name);
        }
        System.debug(skillList);
        return skillList;
    }
}