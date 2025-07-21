import { LightningElement, api, wire, track } from 'lwc';
import getContentDetails from '@salesforce/apex/SocialMediaContentController.getContentDetails';
import getInteractionsByContentId from '@salesforce/apex/SocialMediaContentController.getInteractionsByContentId';

export default class SocialMediaContentViewer extends LightningElement {
    @api recordId; // passed from record page or parent
    @track content = {};
    @track interactions = [];
    viewOriginal=true;

    handleClose() {
        this.dispatchEvent(new CustomEvent('modalclosed', { detail: false }));
    }

    @wire(getContentDetails, { contentId: '$recordId' })
    wiredContent({ error, data }) {
        if (data) this.content = data;
    }

    @wire(getInteractionsByContentId, { contentId: '$recordId' })
    wiredInteractions({ error, data }) {
        if (data) this.interactions = data;
    }

    handleReply(event) {
        const id = event.target.dataset.id;
        alert('Reply to interaction ID: ' + id);
        // You could open a modal or redirect to a reply form here.
    }
}
