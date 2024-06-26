import { LightningElement } from 'lwc';

/**
 * @slot header This is the header slot
 * @slot footer This is the footer slot
 * @slot default This is the default slot
 */
export default class PreboardingLayout extends LightningElement {
    enabledFeatures = ["button","card","divider","grid","image","icon","input-checkbox","text-input","select"];
}