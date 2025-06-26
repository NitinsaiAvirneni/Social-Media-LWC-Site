import { LightningElement, track } from 'lwc';

export default class RightBody extends LightningElement {
    selectedPlatform = '';
    selectedDate = '';
    selectedItem = '';
    visibleCount = 0;
    totalCount = 8;

    platformOptions = [
        { label: 'All Platforms', value: '' },
        { label: 'Facebook', value: 'facebook' },
        { label: 'Twitter', value: 'twitter' },
        { label: 'Instagram', value: 'instagram' }
    ];

    dateOptions = [
        { label: 'Last 7 Days', value: '7days' },
        { label: 'Last 30 Days', value: '30days' },
        { label: 'This Year', value: 'year' }
    ];

    itemOptions = [
        { label: 'All Items', value: '' },
        { label: 'Posts', value: 'posts' },
        { label: 'Reviews', value: 'reviews' }
    ];

    handlePlatformChange(event) {
        this.selectedPlatform = event.detail.value;
        console.log('Selected Platform:', this.selectedPlatform);
        this.dispatchEvent(new CustomEvent('platformchange',  {detail: { value: this.selectedPlatform }}));
    }

    handleDateChange(event) {
        this.selectedDate = event.detail.value;
    }

    handleItemChange(event) {
        this.selectedItem = event.detail.value;
    }

    loadMore() {
        this.visibleCount = Math.min(this.visibleCount + 2, this.totalCount);
    }

}