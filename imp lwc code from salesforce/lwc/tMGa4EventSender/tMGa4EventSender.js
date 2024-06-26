import { LightningElement } from 'lwc';

export default class TMGa4EventSender extends LightningElement {
    connectedCallbackt() {
        // Replace 'GA_MEASUREMENT_ID' with your actual GA4 Measurement ID
        const gaMeasurementId = 'G-2SHSTM1TXG';

        // Replace 'your_event_name' and add any additional parameters as needed
        const eventName = 'job_recommendation';
        const eventParameters = {
            total_recommendation: 22,
            recommendation_generatedby: 'Ashutosh Belwal'
        };

        // Create the gtag script element
        const script = document.createElement('script');
        script.type = 'text/javascript';
        script.async = true;
        script.src = `https://www.googletagmanager.com/gtag/js?id=${gaMeasurementId}`;
        document.head.appendChild(script);

        script.onload = () => {
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', gaMeasurementId);

            // Send the GA4 event
            gtag('event', eventName, eventParameters);
        };
    }
}