import { LightningElement, api, wire } from 'lwc';
import getDataFromContent from '@salesforce/apex/SocialMediaContentController.getDataFromContent';
import sendComment from '@salesforce/apex/SocialMediaContentController.sendComment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

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

////////////////////////parent on  reply handling/////////////////////////////////////////////////////
HandleOnParentReply(event) {
        const clickedId = event.currentTarget.dataset.id;
        console.log('Clicked ID:', clickedId);
        console.log('Data before toggle:', JSON.stringify(this.data, null, 2));
        this.data = this.data.map(record => {                                   ///button on off
            const recordId = record.Id || record.id;
            return {
                ...record,
                showParentReply: recordId === clickedId ? !record.showParentReply : false
                
            };
            
        });
        
    }


    //////////////////////////////////onclick handlers for cancel/////////////////////////////////////////////////////


onReplyParentCancel(event) {
    this.data = this.data.map(record => {
        return {
            ...record,
            showParentReply: false
        };
    });
}


    ////////////////////////////////////////reply handling/////////////////////////////////////////////////////
//      replyText = "";
//  onReplyParentSubmit(event) {
//     console.log('Reply submitted for content ID:', event.currentTarget.dataset.platformInteractionId);
//         var replyInputValues = this.template.querySelectorAll("lightning-textarea");

//         replyInputValues.forEach(function (elementVal) {
//             if (elementVal.name == event.currentTarget.dataset.platformInteractionId) {
//                 this.replyText = elementVal.value;
//                 console.log(this.replyText);
//             }
//         }, this);

       
        
//         if (this.replyText == "") {
//             this.showToast('Error', 'Please enter a reply', 'error');
//         } else {
//             sendComment({
//                 id: event.currentTarget.dataset.platformInteractionId,
//                 message: this.replyText,
//                 platformName: event.currentTarget.dataset.platform,
//                 commentType: "comment"
//             })
        
//             this.HandleOnParentReply(event);
//             this.replyText = "";
//             this.showToast('Success', 'Reply sent successfully', 'success');
//             console.log('Reply sent successfully');   
//         }  
//     }


replyText = "";

test(event) {
    console.log('Test button clicked');
    console.log('dataset data', JSON.stringify(event.target.dataset));
    console.log('Reply submitted for content ID:', event.currentTarget.dataset.id);

    console.log('Reply submitted for content ID:', parentId, 'on platform:', platformName);
    console.log('Element name:', elementVal.name, 'Value:', event.currentTarget.dataset.contentId);
}

async onReplyParentSubmit(event) {
    
    const parentId = event.currentTarget.dataset.contentId;
    const platformName = event.currentTarget.dataset.platform;
    

    const replyInputValues = this.template.querySelectorAll("lightning-textarea");
    replyInputValues.forEach((elementVal) => {
        
        
        if (elementVal.name == event.currentTarget.dataset.contentId) {
            this.replyText = elementVal.value;
            console.log('Reply text:', this.replyText);
        }
    });

  

    if (!this.replyText || this.replyText.trim() === "") {
        console.warn('No reply entered');
        this.showToast('Error', 'Please enter a reply', 'error');
        return;
    }

 

    try {
        await sendComment({
            id: parentId,
            message: this.replyText,
            platformName: platformName,
            commentType: "comment"
        });
        try{
        // Ensure event.currentTarget.dataset is populated correctly
        // If not, try event.target.dataset as a fallback
        const dataset = event.currentTarget?.dataset && Object.keys(event.currentTarget.dataset).length > 0
            ? event.currentTarget.dataset
            : event.target?.dataset || {};

        // Log dataset for debugging
        console.log('Dataset used for HandleOnParentReply:', dataset);

        // Create a synthetic event with the correct dataset if needed
        const syntheticEvent = {
            currentTarget: {
            dataset: dataset
            }
        };

        this.HandleOnParentReply(syntheticEvent);}
        catch(error){
            console.error('Error handling parent reply:', error);
        }
        this.replyText = "";
        this.showToast('Success', 'Reply sent successfully', 'success');
        console.log('Reply sent successfully');
    } catch (error) {
        console.error('Error sending reply:', error);
        this.showToast('Error', 'Failed to send reply', 'error');
    }
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
    ///////////////////////////////////////////////////////////////////////////////////

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
      
    }
}