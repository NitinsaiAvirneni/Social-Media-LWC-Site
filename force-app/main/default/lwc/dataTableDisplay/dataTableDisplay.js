import { LightningElement, api, track,wire } from 'lwc';
import getDataFromAccount from '@salesforce/apex/SocialMediaContentController.getDataFromAccount';

export default class DataDisplayTale extends LightningElement {
    /////////////////////////varaiabel from chile to parent to child/////////////////////////////////////////////////////
    @api selectedPlatform = '';
    @api selectedDate = '';
    @api selectedItem = '';
    @api searchTerm = '';
    @api custombuttonPlatform = '';
    @api subaccountId; // Account Id

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    test() {
        console.log("subaccount", this.subaccountId);
    }
    @track SMData = [];


    @wire(getDataFromAccount, { accountId: '$subaccountId' })
    wiredData({ error, data }) {
        if (data) {
            this.SMData = data;
            console.log('Updated SMData:', JSON.stringify(this.SMData, null, 2));
        } else if (error) {
            console.error('Error fetching SMData:', error);
        }
    }

    ////////////to filter data based on selected platform/////////////////////////////////////////////////////
    get filteredData() {
        // If no filters are selected, return all data
        const hasPlatform = this.selectedPlatform && this.selectedPlatform !== 'Platforms';
        const hasDate = this.selectedDate && this.selectedDate !== 'time';
        const hasItem = this.selectedItem && this.selectedItem !== 'items';
        const hasSearch = this.searchTerm && this.searchTerm.trim().length > 0;
        console.log('this is an item from ', this.searchTerm);

        // If nothing is selected, return all data
        if (!hasPlatform && !hasDate && !hasItem && !hasSearch) {
            return this.SMData;
        }

        return this.SMData.filter(item => {
            // Platform filter
            let platformMatch = true;
            if (hasPlatform) {
                platformMatch = item.source.toLowerCase().includes(this.selectedPlatform.toLowerCase());
            }

            // Date filter
            let dateMatch = true;
            if (hasDate) {
                const today = new Date();
                const itemDate = new Date(item.date);
                if (this.selectedDate === '24') {
                    // Last 24 hours
                    const diff = (today - itemDate) / (1000 * 60 * 60);
                    dateMatch = diff <= 24;
                } else if (this.selectedDate === '7') {
                    // Last 7 days
                    const diff = (today - itemDate) / (1000 * 60 * 60 * 24);
                    dateMatch = diff <= 7;
                } else if (this.selectedDate === '30') {
                    // Last 30 days
                    const diff = (today - itemDate) / (1000 * 60 * 60 * 24);
                    dateMatch = diff <= 30;
                } else if (this.selectedDate === 'year') {
                    // This year
                    dateMatch = itemDate.getFullYear() === today.getFullYear();
                }
            }

            // Item filter
            let itemMatch = true;
            if (hasItem) {
                if (this.selectedItem === 'posts') {
                    itemMatch = item.analysis.contentType.toLowerCase().includes('post');
                } else if (this.selectedItem === 'reviews') {
                    itemMatch = item.analysis.contentType.toLowerCase().includes('review');
                }
            }

            // Search filter (search across all string fields)
            let searchMatch = true;
            if (hasSearch) {
                const term = this.searchTerm.toLowerCase();
                searchMatch =
                    (item.author && item.author.toLowerCase().includes(term)) ||
                    (item.source && item.source.toLowerCase().includes(term)) ||
                    (item.sentiment && item.sentiment.toLowerCase().includes(term)) ||
                    (item.message && item.message.toLowerCase().includes(term)) ||
                    (item.date && item.date.toLowerCase().includes(term)) ||
                    (item.analysis && (
                        (item.analysis.contentType && item.analysis.contentType.toLowerCase().includes(term)) ||
                        (item.analysis.intent && item.analysis.intent.toLowerCase().includes(term)) ||
                        (item.analysis.urgency && item.analysis.urgency.toLowerCase().includes(term)) ||
                        (item.analysis.action && item.analysis.action.toLowerCase().includes(term)) ||
                        (item.analysis.engagement !== undefined && item.analysis.engagement.toString().toLowerCase().includes(term)) ||
                        (item.analysis.confidence !== undefined && item.analysis.confidence.toString().toLowerCase().includes(term))
                    ));
            }

            // Only return items that match all selected filters
            return platformMatch && dateMatch && itemMatch && searchMatch;
        });
    }

}