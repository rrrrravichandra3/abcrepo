public class DJC_Wellness_MyCases_View_Controller extends BaseDJCController{

    public Integer PAGE_SIZE{get; private set;}

    public String url{get;set;}

    public DJC_Wellness_MyCases_View_Controller controller{
        get{
            return this;
        }
        private set;
    }
    
    public DJC_Wellness_MyCases_View_Controller(){
        headermsg = Label.DJC_My_Reimbursement_Cases;
        PAGE_SIZE = 20;
        url = ESDJC_Util.getSiteURL();
    }

    public Integer selectedView{
        get{
            if(selectedView == null){
                selectedView = 0;
            }
            return selectedView;
        }
        set;
    }

    public List<SelectOption> views{
        get{
            if(views == null){
                views = new List<SelectOption>();
                views.add(new SelectOption('0', 'Open Cases'));
                views.add(new SelectOption('1', 'Closed Cases'));
                views.add(new SelectOption('2', 'All Cases'));
            }
            return views;
        }
        private set;
    }

    public List<Case> searchResults{
        get{
            return setController.getRecords();
        }
        private set;
    }

    public void searchCases(){
        setController = null;
    }

    public ApexPages.StandardSetController setController {
        get {
            if(setController == null) {
                setController = new ApexPages.StandardSetController(Database.getQueryLocator(getQuery()));
                setController.setPageSize(PAGE_SIZE);
            }
            return setController;
        }
        set;
    }

    private String getQuery(){
        
        String soql = 'SELECT Id, CaseNumber, Subject, Status, Priority, LastModifiedDate FROM Case WHERE ContactId = \'' + currentUser.contactId + '\' AND RecordType.DeveloperName = \'All_Expense_Cases\' ';
        
        if(selectedView == 0){
            soql += ' AND isClosed = false ';
        }else if(selectedView == 1){
            soql += ' AND isClosed = true ';
        }
        
        return soql + 'ORDER BY createdDate DESC';
    }
    
    public override String getRecordType(){
        return null;
    }
}