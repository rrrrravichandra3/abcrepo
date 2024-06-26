global class OfferApprovalEmailController implements Messaging.InboundEmailHandler {


	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          
		String offerName = email.subject.split('\\|')[3];
		String decision = email.plainTextBody.split('\n')[0];
		String sanitize = offerName.deleteWhitespace();
		String useremail = email.fromAddress;

        // first validated the decision, reject all non acceptable
        // second depends on decision set up the Action value
        // process the approval 
		String finaldecision = decision.toUpperCase();
		Boolean ApproveOrReject = false;
		Boolean isDecisionValid = false;
		
		if ( finaldecision.equals( 'APPROVE') ){
			ApproveOrReject = true;
			isDecisionValid = true;
		}
		if ( finaldecision.equals( 'REJECT') ){
			isDecisionValid = true;
		}

		if ( isDecisionValid ){
			
			try{
				User u =[ select Id, Name from User where email =: useremail and isActive = true and UserType = 'Standard' ];
				ProcessInstance pi = [SELECT Id,ProcessDefinitionId,Status,TargetObjectId FROM ProcessInstance WHERE status = 'Pending' ];
				//select the current approval base on offer and user record 
				List<ProcessInstanceWorkitem> piw = [ SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId =: pi.Id and ActorId =: u.id ];
			
				if ( piw.size() == 1 ){
					
					Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
			        if ( ApproveOrReject ){
			        	req2.setComments('Approving request from Email ' + u.Name + '.');
			        	req2.setAction('Approve');
			        } else {
			        	req2.setComments('Rejecting request from Email ' + u.Name + '.');
			        	req2.setAction('Reject');			        
			        }
					//req2.setNextApproverIds(new Id[] {u.Id});
					req2.setWorkitemId( piw[0].id );
					Approval.ProcessResult resultApproval =  Approval.process(req2);					
				}
				
			} catch (QueryException e) {
				return null;
			}
		
		}
				       

		return result;
      } 
 
}