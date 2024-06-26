@isTest
public with sharing class einstein_GPT_Service_Test {

 
    //test the generateGPTResponse method with a null prompt
    @isTest
    public static void generateGPTResponseNullPrompt(){
        String nullPrompt = null;
        String nullResponse = einstein_GPT_Service.returnGPTResponse(nullPrompt);
        //assert that the response is null
        System.assertEquals(null, nullResponse); 
    }

    //test the generateGPTResponse method with a text prompt
    @isTest(SeeAllData=true)
    public static void generateGPTResponseTextPrompt(){
        
        String textPrompt = 'test';
        String textResponse = einstein_GPT_Service.returnGPTResponse(textPrompt);
        //assert that the response is not null
        System.assertNotEquals(null, textResponse);
        
    }
}