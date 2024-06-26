import { LightningElement, api, wire } from 'lwc';
import setProfilePhoto from '@salesforce/apex/te_profilePhotoController.setProfilePhoto';
import { publish, MessageContext } from 'lightning/messageService';
import IMAGE_CHANGE_CHANNEL from '@salesforce/messageChannel/imageChangeMessageChannel__c';

export default class Te_profilePhoto extends LightningElement {
    @api editEnabled = "true";
    showModal = false;
    blobData;
    @api imgUrl;

    handleEdit(){
        this.showModal=true;
    }

    handleClose(){
        this.showModal=false;
    }
    @wire(MessageContext)
    messageContext;

    handleFileChange(event){
        const uploadedFiles = event.detail.files[0];
        console.log(uploadedFiles);

        if (uploadedFiles) {
            // Read the contents of the file as a data URL
            const reader = new FileReader();
            
            reader.onload = () => {
                const base64Image = reader.result.split(',')[1]; // Extract the base64 data
                this.uploadProfilePhoto(base64Image);
            };

            // Read the file as a data URL
            reader.readAsDataURL(uploadedFiles);
        }
    }



    uploadProfilePhoto(blobData) {
        setProfilePhoto({ base64Image: blobData })
            .then((result) => {
                let newUrl = result.largePhotoUrl.split('my.site.com')[1];
                this.imgUrl = newUrl;

                // Publish the message with the updated image source
                const messagePayload = { imageSrc: this.imgUrl };
                publish(this.messageContext, IMAGE_CHANGE_CHANNEL, messagePayload);
            })
            .catch((error) => {
                console.log(error);
            });
        this.handleClose();
    }
}