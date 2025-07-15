import { api, LightningElement,wire } from 'lwc';
import getParentAccountsWithChildCount from '@salesforce/apex/SocialMediaContentController.getParentAccountsWithChildCount';
import getChildAccountsWithContentTypeCountsByParentId from '@salesforce/apex/SocialMediaContentController.getChildAccountsWithContentTypeCountsByParentId';


export default class accountHierarchy extends LightningElement {
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Variables for the left body component
    parentAccount = {};
    parentAccounts = [];
    showParentModal = false;

    selectedId = '';

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
    children;
    error;

    @wire(getChildAccountsWithContentTypeCountsByParentId, { parentId: '$selectedId' })
    wiredData({ error, data }) {
        if (data) {
            this.children = JSON.stringify(data.Children);
            console.log('Child accounts fetched successfully:', this.children);
            this.error = undefined;
        } else if (error) {
            this.error = error.body.message || error.message;
            this.children = undefined;
        }
    }

    // async fetchChildAccounts() {
    //     if (this.selectedId) {
    //         try {
    //             const children = await getChildAccountsWithContentTypeCountsByParentId({ parentId: this.selectedId });
    //             this.childAccounts = children.map(acc => {
    //                 // Ensure post and review counts are present, default to 0 if missing
    //                 const contentTypes = acc.ContentTypesWithCount || [];
    //                 const postObj = contentTypes.find(ct => ct.ContentType === 'post');
    //                 const reelObj = contentTypes.find(ct => ct.ContentType === 'reel');
    //                 const reviewObj = contentTypes.find(ct => ct.ContentType === 'review');
    //                 const storyObj = contentTypes.find(ct => ct.ContentType === 'story');
    //                 const tweetObj = contentTypes.find(ct => ct.ContentType === 'tweet');
    //                 const videoObj = contentTypes.find(ct => ct.ContentType === 'video');
    //                 return {
    //                     id: acc.Id,
    //                     name: acc.Name,
    //                     parentId: acc.ParentId,
    //                     parentName: acc.Parent && acc.Parent.Name ? acc.Parent.Name : '',
    //                     postCount: postObj ? postObj.Count : 0,
    //                     reelCount: reelObj ? reelObj.Count : 0,
    //                     reviewCount: reviewObj ? reviewObj.Count : 0,
    //                     storyCount: storyObj ? storyObj.Count : 0,
    //                     tweetCount: tweetObj ? tweetObj.Count : 0,
    //                     videoCount: videoObj ? videoObj.Count : 0,
    //                 };
    //             });
    //         } catch (error) {
    //             // handle error if needed
    //             console.error('Error fetching child accounts:', error);
    //         }
    //     } else {
    //         this.childAccounts = [];
    //     }
    // }



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