import { LightningElement, track } from 'lwc';

export default class RightBody extends LightningElement {
    selectedPlatform = '';
    selectedDate = '';
    selectedItem = '';
    searchTerm = '';


    platformOptions = [
        { label: 'All Platforms', value: 'Platforms' },
        { label: 'Facebook', value: 'facebook' },
        { label: 'Twitter', value: 'twitter' },
        { label: 'Instagram', value: 'instagram' },
        { label: 'LinkedIn', value: 'linkedin' },
        { label: 'YouTube', value: 'youtube' }
    ];

    dateOptions = [
        { label: 'All Time', value: 'time' },
        { label: 'Last 24 Hours', value: '24' },
        { label: 'Last 7 Days', value: '7' },
        { label: 'Last 30 Days', value: '30' },
        { label: 'This Year', value: 'year' }
    ];

    itemOptions = [
        { label: 'All Items', value: 'items' },
        { label: 'Posts', value: 'posts' },
        { label: 'Reviews', value: 'reviews' }
    ];

    handlePlatformChange(event) {
        this.selectedPlatform = event.detail.value;
         // Apply filter when platform changes
        
        
    }

    handleDateChange(event) {
        this.selectedDate = event.detail.value;
    }

    handleItemChange(event) {
        this.selectedItem = event.detail.value;
    }

   applyFilter() {
        console.log('Applying filter with:', {
            platform: this.selectedPlatform,
            date: this.selectedDate,
            item: this.selectedItem
        });
        // Dispatch a custom event to notify parent component about the filter changes
        this.dispatchEvent(new CustomEvent('filterchange', {
            detail: {
                value: this.selectedPlatform,
                date: this.selectedDate,
                item: this.selectedItem,
                search: this.searchTerm
            }
        }));
    }

    handleSearchbarChange(event) {
        this.searchTerm = event.target.value;
        console.log('Search term:', this.searchTerm);
    }
    resetFilters() {
        this.selectedPlatform = '';
        this.selectedDate = '';
        this.selectedItem = '';
        this.searchTerm = '';
        console.log('Filters reset');
        // Dispatch a custom event to notify parent component about the reset
        this.dispatchEvent(new CustomEvent('resetfilters'));
    }

}