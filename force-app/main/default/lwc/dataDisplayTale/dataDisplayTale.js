import { LightningElement } from 'lwc';

export default class DataDisplayTale extends LightningElement {
    fakeData = [
        {
            id: '1',
            author: 'Sarah Johnson',
            source: 'Google',
            date: '2024-06-19',
            sentiment: 'positive',
            message: 'Excellent customer service! The staff helped me find the perfect iPhone case.',
            analysis: {
                contentType: 'Review',
                intent: 'Purchase Interest',
                urgency: 'Medium',
                engagement: 12,
                confidence: 87,
                action: 'Follow up within 2 hours'
            }
        },
        {
            id: '2',
            author: 'Apple Store Downtown',
            source: 'Facebook',
            date: '2024-06-19',
            sentiment: 'positive',
            message: 'Check out the new iPhone 15 Pro features! Available now with trade-in options.',
            analysis: {
                contentType: 'Post with Image',
                intent: 'General Inquiry',
                urgency: 'Medium',
                engagement: 176,
                confidence: 87,
                action: 'Standard response within 24 hours'
            }
        },
        {
            id: '3',
            author: 'Mike Chen',
            source: 'Facebook Comment',
            date: '2024-06-19',
            sentiment: 'neutral',
            message: 'When will you have the new MacBook Pro in stock? I’ve been waiting for weeks.',
            analysis: {
                contentType: 'Comment',
                intent: 'Product Availability',
                urgency: 'Medium',
                engagement: 23,
                confidence: 84,
                action: 'Respond with ETA or offer alternative'
            }
        },

        {
            id: '3',
            author: 'Mike Chen',
            source: 'Facebook Comment',
            date: '2024-06-19',
            sentiment: 'neutral',
            message: 'When will you have the new MacBook Pro in stock? I’ve been waiting for weeks.',
            analysis: {
                contentType: 'Comment',
                intent: 'Product Availability',
                urgency: 'Medium',
                engagement: 23,
                confidence: 84,
                action: 'Respond with ETA or offer alternative'
            }
        },
        {
            id: '3',
            author: 'Mike Chen',
            source: 'Facebook Comment',
            date: '2024-06-19',
            sentiment: 'neutral',
            message: 'When will you have the new MacBook Pro in stock? I’ve been waiting for weeks.',
            analysis: {
                contentType: 'Comment',
                intent: 'Product Availability',
                urgency: 'Medium',
                engagement: 23,
                confidence: 84,
                action: 'Respond with ETA or offer alternative'
            }
        }
    ];


    // @track filter = {
    //     sentiment: '',
    //     source: ''
    // };

    // get sentiments() {
    //     return [
    //         { label: 'All', value: '' },
    //         { label: 'Positive', value: 'positive' },
    //         { label: 'Neutral', value: 'neutral' },
    //         { label: 'Negative', value: 'negative' }
    //     ];
    // }

    // get sources() {
    //     const uniqueSources = [...new Set(this.fakeData.map(item => item.source))];
    //     return [{ label: 'All', value: '' }, ...uniqueSources.map(src => ({ label: src, value: src }))];
    // }

    // handleFilterChange(event) {
    //     const { name, value } = event.target;
    //     this.filter = { ...this.filter, [name]: value };
    // }

    // get filteredData() {
    //     return this.fakeData.filter(item => {
    //         const sentimentMatch = this.filter.sentiment ? item.sentiment === this.filter.sentiment : true;
    //         const sourceMatch = this.filter.source ? item.source === this.filter.source : true;
    //         return sentimentMatch && sourceMatch;
    //     });
    // }
}

