import { LightningElement, api, wire } from 'lwc';
import generateQRCode from '@salesforce/apex/PaymentQRCodeController.generateQRCode';

export default class PaymentQRCode extends LightningElement {
    @api recordId;
    qrCodeUrl;

    @wire(generateQRCode, { paymentId: '$recordId' })
    wiredQRCode({ error, data }) {
        if (data) {
            this.qrCodeUrl = data;
            console.log('QR Code URL:', this.qrCodeUrl);  // Log the QR code URL for debugging
        } else if (error) {
            this.qrCodeUrl = null;
            console.error('Error generating QR code:', error);
        }
    }
}