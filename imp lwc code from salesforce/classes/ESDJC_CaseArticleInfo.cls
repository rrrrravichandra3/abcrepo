public with sharing class ESDJC_CaseArticleInfo {
	public String name {get; set;}
	public String url {get; set;}
		
	public ESDJC_CaseArticleInfo() {	
		this.name = '';
		this.url = '';
	}
	
	public ESDJC_CaseArticleInfo(String name, String url) {
		this.name = name;
		this.url = url;	
	}
}