import { LightningElement, api } from 'lwc';

export default class DataDisplayTale extends LightningElement {
/////////////////////////varaiabel from chile to parent to child/////////////////////////////////////////////////////
    @api selectedPlatform = ''; 
    @api selectedDate = '';
    @api selectedItem = '';
    @api searchTerm = '';
    @api custombuttonPlatform = '';
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    // Sample data for demonstration
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
            date: '2024-06-18',
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
            date: '2024-06-17',
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
            id: '4',
            author: 'Linda Park',
            source: 'Twitter',
            date: '2024-06-16',
            sentiment: 'negative',
            message: 'Disappointed with the battery life of my new iPad.',
            analysis: {
                contentType: 'Tweet',
                intent: 'Complaint',
                urgency: 'High',
                engagement: 45,
                confidence: 90,
                action: 'Escalate to support team'
            }
        },
        {
            id: '5',
            author: 'Tech Guru',
            source: 'YouTube',
            date: '2024-06-15',
            sentiment: 'positive',
            message: 'Unboxing and review of the latest Apple Watch!',
            analysis: {
                contentType: 'Video Review',
                intent: 'Product Review',
                urgency: 'Low',
                engagement: 320,
                confidence: 92,
                action: 'Thank creator'
            }
        },
        {
            id: '6',
            author: 'Emily Davis',
            source: 'Instagram',
            date: '2024-06-14',
            sentiment: 'positive',
            message: 'Loving my new AirPods Pro!',
            analysis: {
                contentType: 'Post with Image',
                intent: 'Product Endorsement',
                urgency: 'Low',
                engagement: 88,
                confidence: 85,
                action: 'Like and comment'
            }
        },
        {
            id: '7',
            author: 'John Smith',
            source: 'Google',
            date: '2024-06-13',
            sentiment: 'negative',
            message: 'Store was closed during business hours.',
            analysis: {
                contentType: 'Review',
                intent: 'Complaint',
                urgency: 'High',
                engagement: 5,
                confidence: 80,
                action: 'Apologize and explain'
            }
        },
        {
            id: '8',
            author: 'Gadget News',
            source: 'Twitter',
            date: '2024-06-12',
            sentiment: 'neutral',
            message: 'Apple announces new Mac Studio.',
            analysis: {
                contentType: 'Tweet',
                intent: 'Announcement',
                urgency: 'Low',
                engagement: 200,
                confidence: 88,
                action: 'Retweet'
            }
        },
        {
            id: '9',
            author: 'Priya Patel',
            source: 'Facebook',
            date: '2024-06-11',
            sentiment: 'positive',
            message: 'Great deals on iPhones at the Apple Store!',
            analysis: {
                contentType: 'Post',
                intent: 'Promotion',
                urgency: 'Medium',
                engagement: 67,
                confidence: 86,
                action: 'Share post'
            }
        },
        {
            id: '10',
            author: 'Carlos Rivera',
            source: 'Instagram',
            date: '2024-06-10',
            sentiment: 'positive',
            message: 'Just bought my first MacBook!',
            analysis: {
                contentType: 'Story',
                intent: 'Purchase',
                urgency: 'Low',
                engagement: 34,
                confidence: 83,
                action: 'Congratulate'
            }
        },
        {
            id: '11',
            author: 'Anna Lee',
            source: 'Google',
            date: '2024-06-09',
            sentiment: 'negative',
            message: 'Had to wait too long for service.',
            analysis: {
                contentType: 'Review',
                intent: 'Complaint',
                urgency: 'High',
                engagement: 9,
                confidence: 81,
                action: 'Offer apology and discount'
            }
        },
        {
            id: '12',
            author: 'Mobile Trends',
            source: 'YouTube',
            date: '2024-06-08',
            sentiment: 'positive',
            message: 'Top 5 features of iOS 18!',
            analysis: {
                contentType: 'Video',
                intent: 'Education',
                urgency: 'Low',
                engagement: 410,
                confidence: 93,
                action: 'Comment and like'
            }
        },
        {
            id: '13',
            author: 'Sophie Turner',
            source: 'Facebook',
            date: '2024-06-07',
            sentiment: 'neutral',
            message: 'Thinking about switching to iPhone.',
            analysis: {
                contentType: 'Post',
                intent: 'Consideration',
                urgency: 'Low',
                engagement: 22,
                confidence: 75,
                action: 'Provide info'
            }
        },
        {
            id: '14',
            author: 'David Kim',
            source: 'Twitter',
            date: '2024-06-06',
            sentiment: 'positive',
            message: 'Apple support is always helpful!',
            analysis: {
                contentType: 'Tweet',
                intent: 'Praise',
                urgency: 'Low',
                engagement: 56,
                confidence: 89,
                action: 'Thank user'
            }
        },
        {
            id: '15',
            author: 'Olivia Brown',
            source: 'Instagram',
            date: '2024-06-05',
            sentiment: 'positive',
            message: 'My iPad is perfect for drawing.',
            analysis: {
                contentType: 'Post with Image',
                intent: 'Product Endorsement',
                urgency: 'Low',
                engagement: 77,
                confidence: 84,
                action: 'Like and comment'
            }
        },
        {
            id: '16',
            author: 'Tech Reviews',
            source: 'YouTube',
            date: '2025-06-04',
            sentiment: 'neutral',
            message: 'Comparing iPhone 15 and Samsung S24.',
            analysis: {
                contentType: 'Video Review',
                intent: 'Comparison',
                urgency: 'Low',
                engagement: 290,
                confidence: 90,
                action: 'Engage in comments'
            }
        },
        {
            id: '17',
            author: 'Megan Fox',
            source: 'Google',
            date: '2024-07-03',
            sentiment: 'positive',
            message: 'Fast and friendly service!',
            analysis: {
                contentType: 'Review',
                intent: 'Praise',
                urgency: 'Low',
                engagement: 14,
                confidence: 88,
                action: 'Thank user'
            }
        },
        {
            id: '18',
            author: 'Lucas White',
            source: 'Facebook',
            date: '2024-06-02',
            sentiment: 'negative',
            message: 'Received a defective charger.',
            analysis: {
                contentType: 'Post',
                intent: 'Complaint',
                urgency: 'High',
                engagement: 11,
                confidence: 82,
                action: 'Offer replacement'
            }
        },
        {
            id: '19',
            author: 'Emma Green',
            source: 'Instagram',
            date: '2024-06-01',
            sentiment: 'positive',
            message: 'Love the camera on my new iPhone!',
            analysis: {
                contentType: 'Story',
                intent: 'Product Endorsement',
                urgency: 'Low',
                engagement: 65,
                confidence: 86,
                action: 'Like and comment'
            }
        },
        {
            id: '20',
            author: 'Gadget Insider',
            source: 'Twitter',
            date: '2024-05-31',
            sentiment: 'neutral',
            message: 'Rumors about upcoming Apple event.',
            analysis: {
                contentType: 'Tweet',
                intent: 'Speculation',
                urgency: 'Low',
                engagement: 120,
                confidence: 78,
                action: 'Monitor'
            }
        },
        {
            id: '21',
            author: 'Noah Black',
            source: 'Google',
            date: '2024-05-30',
            sentiment: 'positive',
            message: 'Great experience at the Genius Bar.',
            analysis: {
                contentType: 'Review',
                intent: 'Praise',
                urgency: 'Low',
                engagement: 18,
                confidence: 85,
                action: 'Thank user'
            }
        },
        {
            id: '22',
            author: 'Sophia Martinez',
            source: 'Facebook',
            date: '2024-05-29',
            sentiment: 'negative',
            message: 'My order was delayed.',
            analysis: {
                contentType: 'Post',
                intent: 'Complaint',
                urgency: 'Medium',
                engagement: 13,
                confidence: 80,
                action: 'Apologize and update'
            }
        },
        {
            id: '23',
            author: 'James Wilson',
            source: 'Instagram',
            date: '2024-05-28',
            sentiment: 'positive',
            message: 'Apple Store has the best accessories.',
            analysis: {
                contentType: 'Post with Image',
                intent: 'Product Endorsement',
                urgency: 'Low',
                engagement: 54,
                confidence: 83,
                action: 'Like and comment'
            }
        },
        {
            id: '24',
            author: 'Tech World',
            source: 'YouTube',
            date: '2024-05-27',
            sentiment: 'neutral',
            message: 'Hands-on with the new iPad Air.',
            analysis: {
                contentType: 'Video',
                intent: 'Product Review',
                urgency: 'Low',
                engagement: 370,
                confidence: 91,
                action: 'Comment and like'
            }
        },
        {
            id: '25',
            author: 'Grace Lee',
            source: 'Google',
            date: '2024-05-26',
            sentiment: 'positive',
            message: 'Staff was knowledgeable and helpful.',
            analysis: {
                contentType: 'Review',
                intent: 'Praise',
                urgency: 'Low',
                engagement: 21,
                confidence: 87,
                action: 'Thank user'
            }
        }
    ];

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////c/dataDisplayTale

////////////to filter data based on selected platform/////////////////////////////////////////////////////
    
    get filteredData() {
        // If no filters are selected, return all data
        const hasPlatform = this.selectedPlatform && this.selectedPlatform !== 'Platforms';
        const hasDate = this.selectedDate && this.selectedDate !== 'time';
        const hasItem = this.selectedItem && this.selectedItem !== 'items';
        const hasSearch = this.searchTerm && this.searchTerm.trim().length > 0;
        console.log('this is an item from ', this.searchTerm);

        // If nothing is selected, return all data
        if (!hasPlatform && !hasDate && !hasItem && !hasSearch) {
            return this.fakeData;
        }

        return this.fakeData.filter(item => {
            // Platform filter
            let platformMatch = true;
            if (hasPlatform) {
                platformMatch = item.source.toLowerCase().includes(this.selectedPlatform.toLowerCase());
            }

            // Date filter
            let dateMatch = true;
            if (hasDate) {
                const today = new Date();
                const itemDate = new Date(item.date);
                if (this.selectedDate === '24') {
                    // Last 24 hours
                    const diff = (today - itemDate) / (1000 * 60 * 60);
                    dateMatch = diff <= 24;
                } else if (this.selectedDate === '7') {
                    // Last 7 days
                    const diff = (today - itemDate) / (1000 * 60 * 60 * 24);
                    dateMatch = diff <= 7;
                } else if (this.selectedDate === '30') {
                    // Last 30 days
                    const diff = (today - itemDate) / (1000 * 60 * 60 * 24);
                    dateMatch = diff <= 30;
                } else if (this.selectedDate === 'year') {
                    // This year
                    dateMatch = itemDate.getFullYear() === today.getFullYear();
                }
            }

            // Item filter
            let itemMatch = true;
            if (hasItem) {
                if (this.selectedItem === 'posts') {
                    itemMatch = item.analysis.contentType.toLowerCase().includes('post');
                } else if (this.selectedItem === 'reviews') {
                    itemMatch = item.analysis.contentType.toLowerCase().includes('review');
                }
            }

            // Search filter (search across all string fields)
            let searchMatch = true;
            if (hasSearch) {
                const term = this.searchTerm.toLowerCase();
                searchMatch =
                    (item.author && item.author.toLowerCase().includes(term)) ||
                    (item.source && item.source.toLowerCase().includes(term)) ||
                    (item.sentiment && item.sentiment.toLowerCase().includes(term)) ||
                    (item.message && item.message.toLowerCase().includes(term)) ||
                    (item.date && item.date.toLowerCase().includes(term)) ||
                    (item.analysis && (
                        (item.analysis.contentType && item.analysis.contentType.toLowerCase().includes(term)) ||
                        (item.analysis.intent && item.analysis.intent.toLowerCase().includes(term)) ||
                        (item.analysis.urgency && item.analysis.urgency.toLowerCase().includes(term)) ||
                        (item.analysis.action && item.analysis.action.toLowerCase().includes(term)) ||
                        (item.analysis.engagement !== undefined && item.analysis.engagement.toString().toLowerCase().includes(term)) ||
                        (item.analysis.confidence !== undefined && item.analysis.confidence.toString().toLowerCase().includes(term))
                    ));
            }

            // Only return items that match all selected filters
            return platformMatch && dateMatch && itemMatch && searchMatch;
        });
    }


    // Watch for changes to custombuttonPlatform and filter data accordingly
    // Use this getter in your template or wherever you need the filtered data based on custombuttonPlatform.
    // It will automatically re-evaluate whenever any reactive property it depends on changes.
    get customButtonFilteredData() {
        if (!this.custombuttonPlatform || this.custombuttonPlatform === 'Platforms') {
            return this.filteredData;
        }
        return this.filteredData.filter(item =>
            item.source.toLowerCase().includes(this.custombuttonPlatform.toLowerCase())
        );
    }
}
