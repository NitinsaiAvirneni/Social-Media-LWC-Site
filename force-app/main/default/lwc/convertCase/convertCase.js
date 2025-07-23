import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Update this import to your Apex method for creating a Case
import createCase from '@salesforce/apex/SocialMediaContentController.createCase';

export default class ConvertCase extends LightningElement {
    @api caseData; // Data passed from parent if needed

    @track subject = '';
    @track description = '';
    @track priority = '';
    @track status = '';
    @track origin = '';
    @track email = '';
    @track phone = '';

    show = true;
    showModal = false;

    connectedCallback() {
        if (this.caseData) {
            this.subject = this.caseData.Subject || '';
            this.description = this.caseData.Description || '';
            this.priority = this.caseData.Priority || '';
            this.status = this.caseData.Status || '';
            this.origin = this.caseData.Origin || '';
            this.email = this.caseData.Email || '';
            this.phone = this.caseData.Phone || '';
        }
    }

    handleCancel() {
        this.show = false;
        this.closefirstmodal();
        console.log('Modal closed');
    }

    closefirstmodal() {
        this.dispatchEvent(new CustomEvent('modalclosed', { detail: false }));
    }

    handleConvert() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.closefirstmodal();
    }

    handleChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
    }

    async saveCase() {
        try {
            if (!this.subject) {
                this.dispatchEvent(new ShowToastEvent({
                    title: "Missing Required Fields",
                    message: "Subject is required.",
                    variant: "error"
                }));
                return;
            }
            const caseRecord = {
                Subject: this.subject,
                Description: this.description,
                Priority: this.priority,
                Status: this.status,
                Origin: this.origin,
                SuppliedEmail: this.email,
                SuppliedPhone: this.phone
            };
            await createCase({ caseRecord });
            this.showModal = false;
            this.dispatchEvent(new ShowToastEvent({
                title: "Success",
                message: "Case created successfully.",
                variant: "success"
            }));
            this.closefirstmodal();
        } catch (error) {
            let errorMsg = "Failed to create case.";
            if (error && error.body && error.body.message) {
                errorMsg = `Failed to create case: ${error.body.message}`;
            } else if (error && error.message) {
                errorMsg = `Failed to create case: ${error.message}`;
            }
            this.dispatchEvent(new ShowToastEvent({
                title: "Case Creation Error",
                message: errorMsg,
                variant: "error"
            }));
        }
    }
}