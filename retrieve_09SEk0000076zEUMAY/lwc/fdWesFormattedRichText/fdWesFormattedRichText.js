/*
    Implementation of the WES Rich Text Formatted component
    Maps WES variant name to Lightning variant name
    WES: https://web-experience-subsystem-prd.herokuapp.com/?path=/docs/website-experience-subsystem-foundation-typography--all

    CSS overrides defined in static file: /styles/WesFormattedRichText.css

    Example Usage: 

    <c-fd-wes-formatted-rich-text value={value}></c-fd-wes-formatted-rich-text>

 */
import { LightningElement, api } from 'lwc';
export default class FdWesFormattedRichText extends LightningElement {
  @api value;
  @api className;
  @api disableLinkify = false;
}