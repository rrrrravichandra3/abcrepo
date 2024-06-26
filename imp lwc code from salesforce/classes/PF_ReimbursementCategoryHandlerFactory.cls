public class PF_ReimbursementCategoryHandlerFactory {

    public static PF_ReimbursementRequestCategoryHandler getCategoryHandler(String categoryGroup, DJC_WellnessManagerFactory managerFactory){
        
        PF_ReimbursementRequestCategoryHandler handler = null;
        
        if(categoryGroup == 'Education'){
            handler = new PF_ReimbursementEducationCategoryHandler(managerFactory);
        }else if(categoryGroup == 'Wellness'){
            handler = new PF_ReimbursementWellnessCategoryHandler(managerFactory);
        }else if(categoryGroup == 'Health'){
            handler = new PF_ReimbursementHealthCategoryHandler(managerFactory);
        }
        
        return handler;
    }
    
}