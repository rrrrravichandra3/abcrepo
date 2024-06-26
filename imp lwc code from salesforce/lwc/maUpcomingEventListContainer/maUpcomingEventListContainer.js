import { LightningElement, wire, api } from 'lwc';
import getEventsAttendeesRecords from '@salesforce/apex/MA_UpcomingEventsController.getEventsAttendeesRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
export default class MaUpcomingEventListContainer extends LightningElement {

    isHomePage = false;
    communityEvents;
    setting;
    isLoading = true;
    picklistValues;
    rsvpRecords;
    timeZone = TIME_ZONE;

    @api
    get homepage(){
        return this.isHomePage;
    }

    set homepage(value) {
        this.isHomePage = value;
        this.setAttribute('homepage', this.isHomePage);
    }

   
    @wire(getEventsAttendeesRecords)
    wiredAttendees({ error, data }) {
        if (data) {
            this.rsvpRecords = JSON.parse(JSON.stringify(data.MA_Community_Events__c));
            this.rsvpRecords.forEach(element=>{
                
                element['RSVP_Yes'] = element.RSVP__c == 'Yes' ;
                element['RSVP_No'] = element.RSVP__c == 'No';
                element['RSVP_May_Be'] = element.RSVP__c == 'May Be';
                
                if(element.Community_Event__r.Last_Processed_State__c){
                    const lastState = JSON.parse(element.Community_Event__r.Last_Processed_State__c);
                    element.Start_Date__c       = lastState.start_date__c;
                    element.Event_Type__c       = lastState.event_type__c;
                    element.Name                = lastState.name;
                    element.Start_Time__c       = lastState.start_time__c;
                    element.Start_Datetime__c   = lastState.start_datetime__c;
                    element.Event_Type__c       = lastState.event_type__c;
                    element.Required_Event__c   = lastState.required_event__c ;
                    element.Location__c         = lastState.location__c;
                    element.Event_Link__c       = lastState.event_link__c;
                    element.End_Time__c         = lastState.end_time__c;
                    element.End_Datetime__c     = lastState.end_datetime__c;
                    element.End_Date__c         = lastState.end_date__c;
                    element.All_Day_Event__c    = lastState.all_day_event__c;
                    element.Description__c      = lastState.description__c;
                    delete element.Community_Event__r;
                }

                element.endDateWithTimeZone = this.getDateWithTimeZone(element.All_Day_Event__c, element.End_Datetime__c);
                element.startDateWithTimeZone = this.getDateWithTimeZone(element.All_Day_Event__c, element.Start_Datetime__c);

                element.endDate = this.getFormattedDate(element.endDateWithTimeZone);
                element.startDate = this.getFormattedDate(element.startDateWithTimeZone);
            });
            this.sortUpcomingEvents(this.rsvpRecords);
            this.setting = data.MA_UpcomingEventsSettings__c;
            this.picklistValues = data.picklistValues;
        } else if (error) {
            this.showErroMessage(error)
            this.communityEvents = undefined;
            this.setting = undefined;
            this.picklistValues = undefined;
        }
        this.isLoading = false;
    }

    showErroMessage(error) {
        console.log(error);
        const unknownError = 'Unknown error';
        let errorMessage = Array.isArray(error.body) ? error.body.map(e => e.message).join(', ') : 
                           (typeof error.body.message === 'string') ? error.body.message : unknownError;
        this.dispatchEvent(new ShowToastEvent({"title" : "Error", "message" : errorMessage, "variant" : "error"}));
    }

    getDateWithTimeZone(isAllDayEvent, dateTimeVal) {
        return isAllDayEvent ? new Date(dateTimeVal).toLocaleString("en-US", {timeZone: 'UTC'}) : new Date(dateTimeVal).toLocaleString("en-US", {timeZone: this.timeZone});
    }

    //W-11122431 Changed Date Format for Event StartDate/EndDate
    getFormattedDate(dateWithTimeZoneVal) {
        let dateVal = new Date(dateWithTimeZoneVal);
        const day = dateVal.toLocaleString('default', {day: '2-digit'});
        const month = dateVal.toLocaleString('default', {month: 'short'});
        const year = dateVal.toLocaleString('default', {year: 'numeric'});
        return day + '-' + month + '-' + year;
    }

    sortUpcomingEvents(upcomingEvents) {
        upcomingEvents.sort((eventA, eventB) => {
            let isSameEndDateTime = (eventA.endDateWithTimeZone === eventB.endDateWithTimeZone);
            let isSameStartDateTime = (eventA.startDateWithTimeZone === eventB.startDateWithTimeZone);
            let isRecentEndDateTime = (new Date(eventA.endDateWithTimeZone) > new Date(eventB.endDateWithTimeZone));
            let isRecentStartDateTime = (new Date(eventA.startDateWithTimeZone) > new Date(eventB.startDateWithTimeZone));
            return isSameStartDateTime ? (isSameEndDateTime ? 0 : isRecentEndDateTime ? -1 : 1) : (isRecentStartDateTime ? -1 : 1);
        });
    }
}