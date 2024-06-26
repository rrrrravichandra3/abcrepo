/*Wrapper to hold access code*/
public class NHW_AccessCode{
        public String accessType; 
        public List<NHW_AccessDetails> accessDetailList; 
        
        public NHW_AccessCode(String accessType, List<NHW_AccessDetails> accessDetailList){
            this.accessType = accessType;
            this.accessDetailList = accessDetailList; 
        }
  }