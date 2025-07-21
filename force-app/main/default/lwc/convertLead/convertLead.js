import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Make sure the Apex class 'SocialMediaContentController' exists in your org under force-app/main/default/classes/
// If your class name is different, update it accordingly below:
import createLead from '@salesforce/apex/SocialMediaContentController.createLead';

export default class ConvertLead extends LightningElement {
    @api leadData; // Data passed from the parent component


    @track firstName = '';
    @track lastName = '';
    @track company = '';
    @track title = '';
    @track email = '';
    @track phone = '';

    show = true;////this is first modal variable
    showModal = false;// this is second modal variable


    connectedCallback() {
        if (this.leadData) {
            this.firstName = this.leadData.FirstName || '';
            this.lastName = this.leadData.LastName || '';
            this.company = this.leadData.Company || '';
            this.title = this.leadData.Title || '';
            this.email = this.leadData.Email || '';
            this.phone = this.leadData.Phone || '';
        }
    }

    get fullName() {
        return `${this.firstName} ${this.lastName}`;
    }

    //This page has an error. You might just need to refresh it. [ShowToastEvent is not defined] Failing descriptor: {markup://c:convertLead}
    //////////////////////////////////////////first confimation modal/////////////////////////////////////////////////////
    handleCancel() {
        this.show = false;
        this.closefirstmodal()
        console.log('Modal closed');
    }
    ////////////////////////////////////////////////////////////////////////////////////
    closefirstmodal() {
        this.dispatchEvent(new CustomEvent('modalclosed', { detail: false }));
    }

    //////////////////////////////////////////////////////////

    handleConvert() {
        this.showModal = true;
    }
    ///////////////////////////////////////////secound modal close button/////////////////////////////////////////////////////  
    closeModal() {
        this.showModal = false;
        this.closefirstmodal()///also links first modal with secound modal to close both at once
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    handleChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
    }

    async saveLead() {
        try {
            // Validate required fields before calling Apex
            if (!this.firstName || !this.lastName || !this.company) {
                this.dispatchEvent(new ShowToastEvent({
                    title: "Missing Required Fields",
                    message: "First Name, Last Name, and Company are required.",
                    variant: "error"
                }));
                return;
            }
            const lead = {
                FirstName: this.firstName,
                LastName: this.lastName,
                Company: this.company,
                Title: this.title,
                Email: this.email,
                Phone: this.phone
            };
            console.log('Lead data to be saved:', JSON.stringify(lead, null, 2));
            await createLead({ lead });
            this.showModal = false;
            this.dispatchEvent(new ShowToastEvent({
                title: "Success",
                message: "Lead created successfully.",
                variant: "success"
            }));
            this.closefirstmodal(); // Close the first modal after lead creation
        } catch (error) {
            let errorMsg = "Failed to create lead.";
            if (error && error.body && error.body.message) {
                errorMsg = `Failed to create lead: ${error.body.message}`;
            } else if (error && error.message) {
                errorMsg = `Failed to create lead: ${error.message}`;
            }
            this.dispatchEvent(new ShowToastEvent({
                title: "Lead Creation Error",
                message: errorMsg,
                variant: "error"
            }));
        }
    }
}