import { LightningElement } from 'lwc';
import makeCallout from '@salesforce/apex/MiniPostmanController.makeCallout';
import generateApexClass from '@salesforce/apex/MiniPostmanController.generateApexClass';

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

    headerPlaceholder = '{"Content-Type": "application/json"}';
    bodyPlaceholder = '{"key": "value"}';

    connectedCallback() {
        // Load saved values from localStorage on component initialization
        this.loadSavedValues();
    }

    // Load values from localStorage
    loadSavedValues() {
        this.endpoint = localStorage.getItem('miniPostmanEndpoint') || '';
        this.method = localStorage.getItem('miniPostmanMethod') || 'GET';
        this.headers = localStorage.getItem('miniPostmanHeaders') || '';
        this.requestBody = localStorage.getItem('miniPostmanRequestBody') || '';
    }

    // Save values to localStorage when input changes
    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
        
        // Save each field in localStorage
        localStorage.setItem(`miniPostman${field.charAt(0).toUpperCase() + field.slice(1)}`, event.target.value);
    }

    handleCallout() {
        try {
            const parsedRequestBody = JSON.parse(this.requestBody);

            makeCallout({
                endpoint: this.endpoint,
                method: this.method,
                headers: this.headers,
                requestBody: JSON.stringify(parsedRequestBody)
            })
            .then(response => {
                this.response = JSON.stringify(response, null, 2);
            })
            .catch(error => {
                this.response = JSON.stringify(error, null, 2);
            });
        } catch (error) {
            this.response = `Invalid JSON format: ${error.message}`;
        }
    }

    handleGenerateApex() {
        generateApexClass({
            endpoint: this.endpoint,
            method: this.method,
            headers: this.headers,
            requestBody: this.requestBody
        })
        .then(result => {
            const element = document.createElement('a');
            element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(result.classContent));
            element.setAttribute('download', 'GeneratedApexClass.cls');
            element.style.display = 'none';
            document.body.appendChild(element);
            element.click();
            document.body.removeChild(element);

            const metaElement = document.createElement('a');
            metaElement.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(result.metaContent));
            metaElement.setAttribute('download', 'GeneratedApexClass.cls-meta.xml');
            metaElement.style.display = 'none';
            document.body.appendChild(metaElement);
            metaElement.click();
            document.body.removeChild(metaElement);
        })
        .catch(error => {
            console.error('Error generating Apex class:', error);
        });
    }

    // Clear values and remove them from localStorage
    handleClearValues() {
        this.endpoint = '';
        this.method = 'GET';
        this.headers = '';
        this.requestBody = '';
        
        // Remove saved values from localStorage
        localStorage.removeItem('miniPostmanEndpoint');
        localStorage.removeItem('miniPostmanMethod');
        localStorage.removeItem('miniPostmanHeaders');
        localStorage.removeItem('miniPostmanRequestBody');
    }

    // Tab switching logic (optional, if using tabs)
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