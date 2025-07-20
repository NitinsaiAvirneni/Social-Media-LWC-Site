import { LightningElement, api } from 'lwc';

export default class ConvertCase extends LightningElement {
    @api showModal = false;
    @api leadData;

    get fullName() {
        if (!this.leadData) return '';
        return `${this.leadData.FirstName || ''} ${this.leadData.LastName || ''}`;
    }

    handleConvert() {
        // Add your convert logic here
        this.dispatchEvent(new CustomEvent('convert'));
    }

    handleCancel() {
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    closeModal() {
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
}