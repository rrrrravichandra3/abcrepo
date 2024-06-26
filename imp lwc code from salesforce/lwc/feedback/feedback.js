import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import feedbackLabel from "@salesforce/label/c.feedback";

export default class Feedback extends LightningElement {
    labels = {feedbackLabel};
}