public class CcEmp_ExceptionUtil {
    public class AccessibleFieldsException extends Exception {
        private List<Schema.SObjectField> fields;
    
        public AccessibleFieldsException(List<Schema.SObjectField> fields) {
          this.fields = fields;
        }
    
        public List<Schema.SObjectField> getFields() {
          return fields;
        }
    }
    
    public class CreateableFieldsException extends Exception {
        private List<Schema.SObjectField> fields;
    
        public CreateableFieldsException(List<Schema.SObjectField> fields) {
          this.fields = fields;
        }
    
        public List<Schema.SObjectField> getFields() {
          return fields;
        }
    }
    
    public class UpdateableFieldsException extends Exception {
        private List<Schema.SObjectField> fields;
    
        public UpdateableFieldsException(List<Schema.SObjectField> fields) {
          this.fields = fields;
        }
    
        public List<Schema.SObjectField> getFields() {
          return fields;
        }
    }
    
    public class DeleteableCrudException extends Exception {
        private List<Schema.SObjectType> types;
    
        public DeleteableCrudException(List<Schema.SObjectType> types) {
          this.types = types;
        }
    
        public List<Schema.SObjectType> getTypes() {
          return types;
        }
    }
}