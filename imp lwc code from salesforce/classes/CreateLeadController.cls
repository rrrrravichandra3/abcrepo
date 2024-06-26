public with sharing class CreateLeadController {

  Public boolean isHM {get; set;}
  Public String isHMStr {get; set;}
  Private Id UserProfileId { get; set; }
  Private Id ManagerProfieId = [ select Id from Profile where name = 'Manager' Limit 1 ].Id;
  
  public CreateLeadController(){

    UserProfileId = userinfo.getProfileId();
    
    if ( UserProfileId == ManagerProfieId ){
        isHM = true;
        isHMStr = 'block';
    } else {
        isHM = false;
        isHMStr = 'none';
    }
          
  }
  
  
  
}