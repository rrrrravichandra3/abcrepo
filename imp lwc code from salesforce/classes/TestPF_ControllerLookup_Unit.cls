@isTest
private class TestPF_ControllerLookup_Unit {
   
     static testMethod void  TestControllerLookup(){
        
        ControllerLookup controller = new ControllerLookup();       
        controller.getUsers();
        controller.searchText = 'da';
        controller.Search();
        controller.DoSort();
    }
}