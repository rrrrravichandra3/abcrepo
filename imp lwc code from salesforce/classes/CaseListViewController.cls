public class CaseListViewController {
    private ApexPages.StandardSetController caseSetController;
    public List<Id> selectedCaseIds = new List<Id>();
    public String listViewId;
    public String auraAttribute{get;set;}

    public CaseListViewController(ApexPages.StandardSetController standardSetCtrl){
        this.caseSetController = standardSetCtrl;
        listViewId = caseSetController.getFilterId();
        List<Case> casesSelected = caseSetController.getSelected();
        for(Case c : casesSelected){
            selectedCaseIds.add(c.Id);
        }
        
        auraAttribute = JSON.serialize(
          new Map<String, String> {
            'caseIds' => String.join(selectedCaseIds, ','),
            'listViewId' => listViewId
          }
        );
    }
}