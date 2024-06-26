import { LightningElement,api } from 'lwc';

export default class TeCareerPathingNode extends LightningElement {
    @api nodeId;
    @api graph;

    connectedCallback(){
        console.log('Node Id ----> ' +JSON.stringify(this.nodeId));
        console.log('Graph Data ----> ' +JSON.stringify(this.graph));
        console.log('Node Data ------> '+ JSON.stringify(this.graph[this.nodeId]));
    }
    get label() {
        return this.graph[this.nodeId].label;
    }

    get children() {
        return this.graph[this.nodeId].children || [];
    }

    get parents() {
        return this.graph[this.nodeId].parents || [];
    }

    get hasParents() {
        return this.parents && this.parents.length > 0;
    }
}