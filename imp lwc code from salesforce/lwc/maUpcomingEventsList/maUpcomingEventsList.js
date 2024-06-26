import { LightningElement,track,wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import LOCALE from '@salesforce/i18n/locale';
import ics from './ics.js';
import updateRSVP from '@salesforce/apex/MA_UpcomingEventsController.updateRSVPValue';
import TimeZoneLabel from '@salesforce/label/c.MA_TimeZone_Label';
import Id from '@salesforce/user/Id';
import { getRecord, getFieldDisplayValue } from 'lightning/uiRecordApi';
import TIMEZONE_FIELD from '@salesforce/schema/User.TimeZoneSidKey';

export default class MaUpcomingEventsList extends LightningElement {

    label = {
        TimeZoneLabel
    };


    timeZone = TIME_ZONE;
    locale = LOCALE;
    communityEvents;
    settingsList;
    isHomePage;
    title;
    buttonLabel;
    eventLimitRecord;
    emptyEventsText;
    listContainsElements = false;
    arrayRedady = false;
    picklistValues;
    buttonMoreEventsLabel;
    eventLoadNumber;
    userId = Id;
    
    @track hasRendered = true;
    @track eventArray = [];
    @track eventRecordObject = [];
    @track batchNumber = 0;
    @track showLoadMoreButton = false;
    @track optionsEventType = [{ label: 'Select Event Type', value: 'none' }];
    @track valueEventType = '';
    @track optionsMonths = [{ label: 'Select Month', value: 'none' }];
    @track valueMonth = '';
    @track filterRequired = false;
    @track monthChanges = false;
    @track eventTypeChanges = false;
    @track monthCurrentValue = 'none';
    @track eventTypeCurrentValue = 'none';
    @track requiredCurrentValue = false;
    


    renderedCallback() {  
        if(this.communityEvents != undefined && this.settingsList != undefined){
            if (this.hasRendered) {
                
                this.getOptionMonthsByEvent();

                this.setPicklistValues();

                this.displayEventsRecord();

                this.styleValidation();

                this.hasRendered = false;
                this.monthChanges = true;
                this.filterEvents();
                console.log('after rerender');
                console.log(this.communityEvents);
              
            }
        }
    }

    @wire(getRecord, { recordId: '$userId', fields : [TIMEZONE_FIELD] })
    user;

    get usertimezone() {
        return getFieldDisplayValue(this.user.data, TIMEZONE_FIELD);
    }

    @api
    get homepage(){
        return this.isHomePage;
    }
    set homepage(value) {
        this.isHomePage = value;
        this.setAttribute('homepage', this.isHomePage);
    }

    @api
    get eventlist(){
        return this.communityEvents;
    }

    set eventlist(value) {
        if(value != undefined){
            console.log('inside setter');
            console.log(value);
            this.communityEvents = value;
            this.setAttribute('eventlist', this.communityEvents);
            this.listContainsElements = value.length > 0 ? true : false;
        }
    }

    @api
    get settings(){
        return this.settingsList;
    }

    set settings(value) {
        if(value != undefined){
            this.settingsList = value;
            this.setAttribute('settings', this.settingsList);
            this.title = this.settingsList[0].Title_component__c;
            this.buttonLabel = this.settingsList[0].Button_Label__c;
            this.eventLimitRecord = this.settingsList[0].Limit_Event__c;
            this.emptyEventsText = this.settingsList[0].Empty_Event_Text__c;
            this.buttonMoreEventsLabel = this.settingsList[0].Label_Show_Events__c;
            this.eventLoadNumber = this.settingsList[0].Number_Load_Events__c;
        }
    }
    
    @api
    get wrapperpicklist(){
        return this.picklistValues;
    }

    set wrapperpicklist(value){
        if(value != undefined){
            this.picklistValues = value;
        }
    }

    displayEventsRecord(){
        let is_HomePage = this.isHomePage;
        let eventListHasElements = this.communityEvents.length > 0;
        let listExceedLimit = this.communityEvents.length > this.eventLimitRecord;
        let listBelowLimit = this.communityEvents.length <= this.eventLimitRecord;

        if(eventListHasElements && listExceedLimit && is_HomePage){

            this.eventArray = this.communityEvents.filter((event, index, arr) => index < this.eventLimitRecord);

        }else if(is_HomePage && eventListHasElements && listBelowLimit){

            this.eventArray = this.communityEvents;

        }else if(!is_HomePage && eventListHasElements){

            for(let i = 0; i < this.communityEvents.length; i++){
                this.eventRecordObject.push({index: i, record:this.communityEvents[i], showDetails:false});
            }
            this.showMoreEvents();
        }
        
    }

    loadMoreEvents(){
        let urlString = window.location.href;
        urlString+="ma-upcoming-events";
        window.open(urlString,"_self");
    }

    showMoreEvents(){
        this.listContainsElements = this.eventRecordObject.length > 0 ? true : false;
        this.batchNumber++;
        this.eventArray = this.eventRecordObject.filter((event, index, arr) => index < this.eventLoadNumber * this.batchNumber);
        if(this.eventRecordObject.length > this.eventLoadNumber * this.batchNumber){
            this.showLoadMoreButton = true;
        }else{
            this.showLoadMoreButton = false;
        }
    }

    hideDisplayDetails(event){
        for(let i = 0; i < this.eventRecordObject.length; i++){
            if(this.eventRecordObject[i].index == event.currentTarget.name){
                this.eventRecordObject[i].showDetails = !this.eventRecordObject[i].showDetails; 
            }
        }
    }

    handleChangeMonth(event){
        this.monthChanges = false;
        if(event.currentTarget.name == 'month' && event.detail.value != 'none'){
            this.monthChanges = true;
        }
        this.monthCurrentValue = event.detail.value;
        this.filterEvents();
    }

    handleChangeEventType(event){
        this.eventTypeChanges = false;
        if(event.currentTarget.name == 'eventType' && event.detail.value != 'none'){
            this.eventTypeChanges = true;
        }
        this.eventTypeCurrentValue = event.detail.value;
        this.filterEvents();
    }

    handleChangeCheckBox(){
        this.requiredCurrentValue = (this.filterRequired = !this.filterRequired);
        this.filterEvents();
    }

    getOptionMonthsByEvent(){
        const today = new Date();
        const upcomingStr = 'Upcoming';
        const todayVal = this.getDateLocaleString(today, "year", "numeric") + "-" + this.getDateLocaleString(today, "month", "numeric");

        let monthSelector = [{label: upcomingStr , value: upcomingStr}];
        let monthCheck = new Set();
        
        this.communityEvents.forEach(communityEvent => {
            if(communityEvent.Start_Datetime__c) {
                const eventStartDate = new Date(communityEvent.Start_Datetime__c);
                const eventDateVal = this.getDateLocaleString(eventStartDate, "year", "numeric") + "-" + this.getDateLocaleString(eventStartDate, "month", "numeric");
                
                if(!monthCheck.has(eventDateVal)) {
                    monthSelector.push({
                        "label" : this.getDateLocaleString(eventStartDate, "month", "long") + " " + this.getDateLocaleString(eventStartDate, "year", "numeric"),
                        "value" : eventDateVal
                    });
                    monthCheck.add(eventDateVal);
                }

                if(todayVal == eventDateVal) {
                    this.valueMonth = eventDateVal;
                }
            }
        });

        this.monthCurrentValue = this.valueMonth = upcomingStr;
        this.optionsMonths = monthSelector;
    }

    getDateLocaleString(dateVal, localeParam, localParamVal) {
        const localeParams = {};
        localeParams.timeZone = this.timeZone;
        localeParams[localeParam] = localParamVal;
        return dateVal.toLocaleString('default', localeParams);
    }

    setPicklistValues(){
        this.optionsEventType = [{label: 'All' , value: 'All'}];
        const availableEvents = new Set();
        this.communityEvents.forEach((current) => {
            availableEvents.add(current.Event_Type__c);
        });

        if(this.picklistValues.length > 0){
            for(let i = 0; i < this.picklistValues.length; i++){
                if(availableEvents.has(this.picklistValues[i].label)){
                    const option = {
                        label: this.picklistValues[i].label,
                        value: this.picklistValues[i].value
                    };
                    this.optionsEventType.push(option);
                }
            }            
        }

        // W-10462135 : Added "All" option to Event Type filter as default.
        this.eventTypeCurrentValue = (this.valueEventType = 'All');
    }

    styleValidation(){
        if(!this.isHomePage){
            this.template.querySelector('[data-id="principalContainer"]').className='transparentBackground';
            this.template.querySelector('[data-id="innerContainer"]').className='transparentBackground';
        }
    }

    filterEvents(){
        this.eventRecordObject = [];
        let filterById = new Set();
        if(this.monthChanges == false && this.eventTypeChanges == false && this.requiredCurrentValue == false){
            for(let i = 0; i < this.communityEvents.length; i++){
                this.eventRecordObject.push({index: i, record:this.communityEvents[i], showDetails:false});
            }
        }else{
            filterById = this.filterByMonth(this.monthCurrentValue, filterById);
            filterById = this.filterByTypeEvent(this.eventTypeCurrentValue, filterById);
            filterById = this.filterByRequired(this.requiredCurrentValue, filterById);
            for(let i = 0; i < this.communityEvents.length; i++){
                if(filterById.has(this.communityEvents[i].Id)){
                    this.eventRecordObject.push({index: i, record:this.communityEvents[i], showDetails:false});
                }
            }
        }

        if(this.monthCurrentValue === "Upcoming" && this.eventRecordObject.length > 0) {
            this.eventRecordObject.reverse();
        }

        this.batchNumber = 0;
        this.showMoreEvents();
    }

    filterByMonth(currentValue, filterMonthById) {
        if(this.monthChanges) {
            this.communityEvents.forEach(communityEvent => {
                const eventStartDate = new Date(communityEvent.Start_Datetime__c);
                const todayDate = new Date();
                const eventDateVal = this.getDateLocaleString(eventStartDate, "year", "numeric") + "-" + this.getDateLocaleString(eventStartDate, "month", "numeric");                
                
                if(currentValue === "Upcoming" && eventStartDate >= todayDate ) {
                    filterMonthById.add(communityEvent.Id);
                }else if(currentValue === eventDateVal) {
                    filterMonthById.add(communityEvent.Id);
                }
            });
        }
        return filterMonthById;
    }

    filterByTypeEvent(currentValue, filterByTypeEventId){
        let idsByEventType = new Set();

        if(this.eventTypeChanges) {
            this.communityEvents.forEach(communityEvent => {
                let eventId = communityEvent.Id;
                // W-10462135 : "All" option to display all Event Types for a selected Month.
                if(currentValue === "All" || currentValue == communityEvent.Event_Type__c) {
                    idsByEventType.add(eventId);
                }else if(this.monthChanges && filterByTypeEventId.has(eventId)) {
                    filterByTypeEventId.delete(eventId);
                }
            });

            if(!this.monthChanges) {
                filterByTypeEventId = idsByEventType;
            }
        }

        return filterByTypeEventId;
    }

    filterByRequired(currentValue, filterByRequiredId){
        let idsByRequired = new Set();

        if(currentValue) {
            let isMonthOrEventTypeChange = (this.monthChanges || this.eventTypeChanges);

            this.communityEvents.forEach(communityEvent => {
                let eventId = communityEvent.Id;

                if(communityEvent.Required_Event__c){
                    idsByRequired.add(eventId);
                }else if(isMonthOrEventTypeChange && filterByRequiredId.has(eventId)) {
                    filterByRequiredId.delete(eventId);
                }
            });

            if(!isMonthOrEventTypeChange) {
                filterByRequiredId = idsByRequired;
            }
        }

        return filterByRequiredId;
    }

    generateIcsFile(event){
        
        let eventRecord;
        for(let i = 0; i < this.eventRecordObject.length; i++){
            if(this.eventRecordObject[i].index == event.currentTarget.name){
                eventRecord = this.eventRecordObject[i];
            }
        }
        
       
        const location          = eventRecord.record.Location__c != undefined && eventRecord.record.Location__c != null ? eventRecord.record.Location__c: '';
        const description       = eventRecord.record.Description__c != undefined && eventRecord.record.Description__c != null ? eventRecord.record.Description__c: '';
        const startDateTime     = eventRecord.record.Start_Datetime__c != undefined && eventRecord.record.Start_Datetime__c != null ? eventRecord.record.Start_Datetime__c	: '';
        const endDateTime       = eventRecord.record.End_Datetime__c != undefined && eventRecord.record.End_Datetime__c != null ? eventRecord.record.End_Datetime__c : '';
         
        let cal_single = ics();
       
        cal_single.addEvent(eventRecord.record.Name, description, location, startDateTime, endDateTime, eventRecord.record.All_Day_Event__c);
        cal_single.download('calendar')
    }
   
    updateRSVP(event){
        
        let eventRecordId;
        let arrayTemp = JSON.parse(JSON.stringify(this.eventArray));

        for(let i = 0; i < arrayTemp.length; i++){
            if(arrayTemp[i].index == event.currentTarget.name){
                
                eventRecordId = arrayTemp[i].record.Id;

                arrayTemp[i].record.RSVP_Yes = false;
                arrayTemp[i].record.RSVP_No = false;
                arrayTemp[i].record.RSVP_May_Be = false;
                if(event.currentTarget.dataset.id == 'Yes'){
                    arrayTemp[i].record.RSVP_Yes = true;
                }else if(event.currentTarget.dataset.id == 'No'){
                    arrayTemp[i].record.RSVP_No = true;
                }else if(event.currentTarget.dataset.id == 'May Be'){
                    arrayTemp[i].record.RSVP_May_Be = true;
                }
            }
        }
        
        this.eventArray = arrayTemp;
        
        updateRSVP({recordId:eventRecordId, response:event.currentTarget.dataset.id})
        .then(data=>{
            console.log('response captured successfully');
        }).catch(error => {
            console.log(error);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        });
    }
}