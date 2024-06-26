public Interface NH_DataMapping_CustomMapping {
	List<String> getAdditionalSourceFieldsString();
    void performSourceToTargetCustomMapping(SObject source, SObject target);
}