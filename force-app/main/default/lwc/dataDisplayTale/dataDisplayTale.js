import { LightningElement, api } from 'lwc';

export default class DataDisplayTale extends LightningElement {
    @api selectedPlatform ;


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



    // get filteredData() {
    //     if (!this.selectedPlatform) {
    //         console.log('No platform selected, returning all data', this.fakeData);
    //         return this.fakeData;
    //     }
    //     else {
    //         console.log('Filtering data for platform:', this.selectedPlatform);
    //     return this.fakeData.filter(item => item.source.includes(this.selectedPlatform));
    // }   

    // }  
    
    get filteredData() {
        if (!this.selectedPlatform) {
            console.log('No platform selected, returning all data', this.fakeData);
            return this.fakeData;
        }
        console.log('Filtering data for platform:', this.selectedPlatform);
        return this.fakeData.filter(item =>
            item.source.toLowerCase().includes(this.selectedPlatform.toLowerCase())
        );
    }
}
