/* eslint-env Croppr */
import { LightningElement, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import cropprResource from '@salesforce/resourceUrl/croppr';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import imageUploader from '@salesforce/apex/Cc_Emp_PersonalInformationController.uploadCroppedImage';
import IMAGE_CROPPER_BROKEN_FILE_ALT_TEXT from '@salesforce/label/c.Cc_Emp_ImageCropperBrokenFileAltText';
import IMAGE_CROPPER_BUTTON_LABEL from '@salesforce/label/c.Cc_Emp_ImageCropperButtonLabel';
import IMAGE_CROPPER_ERROR_TITLE from '@salesforce/label/c.Cc_Emp_ImageCropperErrorTitle';
import IMAGE_CROPPER_LABEL from '@salesforce/label/c.Cc_Emp_ImageCropperLabel';
import IMAGE_CROPPER_SUCCESS_TITLE from '@salesforce/label/c.Cc_Emp_ImageCropperSuccessTitle';
import IMAGE_CROPPER_UPLOAD_SUCCESS_MESSAGE from '@salesforce/label/c.Cc_Emp_ImageCropperUploadSuccessMessage';

export default class CcEmpImageCropperModal extends LightningElement {
  cropprCssUrl = `${cropprResource}/croppr.min.css`;
  cropprJsUrl = `${cropprResource}/croppr.min.js`;
  imageCroppr;
  isCropprLoaded = false;
  cropprOptions = {};
  cropprInitialized = false;
  showSpinner = false;
  showModal = false;
  imageElement;
  imageMimeType = '';
  imageName = '';

  croppedImageDataUrl = '';
  croppingEnabled = false;

  @api aspectRatio = null;
  @api maxCropWidth = 0;
  @api maxCropHeight = 0;
  @api minCropWidth = 0;
  @api minCropHeight = 0;

  @api open() {
    this.showModal = true;
  }
  @api close() {
    this.showModal = false;
  }

  LABELS = {
    IMAGE_CROPPER_BROKEN_FILE_ALT_TEXT,
    IMAGE_CROPPER_BUTTON_LABEL,
    IMAGE_CROPPER_ERROR_TITLE,
    IMAGE_CROPPER_LABEL,
    IMAGE_CROPPER_UPLOAD_SUCCESS_MESSAGE,
    IMAGE_CROPPER_SUCCESS_TITLE,
  };

  get isComponentReady() {
    return this.isCropprLoaded;
  }

  get isCroppingEnabled() {
    return this.isComponentReady && this.cropprInitialized && this.croppingEnabled;
  }

  renderedCallback() {
    if (this.isCropprLoaded) {
      return;
    }

    Promise.all([loadStyle(this, this.cropprCssUrl), loadScript(this, this.cropprJsUrl)])
      .then(() => {
        this.cropprOptions = this.prepareOptions();
        this.imageElement = this.template.querySelector('.cropperImage');
        this.isCropprLoaded = true;
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: this.LABELS.IMAGE_CROPPER_ERROR_TITLE,
            message: error.message,
            variant: 'error',
          })
        );
      });
  }

  prepareOptions() {
    const options = { startSize: [100, 100, '%'] };

    if (this.maxCropHeight && this.maxCropWidth) {
      options.maxSize = [this.maxCropWidth, this.maxCropHeight, 'px'];
    }

    if (this.minCropHeight && this.minCropWidth) {
      options.minSize = [this.minCropWidth, this.minCropHeight, 'px'];
    }

    if (this.aspectRatio && !isNaN(this.aspectRatio)) {
      options.aspectRatio = Number(this.aspectRatio);
    }

    options.onInitialize = () => {
      this.cropprInitialized = true;
    };

    return options;
  }

  handleFileChange(event) {
    if (this.cropprInitialized) {
      this.cropprInitialized = false;
      if (this.imageCroppr) {
        this.imageCroppr.destroy();
      }
    }

    const [file] = event.target.files;
    this.imageName = file.name;

    if (file) {
      this.imageElement = this.template.querySelector('.cropperImage');
      if (this.imageElement) {
        this.imageElement.src = URL.createObjectURL(file);
      }
      this.imageMimeType = file.type;
    }
  }

  imageLoadHandler(event) {
    event.target.style = '';
    this.croppingEnabled = true;
    this.imageCroppr = new Croppr(this.imageElement, this.cropprOptions);
    console.log('this.imageCroppr', this.imageCroppr);
  }

  handleImageCrop() {
    const croppedData = this.imageCroppr.getValue();
    const canvas = this.template.querySelector('canvas');

    canvas.height = croppedData.height;
    canvas.width = croppedData.width;

    const context = canvas.getContext('2d');
    context.drawImage(
      this.imageElement,
      croppedData.x,
      croppedData.y,
      croppedData.width,
      croppedData.height,
      0,
      0,
      croppedData.width,
      croppedData.height
    );

    this.croppedImageDataUrl = canvas.toDataURL(this.imageMimeType)?.split(';base64,')[1];
    this.uploadFile();
  }

  uploadFile() {
    this.showSpinner = true;
    imageUploader({ imageBase64: this.croppedImageDataUrl })
      .then(() => {
        console.log('image uploaded successfully!!!');

        this.croppingEnabled = false;
        if (this.imageCroppr) {
          this.imageCroppr.destroy();
        }
        this.imageCroppr = null;
        this.imageElement.style = 'display: none;';

        this.dispatchEvent(
          new ShowToastEvent({
            title: this.LABELS.IMAGE_CROPPER_SUCCESS_TITLE,
            message: this.LABELS.IMAGE_CROPPER_UPLOAD_SUCCESS_MESSAGE,
            variant: 'success',
          })
        );
        this.dispatchEvent(new CustomEvent('success'));
        console.log('event dispatched successfully!');
      })
      .catch((error) => {
        console.log('error in file upload', error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: this.LABELS.IMAGE_CROPPER_ERROR_TITLE,
            message: error.message,
            variant: 'error',
          })
        );
      })
      .finally(() => {
        this.showSpinner = false;
        this.close();
      });
  }

  closeModal() {
    this.close('success');
  }
}