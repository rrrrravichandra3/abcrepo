import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getInitData from '@salesforce/apex/PF_CaseUIComponentController.getInitData';

const LABELS = {
  ER_CASES : 'Related Employee Relations Cases',
  MESSAGE_NO_RECORDS : 'There are no "Employee Relations" related records to show.',
  HIDE_LEGENDS : 'Hide Legends',
  SHOW_LEGENDS : 'Show Legends',
  RT_ER_INVESTIGATION : 'ER Investigations',
  RT_MANAGER_GUIDANCE : 'Manager Guidance',
  RT_ER_PERFORMANCE_IMPROVEMENT : 'ER Performance Improvement',
  RT_GENERAL_ER_CASE : 'General Employee Relations Case',
  LEGEND_RESTRICTED : 'Record Is Restricted',
  CASE_NUMBER : 'Case Number',
  OWNER_NAME : 'Owner Name',
  STATUS : 'Status',
  FINDINGS : 'Findings',
  OUTCOME : 'Outcome',
  CONTACT_NAME : 'Contact Name',
  IN_REFERENCE_TO : 'In Reference To',
  RECORD_TYPE_NAME : 'Record Type'
};
const RT_API_ER_INVESTIGATION = 'ER_Investigations';
const RT_API_ER_PERFORMANCE_IMPROVEMENT = 'ER_Performance_Improvement';
const RT_API_GENERAL_ER_CASE = 'General_Employee_Relations_Case';
const RT_API_MANAGER_GUIDANCE = 'Manager_Guidance_CRT';
const RT_API_WARM_LINE = 'Warmline';
const SUPPORTED_ER_RECORD_TYPES = [
  RT_API_ER_INVESTIGATION,
  RT_API_ER_PERFORMANCE_IMPROVEMENT,
  RT_API_GENERAL_ER_CASE,
  RT_API_MANAGER_GUIDANCE
];


export default class Pf_uiComponent extends NavigationMixin(LightningElement) {
  LABELS = LABELS;

  @api recordId;
  @api fieldSetName;

  @track showComponent = false;
  @track showError = false;
  @track isProcessing = false;
  _isConnected = false;
  _hasError = false;
  _errorMessage = '';
  _contextRecordType;
  _tableColumns;
  _tableRecords;
  _showLegendsBlock = false;


  get defaultColumns() {
    return this._tableColumns;
  }

  get tableRecords() {
    return [...this._tableRecords].sort((a, b) => Number(b.caseNumber) - Number(a.caseNumber));
  }

  get showContent() {
    return this._isConnected && !this._hasError;
  }

  get showErrorBlock() {
    return this._isConnected && this._hasError;
  }

  get errorMessage() {
    return this._errorMessage;
  }

  get hasRecords() {
    return !!this._tableRecords ? this._tableRecords.length > 0 : false;
  }

  get cardLabel() {
    return `${LABELS.ER_CASES}${this._tableRecords?.length ? ` (${this._tableRecords.length})` : ''}`;
  }

  get showWarmLineFields() {
    return this._contextRecordType === RT_API_WARM_LINE;
  }

  get isERRecordType() {
    return SUPPORTED_ER_RECORD_TYPES.includes(this._contextRecordType);
  }

  get showERFields() {
    return SUPPORTED_ER_RECORD_TYPES.includes(this._contextRecordType);
  }

  get showERLegends() {
    return this._showLegendsBlock;
  }
  get toggleLegendsLabel() {
    return this._showLegendsBlock ? LABELS.HIDE_LEGENDS : LABELS.SHOW_LEGENDS;
  }
  get legendERILabel() {
    return `- ${LABELS.RT_ER_INVESTIGATION}`;
  }
  get legendMGLabel() {
    return `- ${LABELS.RT_MANAGER_GUIDANCE}`;
  }
  get legendERPILabel() {
    return `- ${LABELS.RT_ER_PERFORMANCE_IMPROVEMENT}`;
  }
  get legendGERCLabel() {
    return `- ${LABELS.RT_GENERAL_ER_CASE}`;
  }
  get legendRestrictedLabel() {
    return `- ${LABELS.LEGEND_RESTRICTED}`;
  }

  connectedCallback() {
    this.init();
  }

  async init() {
    this.activateSpinner();

    let { status, message, ...result } = await getInitData({
      recordId: this.recordId,
      fieldSetName: this.fieldSetName
    });

    if (status === 'SUCCESS') {
      this._tableColumns = result.tableColumns;
      this._tableRecords = result.records;
      this._contextRecordType = result.caseRecordType;
      this.showComponent = true;
    } else {
      this._hasError = true;
      this._errorMessage = message;
      console.error(message);
    }

    this._isConnected = true;

    this.deactivateSpinner();
  }

  handleToggleLegendsAction() {
    this._showLegendsBlock = !this._showLegendsBlock;
  }

  async handleRefreshButton() {
    await this.init();
  }

  handleNavigateToLookup(event) {
    event.preventDefault();
    let targetId = event.currentTarget.dataset.targetId;

    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: targetId,
        actionName: 'view',
      }
    });
  }

  activateSpinner() {
    this.setSpinnerState(true);
  }

  deactivateSpinner() {
    this.setSpinnerState(false);
  }

  setSpinnerState(newValue) {
    this.isProcessing = newValue;
  }
}