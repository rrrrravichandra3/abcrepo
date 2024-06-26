/* This class marks the recent response of the ES Rep as a best answer. 
Change History : 


*/


public without sharing class ESDJC_CaseController {
    boolean isFieldAgent;
    public Case esdjcCase;
    public Question  question;
    public String textArea{get;set;}
    public boolean hasBestAnswer{get; set;}
    public boolean hasError{get; set;}
    
    public ESDJC_CaseController(ApexPages.StandardController controller) {
        esdjcCase = [select id,questionId from case where id = : controller.getId()]; //get questionId from the case (this is valid onnly for public questions)
        List<Question> question = [select BestReplyId from Question where Id = :esdjcCase.questionId];
        if (!question.isEmpty()) {
            hasBestAnswer = (question[0].BestReplyId!=null);
        }
    }
    
    /*show the standard case feed layout to users*/
    public Component.Apex.OutputPanel getCasePage() {
        Component.Apex.OutputPanel panel = new Component.Apex.OutputPanel();
        Component.Support.CaseFeed caseFeed = new Component.Support.CaseFeed();
        caseFeed.caseId = esdjcCase.Id;
        panel.childComponents.add(caseFeed);
        return panel;
    }

     /*
     ** Following method inserts reply and marks it as the best answer if user selects it as the
     ** best answer
     */
    public void markAsBestReply(){
        hasError = false;
        String strReply = ApexPages.currentPage().getParameters().get('reply');
        String isBestAns = ApexPages.currentPage().getParameters().get('isBestAns');
        
        //Create a new reply
        if (esdjcCase != null && esdjcCase.questionId != null && strReply != null && strReply.trim() != '') {
            try{
                Reply reply = new Reply(Body=strReply, QuestionId=esdjcCase.questionId);
                insert reply;
                
                //If user marked the answer as best answer, update the question with best answer id
                if (isBestAns == 'yes') {
                    Question question = new Question(Id=esdjcCase.questionId, BestReplyId=reply.Id);
                    update question;
                    hasBestAnswer = true;
                }
            }
            catch(System.DMLException e) {
                hasError = true;
                 ApexPages.addMessages(e);
            }
        }

    }
}