public with sharing class einstein_GPT_Service {
    private static final string APPLICATION_NAME = 'TalentMarketplace';

    @AuraEnabled
    public static string returnGPTResponse(String textPrompt) {
        if(textPrompt != null){
            ConnectApi.EinsteinLlmGenerationsInput generationsInput = new ConnectApi.EinsteinLlmGenerationsInput();
            generationsInput.promptTextorId = textPrompt;
            generationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            generationsInput.additionalConfig.maxTokens = 10000;
            generationsInput.additionalConfig.model = 'gpt-4-32k';
            generationsInput.additionalConfig.applicationName = APPLICATION_NAME; 


            // Call the service.
            ConnectApi.EinsteinLLMGenerationsOutput generationsOutput = ConnectApi.EinsteinLLM.generateMessages(generationsInput);
            // Consume response
            ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
            System.debug('Response: ' + response.text);
            string text = response.text;
            return text;
        }else{
            return null;
        }
    }

    public static string returnEmbedding(String input){
        // Create input
        ConnectApi.EinsteinLlmEmbeddingsInput embeddingsInput = new ConnectApi.EinsteinLlmEmbeddingsInput();
        embeddingsInput.additionalConfig = new ConnectApi.EinsteinLlmEmbeddingsAdditionalConfigInput();
        embeddingsInput.additionalConfig.applicationName = APPLICATION_NAME;
        embeddingsInput.prompts = new String[] {input};

        // Call the service
        ConnectApi.EinsteinLLMEmbeddingsOutput embeddingsOutput = ConnectApi.EinsteinLLM.createEmbeddings(embeddingsInput);
        // Consume response
        ConnectApi.EinsteinLLMEmbeddingItemOutput embedding = embeddingsOutput.embeddings[0];

        List<String> listVectors = new List<String>();
        String embeddingString = '';
        for(Object obj : embedding.embedding){
            listVectors.add(String.valueOf(obj));
        }
        embeddingString =  '['+String.join(listVectors, ',')+']';
        System.debug(embeddingString);
        
        return embeddingString;
    }

}