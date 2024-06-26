import { LightningElement, api } from 'lwc';
import HAMBURGER_ICON from '@salesforce/resourceUrl/ms_hamburgerIcon';
import X_ICON from '@salesforce/resourceUrl/ms_XIcon';

export default class PbMobileNavigation extends LightningElement {
    @api logo;
    hamburgerIcon = HAMBURGER_ICON;
    xIcon = X_ICON;
    showHamburgerMenu;


    /**
     * @description handleHamburgerMenuToggle method listens for 
     *              an onclick event to conditionally render
     *              the mobile menu
     * @param   evt
     */
    handleHamburgerMenuToggle(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        if (this.showHamburgerMenu) {
            this.showHamburgerMenu = false;
        } else {
            this.showHamburgerMenu = true;
        }
    }


    
}