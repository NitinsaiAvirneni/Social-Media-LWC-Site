import { LightningElement, api, track, wire } from 'lwc';
import getDataFromAccount from '@salesforce/apex/SocialMediaContentController.getDataFromAccount';
import getSocialMediaContentById from '@salesforce/apex/SocialMediaContentController.getSocialMediaContentById';
import sendComment from '@salesforce/apex/SocialMediaContentController.sendComment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DataDisplayTale extends LightningElement {
    /////////////////////////variables from child to parent to child/////////////////////////////////////////////////////
    @api selectedPlatform = '';
    @api selectedDate = '';
    @api selectedItem = '';
    @api searchTerm = '';
    @api custombuttonPlatform = '';
    @api subaccountId; // Account Id
    @api showAnalyis; // Show AI Analysis

    //////////////////////track variables/////////////////////////////////////////////////////
    @track SMData = []; // Social Media Data

    /////////////////////////////////////////show only to select table variables
    @track selectedLeadItemId; // Track selected lead item ID
    @track selectedCaseItemId; // Track selected case item ID
    @track selectedViewOriginalId; // Track selected item ID for view original

    test(event) {
        console.log("this is ", event.item.id);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @wire(getDataFromAccount, { accountId: '$subaccountId' })
    wiredData({ error, data }) {
        if (data) {
            this.SMData = data.map(record => ({
                ...record,
                allowComment: (record.source === 'Facebook' || record.source === 'Instagram')?true:false,
                showChild: false,
                showReply: false,
                showCase: false,
                showLead: false
            }));
            console.log('Fetched SMData:', JSON.stringify(this.SMData, null, 2));
        } else if (error) {
            console.error('Error fetching SMData:', error);
            this.showToast('Error', 'Error fetching social media data', 'error');
        }
    }

    HandleOnView(event) {
        const clickedId = event.currentTarget.dataset.id;
        this.SMData = this.SMData.map(record => {
            const recordId = record.Id || record.id;
            return {
                ...record,
                showChild: recordId === clickedId ? !record.showChild : false
            };
        });
    }

    HandleOnReply(event) {
        const clickedId = event.currentTarget.dataset.id;
        console.log('61', clickedId);
        this.SMData = this.SMData.map(record => {
            const recordId = record.Id || record.id;
            return {
                ...record,
                showReply: recordId === clickedId ? !record.showReply : false
                
            };
            
        });
        
    }

    HandleOnLead(event) {
        const clickedId = event.currentTarget.dataset.id;
        this.SMData = this.SMData.map(record => {
            const recordId = record.Id || record.id;
            return {
                ...record,
                showLead: recordId === clickedId ? !record.showLead : false
            };
        });
    }

    /////////////////////////////convert to lead/////////////////////////////////////////////////////
    ConvertToLead(event) {
        if (event.detail === false) {
            this.HandleOnLead(event);
        }
    }

    HandleOnCase(event) {
        const clickedId = event.currentTarget.dataset.id;
        this.SMData = this.SMData.map(record => {
            const recordId = record.Id || record.id;
            return {
                ...record,
                showCase: recordId === clickedId ? !record.showCase : false
            };
        });
    }

    ///close child component from parent
    ConvertTocase(event) {
        if (event.detail === false) {
            this.HandleOnCase(event);
        }
    }

    /////////////////reply button//////////////////////
    showReplyCard = false;
    replyText = "";

    onReplyCancel(event) {
        this.HandleOnReply(event);
    }

    onReplySubmit(event) {
        var replyInputValues = this.template.querySelectorAll("lightning-textarea");
        const recordId = event.currentTarget.dataset.id;

        replyInputValues.forEach(function (elementVal) {
            if (elementVal.name == event.currentTarget.dataset.contentId) {
                this.replyText = elementVal.value;
            }
        }, this);
            
        sendComment({
            id: event.currentTarget.dataset.contentId,
            message: this.replyText,
            platformName: event.currentTarget.dataset.platformName,
            commentType: "post"
        })
            .then(() => {
                this.HandleOnReply(event);
                this.replyText = "";
                this.showToast('Success', 'Reply sent successfully', 'success');
                console.log('Reply sent successfully');
            })
            .catch(error => {
                this.showToast('Error', 'Error sending reply', 'error');
                console.error('Error sending reply:', error);
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }


/////////////////////////////filtered DATA Display/////////////////////////////////////////////////////
    
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
                } else if (this.selectedItem === 'reels') {
                    itemMatch = item.analysis.contentType.toLowerCase().includes('reel');
                } else if (this.selectedItem === 'stories') {
                    itemMatch = item.analysis.contentType.toLowerCase().includes('story');
                } else if (this.selectedItem === 'tweets') {
                    itemMatch = item.analysis.contentType.toLowerCase().includes('tweet');
                } else if (this.selectedItem === 'videos') {
                    itemMatch = item.analysis.contentType.toLowerCase().includes('video');
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


    // ///////////////////////////////////DND Filtered data/////////////////////////////////////////////////////
}