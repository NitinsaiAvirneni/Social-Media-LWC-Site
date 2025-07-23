import { LightningElement, api, wire } from 'lwc';
import getDataFromContent from '@salesforce/apex/SocialMediaContentController.getDataFromContent';

export default class ViewOriginal extends LightningElement {
    @api contentId ; // Set this dynamically as needed
    data = [];
    error;

    @wire(getDataFromContent, { contentId: '$contentId' })
    wiredData({ data, error }) {
        if (data) {
            this.data = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = [];
        }
    }

    get hasData() {
        console.log('Data:', this.data);
        return this.data && this.data.length > 0;
    }
}