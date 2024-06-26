public abstract class Pagination {
	
   public Integer noOfpages {get; set;}
   public Integer currentPage {get; set;}	
   public Boolean showPagination { get{return(noOfpages >= 2);} set; }
   public Boolean showFirstLink { get{return(currentPage != 1);} set; }
   public Boolean showPreviousLink { get{return(currentPage > 1);} set; }
   public Boolean showNextLink { get{return(currentPage < noOfpages);} set; }
   public Boolean showLastLink { get{return(currentPage  != noOfpages);} set; }
   
   public void firstPageAction() {
       currentPage = 1;
       getPaginationNotesData();
   }
    
   public void previousPageAction() {
        if (currentPage > 1) {
             currentPage--;
        } else {
            currentPage = 1;
        }
        getPaginationNotesData();
   }
   public void nextPageAction() {
        if (currentPage < noOfpages) {  
            currentPage++;
        } else {
            currentPage = (noOfpages>=1) ? noOfpages : 1;
        }
        getPaginationNotesData();
   }
   public void lastPageAction() {
        currentPage = (noOfpages>=1) ? noOfpages : 1;
        getPaginationNotesData();
   }
   
   public abstract void getPaginationNotesData();
}