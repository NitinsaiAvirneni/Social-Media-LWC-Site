import { LightningElement, track} from 'lwc';
import runSocialMediaSync from '@salesforce/apex/SocialMediaController.runSocialMediaSync';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class socialMediaHome extends LightningElement {
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////c/dataDisplayTale

////////////////////Variables for the social media site/////////////////////////////////////////////////////
    selectedPlatform;
    selectedDate;
    selectedItem;
    searchTerm;
    @ track showParentModal = false;
    custombuttonPlatform;
    subaccountId ;
////////////////////ai analysis variable/////////////////////////////////////////////////////
    showAnalyis =false; // Variable to control AI analysis visibility
    recordId; // Variable to hold the record ID for child component
 ShowAIAnalysis() {
        this.showAnalyis = !this.showAnalyis;
       }
setchildaccountid(event) {
    this.subaccountId = event.detail.childId;////get id from child component accountHierarchy
        this.recordId=this.subaccountId;////get id from child component piechart lwc
  }////send and call dataTableDisplay component

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    testAnalytics() {
        console.log('Social Media Site Test Analytics');
    }

// this is a test function to check the analytics of the social media site                   ///these are for buttons in the header
openParentModal() {
        this.showParentModal = true;
        this.showToast('Info', 'Batch class is running...');
        runSocialMediaSync()
        .then(() => {
                console.log('Social media sync completed');
            })
            .catch(error => {
                console.error('Error syncing:', error);
            });

        // Use setTimeout to wait for modal DOM to render
        setTimeout(() => this.loadParentChart(), 0);
    }

 showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

testSchedule(){
    console.log('Social Media Site Test Schedule');
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

showRightBody = false;
// this is a test function to check the schedule of the social media site
toggleRightBody() {                                           ////these are  filter on/off in the header
    this.showRightBody = !this.showRightBody;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////custom event from filter component to left body component//////////////////////////////////////////////////
handleselectedPlatformChange(event) {
    this.selectedPlatform = event.detail.value;
    this.selectedDate = event.detail.date;
    this.selectedItem = event.detail.item;
    this.searchTerm = event.detail.search;

}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
handlefbClick() {
    this.custombuttonPlatform = 'Facebook';
    console.log('Facebook button clicked ' + this.custombuttonPlatform);
    this.handlelcustomfilterClick(); 
}
 
handleimClick(){
    this.custombuttonPlatform = 'Instagram';
    console.log('Instagram button clicked'+ this.custombuttonPlatform);
    this.handlelcustomfilterClick();    
}

handleYtClick() {
    this.custombuttonPlatform = 'YouTube';
    console.log('YouTube button clicked'    + this.custombuttonPlatform);
    this.handlelcustomfilterClick();
}
handletwClick() {   
    this.custombuttonPlatform = 'Twitter';
    console.log('Twitter button clicked' + this.custombuttonPlatform);
    this.handlelcustomfilterClick();
}       
handlegeClick() {
    this.custombuttonPlatform = 'Google';
    console.log('Google button clicked' + this.custombuttonPlatform);
    this.handlelcustomfilterClick();
}   

////////////////////////////////////////////////////////////////////////////////////////////////////c/dataDisplayTale
handlelcustomfilterClick() {
    this.ref.childRef.filteredData();}

}////////////calls filter bution in dataTableDisplay component to filter the data based on selected platform
/////////////////////////////////////////////////////////