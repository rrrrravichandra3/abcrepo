/**
 * W-12578110
 * Contains exportable variables (constants & custom labels), used within the M&A Docusign LWC components.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         15/03/2023      Chakshu Malhotra        W-12578110 - Adds exportable variables (constants & custom labels), used within the M&A Docusign LWC components.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import addRulesCriteriaModalHeader from '@salesforce/label/c.MA_DS_Add_Rules_Criteria_Modal_Header';
import loadingRulesMsg from '@salesforce/label/c.MA_DS_Loading_Rules';
import rulesCriteriaTab from '@salesforce/label/c.MA_DS_Rules_Criteria_Tab';
import auditFlagsTab from '@salesforce/label/c.MA_DS_Audit_Flags_Tab';
import processRulesSuccessMessage from '@salesforce/label/c.MA_DS_Process_Rules_Success_Message';

const addRulesCriteriaLabels = {
    addRulesCriteriaModalHeader,
    loadingRulesMsg,
    rulesCriteriaTab,
    auditFlagsTab,
    processRulesSuccessMessage
};

const PARENT_SOBJECT = "parentSObject";
const CHILD_REL_MAP = "childRelationshipMap";
const FIELD_ROW_MAP = "fieldRowMap";
const RULE_LOGIC_MAP = "ruleLogicMap";
const FIELD_VALUE_MAP = "fieldValueMap";
const CUSTOM_LOGIC_MAP = "customLogicMap";
const FIELD_OPERATOR_MAP = "fieldOperatorMap";
const AUDIT_FLAGS_JSON_KEY = "auditFlagsJSON";
const RULES_CRITERIA_JSON_KEY = "rulesCriteriaJSON";

const addRulesCriteriaConstants = {
    PARENT_SOBJECT,
    CHILD_REL_MAP,
    FIELD_ROW_MAP,
    RULE_LOGIC_MAP,
    FIELD_VALUE_MAP,
    CUSTOM_LOGIC_MAP,
    FIELD_OPERATOR_MAP,
    AUDIT_FLAGS_JSON_KEY,
    RULES_CRITERIA_JSON_KEY
};

export {addRulesCriteriaConstants, addRulesCriteriaLabels};

import objectLabel from '@salesforce/label/c.MA_DS_Object_Combobox_Label';
import fieldLabel from '@salesforce/label/c.MA_DS_Field_Combobox_Label';
import operatorLabel from '@salesforce/label/c.MA_DS_Operator_Combobox_Label';
import valueLabel from '@salesforce/label/c.MA_DS_Value_Input_Label';

const rulesCriteriaTabLabels = {
    objectLabel,
    fieldLabel,
    operatorLabel,
    valueLabel
};

const RULES = "rules";
const FIELD_KEY = "fieldKey";
const FIELD_VAL = "fieldVal";
const OBJECT_KEY = "objectKey";
const RULE_LOGIC = "ruleLogic";
const OPERATOR_KEY = "operator";
const FIELD_LABEL = "fieldLabel";
const OBJECT_LABEL = "objectLabel";
const CUSTOM_LOGIC = "customLogic";
const BUTTON_MARGIN = " date-time-margin";
const BUTTON_CLASS = "align-bottom bold-font";

const rulesCriteriaTabConstants = {
    RULES,
    FIELD_KEY,
    FIELD_VAL,
    OBJECT_KEY,
    RULE_LOGIC,
    OPERATOR_KEY,
    FIELD_LABEL,
    OBJECT_LABEL,
    CUSTOM_LOGIC,
    BUTTON_CLASS,
    BUTTON_MARGIN,
    FIELD_ROW_MAP,
    RULE_LOGIC_MAP,
    FIELD_VALUE_MAP,
    CUSTOM_LOGIC_MAP,
    FIELD_OPERATOR_MAP
};

export {rulesCriteriaTabConstants, rulesCriteriaTabLabels};

import sampleSizeLabel from '@salesforce/label/c.MA_DS_Sample_Size_Label';

const auditFLagsTabLabels = {
    objectLabel,
    fieldLabel,
    sampleSizeLabel
};

const TYPE = "type";
const SAMPLE_SIZE = "sampleSize";

const auditFlagsTabConstants = {
    TYPE,
    RULES,
    FIELD_KEY,
    OBJECT_KEY,
    FIELD_LABEL,
    SAMPLE_SIZE,
    OBJECT_LABEL
};

export {auditFlagsTabConstants, auditFLagsTabLabels};

import addRuleLogic from '@salesforce/label/c.MA_DS_Add_Rule_Logic';
import ruleLogic from '@salesforce/label/c.MA_DS_Rule_Logic';
import ruleLogicHelpText from '@salesforce/label/c.MA_DS_Rule_Logic_Help_Text';
import removeLabel from '@salesforce/label/c.MA_DS_Remove_Rule_Logic';
import ruleLogicPlaceholder from '@salesforce/label/c.MA_DS_Rule_Logic_Placeholder';

const selectedRulesLabels = {
    addRuleLogic,
    ruleLogic,
    ruleLogicHelpText,
    removeLabel,
    ruleLogicPlaceholder
};

const RULE_WITH_CUSTOM_LOGIC_CLASS = " rule-item-custom-logic";
const RULE_WITH_NO_CUSTOM_LOGIC_CLASS = " rule-item-no-custom-logic";
const RULE_COMMON_CLASSES = "rule-item-padding slds-m-around_xx-small";

const selectedRulesConstants = {
    RULE_WITH_CUSTOM_LOGIC_CLASS,
    RULE_WITH_NO_CUSTOM_LOGIC_CLASS,
    RULE_COMMON_CLASSES
};

export {selectedRulesConstants, selectedRulesLabels};

const RULE_TILE_QUERY_SELECTOR = ".rule-tile-layout";
const RULE_SELECTION_CLASS = "rule-selection-background";

const selectedRuleTileConstants = {
    RULE_SELECTION_CLASS,
    RULE_TILE_QUERY_SELECTOR
};

export {selectedRuleTileConstants};

import booleanTrue from '@salesforce/label/c.MA_DS_Boolean_Type_True';
import booleanFalse from '@salesforce/label/c.MA_DS_Boolean_Type_False';
import inputValueLabel from '@salesforce/label/c.MA_DS_Input_Value_Label';
import valuePlaceholder from '@salesforce/label/c.MA_DS_Input_Value_Placeholder';
import numberPlaceholder from '@salesforce/label/c.MA_DS_Add_Number_Value';
import missingValueValidity from '@salesforce/label/c.MA_DS_Missing_Field_Validity';
import equalsOperator from '@salesforce/label/c.MA_DS_Equals_Operator';
import doesNotEqualOperator from '@salesforce/label/c.MA_DS_Does_Not_Equal_Operator';
import emailValidity from '@salesforce/label/c.MA_DS_Email_Validity';
import picklistValidity from '@salesforce/label/c.MA_DS_Picklist_Validity';
import somethingWrongValidity from '@salesforce/label/c.MA_DS_Something_Went_Wrong';

const rulesCriteriaValueLabels = {
    booleanTrue,
    booleanFalse,
    inputValueLabel,
    valuePlaceholder,
    numberPlaceholder,
    missingValueValidity,
    equalsOperator,
    doesNotEqualOperator,
    emailValidity,
    picklistValidity,
    somethingWrongValidity,
};

const BLANK_LABEL = "";
const ERROR_INPUT_CLASS = " slds-has-error";

const rulesCriteriaValueConstants = {
    BLANK_LABEL,
    ERROR_INPUT_CLASS
};

export {rulesCriteriaValueConstants, rulesCriteriaValueLabels};

const ERROR_BORDER_CLASS = " error-border";
const INPUT_CLASS = "slds-input slds-combobox__input multi-select-combobox__input";

const multiselectComboboxConstants = {
    ERROR_BORDER_CLASS,
    INPUT_CLASS
};

export {multiselectComboboxConstants};

import incompleteLogicValidity from '@salesforce/label/c.MA_DS_Incomplete_Rule_Logic';
import spellingValidity from '@salesforce/label/c.MA_DS_Rule_Logic_Spelling_Validity';
import undefinedLogicValidity from '@salesforce/label/c.MA_DS_Undefined_Rule_Logic_Validity';
import duplicateLogicValidity from '@salesforce/label/c.MA_DS_Duplicate_Rule_Logic_Validity';
import openParenthesisValidity from '@salesforce/label/c.MA_DS_Open_Parenthesis_Validity';
import closedParenthesisValidity from '@salesforce/label/c.MA_DS_Closed_Parenthesis_Validity';
import rightOperandValidity from '@salesforce/label/c.MA_DS_Right_Operand_Validity';
import successiveRulesValidity from '@salesforce/label/c.MA_DS_Successive_Rule_Number_Validity';
import successiveAndOrValidity from '@salesforce/label/c.MA_DS_Successive_AND_OR_Validity';

const ruleLogicValidatorLabels = {
    incompleteLogicValidity,
    spellingValidity,
    undefinedLogicValidity,
    duplicateLogicValidity,
    openParenthesisValidity,
    closedParenthesisValidity,
    rightOperandValidity,
    successiveRulesValidity,
    successiveAndOrValidity
};

export {ruleLogicValidatorLabels};

import massRecallDialogLabel from '@salesforce/label/c.MA_DS_Mass_Recall_Confirm_Dialog_Label';
import massRecallDialogMessage from '@salesforce/label/c.MA_DS_Mass_Recall_Confirm_Dialog_Message';

const recallPackagesLabels = {
    massRecallDialogLabel,
    massRecallDialogMessage
};

export {recallPackagesLabels};