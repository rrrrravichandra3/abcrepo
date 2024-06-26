import { LightningElement, track } from 'lwc';
export default class PbFrequentlyAskedQuestion extends LightningElement {
    @track faqlist = [
        {
            'question': 'When will I receive my laptop?',
            'answer': "A New Hire's equipment should be ready on their first day. Due to office closures, global supplies, and shipping constraints, we are experiencing challenges in delivering New Hire equipment on time.\n\nOn your first day, you may need to join the Onboarding webinar from your personal device with MDM (Mobile Device Management). Our Techforce team joins our Onboarding webinars to share login details, passwords, and assist you with setup.\n\nIf you receive your laptop early, you may need to wait until Techforce helps you set up your laptop.",
            'label': 'Equipment',
            'iconName': 'utility:chevrondown'
        },
        {
            'question': 'What is the new hire I-9/GWA verification process?',
            'answer': 'Work authorization is a legally required process of verifying if a New Hire has the right to work in the country location they’ve been hired to, or are currently working in.',
            'label': 'Support',
            'iconName': 'utility:chevrondown'
        }
        ,
        {
            'question': 'How can I login to Workday prior to my start date?',
            'answer': 'Before you start, you will receive Workday login details in an email sent from salesforce@myworkday.com to your personal'
                + 'email address. The email subject line is “Accessing your Workday account for Salesforce"',
            'label': 'Support',
            'iconName': 'utility:chevrondown'
        },
        {
            'question': 'How can I review the Salesforce Benefit Plans?',
            'answer': 'You will only be able to elect benefits once you start at Salesforce. To view our Salesforce benefits, you can visit our benefits'
                + 'website: https://www.salesforcebenefits.com/index.html',
            'label': 'Benefits',
            'iconName': 'utility:chevrondown'
        }
    ];



    handleClick(event) {

        let dId = event.currentTarget.dataset.id;
        if (this.template.querySelector(`.borderline[data-id="${dId}"]`)?.classList.contains('noshow')) {
            this.faqlist[dId].iconName = 'utility:chevronup';
        } else {
            this.faqlist[dId].iconName = 'utility:chevrondown';
        }
        this.template.querySelector(`.faq-item[data-id="${dId}"]`)?.classList.toggle('incHeight');
        this.template.querySelector(`.faq-question[data-id="${dId}"]`)?.classList.toggle('addPadding');
        this.template.querySelector(`.faq-answer[data-id="${dId}"]`)?.classList.toggle('noshow');
        this.template.querySelector(`.borderline[data-id="${dId}"]`)?.classList.toggle('noshow');


    }
}