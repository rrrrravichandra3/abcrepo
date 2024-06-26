public with sharing class te_SkillProfileController {

    public te_SkillProfileController() {

    }

    @AuraEnabled
    public static SkillProfileWrapper getSkillProfile() {
        //TODO impement a service
        return new SkillProfileWrapper('Java','Develops robust and scalable applications using Java, leveraging its object-oriented programming capabilities. Demonstrates proficiency in designing and implementing efficient algorithms, ensuring optimal performance and code maintainability. Utilizes Java frameworks and libraries to create innovative solutions, meeting project requirements and delivering high-quality software products.', 377, true);
    }

    @AuraEnabled
    public static User[] getMentorsBySkill(String skillName, String skillId) {
        //TODO impement a service
        return null;
    }

    @AuraEnabled
    public static String[] getTrainingBySkill(String skillName, String skillId) {
        //TODO impement a service
        return null;
    }

    @AuraEnabled
    public static String[] getGigsBySkill(String skillName, String skillId) {
        //TODO impement a service
        return null;
    }

    public class SkillProfileWrapper {
        @AuraEnabled
        public String skillName;
        @AuraEnabled
        public String skillDescription;
        @AuraEnabled
        public Integer skillCount;
        @AuraEnabled
        public Boolean isCritical;

        public SkillProfileWrapper(String skillName, String skillDescription, Integer skillCount, Boolean isCritical){
            this.skillName = skillName;
            this.skillDescription = skillDescription;
            this.skillCount = skillCount;
            this.isCritical = isCritical;
        }
    }
}