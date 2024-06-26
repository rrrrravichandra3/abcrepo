/**
 * W-12578110
 * Creates UI to show each individual added Rule / Audit Flag in the form of a tile.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         15/03/2023      Chakshu Malhotra        W-12578110 - Adds & interacts with UI to show each individual added Rule / Audit Flag in the form of a tile.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api, wire, track } from 'lwc';
import { selectedRuleTileConstants } from 'c/madsUtils';

export default class MadsSelectedRuleTile extends LightningElement {
    @api ruleNum;
    @api fieldKey;
    @api fieldVal;
    @api operator;
    @api objectKey;
    @api fieldLabel;
    @api sampleSize;
    @api rulesCriteria;

    showSpinner = false;
    initialized = false;
    ruleSelected = false;

    constants = selectedRuleTileConstants;

    get subtitleText() {
        return this.rulesCriteria ? (`${this.operator.toLowerCase()}   `) : (`Sample Size:   `);
    }

    get subtitleTextVal() {
        return `${this.rulesCriteria ? this.fieldVal : this.sampleSize}`;
    }

    renderedCallback() {
        if(!this.initialized) {
            this.template.querySelector("[data-id='closeBtn']").addEventListener("click", (event) => {
                this.handleRemoveRule(event);
                event.stopPropagation();
            });
            this.template.addEventListener("click", (event) => {
                if(!this.ruleSelected) {
                    this.showSpinner = true;

                    setTimeout(() => {
                        this.handleRuleSelection();
                        event.stopPropagation();
                        this.showSpinner = false;
                    }, 0);
                }
            });
            document.addEventListener("click", () => {
                if(this.ruleSelected) {
                    this.clearAllRuleSelection();
                }
            });
            this.initialized = true;
        }
    }

    handleRemoveRule(event) {
        event.preventDefault();
        this.ruleSelected = false;
        this.dispatchEvent(new CustomEvent("remove", this.getEventObject()));
    }

    handleRuleSelection() {
        this.ruleSelected = true;
        this.template.querySelector(this.constants.RULE_TILE_QUERY_SELECTOR).classList.add(this.constants.RULE_SELECTION_CLASS);
        this.dispatchEvent(new CustomEvent("select", this.getEventObject()));
    }

    getEventObject() {
        return {"detail": this.getEventDetail(), "bubbles": true, "composed": true};
    }

    getEventDetail() {
        return {"ruleNum": parseInt(this.ruleNum), "objectKey": this.objectKey, "fieldKey": this.fieldKey};
    }

    clearAllRuleSelection() {
        this.ruleSelected = false;
        this.template.querySelector(this.constants.RULE_TILE_QUERY_SELECTOR).classList.remove(this.constants.RULE_SELECTION_CLASS);
        this.dispatchEvent(new CustomEvent("clear", this.getEventObject()));
    }

    @api
    clearRuleSelection() {
        if(this.ruleSelected) {
            this.ruleSelected = false;
            this.template.querySelector(this.constants.RULE_TILE_QUERY_SELECTOR).classList.remove(this.constants.RULE_SELECTION_CLASS);
        }
    }
}