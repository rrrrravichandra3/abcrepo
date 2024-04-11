import { LightningElement, wire, track } from 'lwc';
import fdResources from '@salesforce/resourceUrl/FrontDeskCustom';
import { NavigationMixin } from 'lightning/navigation';
import getConfigurationValues from '@salesforce/apex/FdEmp_ConfigurationValue.getConfigurationValues';

const supportTiles = [
  'GlobalWellnessProgramSupportTileLink',
  'EducationReimbursementSupportLink',
  'RequestSoftwareSupportTileLink',
  'RequestOrgAccessSupportTileLink',
  'RemoteOfficeSupportTileLink',
];

export default class FdEmpHomeSupportPanel extends NavigationMixin(LightningElement) {
  @track isDataLoaded = false;
  supportTilesData = [
    {
      id: 'global-wellness',
      logo: `${fdResources}/images/supportTiles/wellness.svg`,
      name: 'Global Wellness Program',
      isInternal: true,
    },
    {
      id: 'education-reimbursement',
      logo: `${fdResources}/images/supportTiles/education_reimbursement.svg`,
      name: 'Education Reimbursement',
      isInternal: true,
    },
    {
      id: 'request-software',
      logo: `${fdResources}/images/supportTiles/request_software.svg`,
      name: 'Request Software',
      isInternal: false,
    },
    {
      id: 'request-org-access',
      logo: `${fdResources}/images/supportTiles/request_org_access.svg`,
      name: 'Request Org Access',
      isInternal: false,
    },
    {
      id: 'remote-employee-expense',
      logo: `${fdResources}/images/supportTiles/remote_office_expense.svg`,
      name: 'Remote Office Expense',
      isInternal: true,
    },
  ];

  @wire(getConfigurationValues, { configNames: supportTiles })
  getConfigurationValue({ error, data }) {
    if (data) {
      this.supportTilesData.forEach((supportTile, index) => {
        supportTile.link = data[index];
      });
      this.isDataLoaded = true;
    } else if (error) {
      this.error = error;
    }
  }
}