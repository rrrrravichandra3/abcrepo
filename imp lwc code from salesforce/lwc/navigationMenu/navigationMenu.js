import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import TE_SF_Logo from '@salesforce/resourceUrl/TE_SF_Logo';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import FullPhotoUrl from '@salesforce/schema/User.FullPhotoUrl';
import { NavigationMixin } from 'lightning/navigation';
import getNavigationMenuItems from '@salesforce/apex/NavigationMenuItemsController.getNavigationMenuItems';
import getProfileNavigationItems from '@salesforce/apex/NavigationMenuItemsController.getProfileNavigationItems';
import { subscribe, MessageContext } from 'lightning/messageService';
import IMAGE_CHANGE_CHANNEL from '@salesforce/messageChannel/imageChangeMessageChannel__c';

/**
 * This is a custom LWC navigation menu component.
 * Make sure the Guest user profile has access to the NavigationMenuItemsController apex class.
 */

export default class NavigationMenu extends NavigationMixin(LightningElement) {
    imgUrl = TE_SF_Logo;
    @track name;
    @track userPhoto;
    /**
     * the label or name of the nav menu linkset (NavigationMenuLinkSet.MasterLabel) exposed by the .js-meta.xml,
     * used to look up the NavigationMenuLinkSet.DeveloperName
     */
    @api linkSetMasterLabel;

    /**
     * include the Home menu item, if true
     */
    @api addHomeMenuItem = false;

    /**
     * include image URLs in the response, if true
     * useful for building a tile menu with images
     */
    @api includeImageUrls = false;

    /**
     * the menu items when fetched by the NavigationItemsController
     */
    @track menuItems = [];

    /**
     * if the items have been loaded
     */
    @track isLoaded = false;

    /**
     * the error if it occurs
     */
    @track error;

    /**
     * the published state of the site, used to determine from which schema to 
     * fetch the NavigationMenuItems
     */
    publishStatus;

    /**
     * DropdownItems for Profile Component
     */
    @track dropDownOptions = [];
    @track dropdownOpen = false;



    /**
     * 
     * @param {*} param0 
     */
    @wire(getRecord, { recordId: Id, fields: [Name, FullPhotoUrl] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            console.log(data);

            if (data.fields.Name.value != null) {
                this.name = data.fields.Name.value;
            }
            if (data.fields.FullPhotoUrl.value != null) {
                this.userPhoto = data.fields.FullPhotoUrl.value;
            }
        }
        console.log(this.userPhoto);
    }

    /**
     * Using a custom Apex controller, query for the NavigationMenuItems using the
     * menu name and published state.
     * 
     * The custom Apex controller is wired to provide reactive results. 
     */
    @wire(getNavigationMenuItems, {
        navigationLinkSetMasterLabel: '$linkSetMasterLabel',
        publishStatus: '$publishStatus',
        addHomeMenuItem: '$addHomeMenuItem',
        includeImageUrl: '$includeImageUrls'
    })
    wiredMenuItems({error, data}) {
        if (data && !this.isLoaded) {
            this.menuItems = data.map((item, index) => {
                return {
                    target: item.actionValue,
                    id: index,
                    label: item.label,
                    type: item.actionType,
                    subMenu: item.subMenu,
                    imageUrl: item.imageUrl,
                    windowName: item.target
                }
            });
            this.error = undefined;
            this.isLoaded = true;
        } else if (error) {
            this.error = error;
            this.menuItems = [];
            this.isLoaded = true;
            console.error(`Navigation menu error: ${JSON.stringify(this.error)}`);
        }
    }

    /**
     * Using the CurrentPageReference, check if the app is 'commeditor'.
     * 
     * If the app is 'commeditor', then the page will use 'Draft' NavigationMenuItems. 
     * Otherwise, it will use the 'Live' schema.
    */
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        const app = currentPageReference && currentPageReference.state && currentPageReference.state.app;
        if (app === 'commeditor') {
            this.publishStatus = 'Draft';
        } else {
            this.publishStatus = 'Live';
        }
    }

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        // Subscribe to the message channel
        this.subscription = subscribe(
            this.messageContext,
            IMAGE_CHANGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
        // Add event listener when the component is connected to the DOM
        document.body.addEventListener('click', this.handleDocumentClick.bind(this));
    }

    handleMessage(message) {
        // Update the image source with the received data from the message
        this.userPhoto = message.imageSrc;
    }

    disconnectedCallback() {
        // Remove event listener when the component is removed from the DOM
        document.body.removeEventListener('click', this.handleDocumentClick.bind(this));
    }

    handleDropdownClick(event) {
        // Prevent click event from bubbling up to the document body
        event.stopPropagation();
        this.dropdownOpen = !this.dropdownOpen;
    }

    handleDocumentClick() {
        // Close dropdown when clicking elsewhere on the document
        this.dropdownOpen = false;
    }

    toggleDropdown(event) {
        event.stopPropagation();
        this.dropdownOpen = !this.dropdownOpen;
    }

    handleOptionSelection(event) {
        event.stopPropagation();
        const selectedOption = event.target.getAttribute('data-option');
        const selectedOptionItem = this.dropDownOptions.find(option => option.label === selectedOption);
        if (selectedOptionItem) {

            const selectedOptionURL = selectedOptionItem.url;
            this.redirectToPage(selectedOptionURL);
            this.dropdownOpen = false;

        } else {
            console.error('Selected option not found in dropDownOptions array');
        }
    }
    /**
     * Using a custom Apex controller, query for the profile Menu Items using the
     * menu name and published state.
     * 
     * The custom Apex controller is wired to provide reactive results. 
     */
    @wire(getProfileNavigationItems)
    wiredProfileMenuItems({ error, data }) {
        if (data) {
            this.dropDownOptions = data.map((item) => {
                return {
                    label: item.MasterLabel,
                    url: item.URLName__c,
                }
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.dropDownOptions = [];
            console.error(`Profile menu error: ${JSON.stringify(this.error)}`);
        }
    }

    redirectToPage(pageUrl) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: pageUrl // Replace with your actual URL
            }
        });
        this.dropdownOpen = false;
    }
}