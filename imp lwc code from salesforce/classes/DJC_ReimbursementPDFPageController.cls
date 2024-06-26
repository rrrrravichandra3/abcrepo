public without sharing class DJC_ReimbursementPDFPageController {

    public ReimbursementPDFController pdfController{
        get{
            if(pdfController == null){
                pdfController = new ReimbursementPDFController();
                pdfController.reimbursementCaseId = ApexPages.currentPage().getParameters().get('caseId');
            }
            return pdfController;
        }
        set;
    }
}