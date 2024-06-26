//This is a junction object between the  CaseHelpLink records and the UI representation
public with sharing class ESDJC_CaseHelpLinkInfo {
	public String name {get; set;}
	public String url {get; set;}
	
	public List<ESDJC_CaseHelpLinkInfo> row {get; set;}
	
	public ESDJC_CaseHelpLinkInfo() {	
		row = new List<ESDJC_CaseHelpLinkInfo>();
	}
	
	public ESDJC_CaseHelpLinkInfo(String name, String url) {
		this.name = name;
		this.url = url;	
	}
	
	public void addRow(ESDJC_CaseHelpLinkInfo column) {
		row.add(column);
	}
	
	public ESDJC_CaseHelpLinkInfo getColumn1() {
		if(row.size() > 0){
			return row.get(0);
		} else {
			return new ESDJC_CaseHelpLinkInfo('','');
		}
	}
	public ESDJC_CaseHelpLinkInfo getColumn2() {
		if(row.size() > 1){
			return row.get(1);
		} else {
			return new ESDJC_CaseHelpLinkInfo('','');
		}
	}
	public ESDJC_CaseHelpLinkInfo getColumn3() {
		if(row.size() > 2){
			return row.get(2);
		} else {
			return new ESDJC_CaseHelpLinkInfo('','');
		}
	}
	public ESDJC_CaseHelpLinkInfo getColumn4() {
		if(row.size() > 3){
			return row.get(3);
		} else {
			return new ESDJC_CaseHelpLinkInfo('','');
		}
	}
}