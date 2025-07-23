import { LightningElement, track, api } from 'lwc';
import ChartJs from '@salesforce/resourceUrl/ChartJS';
import { loadScript } from 'lightning/platformResourceLoader';

import getInteractionSummaryByParent from '@salesforce/apex/SocialMediaContentController.getInteractionSummaryByParent';
import getPlatformBreakdownByAccount from '@salesforce/apex/SocialMediaContentController.getPlatformBreakdownByAccount';

export default class SocialMediaPieAnalytics extends LightningElement {
    @api recordId; // Parent Account Id
    @track showParentModal = false;
    @track showChildModal = false;
    @track childChartTitle = '';

    chartJsInitialized = false;
    parentChart;
    childChart;

    connectedCallback() {
        if (!this.chartJsInitialized) {
            loadScript(this, ChartJs)
                .then(() => {
                    this.chartJsInitialized = true;
                })
                .catch(error => console.error('ChartJS load error', error));
        }
    }

    openParentModal() {
        this.showParentModal = true;

        // Use setTimeout to wait for modal DOM to render
        setTimeout(() => this.loadParentChart(), 0);
    }

    closeParentModal() {
        this.showParentModal = false;
        this.showChildModal = false;

        if (this.parentChart) this.parentChart.destroy();
        if (this.childChart) this.childChart.destroy();
    }

    closeChildModal() {
        this.showChildModal = false;
        if (this.childChart) this.childChart.destroy();
    }

    loadParentChart() {
        getInteractionSummaryByParent({ parentId: this.recordId })
            .then(data => {
                const canvas = this.template.querySelector('.parent-chart');
                const ctx = canvas.getContext('2d');

                if (this.parentChart) this.parentChart.destroy();

                this.parentChart = new window.Chart(ctx, {
                    type: 'pie',
                    data: {
                        labels: data.map(d => d.label),
                        datasets: [{
                            data: data.map(d => d.value),
                            backgroundColor: this.generateColors(data.length)
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: {
                            legend: { position: 'bottom' },
                            title: { display: true, text: 'Interactions by Child Account' }
                        },
                        onClick: (event, elements) => {
                            if (elements.length > 0) {
                                const index = elements[0].index;
                                const selected = data[index];
                                this.loadChildChart(selected.id, selected.label);
                            }
                        }
                    }
                });
            });
    }

    loadChildChart(accountId, accountName) {
        getPlatformBreakdownByAccount({ accountId })
            .then(data => {
                this.childChartTitle = `Content Breakdown for ${accountName}`;
                this.showChildModal = true;

                setTimeout(() => {
                    const canvas = this.template.querySelector('.child-chart');
                    const ctx = canvas.getContext('2d');

                    if (this.childChart) this.childChart.destroy();

                    this.childChart = new window.Chart(ctx, {
                        type: 'pie',
                        data: {
                            labels: data.map(d => d.label),
                            datasets: [{
                                data: data.map(d => d.value),
                                backgroundColor: this.generateColors(data.length)
                            }]
                        },
                        options: {
                            responsive: true,
                            plugins: {
                                legend: { position: 'bottom' },
                                title: { display: true, text: this.childChartTitle }
                            }
                        }
                    });
                }, 0);
            });
    }

    generateColors(count) {
        const palette = ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40', '#00A8FF', '#EA2027'];
        return Array.from({ length: count }, (_, i) => palette[i % palette.length]);
    }
}