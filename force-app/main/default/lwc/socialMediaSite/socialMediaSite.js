import { LightningElement, track } from 'lwc';

export default class SocialMediaSite extends LightningElement {
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////c/dataDisplayTale

////////////////////Variables for the social media site/////////////////////////////////////////////////////
    @track selectedPlatform ;
    @track selectedDate ;
    @track selectedItem ;
    @track searchTerm ;
    @track custombuttonPlatform ;
 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    testAnalytics() {
        console.log('Social Media Site Test Analytics');
    }

// this is a test function to check the analytics of the social media site                   ///these are for buttons in the header


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
    console.log('Facebook button clicked' + this.custombuttonPlatform);
}
 
handleimClick(){
    this.custombuttonPlatform = 'Instagram';
    console.log('Instagram button clicked'+ this.custombuttonPlatform);
}

handleYtClick() {
    this.custombuttonPlatform = 'YouTube';
    console.log('YouTube button clicked'    + this.custombuttonPlatform);
}
handletwClick() {   
    this.custombuttonPlatform = 'Twitter';
    console.log('Twitter button clicked' + this.custombuttonPlatform);
}       
handlegeClick() {
    this.custombuttonPlatform = 'Google';
    console.log('Google button clicked' + this.custombuttonPlatform);
}   
}