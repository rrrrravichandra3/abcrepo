import { LightningElement,api } from 'lwc';
import getEinsteinJobInsights from '@salesforce/apex/talentMP_SearchJobService.getEinsteinJobInsights'

export default class TalentMp_jobEinsteinInsights extends LightningElement {
    @api employeeskills;
    @api jobid;
    @api contact
    isLoading = true;
    insights;
    matchStrength;
    improvementAreas = [];
    additionalNotes = [];
    missingSkills = []

    connectedCallback(){
        getEinsteinJobInsights({contactId: this.contact.Id, employeeSkills : this.employeeskills, jobId: this.jobid})  
        .then(result => {
            this.parseResponse(result);
            this.isLoading = false;
        }).catch(error => {
            console.log(error);
        });
    }

    parseResponse(response) {
        const matchStrengthRegex = /Match Strength: (.+)/;
        const improvementAreasRegex = /Improvement Areas:\s*- (.+?(?=\d\.|$))/gs;
        const additionalNotesRegex = /Additional Notes:\s*- (.+?(?=\d\.|$))/gs;
      
        // Extract Match Strength
        const matchStrengthMatch = response.match(matchStrengthRegex);
        console.log(matchStrengthMatch);
        this.matchStrength = matchStrengthMatch ? matchStrengthMatch[1].trim() : '';
      
        // Extract Improvement Areas
        const improvementAreasMatches = response.matchAll(improvementAreasRegex);
        console.log(improvementAreasMatches);
        for (const match of improvementAreasMatches) {
          this.improvementAreas.push(match[1].trim());
        }
      
        // Extract Additional Notes
        const additionalNotesMatches = response.matchAll(additionalNotesRegex);
        for (const match of additionalNotesMatches) {
          this.additionalNotes.push(match[1].trim());
        }
    }
}