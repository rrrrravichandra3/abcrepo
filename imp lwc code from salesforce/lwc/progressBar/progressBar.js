import { LightningElement,track,api } from 'lwc';

export default class ProgressBar extends LightningElement {
    totalsteps = 6;
    @track _currentstep;

    @track _progress= [
        {
            'name' : 'Accept Job Offer',
            'estTime' : '20 min',
            'completed' : false,
            'active' : false
        },
        {
            'name' : 'Choose Equipment',
            'estTime' : '5 min',
            'completed' : false,
            'active' : false
        },
        {
            'name' : 'Workday Tasks',
            'estTime' : '10 min',
            'completed' : false,
            'active' : false
        },
        {
            'name' : 'Accessibility Needs',
            'estTime' : '5 min',
            'completed' : false,
            'active' : false
        },
        {
            'name' : 'Request a Badge',
            'estTime' : '5 min',
            'completed' : false,
            'active' : false
        },
        {
            'name' : 'Complete Profile',
            'estTime' : '5 min',
            'completed' : false,
            'active' : false
        },
    ];

    @api get currentstep() {
        return this._currentstep;
    }

    set currentstep(val) {
        this._currentstep = val;
        let k = parseInt(this._currentstep);
        for(let i = 0 ; i < k ; i++) {
            this._progress[i].completed = true;
            this._progress[i].active = false;
        }
        this._progress[k].active = true;
        console.log('heree');
        console.log(this._progress)
    }

    connectedCallback() {
        let k = parseInt(this.currentstep);
        console.log(k);
        for(let i = 0 ; i < k ; i++) {
            console.log(i);
            console.log(this._progress[i]);
            this._progress[i].completed = true;
            this._progress[i].active = false;
        }
        this._progress[k].active = true;
        console.log('here');
        console.log(this._progress)
    }
}