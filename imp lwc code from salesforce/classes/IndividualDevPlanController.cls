public with sharing class IndividualDevPlanController {
	public MyCarrerPlan__c carPlan {get;set;}
	public string us {get{ return UserInfo.getUserID();}set;}
	public string v2momOwnerID{get;set;}
	public String devPlanID{get;set;}
	
	public IndividualDevPlanController(ApexPages.StandardController stdController){
		Map<String, String> pars = Apexpages.currentPage().getParameters();
		if(pars.containsKey('Id')){
			Id id= apexPages.currentPage().getParameters().get('Id');
			devPlanId= (String)id;
		}
		else{
			devPlanId='new';
		}
		if(devPlanID.equals('new')){
			if (!MyCarrerPlan__c.Status__c.getDescribe().isCreateable()&& 
			     !MyCarrerPlan__c.Name.getdescribe().isUpdateable()){
				ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.FATAL, 'Insufficient access'));			
			}
			Datetime myDT = Datetime.now();
			String myDate = myDT.format('MMM d, yyyy');
			carplan=new MyCarrerPlan__c();
			carPlan.status__c='Unlocked';
			carPlan.Name=Userinfo.getName()+'\'s Career Plan - ' + myDate ;
			carplan.OwnerId = userinfo.getUserID();
			
		}
		else{
		carPlan =[select id,
						OwnerId,
						name,
						Compensation__c,
						CompensationRating__c,
						DomainExpertise__c,
						DomainExpertiseRating__c,
						ExperiencesImportant4Role__c,
						ExposureCompetenciesToTarget__c,
						ExposureKeyActivities__c,
						ExposureMilestoneDates__c,
						ExposureSupportNeeded__c,
						FeedBackPlan__c,
						FiveYears__c,
						JobExperiencesCompetencies__c,
						JobExperiencesKeyActivities__c,
						JobExperiencesMilestoneDates__c,
						JobExperiencesSupportNeeded__c	,
						LeadershipExpertise__c,
						LeadershipExpertiseRating__c,
						LifeOutsideWork__c,
						LifeOutsideWorkRating__c,
						Location__c,
						LocationRating__c,
						MisionRating__c,
						Mission__c,
						NextCheckDate__c,
						NextStep__c,
						PeopleMgmtExpertise__c,
						PeopleMgmtExpertiseRating__c,
						SkillsToAccelerateMyCarrer__c,
						SupportNeeded__c,
						ThreeYears__c,
						TrainingCompetenciesToTarget__c,
						TrainingKeyActivities__c,
						TrainingMilestoneDates__c,
						TrainingSupportNeeded__c,
						WhereGoNext__c,
						Status__c,
						V2MOM__r.OwnerId,
						v2mom__c
						from MyCarrerPlan__c
						where id=:devPlanID];
		
		}
		
	}
	public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('1','1')); 
        options.add(new SelectOption('2','2')); 
        options.add(new SelectOption('3','3'));
        options.add(new SelectOption('4','4')); 
        options.add(new SelectOption('5','5')); 
         return options; 
    }
  	public Pagereference save(){
  		if (!MyCarrerPlan__c.sObjectType.getDescribe().isCreateable()
  			|| !MyCarrerPlan__c.sObjectType.getDescribe().isUpdateable()){
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.FATAL, 'Insufficient access'));
			return null;
		}
  		upsert carPlan;
		PageReference page = new  PageReference('/apex/MyCareerPlan?id='+carPlan.Id+'&v2mom='+carPlan.v2mom__c);
		page.setRedirect(true);
		return page;
	}
	public boolean getDisabled(){	
			
			return carPlan.Status__c.equals('Locked')||!getItsMine();
		
	}
	public boolean getItsMine(){	
			return carPlan.OwnerId==userInfo.getUserId();
			
	}
	public boolean getIsCarPlanIdNull(){	
			return carPlan.id==null;
			
	}
	public Pagereference lockCareerPlan(){
	  	if (!MyCarrerPlan__c.sObjectType.getDescribe().isCreateable()
  			|| !MyCarrerPlan__c.sObjectType.getDescribe().isUpdateable()){
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.FATAL, 'Insufficient access'));
			return null;
		}
		carPlan.Status__c='Locked';
		upsert carPlan;
		PageReference page =  new PageReference('/apex/myCareerPlan?id='+carPlan.Id);
		page.setRedirect(true);
		return page;
	}
	public PageReference cloneMe(){
		if (!MyCarrerPlan__c.sObjectType.getDescribe().isCreateable()
  			|| !MyCarrerPlan__c.sObjectType.getDescribe().isUpdateable()){
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.FATAL, 'Insufficient access'));
			return null;
		}
		MyCarrerPlan__c carPlan2 = new MyCarrerPlan__c();
		Datetime myDT = Datetime.now();
		String myDate = myDT.format('MMM d, yyyy');
		carPlan2.name=Userinfo.getName()+'\'s Career Plan - ' + myDate ;
		carPlan2.Compensation__c=carPlan.Compensation__c;
		carPlan2.CompensationRating__c=carPlan.CompensationRating__c;
		carPlan2.DomainExpertise__c=carPlan.DomainExpertise__c;
		carPlan2.DomainExpertiseRating__c=carPlan.DomainExpertiseRating__c;
		carPlan2.ExperiencesImportant4Role__c=carPlan.ExperiencesImportant4Role__c;
		carPlan2.ExposureCompetenciesToTarget__c=carPlan.ExposureCompetenciesToTarget__c;
		carPlan2.ExposureKeyActivities__c=carPlan.ExposureKeyActivities__c;
		carPlan2.ExposureMilestoneDates__c=carPlan.ExposureMilestoneDates__c;
		carPlan2.ExposureSupportNeeded__c=carPlan.ExposureSupportNeeded__c;
		carPlan2.FeedBackPlan__c=carPlan.FeedBackPlan__c;
		carPlan2.FiveYears__c=carPlan.FiveYears__c;
		carPlan2.JobExperiencesCompetencies__c=carPlan.JobExperiencesCompetencies__c;
		carPlan2.JobExperiencesKeyActivities__c=carPlan.JobExperiencesKeyActivities__c;
		carPlan2.JobExperiencesMilestoneDates__c=carPlan.JobExperiencesMilestoneDates__c;
		carPlan2.JobExperiencesSupportNeeded__c=carPlan.JobExperiencesSupportNeeded__c;
		carPlan2.LeadershipExpertise__c=carPlan.LeadershipExpertise__c;
		carPlan2.LeadershipExpertiseRating__c=carPlan.LeadershipExpertiseRating__c;
		carPlan2.LifeOutsideWork__c=carPlan.LifeOutsideWork__c;
		carPlan2.LifeOutsideWorkRating__c=carPlan.LifeOutsideWorkRating__c;
		carPlan2.Location__c=carPlan.Location__c;
		carPlan2.LocationRating__c=carPlan.LocationRating__c;
		carPlan2.Mission__c=carPlan.Mission__c;
		carPlan2.MisionRating__c=carPlan.MisionRating__c;
		carPlan2.NextCheckDate__c=carPlan.NextCheckDate__c;
		carPlan2.NextStep__c=carPlan.NextStep__c;
		carPlan2.PeopleMgmtExpertise__c=carPlan.PeopleMgmtExpertise__c;
		carPlan2.PeopleMgmtExpertiseRating__c=carPlan.PeopleMgmtExpertiseRating__c;
		carPlan2.SkillsToAccelerateMyCarrer__c=carPlan.SkillsToAccelerateMyCarrer__c;
		carPlan2.SupportNeeded__c=carPlan.SupportNeeded__c;
		carPlan2.ThreeYears__c=carPlan.ThreeYears__c;
		carPlan2.TrainingCompetenciesToTarget__c=carPlan.TrainingCompetenciesToTarget__c;
		carPlan2.TrainingKeyActivities__c=carPlan.TrainingKeyActivities__c;
		carPlan2.TrainingMilestoneDates__c=carPlan.TrainingMilestoneDates__c;
		carPlan2.TrainingSupportNeeded__c=carPlan.TrainingSupportNeeded__c;
		carPlan2.WhereGoNext__c=carPlan.WhereGoNext__c;
		carPlan2.v2mom__c=carPlan.v2mom__c;
		carPlan2.status__c='Unlocked';
		
		insert carPlan2;
		PageReference page = new PageReference('/apex/myCareerPlan?id='+carPlan2.Id);
		page.setRedirect(true);
		return page;
		
	}
	public pageReference printView(){
		if (!MyCarrerPlan__c.sObjectType.getDescribe().isCreateable()
  			|| !MyCarrerPlan__c.sObjectType.getDescribe().isUpdateable()){
			if(getItsMine()&&!getDisabled()){
				upsert carplan;
			}
  		}
		pageReference page = new Pagereference('/apex/myCareerPlanPrint?id='+carPlan.id);
		page.setRedirect(true);
		return page;
	}
	public pageReference gotoSharing(){
		pageReference page = new PageReference('/p/share/CustomObjectSharingEdit?parentId='+carplan.id+'&retURL=apex/MyCareerPlan?id='+carplan.id);
		page.setRedirect(true);
		return page;
	}
	public pageReference gotoAccess(){
		pageReference page = new PageReference('/p/share/CustomObjectSharingDetail?parentId='+carplan.id);
		page.setRedirect(true);
		return page;
		
	}
	public boolean getRenderSharing(){
		boolean back = false;
		if(userInfo.getUserId()==carPlan.OwnerId){
			if(carplan.id!=null){
			back=true;
			}
		}
		return back;
	}

}