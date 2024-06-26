public class PF_NHW_ProvisioningType {

    public static final PF_NHW_ProvisioningType ORGANIZATION = new PF_NHW_ProvisioningType('Organization', Type.forName('PF_NHW_OrgProvisioningTypeService'));
    public static final PF_NHW_ProvisioningType ROLE = new PF_NHW_ProvisioningType('Role', Type.forName('PF_NHW_RoleProvisioningTypeService'));
    public static final PF_NHW_ProvisioningType RESOURCETYPE = new PF_NHW_ProvisioningType('Resource Type', Type.forName('PF_NHW_ResTypeProvisioningTypeService'));
    public static final PF_NHW_ProvisioningType HIREREASON = new PF_NHW_ProvisioningType('Hire Reason', Type.forName('PF_NHW_HireReasonProvisioningTypeService'));
    
    public static final PF_NHW_ProvisioningType LAPTOP = new PF_NHW_ProvisioningType('Laptop', Type.forName('PF_NHW_LaptopProvisioningTypeService'));
    public static final PF_NHW_ProvisioningType DESKTOP = new PF_NHW_ProvisioningType('Desktop', Type.forName('PF_NHW_DesktopProvisioningTypeService'));
    public static final PF_NHW_ProvisioningType VDI = new PF_NHW_ProvisioningType('VDI', Type.forName('PF_NHW_VDIProvisioningTypeService'));
    public static final PF_NHW_ProvisioningType TRAINING = new PF_NHW_ProvisioningType('Training', Type.forName('PF_NHW_TrainingProvisioningTypeService'));
    public static final PF_NHW_ProvisioningType APPLICATION = new PF_NHW_ProvisioningType('Application', Type.forName('PF_NHW_AppProvisioningTypeService'));
    
    private static final List<PF_NHW_ProvisioningType> instances = new List<PF_NHW_ProvisioningType>{
        ORGANIZATION, ROLE, RESOURCETYPE,HIREREASON, LAPTOP, DESKTOP,TRAINING, APPLICATION, VDI};
    
    public String name{get; private set;}
    private Type provisioningTypeServiceType;
    
    private PF_NHW_ProvisioningType(String name, Type provisioningTypeServiceType){
        this.name = name;
        this.provisioningTypeServiceType = provisioningTypeServiceType;
    }
    
    public static PF_NHW_ProvisioningType getProvisioningTypeByName(String provisioningTypeName){
        if(provisioningTypeName != null){
            for(PF_NHW_ProvisioningType instance:instances){
                if(provisioningTypeName == instance.name){
                    return instance;
                }
            }
        }
        return null;
    }
    
    public PF_NHW_ProvisioningTypeService createService(Case provisioningCase){
        PF_NHW_ProvisioningTypeService service = (PF_NHW_ProvisioningTypeService) provisioningTypeServiceType.newInstance();
        service.provisioningType = this;
        service.provisioningCase = provisioningCase;
        return service;
    }
}