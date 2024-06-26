import { LightningElement, api, track, wire } from 'lwc';
import communityPath from '@salesforce/community/basePath';
import generateSSOUrl from '@salesforce/apex/MA_CommunitySSOController.generateSSOUrl';
import getSSOUrlFromInvitation from '@salesforce/apex/MA_CommunitySSOController.getSSOUrlFromInvitation';
import { NavigationMixin } from "lightning/navigation";

export default class MaLoginSSo extends NavigationMixin(LightningElement) {
    parameters = {};
    startUrl = '';
    communityUrl;
    invitationId
    ssoId;
    

    connectedCallback() {
        this.communityUrl  = window.location.href.substring(0, window.location.href.indexOf("/s"));

        this.parameters = this.parseUrlParams(location.search.substring(1));
        if(this.parameters.startURL){
            this.startUrl = this.parameters.startURL
        }else{
            this.redirectToSSO()
        }

        if(this.parameters.startURL){
            let objUrl = new URL(this.communityUrl+this.parameters.startURL);
            const params = this.parseUrlParams(objUrl.search)
            
            if(params.invitationId){
                this.invitationId = params.invitationId
            }else if(params.sso){
                this.ssoId = params.sso
               
            }
        }
        
        if(this.invitationId){
            this.getSSOUrlFromSurvey()
        }else{
            this.redirectToSSO()
        }
        
        
    }

    getSSOUrlFromSurvey(){
        
        getSSOUrlFromInvitation({InvitationId : this.invitationId, startUrl: this.startUrl,communityUrl: this.communityUrl})
        .then(result => {
           
            window.open(result,"_self")
        })
        .catch(error => {
            console.log(error)
        });
    }

    redirectToSSO(){
        
        generateSSOUrl({ssoId : this.ssoId, startUrl: this.startUrl,communityUrl: this.communityUrl})
        .then(result => {
            
            window.open(result,"_self")
        })
        .catch(error => {
            console.log(error)
        });
    }

    

    parseUrlParams(query){
        const params = new Proxy(new URLSearchParams(query), {
            get: (searchParams, prop) => searchParams.get(prop),
          });
        return params
    }


    
}