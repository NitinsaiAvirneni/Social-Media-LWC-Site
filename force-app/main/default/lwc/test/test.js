import { LightningElement, track } from 'lwc';

export default class test extends LightningElement {
    @track records = [
        { id: '1', name: 'Item 1', description: 'Details for Item 1', showDetails: false },
        { id: '2', name: 'Item 2', description: 'Details for Item 2', showDetails: false },
        { id: '3', name: 'Item 3', description: 'Details for Item 3', showDetails: false }
    ];

    handleShowBox(event) {
        const selectedId = event.currentTarget.dataset.id;

        // Toggle visibility for the selected item, hide others
        this.records = this.records.map(record => ({
            ...record,
            showDetails: record.id === selectedId ? !record.showDetails : false
        }));
    }
}
