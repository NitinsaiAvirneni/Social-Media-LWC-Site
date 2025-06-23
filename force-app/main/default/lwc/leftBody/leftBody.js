import { LightningElement } from 'lwc';

export default class LeftBody extends LightningElement {
    stores = [
        {
            id: 1,
            name: 'Apple Store Downtown',
            reviews: 342,
            followers: 15200,
            posts: 156,
            tweets: 234,
            highlight: true,
            status: ['green', 'green', 'green', 'green']
        },
        {
            id: 2,
            name: 'Apple Store Westfield Mall',
            reviews: 198,
            followers: 9800,
            posts: 89,
            tweets: 0,
            highlight: false,
            status: ['green', 'red', 'red', 'green']
        },
        {
            id: 3,
            name: 'Apple Store Northside',
            reviews: 267,
            followers: 12100,
            posts: 134,
            tweets: 189,
            highlight: false,
            status: ['green', 'green', 'green', 'green']
        }
    ];

    // reconfigure the stores data to include a new store by getting the data from the apex or salefroce 
}