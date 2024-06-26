import { LightningElement, track, wire } from 'lwc';
import getRecentArticles from '@salesforce/apex/MA_RecentKnowledgeArticleList.getRecentArticles';
import recentlyAddedModifiedArticle from '@salesforce/label/c.MA_RecentlyAddedModifiedArticle';
import noArticleToDisplay from '@salesforce/label/c.MA_NoArticleToDisplay';
import lastModifiedDateLabel from '@salesforce/label/c.MA_LastModifiedDate';
import newArticleIndication from '@salesforce/label/c.MA_NewArticleIndication';
import modifiedArticleIndication from '@salesforce/label/c.MA_ModifiedArticleIndication';
import MA_Recent_Articles_Days from '@salesforce/label/c.MA_Recent_Articles_Days';
import { reduceErrors } from 'c/maErrorHandlingUtility';
import basePath from '@salesforce/community/basePath';

export default class MaRecentKnowledgeArticles extends LightningElement {

    label = {
        recentlyAddedModifiedArticle,
        noArticleToDisplay,
        lastModifiedDateLabel,
        newArticleIndication,
        modifiedArticleIndication
    };

    @track articles;
    @track topArticles;
    showLoadMore = false;
    hasArticles = false;
    newArticle = false;
    updatedArticle = false;
    
    @wire(getRecentArticles)
    wiredArticles({error, data}){
        if(data){
            this.articles = JSON.parse(JSON.stringify(data));
            this.articles.forEach(element => {
                element.articleURL = basePath+'/article/'+element.UrlName;
                element.lastModifiedDate = this.getFormattedDate(element.LastModifiedDate);

                this.setNewOrModifiedIndications(element);
               
            });
            this.hasArticles = this.articles.length > 0;
            this.topArticles = this.articles.slice(0,5);
            this.showLoadMore = this.articles.length > 5;
        }else if (error) {
            this.showErroMessage(error)
        }
    }

    loadmoreArticles(){
        this.topArticles = this.articles.slice(0, this.articles.length);
        this.showLoadMore =  !(this.topArticles.length >= this.articles.length);
    }

    getFormattedDate(value) {
       
        var dateWithTimeZone = new Date(value).toLocaleString("en-US", {timeZone: this.timeZone});
        let date = new Date(dateWithTimeZone);

        const day = date.toLocaleString('default', { day: '2-digit' });
        const month = date.toLocaleString('default', { month: 'short' });
        const year = date.toLocaleString('default', { year: 'numeric' });
        return day + '-' + month + '-' + year;
    }

    setNewOrModifiedIndications(element){

        let today = new Date();
        

        let createdDate = new Date(element.ArticleCreatedDate);
        let updatedDate = new Date(element.LastModifiedDate);

        // there is a slight difference beteen ArticleCreatedDate and LastModifiedDate on creation. these can not be equal
        //let isNewArticle = new Date(element.ArticleCreatedDate).toDateString() === new Date(element.LastModifiedDate).toDateString();
        
        const timeBetweenModification = updatedDate.getTime() - createdDate.getTime()
        const msBetweenDates = Math.abs(today.getTime() - updatedDate.getTime());
        const secondsBetweendChange = timeBetweenModification/(1000)

        let isNewArticle = secondsBetweendChange < 60;

        const daysBetweenDates = msBetweenDates / (24 * 60 * 60 * 1000);
        const articleDaysBetween = parseInt(MA_Recent_Articles_Days);

        if(isNewArticle && daysBetweenDates <= articleDaysBetween){
            element.newArticle = true;
        }else if(daysBetweenDates <= articleDaysBetween){
            element.updatedArticle = true;
        }
    }

    showErroMessage(error) {
        console.log(error)
        this.dispatchEvent(new ShowToastEvent({"title" : "Error", "message" : reduceErrors(error), "variant" : "error"}))
    }
}