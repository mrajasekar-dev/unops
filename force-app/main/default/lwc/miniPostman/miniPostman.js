import { LightningElement } from 'lwc';
import makeCallout from '@salesforce/apex/MiniPostmanController.makeCallout';
import generateApexClass from '@salesforce/apex/MiniPostmanController.generateApexClass';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MiniPostman extends LightningElement {
    endpoint = '';
    method = 'GET';
    headers = '';
    requestBody = '';
    response = '';

    methodOptions = [
        { label: 'GET', value: 'GET' },
        { label: 'POST', value: 'POST' },
        { label: 'PUT', value: 'PUT' },
        { label: 'DELETE', value: 'DELETE' }
    ];

    connectedCallback() {
        // Load saved values from localStorage on component initialization
        this.loadSavedValues();
    }

    loadSavedValues() {
        this.endpoint = localStorage.getItem('miniPostmanEndpoint') || '';
        this.method = localStorage.getItem('miniPostmanMethod') || 'GET';
        this.headers = localStorage.getItem('miniPostmanHeaders') || '';
        this.requestBody = localStorage.getItem('miniPostmanRequestBody') || '';
    }

    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;

        // Save each field in localStorage
        localStorage.setItem(`miniPostman${field.charAt(0).toUpperCase() + field.slice(1)}`, event.target.value);
    }

    handleCallout() {
        makeCallout({
            endpoint: this.endpoint,
            method: this.method,
            headers: this.headers,
            requestBody: this.requestBody
        })
        .then(response => {
            try {
                // Parse and pretty-print the JSON response
                const parsedResponse = JSON.parse(response);
                this.response = JSON.stringify(parsedResponse, null, 2);
            } catch (error) {
                this.response = `Error parsing JSON response: ${error.message}`;
            }
        })
        .catch(error => {
            this.response = `Error during callout: ${JSON.stringify(error, null, 2)}`;
        });
    }

    handleGenerateApex() {
        generateApexClass({
            endpoint: this.endpoint,
            method: this.method,
            headers: this.headers,
            requestBody: this.requestBody
        })
        .then(result => {
            const fileName = `${result.className}.cls`;

            const element = document.createElement('a');
            element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(result.classContent));
            element.setAttribute('download', fileName); 
            element.style.display = 'none';
            document.body.appendChild(element);
            element.click();
            document.body.removeChild(element);

            const metaFileName = `${result.className}.cls-meta.xml`;
            const metaElement = document.createElement('a');
            metaElement.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(result.metaContent));
            metaElement.setAttribute('download', metaFileName);  
            metaElement.style.display = 'none';
            document.body.appendChild(metaElement);
            metaElement.click();
            document.body.removeChild(metaElement);
        })
        .catch(error => {
            console.error('Error generating Apex class:', error);
        });
    }

    handleGenerateAnonymousCode() {
        generateApexClass({
            endpoint: this.endpoint,
            method: this.method,
            headers: this.headers,
            requestBody: this.requestBody
        })
        .then(result => {
            const anonymousCode = result.anonymousCode;

            this.copyToClipboard(anonymousCode);

            this.showToast('Success', 'Anonymous code copied to clipboard!', 'success');
        })
        .catch(error => {
            console.error('Error generating anonymous code:', error);
            this.showToast('Error', 'Failed to generate anonymous code', 'error');
        });
    }    

    copyToClipboard(text) {
        const textArea = document.createElement('textarea');
        textArea.value = text;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    handleClearValues() {
        this.endpoint = '';
        this.method = 'GET';
        this.headers = '';
        this.requestBody = '';

        localStorage.removeItem('miniPostmanEndpoint');
        localStorage.removeItem('miniPostmanMethod');
        localStorage.removeItem('miniPostmanHeaders');
        localStorage.removeItem('miniPostmanRequestBody');
    }

    handleTabClick(event) {
        const tabName = event.target.getAttribute('aria-controls');
        this.template.querySelectorAll('.slds-tabs_default__content').forEach((tabContent) => {
            if (tabContent.id === tabName) {
                tabContent.classList.remove('slds-hide');
                tabContent.classList.add('slds-show');
            } else {
                tabContent.classList.add('slds-hide');
                tabContent.classList.remove('slds-show');
            }
        });

        this.template.querySelectorAll('.slds-tabs_default__item').forEach((tabItem) => {
            if (tabItem.querySelector('a').getAttribute('aria-controls') === tabName) {
                tabItem.classList.add('slds-is-active');
            } else {
                tabItem.classList.remove('slds-is-active');
            }
        });
    }
}