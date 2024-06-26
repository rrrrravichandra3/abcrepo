public class NHW_CategoryMatcherFactory {

    public static NHW_CategoryMatcher getCategoryMatcher(String categoryName){
        if(categoryName == 'BU CC'){
            return new NHW_BUCCCategoryMatcher();
        }
       	else if (categoryName == 'BU CC JobProfile'){
            return new NHW_BUCCJobProfileCategoryMatcher();
        }
        return null;
    }    
}