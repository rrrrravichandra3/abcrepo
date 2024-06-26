import { LightningElement, wire } from 'lwc';
import getOnloadData from '@salesforce/apex/Cc_Emp_PersonalInformationController.getOnloadData';
import updateUserInfo from '@salesforce/apex/Cc_Emp_PersonalInformationController.updateUserInfo';
import { refreshApex } from '@salesforce/apex';
import LINKEDIN_LABEL from '@salesforce/label/c.Cc_Emp_Linked_Input_Label';
import PERSONAL_WEBSITE_LABEL from '@salesforce/label/c.Cc_Emp_Personal_Website_Label';
import PERSONAL_WEBSITE_PLACEHOLDER from '@salesforce/label/c.Cc_Emp_Personal_Website_PlaceHolder';
import LINKEDIN_PLACEHOLDER from '@salesforce/label/c.Cc_Emp_LinkedIn_PlaceHolder';
import { showToast } from 'c/ccEmpLmsUtil';

export default class CcEmpPersonalInformation extends LightningElement {
  userData;
  hasLoaded = false;
  responseRef;
  showSpinner = false;
  label = {
    LINKEDIN_LABEL,
    PERSONAL_WEBSITE_LABEL,
    PERSONAL_WEBSITE_PLACEHOLDER,
    LINKEDIN_PLACEHOLDER,
  };

  @wire(getOnloadData)
  wiredNavItems(response) {
    this.responseRef = response;
    const { error, data } = response;
    console.log('data', data);
    if (data) {
      this.userData = data;
      this.hasLoaded = true;
    } else if (error) {
      showToast({
        title: 'Error!',
        message: JSON.stringify(error),
        variant: 'error',
      });
    }
  }

  async uploadImage() {
    console.log('uploading');
    const comp = this.template.querySelector('c-cc-emp-image-cropper-modal');
    comp.open();
  }

  handleUploadResult(event) {
    this.hasLoaded = false;
    refreshApex(this.responseRef);
    console.log('refreshing data');
  }

  updatePersonalInfo() {
    const userData = {
      LinkedInUrl: this.template.querySelector('.linkedinInpt').value,
      PersonalWebsite: this.template.querySelector('.personalWebsiteInpt').value,
      AboutMe: this.template.querySelector('.bioText').value,
      EmpPrefId: this.userData.Id,
    };

    console.log('userData', userData);
    this.showSpinner = true;
    updateUserInfo({ data: JSON.stringify(userData) })
      .then((data) => {
        showToast({
          title: 'Success',
          message: 'Information Updated Successfully!',
          variant: 'success',
        });
        this.showSpinner = false;
      })
      .catch((error) => {
        console.log(error);
        this.showSpinner = false;
      });
  }
}