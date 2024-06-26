public with sharing class PF_NHW_CustomCaseComment {

		@AuraEnabled
        public String author{get; private set;}
        @AuraEnabled
        public String publishDate{get; private set;}
        @AuraEnabled
        public String comment{get; private set;}
        
        public PF_NHW_CustomCaseComment(String author, String publishDate, String comment){
            this.author = author;
            this.publishDate = publishDate;
            this.comment = comment;
        }
}