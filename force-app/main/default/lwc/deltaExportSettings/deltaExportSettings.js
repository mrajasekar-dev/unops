// deltaExportSettings.js
import { LightningElement, track } from 'lwc';
import getSettings from '@salesforce/apex/DeltaExportSettingsController.getSettings';
import saveSettings from '@salesforce/apex/DeltaExportSettingsController.saveSettings';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DeltaExportSettings extends LightningElement {
    @track selectedObjects = [];
    @track exportFrequency;
    @track selectedFormats = [];
    @track selectedStorage;

    // Options for objects (Replace with dynamic retrieval if needed)
    objectOptions = [
        { label: 'Account', value: 'Account' },
        { label: 'Contact', value: 'Contact' },
        { label: 'Opportunity', value: 'Opportunity' },
        { label: 'Lead', value: 'Lead' },
        { label: 'Case', value: 'Case' },
        { label: 'CustomObject1__c', value: 'CustomObject1__c' },
        { label: 'CustomObject2__c', value: 'CustomObject2__c' },
        // Add up to 10 objects
    ];

    // Export frequency options
    frequencyOptions = [
        { label: 'Daily', value: 'Daily' },
        { label: 'Weekly', value: 'Weekly' },
        { label: 'Monthly', value: 'Monthly' },
    ];

    // File format options
    formatOptions = [
        { label: 'CSV', value: 'csv' },
        { label: 'TSV', value: 'tsv' },
        { label: 'TXT', value: 'txt' },
        { label: 'XLSX', value: 'xlsx' },
    ];

    // Storage options
    storageOptions = [
        { label: 'Direct Download', value: 'download' },
        { label: 'Google Drive', value: 'gdrive' },
        { label: 'OneDrive', value: 'onedrive' },
        { label: 'SharePoint', value: 'sharepoint' },
        { label: 'Dropbox', value: 'dropbox' },
    ];

    // Load existing settings when component is initialized
    connectedCallback() {
        this.loadSettings();
    }

    // Retrieve settings from Apex controller
    loadSettings() {
        getSettings()
            .then((result) => {
                if (result) {
                    this.selectedObjects = result.SelectedObjects__c ? result.SelectedObjects__c.split(';') : [];
                    this.exportFrequency = result.ExportFrequency__c;
                    this.selectedFormats = result.FileFormats__c ? result.FileFormats__c.split(';') : [];
                    this.selectedStorage = result.StorageOption__c;
                }
            })
            .catch((error) => {
                this.showToast('Error', 'Failed to load settings.', 'error');
                console.error(error);
            });
    }

    // Handlers for input changes
    handleObjectChange(event) {
        this.selectedObjects = event.detail.value;
    }

    handleFrequencyChange(event) {
        this.exportFrequency = event.detail.value;
    }

    handleFormatChange(event) {
        this.selectedFormats = event.detail.value;
    }

    handleStorageChange(event) {
        this.selectedStorage = event.detail.value;
    }

    // Save settings using Apex controller
    saveSettings() {
        if (this.selectedObjects.length > 10) {
            this.showToast('Warning', 'You can select up to 10 objects.', 'warning');
            return;
        }

        saveSettings({
            selectedObjects: this.selectedObjects.join(';'),
            exportFrequency: this.exportFrequency,
            fileFormats: this.selectedFormats.join(';'),
            storageOption: this.selectedStorage,
        })
            .then(() => {
                this.showToast('Success', 'Settings saved successfully.', 'success');
            })
            .catch((error) => {
                this.showToast('Error', 'Failed to save settings.', 'error');
                console.error(error);
            });
    }

    // Utility method to show toast messages
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
            })
        );
    }
}
