@isTest
public class IFBTestDataSet_Question {

	public static List<IFB_Interview_Question__c> getQuestions() {
		List<IFB_Interview_Question__c> questions = new List<IFB_Interview_Question__c>();
		Set<String> competencies = new Set<String>();
		
		// Technical Interview
		competencies.clear();
		competencies.add('Development');
		competencies.add('MDM and Integration');
		competencies.add('Mobile');
		competencies.add('Salesforce');
		competencies.add('Scalability');
		competencies.add('Security');
		competencies.add('Tech Governance');

		for (String competency : competencies) {
			questions.add(IFBTestData_Question.getQuestion(new IFB_Interview_Question__c(Question_Category__c = 'Technical Interview',  Domain__c = competency, Group__c = 'CSG'), IFBTestData_Question.Option.ACTIVE));
		}

		// Consulting Interview
		competencies.clear();
		competencies.add('Core CRM');
		competencies.add('Facilitation & Negotiation');
		competencies.add('Objection Handling');
		competencies.add('Problem Solving');
		competencies.add('Selling, Being Prescriptive');
		competencies.add('Situational Adaptability');
		competencies.add('Storytelling / Painting a Vision');

		for (String competency : competencies) {
			questions.add(IFBTestData_Question.getQuestion(new IFB_Interview_Question__c(Question_Category__c = 'Consulting Interview',  Domain__c = competency, Group__c = 'CSG'), IFBTestData_Question.Option.ACTIVE));
		}

		// Panel Interview
		competencies.clear();
		competencies.add('Business Acumen');
		competencies.add('Communication Skills');
		competencies.add('Cultural Fit');
		competencies.add('Polish and Presence');
		competencies.add('Selling, Being Prescriptive');
		competencies.add('Situational Adaptability');

		for (String competency : competencies) {
			questions.add(IFBTestData_Question.getQuestion(new IFB_Interview_Question__c(Question_Category__c = 'Panel Interview',  Domain__c = competency, Group__c = 'CSG'), IFBTestData_Question.Option.ACTIVE));
		}

		// Content Question
		competencies.clear();
		competencies.add('Adoption / Readiness');
		competencies.add('Analytics / Vision & Key Metrics');
		competencies.add('Delivery Innovation');
		competencies.add('Enterprise Program Management / Run Your Business');
		competencies.add('Govern Your Investment (COE)');
		competencies.add('Polish and Presence');
		competencies.add('Role Readiness');
		competencies.add('Self Sufficiency / Talent Strategy');

		for (String competency : competencies) {
			questions.add(IFBTestData_Question.getQuestion(new IFB_Interview_Question__c(Question_Category__c = 'Content Question',  Domain__c = competency, Group__c = 'CSG'), IFBTestData_Question.Option.ACTIVE));
		}

		// PM Question
		competencies.clear();
		competencies.add('Project Closure');
		competencies.add('Project Consulting');
		competencies.add('Project Leadership');
		competencies.add('Project Monitoring and Control');
		competencies.add('Project Planning');
		competencies.add('Project Preparation');

		for (String competency : competencies) {
			questions.add(IFBTestData_Question.getQuestion(new IFB_Interview_Question__c(Question_Category__c = 'PM Question',  Domain__c = competency, Group__c = 'CSG'), IFBTestData_Question.Option.ACTIVE));
		}

		// EM Consulting
		competencies.clear();
		competencies.add('Cultural Fit');
		competencies.add('Customer Success');
		competencies.add('Engagement Management');
		competencies.add('Leadership');
		competencies.add('Role Readiness');

		for (String competency : competencies) {
			questions.add(IFBTestData_Question.getQuestion(new IFB_Interview_Question__c(Question_Category__c = 'EM Consulting',  Domain__c = competency, Group__c = 'CSG'), IFBTestData_Question.Option.ACTIVE));
		}

		// EM Technical
		competencies.clear();
		competencies.add('Cultural Fit');
		competencies.add('Customer Success');
		competencies.add('Engagement Management');
		competencies.add('Leadership');
		competencies.add('Role Readiness');

		for (String competency : competencies) {
			questions.add(IFBTestData_Question.getQuestion(new IFB_Interview_Question__c(Question_Category__c = 'EM Technical',  Domain__c = competency, Group__c = 'CSG'), IFBTestData_Question.Option.ACTIVE));
		}

		// SP Consulting
		competencies.clear();
		competencies.add('Business Consulting');
		competencies.add('Cultural Fit');
		competencies.add('Customer Success');
		competencies.add('Leadership');
		competencies.add('Role Readiness');

		for (String competency : competencies) {
			questions.add(IFBTestData_Question.getQuestion(new IFB_Interview_Question__c(Question_Category__c = 'SP Consulting',  Domain__c = competency, Group__c = 'CSG'), IFBTestData_Question.Option.ACTIVE));
		}

		// SP Technical
		competencies.clear();
		competencies.add('Business Consulting');
		competencies.add('Cultural Fit');
		competencies.add('Customer Success');
		competencies.add('Leadership');
		competencies.add('Role Readiness');

		for (String competency : competencies) {
			questions.add(IFBTestData_Question.getQuestion(new IFB_Interview_Question__c(Question_Category__c = 'SP Technical',  Domain__c = competency, Group__c = 'CSG'), IFBTestData_Question.Option.ACTIVE));
		}

		// SA Technical
		competencies.clear();
		competencies.add('Development');
		competencies.add('MDM and Integration');
		competencies.add('Mobile');
		competencies.add('Project Consulting');
		competencies.add('Project Planning');
		competencies.add('Project Preparation');
		competencies.add('Salesforce');
		competencies.add('Scalability');
		competencies.add('Security');
		competencies.add('Tech Governance');

		for (String competency : competencies) {
			questions.add(IFBTestData_Question.getQuestion(new IFB_Interview_Question__c(Question_Category__c = 'SA Technical',  Domain__c = competency, Group__c = 'CSG'), IFBTestData_Question.Option.ACTIVE));
		}

		// Sales - 1st stage interview (HM phone screen/onsite, chrono/panel)
		competencies.clear();
		competencies.add('Business Acumen');
		competencies.add('Coachable');
		competencies.add('Collaboration and Influence-Win as a Team');
		competencies.add('Compelling Communicator');
		competencies.add('Comptetitive Spirit');
		competencies.add('Consultative Selling');
		competencies.add('Prospective Skills');
		competencies.add('Resourceful');
		competencies.add('Trusted Advisor');
		competencies.add('Urgency');

		for (String competency : competencies) {
			questions.add(IFBTestData_Question.getQuestion(new IFB_Interview_Question__c(Question_Category__c = 'Sales - 1st stage interview (HM phone screen/onsite, chrono/panel)',  Domain__c = competency, Group__c = 'Sales'), IFBTestData_Question.Option.ACTIVE));
		}

		// Sales - AE Presentation/Final Stage
		competencies.clear();
		competencies.add('Articulation of ROI');
		competencies.add('Discovery');
		competencies.add('Drive for Results');
		competencies.add('Engagement (capture the audience\'s attention)');
		competencies.add('Influence');
		competencies.add('Objection Handling');
		competencies.add('Planning & Closing Skills');
		competencies.add('Solition Selling');	

		for (String competency : competencies) {
			questions.add(IFBTestData_Question.getQuestion(new IFB_Interview_Question__c(Question_Category__c = 'Sales - AE Presentation/Final Stage',  Domain__c = competency, Group__c = 'Sales'), IFBTestData_Question.Option.ACTIVE));
		}

		return questions;
	}
}