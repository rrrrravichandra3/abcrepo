import { LightningElement, api, track } from "lwc";
import getCertificatesSearchResult from "@salesforce/apex/talentMP_CertificateService.getCertificatesSearchResult";
import getCertificateAssignments from "@salesforce/apex/talentMP_CertificateService.getCertificateAssignments";
import removeCertificateAssignments from "@salesforce/apex/talentMP_CertificateService.removeCertificateAssignments";
import processNewCertificateAssignments from "@salesforce/apex/talentMP_CertificateService.processNewCertificateAssignments";
import createCertificate from "@salesforce/apex/talentMP_CertificateService.createCertificate";
import basePath from "@salesforce/community/basePath";


export default class Te_certification extends LightningElement {
  @api title = 'My Certifications';
  @track certificationMap = [];
  @track certifications = [];
  @track editAbility = true;
  @track showSpinner = false;
  @track searchComboStyleClass = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
  editButtonVisibility;
  @track editMode = false;
  @track editEnabled = true;
  @track isModalOpen = false;
  hasCertifications;
  addedCertifications = [];
  removedCertifications = [];
  existingCertifications = [];
  certName;
  certssignmentId;
  selectedFile;
  searchResults = [];

  connectedCallback() {
    this.getCertificateAssignments();
  }

  getCertificateAssignments() {
    getCertificateAssignments()
      .then((result) => {
        let communityUrl = window.location.origin + "" + basePath;
        communityUrl = communityUrl.replace("/s", "");
        this.certifications = result.certificationIdName;

        this.certifications.forEach(
          (element) =>
          (element.Image =
            communityUrl +
            "/sfsites/c/sfc/servlet.shepherd/version/download/" +
            result.certificationContentVersionMap[element.Id] +
            "?operationContext=S1")
        );
        this.setSearchRelatedData();
        this.certificationMap = result.certificationContentVersionMap;

        console.log("certificationMap ", this.certificationMap);
      })
      .catch((error) => {
        console.log(error);
      });
  }


  setSearchRelatedData() {
    if (this.certifications.length > 0) {
      this.existingCertifications = this.certifications.map(
        (certification) => certification.Id
      );
      this.hasCertifications = true;
      console.log("existingCertifications** " + this.existingCertifications);
    } else {
      this.certifications = [];
    }
  }

  @api
  get hasCertifications() {
    if (this.certifications === null || this.certifications.length === 0) {
      return false;
    } else {
      return true;
    }
  }
  
  async saveUpdatedCertifications() {
    this.showSpinner = true;
    if (this.removedCertifications.length !== 0) {
      await removeCertificateAssignments({
        certificationIds: this.removedCertifications
      });
    }
    if (this.addedCertifications.length !== 0) {
      await processNewCertificateAssignments({
        certificationIds: this.addedCertifications
      });
    }
    if (
      this.addedCertifications.length !== 0 ||
      this.removedCertifications.length !== 0
    ) {
      this.getCertificateAssignments();
    }

    this.editMode = false;
    this.removedSkills = [];
    this.addedCertifications = [];
    this.searchResults = [];
    this.showSpinner = false;
  }

  handleCancelClick() {
    this.removedCertifications = [];
    this.addedCertifications = [];
    this.editMode = false;
  }

  handleSearchCertificate(event) {
    let searchString = event.target.value;
    if (searchString.length > 0) {
      getCertificatesSearchResult({
        CertificateName: searchString,
        existingCertifications: this.existingCertifications
      })
        .then((result) => {
          console.log(JSON.stringify(result));
          this.searchComboStyleClass =
            result.length > 0
              ? "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open"
              : "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open";
          this.searchResults = result;
        })
        .catch((error) => {
          console.log(error);
        });
    } else {
      this.searchResults = [];
      this.searchComboStyleClass =
        "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
    }
  }

  handleRemoveCertificate(event) {
    let removedId = event.target.dataset.id;

    this.certifications = this.certifications.filter((certification) => {
      return certification.Id !== removedId;
    });
    const index = this.existingCertifications.indexOf(removedId);
    console.log("remove 1 index-->>" + index);
    if (index !== -1) {
      this.existingCertifications.splice(index, 1);
      this.removedCertifications.push(removedId);
    }
    const selectedIndex = this.addedCertifications.indexOf(removedId);
    console.log("remove selectedIndex-->>" + selectedIndex);
    if (selectedIndex !== -1) {
      this.addedCertifications.splice(selectedIndex, 1); // remove from selected list too
    }

  }

  getCertificateValue(key) {
    return this.certificationMap[key];
  }

  handleAddCertificate(event) {
    const certificateId = event.currentTarget.dataset.id;
    const certificateName = event.currentTarget.dataset.value;
    let communityUrl = window.location.origin + "" + basePath;
    communityUrl = communityUrl.replace("/s", "");

    this.certifications.push({
      Id: certificateId,
      Name: certificateName,
      Image:
        communityUrl +
        "/sfsites/c/sfc/servlet.shepherd/version/download/" +
        this.getCertificateValue(certificateId) +
        "?operationContext=S1"
    });


    this.searchResults = this.searchResults.filter((certification) => {
      return certification.Id !== certificateId;
    });
    if (this.searchResults.length === 0) {
      this.searchComboStyleClass =
        "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
    }
    if (!this.addedCertifications.includes(certificateId)) {
      this.addedCertifications.push(certificateId);
    }
  }

  handleRecordClick(event) {
    const recordId = event.target.dataset.recordId;
    const record = this.records.find((record) => record.Id === recordId);
    const selectEvent = new CustomEvent("select", { detail: record });
    this.dispatchEvent(selectEvent);
  }

  handleEditClick() {
    this.editMode = true;
  }

  @api
  get editButtonVisibility() {
    return this.editAbility && !this.editMode;
  }

  @api
  get editView() {
    return this.editAbility && this.editMode;
  }

  openModal() {
    this.isModalOpen = true;
  }

  closeModal() {
    this.isModalOpen = false;
  }

  handleCertNameChange(event) {
    this.certName = event.target.value;
  }
  
  handleUploadFinished(event) {
    const file = event.target.files[0];
    this.selectedFile = file;
  }

  async handleCreateCertification() {
    this.showSpinner = true;
    try {
      const reader = new FileReader();
      reader.onloadend = async () => {
        const base64Data = reader.result.split(',')[1];
        try {
          this.certssignmentId = await createCertificate({ certificateName: this.certName, title: this.selectedFile.name, base64Data });
          console.log('File uploaded successfully:', this.certssignmentId);
          if (this.certssignmentId) {
            this.getCertificateAssignments();
            //Reset variables and perform other actions
            this.editMode = false;
            this.removedSkills = [];
            this.addedCertifications = [];
            this.searchResults = [];
            this.showSpinner = false;
            this.isModalOpen = false;
            this.selectedFile = '';
            this.searchComboStyleClass = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
          }
        }
        catch (error) {
          // Handle errors from createCertificate
          console.error('Error during createCertificate:', error);
          this.showSpinner = false;
        }
      };
      reader.readAsDataURL(this.selectedFile);

    } catch (error) {
      // Handle errors from FileReader
      console.error('Error reading file:', error);
      this.showSpinner = false;
    }
  }

}