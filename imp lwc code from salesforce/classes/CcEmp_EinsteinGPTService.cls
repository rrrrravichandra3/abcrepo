public with sharing class CcEmp_EinsteinGPTService {
    private static final string APPLICATION_NAME = 'TalentMarketplace';

    @AuraEnabled
    public static string returnGPTResponse(String textPrompt) {
        if(textPrompt != null){
            ConnectApi.EinsteinLlmGenerationsInput generationsInput = new ConnectApi.EinsteinLlmGenerationsInput();
            generationsInput.promptTextorId = textPrompt;
            generationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            generationsInput.additionalConfig.maxTokens = 10000;
            generationsInput.additionalConfig.model = 'gpt-3.5-turbo-16k';
            generationsInput.additionalConfig.applicationName = APPLICATION_NAME;
            // Call the service.
            ConnectApi.EinsteinLLMGenerationsOutput generationsOutput = ConnectApi.EinsteinLLM.generateMessages(generationsInput);
            // Consume response
            ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
            string text = response.text;
            return text;
        }else{
            return null;
        }
    }
}