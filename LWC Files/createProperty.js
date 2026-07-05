import { LightningElement } from 'lwc';
import createPropertyWithImages from '@salesforce/apex/PropertyCreateController.createPropertyWithImages';

export default class CreateProperty extends LightningElement {

    propertyRecord = {};
    base64Images = [];
    fileNames = [];
    errorMessage;

    typeOptions = [
        { label: 'Residential', value: 'Residential' },
        { label: 'Commercial', value: 'Commercial' }
    ];
    furnishingOptions = [
        { label: 'Furnished', value: 'Furnished' },
        { label: 'Semi-Furnished', value: 'Semi-Furnished' },
        { label: 'Unfurnished', value: 'Unfurnished' }
    ];
    statusOptions = [
        { label: 'Occupied', value: 'Occupied' },
        { label: 'Available', value: 'Available' }
    ];

    get fileNamesDisplay() {
        return this.fileNames.join(', ');
    }

    handleChange(event) {
        const fieldName = event.target.dataset.field;
        this.propertyRecord = { ...this.propertyRecord, [fieldName]: event.target.value };
    }

    
    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                resolve(base64);
            };
            reader.onerror = () => reject(reader.error);
            reader.readAsDataURL(file);
        });
    }

    async handleFilesChange(event) {
        const files = event.target.files;
        if (!files || files.length === 0) {
            this.base64Images = [];
            this.fileNames = [];
            return;
        }

        try {
            
            const base64Results = await Promise.all(
                Array.from(files).map(file => this.readFileAsBase64(file))
            );

            
            this.base64Images = base64Results;
            this.fileNames = Array.from(files).map(file => file.name);
            this.errorMessage = '';
        } catch (err) {
            this.errorMessage = 'Something went wrong reading the file(s). Please try again.';
        }
    }

    checkRequiredFields() {
        const inputs = this.template.querySelectorAll('lightning-input, lightning-textarea, lightning-combobox');
        let allValid = true;
        inputs.forEach(input => {
            if (!input.reportValidity()) {
                allValid = false;
            }
        });
        return allValid;
    }

    handleSave() {
        if (!this.checkRequiredFields()) {
            this.errorMessage = 'Please fill all required fields.';
            return;
        }

        if (this.fileNames.length === 0) {
            this.errorMessage = 'Please upload at least one image.';
            return;
        }

        createPropertyWithImages({
            prop: this.propertyRecord,
            base64Images: this.base64Images,
            fileNames: this.fileNames
        })
        .then(() => {
            this.errorMessage = '';
            alert('Property saved successfully with images!');
            
            this.propertyRecord = {};
            this.base64Images = [];
            this.fileNames = [];
        })
        .catch(error => {
            this.errorMessage = error.body ? error.body.message : 'Save failed.';
        });
    }
}
