import { LightningElement } from 'lwc';

export default class SocialMediaSite extends LightningElement {

    testAnalytics() {
        console.log('Social Media Site Test Analytics');
    }

// this is a test function to check the analytics of the social media site


testSchedule(){
    console.log('Social Media Site Test Schedule');
}

showRightBody = false;
// this is a test function to check the schedule of the social media site
toggleRightBody() {
    this.showRightBody = !this.showRightBody;
}
}