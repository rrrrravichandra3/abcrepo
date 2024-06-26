import {
    LightningElement,
    api
} from 'lwc';

import standardButton from './filterButton.html';
import treeButton from './treeButton.html';

export default class FilterButton extends LightningElement {
    @api filter;
    @api startFilters;

    render(){
        return this.filter.tree ? treeButton : standardButton;
    }

    handleFilterClick(event) {
        event.preventDefault();
        this.dispatchEvent(
            new CustomEvent("pressclick", {
                detail: event.currentTarget.getAttribute("data-id")
            })
        );

        this.filter.isActive = true;
    }

    get checkActive() {
        if (this.startFilters) {
            return this.startFilters.has(this.filter.id);
        }   
    }
}