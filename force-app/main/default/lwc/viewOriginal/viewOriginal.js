import { LightningElement, api, wire } from 'lwc';
import getDataFromContent from '@salesforce/apex/SocialMediaContentController.getDataFromContent';

export default class ViewOriginal extends LightningElement {
    @api contentId;
    data = [];
    error;

    @wire(getDataFromContent, { contentId: '$contentId' })
    wiredData({ data, error }) {
        if (data) {
            this.data = data.map(record => ({
                ...record,
                showParentReply: false,///extra variable to track parent reply visibility to data
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = [];
        }
    }

////////////////////////parent reply handling/////////////////////////////////////////////////////
HandleOnParentReply(event) {
        const clickedId = event.currentTarget.dataset.id;
        console.log('parent', clickedId);
        this.data = this.data.map(record => {
            const recordId = record.Id || record.id;
            return {
                ...record,
                showParentReply: recordId === clickedId ? !record.showParentReply : false
                
            };
            
        });
        
    }


    //////////////////////////////////onclick handlers for reply and cancel/////////////////////////////////////////////////////




    get hasData() {
        return this.data && this.data.length > 0;
    }

    // Group data into parentRows with childRows, sorted by CreatedDate
    get parentRows() {
        if (!this.hasData) return [];
        // Sort data by CreatedDate ascending
        const sortedData = [...this.data].sort((a, b) => new Date(a.CreatedDate) - new Date(b.CreatedDate));
        // Parent: Parent_Interaction_Id__c is null/undefined
        const parents = sortedData.filter(item => !item.Parent_Interaction_Id__c);
        return parents.map(parent => ({
            ...parent,
            childRows: sortedData.filter(
                child => child.Parent_Interaction_Id__c === parent.Platform_Interaction_Id__c
            )
        }));
    }





    handleReply(event) {
        const commentId = event.target.dataset.id;
        // Implement your reply logic here, e.g., open a modal or fire an event
        // Example:
        // this.dispatchEvent(new CustomEvent('reply', { detail: { commentId } }));
        // For now, just log:
        console.log('Reply to:', commentId);
    }
}