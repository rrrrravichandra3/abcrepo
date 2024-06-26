public class IAAssignPublicGroupToPortalUserHandler {
    /*******************************************************************************************************
       * @description Defines method to do adding check on PS and PG for candidate user
    */
    public static void assignPublicGrouptriggerHandler(List<IA_Assign_Public_Group_To_Portal_User__e> listOfPlatformEvents){
        String customLoginAccessImplClass;
        if (!Test.isRunningTest()) {
            customLoginAccessImplClass = IA_Util.InsiderConfigDefaultRec.IA_PG_Check_Impl_Class__c;
        }
        Type t = Type.forName(customLoginAccessImplClass);
        ((IAAssignPublicGroupToPortalUserInterface) t.newInstance()).assignPGToPortalUsers(listOfPlatformEvents);
    }
}