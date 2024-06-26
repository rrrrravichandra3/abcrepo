import { LightningElement, api } from 'lwc';

export default class Te_RoleCard extends LightningElement {
    @api title;
    @api grade;
    @api skillsList = [];
    @api skillsMissingList = [];
    @api salaryRange;
    @api team;
    @api openPositions;
    buttonText = 'View Open Positions'

    connectedCallback(){
        this.buttonText += ' ('+this.openPositions+')';
    }

    get hasOpenPositions(){
        return this.openPositions == 0;
    }
}