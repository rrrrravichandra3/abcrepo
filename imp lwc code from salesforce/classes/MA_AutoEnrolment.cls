/**
 * W-10449458 / W-10678114 / W-10702588
 * Abstract class to identify the Enrolment Service implmentation to execute for auto-enrolment action.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/02/2022      Chakshu Malhotra        Implements strategy pattern to identify right implemtation of Enrolment Service to execute.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract class MA_AutoEnrolment {
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Interface to implement different enrolment services based on Enrolment Type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public interface EnrolmentService {
        void autoEnrol(List<MA_Auto_Enrolment_Event__e> autoEnrolmentEvents);
    }

    private static EnrolmentStrategy strategyInstance;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to retrieve singleton instance of EnrolmentStrategy type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   EnrolmentStrategy        DESCRIPTION (return instance of EnrolmentStrategy)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static EnrolmentStrategy getEnrolmentStrategy() {
        if(strategyInstance == null) {
            strategyInstance = new EnrolmentStrategy();
        }
        return strategyInstance;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Strategy class to return right implementation of EnrolmentService based on Enrolment Type. 
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class EnrolmentStrategy {
        private Map<String, String> enrolmentServiceMap;

        private EnrolmentStrategy() {
            enrolmentServiceMap = new Map<String, String>();
            for(MA_Enrolment_Service_Mapping__mdt serviceMapping : MA_Enrolment_Service_Mapping__mdt.getAll()?.values()) {
                enrolmentServiceMap.put(serviceMapping.Enrolment_Type__c.toLowerCase(), serviceMapping.Enrolment_Service__c);
            }
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method is used to retrieve EnrolmentService implementation instance.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    enrolmentType         DESCRIPTION (Data type String, Enrolment Type to get Enrolment Service)
        * @param    autoEnrolmentEvents   DESCRIPTION (Data type List<MA_Auto_Enrolment_Event__e>, List of auto enrolment platform event records)     
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public void autoEnrol(String enrolmentType, List<MA_Auto_Enrolment_Event__e> autoEnrolmentEvents) {
            try {
                EnrolmentService enrolmentService = getEnrolmentService(enrolmentType);
                enrolmentService.autoEnrol(autoEnrolmentEvents);
            }catch(UnknownEnrolmentServiceException exType) {
                MA_AbstractLogger.logException(exType, UnknownEnrolmentServiceException.class.getName());
            }
        }

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method is used to retrieve EnrolmentService implementation instance.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @param    enrolmentType                       DESCRIPTION (Data type String, Enrolment Type to get Enrolment Service)     
        * @return   EnrolmentService                    DESCRIPTION (return instance of EnrolmentService implementation)
        * @throws   UnknownEnrolmentServiceException    DESCRIPION (thrown if EnrolmentService implementation is not found)
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        private EnrolmentService getEnrolmentService(String enrolmentType) {
            if(!enrolmentServiceMap.containsKey(enrolmentType)) {
                throw new UnknownEnrolmentServiceException(UnknownEnrolmentServiceException.class.getName() + ' : ' + enrolmentType);
            }
            return (EnrolmentService) Type.forName(enrolmentServiceMap.get(enrolmentType)).newInstance();
        }
    }

    public class UnknownEnrolmentServiceException extends Exception {}
}