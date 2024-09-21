import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import jquery from '@salesforce/resourceUrl/jquery';
import qrcodejs from '@salesforce/resourceUrl/qrcodejs';

export default class githubQRCode extends LightningElement {
    @track inputText = '';
    qrcode;
    qrcodeJsInitialized = false;
    jQueryInitialized = false;

    renderedCallback() {
        if (this.qrcodeJsInitialized && this.jQueryInitialized) {
            return;
        }
        Promise.all([
            loadScript(this, jquery),
            loadScript(this, qrcodejs + '/?')
        ])
        .then(() => {
            console.log('jQuery and qrcodejs loaded successfully');
            this.jQueryInitialized = true;
            this.qrcodeJsInitialized = true;
        })
        .catch(error => {
            console.error('Error loading jQuery or qrcodejs', error);
        });
    }

    handleInputChange(event) {
        this.inputText = event.target.value;
    }

    generateQRCode() {
        console.log('Generating QR Code');
        if (!this.qrcode) {
            console.log('Initializing QR Code');
            this.qrcode = new QRCode(this.template.querySelector('#qrcode'), {
                width: 128,
                height: 128
            });
        }
        this.qrcode.clear(); // clear the code.
        this.qrcode.makeCode(this.inputText); // make another code.
    }
}