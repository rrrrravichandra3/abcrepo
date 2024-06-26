import { LightningElement,api } from 'lwc';

export default class TeCareerPathingNodeList extends LightningElement { 
    @api nodes;
    @api graph;

    connectedCallback(){
        //console.log(nodes);
        //console.log(graph)
    }
}