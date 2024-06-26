import { LightningElement, api } from 'lwc';

export default class EinsteinHeader extends LightningElement {
  @api heading;
  @api subHeading;
}