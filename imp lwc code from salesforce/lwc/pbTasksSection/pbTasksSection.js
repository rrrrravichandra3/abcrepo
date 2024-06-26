import { LightningElement, api, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import UserId from "@salesforce/user/Id"; // get the current user's id

export default class PbTasksSection extends LightningElement {
    userId = UserId;
    contactId;
    daysToStartDate = 0;
    daysToStartDate1;
    daysToStartDate2;
    showComponent = false;

    @api header;
    @api subheader;
    @api bushesImageId;
    @api balloonImageId;

    @api chevronId;
    @api wdStep1Id;
    @api wdStep2Id;
    @api wdStep3Id;
    @api totalDays;
    @api totalDay;

    @api wdFirstHeader;
    @api wdFirstSubheader;
    @api wdStep1Header;
    @api wdStep1Subheader;
    @api wdStep2Header;
    @api wdStep2Subheader;
    @api wdStep3Header;
    @api wdStep3Subheader;

    @api wdSecondHeader;
    @api wdTask1Header;
    @api wdTask1Subheader;
    @api wdTask2Header;
    @api wdTask2Subheader;
    @api wdTask3Header;
    @api wdTask3Subheader;
    @api wdTask4Header;
    @api wdTask4Subheader;
    @api wdTask5Header;
    @api wdTask5Subheader;
    @api buttonText;

    baseUrl = 'sfsites/c/cms/delivery/media/';

    enabledFeatures = ["button", "card", "divider", "grid", "image"];

    __bushesUrl;
    @api
    get bushesUrl() {
        return this.baseUrl + this.bushesImageId;
    }
    set bushesUrl(value) {
        this.__bushesUrl = value;
    }
    __balloonUrl;
    @api
    get balloonsUrl() {
        return this.baseUrl + this.balloonImageId;
    }
    set balloonsUrl(value) {
        this.__balloonUrl = value;
    }
    __chevronUrl;
    @api
    get chevronUrl() {
        return this.baseUrl + this.chevronId;
    }
    set chevronUrl(value) {
        this.__chevronUrl = value;
    }
    __wdStep1Url;
    @api
    get wdStep1Url() {
        return this.baseUrl + this.wdStep1Id;
    }
    set wdStep1Url(value) {
        this.__WDStep1Url = value;
    }
    __wdStep2Url;
    @api
    get wdStep2Url() {
        return this.baseUrl + this.wdStep2Id;
    }
    set wdStep2Url(value) {
        this.__wdStep2Url = value;
    }
    __wdStep3Url;
    @api
    get wdStep3Url() {
        return this.baseUrl + this.wdStep3Id;
    }
    set wdStep3Url(value) {
        this.__wdStep3Url = value;
    }

    @wire(getRecord, { recordId: "$userId", fields: ["User.ContactId"] })
    getContactId({ data, error }) {
        if (data) {
            this.handleContactIdData(data);
        } else if (error) {
            this.handleError(error);
        }
    }

    @wire(getRecord, {
        recordId: "$contactId",
        fields: ["Contact.Start_Date__c"]
    })
    getContactRecord({ data, error }) {
        if (data) {
            this.calculateDaysToStartDate(data);
        } else if (error) {
            this.handleError(error);
        }
    }

    // Helper functions

    handleContactIdData(data) {
        if (data.fields.ContactId.value) {
            this.contactId = data.fields.ContactId.value;
        }
    }

    calculateDaysToStartDate(data) {
        if (data.fields.Start_Date__c) {
            const startDate = new Date(data.fields.Start_Date__c.value);
            const currentDate = new Date();
            const diffInDays = this.calculateDifferenceInDays(startDate, currentDate);

            if (this.handleShowComponent(diffInDays)) {
                this.showComponent = true;
            } else {
                this.showComponent = false;
            }

            if (diffInDays === 1) {
                this.daysToStartDate1 = diffInDays;
            } else {
                this.daysToStartDate2 = diffInDays;
            }

            this.daysToStartDate = diffInDays;
        }
    }

    calculateDifferenceInDays(startDate, currentDate) {
        const timeDiff = startDate.getTime() - currentDate.getTime();
        const diffInDays = Math.ceil(timeDiff / (1000 * 3600 * 24)) + 1;
        const weekendDays = this.calculateWeekendDays(currentDate, startDate);
        return diffInDays - weekendDays;
    }

    calculateWeekendDays(startDate, endDate) {
        const oneDay = 24 * 60 * 60 * 1000;
        let currentDate = new Date(startDate.getTime());
        let weekendDays = 0;

        while (currentDate <= endDate) {
            if (currentDate.getDay() === 0 || currentDate.getDay() === 6) {
                weekendDays++;
            }
            currentDate = new Date(currentDate.getTime() + oneDay);
        }

        return weekendDays;
    }

    handleShowComponent(diffInDays) {
        return diffInDays >= 1 && diffInDays <= 3;
    }

    handleError(error) {
        this.error = error;
        console.log("error: ", error);
    }
}