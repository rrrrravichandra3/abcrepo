public without sharing class MA_MyInfoUpdatesListViewCtrl {

    public Boolean isError { get; set; }
    public Boolean noRecords{ get; set; }
    public Boolean isApproving{ get; set; }
    public Boolean flowFinish { get; set; }
    public String approverComments { get; set;}
    public List<MA_My_Info_Updates__c> listSelectedUpdates { get; set;}
    public Map<String, Object> params { get; set; }

    public MA_MyInfoUpdatesListViewCtrl(ApexPages.StandardSetController listcontroller) {
        approverComments = '';
        params = new Map<String, Object>();
        Set<Id> myInfoUpdSelectedIds = new Set<Id>();
        listSelectedUpdates = new List<MA_My_Info_Updates__c>();

        for (MA_My_Info_Updates__c myInfoUpdates: (MA_My_Info_Updates__c[]) listcontroller.getSelected()) {
            myInfoUpdSelectedIds.add(myInfoUpdates.Id);
        }

        for(MA_My_Info_Updates__c myInfoUpdates : [SELECT Id, Name, Mass_Approval__c, Mass_Rejection__c, Status__c, CreatedById, Field_Label__c FROM MA_My_Info_Updates__c WHERE Id IN: myInfoUpdSelectedIds AND Status__c = 'Submit']){
            listSelectedUpdates.add(myInfoUpdates);
        }
        noRecords = true;
        if(listSelectedUpdates.size() > 0){
            noRecords = false;
        }
    }

    public static PageReference navigateToListView(){
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get('MA_My_Info_Updates__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String keyPrefix = r.getKeyPrefix();
        PageReference pageRef = new PageReference('/' + keyPrefix );
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void massApproveFlowProcess() {
        isError = false;
        setFlowParams(true);
        Flow.Interview.ApprovalProcessMassResponse approvalFlow = new Flow.Interview.ApprovalProcessMassResponse(params);
        approvalFlow.start();
        flowFinish = (Boolean) approvalFlow.getVariableValue('FlowFinish');
    }

    public void massRejectFlowProcess() {
        isError = false;
        setFlowParams(false);
        if (approverComments.length() == 0) {
            isError = true;
        } else {
            Flow.Interview.ApprovalProcessMassResponse approvalFlow = new Flow.Interview.ApprovalProcessMassResponse(params);
            approvalFlow.start();
            flowFinish = (Boolean) approvalFlow.getVariableValue('FlowFinish');
        }
    }

    public void setFlowParams(Boolean isApproving) {
        params.put('IsApproving', isApproving);
        params.put('ApproverComments', approverComments);
        params.put('MyInfoUpdateRecordsSelected', listSelectedUpdates);
    }
}