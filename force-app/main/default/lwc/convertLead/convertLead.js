import { LightningElement, api, track } from 'lwc';
// Make sure the Apex class 'SocialMediaContentController' exists in your org under force-app/main/default/classes/
// If your class name is different, update it accordingly below:
import createLead from '@salesforce/apex/SocialMediaContentController.createLead';

export default class ConvertLead extends LightningElement {
    @api showModal = false;//
    @api leadData; // Data passed from the parent component


    @track firstName = '';
    @track lastName = '';
    @track company = '';
    @track title = '';
    @track email = '';
    @track phone = '';

    show = true;

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

    

    handleCancel() {
        this.show = false;
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('modalclosed', { detail: false }));
        console.log('Modal closed');
    }



    handleConvert() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handleChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
    }

    async saveLead() {
        try {
            const lead = {
                FirstName: this.firstName,
                LastName: this.lastName,
                Company: this.company,
                Title: this.title,
                Email: this.email,
                Phone: this.phone
            };
            await createLead({ lead });
            this.showModal = false;
            this.dispatchEvent(new CustomEvent('leadcreated'));
        } catch (error) {
            // Handle error (show toast, etc.)
        }
    }
}