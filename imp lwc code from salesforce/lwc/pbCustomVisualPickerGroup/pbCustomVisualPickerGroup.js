import { LightningElement,api } from 'lwc';

export default class PbCustomVisualPickerGroup extends LightningElement {
    selecteditemid='';
    @api multiselect = false;
    @api items;
    @api type = 'overflow';
    get getStyle() {
        if(!this.multiselect) {
            return (this.items.length > 2) ? 'container overflow' : 'container default';
        } else return 'container wrap';
    }

    get getArrowStyle() {
        if(!this.multiselect) {
            return (this.items.length > 2) ? 'arrow' : 'arrowHidden';
        } else return 'arrowHidden';
    }


    scrollRight() {
        this.template.querySelector(".container").scrollBy({
            top: 0,
            left: 100,
            behavior: "smooth",
        });
    }

    selectItem(event) {
        if(!this.multiselect) {
            this.template.querySelectorAll("c-pb-custom-visual-picker").forEach(e=> {
                    e.deselect();
           });
           event.target.select();
           this.selecteditemid = event.target.getAttribute("data-id");
           this.dispatchEvent(new CustomEvent('select', {
           detail: this.selecteditemid
        }));
        } else {
            let choice = event.target;
            this.selecteditemid = choice.getAttribute("data-id");
            if(!choice.isselected) {
                choice.select();
                this.dispatchEvent(new CustomEvent('select', {
                    detail: {
                        id:this.selecteditemid,
                        select:true
                       }
                }));
            } else {
                choice.deselect();
                this.dispatchEvent(new CustomEvent('select', {
                    detail: {
                        id:this.selecteditemid,
                        select:false
                       }
                }));
            }
        }
    }
}