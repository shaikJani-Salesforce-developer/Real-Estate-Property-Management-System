import { LightningElement, track } from 'lwc';
import getProperties from '@salesforce/apex/PropertyListController.getProperties';

const COLUMNS = [
    { label: 'Property Name', fieldName: 'Name' },
    { label: 'City', fieldName: 'City__c' },
    { label: 'Type', fieldName: 'Type__c' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Furnishing', fieldName: 'Furnishing_Status__c' },
    { label: 'Rent', fieldName: 'Rent__c', type: 'currency' }
];

export default class PropertyList extends LightningElement {

    columns = COLUMNS;
    @track properties = [];

    pageNumber = 1;
    pageSize = 25;
    totalRecords = 0;

    minRent;
    maxRent;
    availabilityStatus;
    furnishingStatus;

    statusOptions = [
        { label: 'All', value: '' },
        { label: 'Occupied', value: 'Occupied' },
        { label: 'Available', value: 'Available' }
    ];

    furnishingOptions = [
        { label: 'All', value: '' },
        { label: 'Furnished', value: 'Furnished' },
        { label: 'Semi-Furnished', value: 'Semi-Furnished' },
        { label: 'Unfurnished', value: 'Unfurnished' }
    ];

    
    connectedCallback() {
        this.loadProperties();
    }

    
    loadProperties() {
        getProperties({
            pageNumber: this.pageNumber,
            pageSize: this.pageSize,
            minRent: this.minRent,
            maxRent: this.maxRent,
            availabilityStatus: this.availabilityStatus,
            furnishingStatus: this.furnishingStatus
        })
        .then(result => {
            this.properties = result.records;
            this.totalRecords = result.totalRecords;
        })
        .catch(error => {
            console.error('Error loading properties:', error);
        });
    }

    get totalPages() {
        return Math.ceil(this.totalRecords / this.pageSize) || 1;
    }

    get isFirstPage() {
        return this.pageNumber <= 1;
    }

    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    handlePrevious() {
        this.pageNumber = this.pageNumber - 1;
        this.loadProperties();
    }

    handleNext() {
        this.pageNumber = this.pageNumber + 1;
        this.loadProperties();
    }

    
    handleMinRent(event) {
        this.minRent = event.target.value;
        this.pageNumber = 1;
        this.loadProperties();
    }

    handleMaxRent(event) {
        this.maxRent = event.target.value;
        this.pageNumber = 1;
        this.loadProperties();
    }

    handleStatus(event) {
        this.availabilityStatus = event.detail.value;
        this.pageNumber = 1;
        this.loadProperties();
    }

    handleFurnishing(event) {
        this.furnishingStatus = event.detail.value;
        this.pageNumber = 1;
        this.loadProperties();
    }
}