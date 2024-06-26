import { LightningElement } from 'lwc';

import pageDoesntExistLabel from '@salesforce/label/c.page_doesn_t_exist';

export default class notFound extends LightningElement {
    labels = { pageDoesntExistLabel };
}