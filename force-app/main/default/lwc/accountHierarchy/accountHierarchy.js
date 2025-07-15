import { api, LightningElement, wire, track } from 'lwc';
import getParentAccountsWithChildCount from '@salesforce/apex/SocialMediaContentController.getParentAccountsWithChildCount';
import getChildAccountsWithContentTypeCountsByParentId from '@salesforce/apex/SocialMediaContentController.getChildAccountsWithContentTypeCountsByParentId';


export default class accountHierarchy extends LightningElement {
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Variables for the left body component
    parentAccount = {};
    parentAccounts = [];
    showParentModal = false;

    ///////////////////////////////////////////PARENT ACCOUNT JS/////////////////////////////////////////////////////
    async connectedCallback() {
        // Fetch parent accounts with child count
        try {
            const accounts = await getParentAccountsWithChildCount();
            // Map Apex keys to JS keys for consistency
            this.parentAccounts = accounts.map(acc => ({
                id: acc.Id,
                name: acc.Name,
                childCount: acc.ChildCount
            }));
            if (this.parentAccounts.length > 0) {
                this.parentAccount = this.parentAccounts[0];
            }
        } catch (error) {

        }
    }

    handleParentClick() {
        this.showParentModal = true;
    }

    closeParentModal() {
        this.showParentModal = false;
    }

    selectParentAccount(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selected = this.parentAccounts.find(acc => acc.id === selectedId);
        if (selected) {
            this.parentAccount = selected;
            this.selectedId = selectedId;
            this.fetchChildAccounts();
        }
        this.showParentModal = false;
    }

    ////////////////////////////////////////////////////////////PARENT ACCOUNT JS DND /////////////////////////////////////////////////////////////////////////////



    //////////////////////////////////////TEST//////////////////////////////
    testButton() {
        console.log(this.selectedId);
        this.fetchChildAccounts();
    }

    ////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////CHILD ACCOUNT JS/////////////////////////////////////////////////////
   

    
    @track childAccounts = [];
    @track error;
    @track selectedId; //

async fetchChildAccounts() {
        if (this.selectedId) {
            try {
                const result = await getChildAccountsWithContentTypeCountsByParentId({ 
                    parentId: this.selectedId 
                });
                
                // The Apex method returns a Map with 'Children' key
                this.childAccounts = result.Children ? result.Children.map(acc => {
                    // Process ContentTypesWithCount to extract individual counts
                    const contentTypes = acc.ContentTypesWithCount || [];
                    const postObj = contentTypes.find(ct => ct.ContentType === 'post');
                    const reelObj = contentTypes.find(ct => ct.ContentType === 'reel');
                    const reviewObj = contentTypes.find(ct => ct.ContentType === 'review');
                    const storyObj = contentTypes.find(ct => ct.ContentType === 'story');
                    const tweetObj = contentTypes.find(ct => ct.ContentType === 'tweet');
                    const videoObj = contentTypes.find(ct => ct.ContentType === 'video');
                    
                    return {
                        Id: acc.Id,
                        Name: acc.Name,
                        ContentTypesWithCount: acc.ContentTypesWithCount,
                        postCount: postObj ? postObj.Count : 0,
                        reelCount: reelObj ? reelObj.Count : 0,
                        reviewCount: reviewObj ? reviewObj.Count : 0,
                        storyCount: storyObj ? storyObj.Count : 0,
                        tweetCount: tweetObj ? tweetObj.Count : 0,
                        videoCount: videoObj ? videoObj.Count : 0,
                    };
                }) : [];
                
                this.error = undefined;
            } catch (error) {
                console.error('Error fetching child accounts:', error);
                this.error = error.body?.message || error.message;
                this.childAccounts = [];
            }
        } else {
            this.childAccounts = [];
        }
    }

    // Method to handle parent selection change
    handleParentChange(event) {
        this.selectedId = event.target.value;
        // If using imperative method, call fetchChildAccounts here
        // this.fetchChildAccounts();
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////c/dataDisplayTale
    @api selectedPlatform = '';

    get updateSelectedPlatform() {
        if (this.selecetedPlatform !== '') {
            return this.fakedata
        }
        else {
            const fakedata1 = this.fakedata.filter(item => item.source === this.selectedPlatform);
            return fakedata1;
        }
    }

    // /////////////////////////////////////////////////////////////////
}