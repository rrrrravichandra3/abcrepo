/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 */

/*
 * this class will take an account and assign it to a user.
 * @author Mike Fullmore - 4/2/2009
*/

public class ReviewSharing {

 
    PerformanceReview__c review;

    Id reviewer;

    String sharingNode;

    List<CompetencyReview__c> comps = new List<CompetencyReview__c>();
    List<MethodReview__c> methods = new List<MethodReview__c>();
    List<ReviewRating__c> ratings = new List<ReviewRating__c>();
    List<AdditionalComment__c> comments = new List<AdditionalComment__c>();
    List<ScorecardSupportComment__c> ssupcomments = new List<ScorecardSupportComment__c>();
    List<ScorecardSupportReview__c> ssupreviews = new List<ScorecardSupportReview__c>();
    
    public ReviewSharing(PerformanceReview__c r, Id u, String s) {
        review = r;
        reviewer = u;
        sharingNode = s;
    }

    public void add(CompetencyReview__c review) {
        comps.add(review);
    }

    public void add(MethodReview__c review) {
        methods.add(review);
    }

    public void add(ReviewRating__c review) {
        ratings.add(review);
    }

    public void add(AdditionalComment__c comment) {
        comments.add(comment);
    }
    
    public void add(ScorecardSupportComment__c ssc) {
        ssupcomments.add(ssc);
    }
    
    public void add(ScorecardSupportReview__c ssr) {
        ssupreviews.add(ssr);
    }

    public void setPerformanceReview(PerformanceReview__c r) {
        review = r;
    }

    public PerformanceReview__c getPerformanceReview() {
        return review;
    }

    public void setReviewer(Id u) {
        reviewer = u;
    }

    public String getSharingNode() {
        return sharingNode;
    }

    public List<CompetencyReview__Share> createCompetencyReviewShare(Id node) {

        List<CompetencyReview__Share> shares = new List<CompetencyReview__Share>();

        if(node == null) return shares;

        for(CompetencyReview__c review: comps) {

            if(reviewer == null ||
               review.Reviewer__c == reviewer)
                shares.add(  new CompetencyReview__Share(ParentId = review.Id ,
                                                         UserOrGroupId = node,
                                                         AccessLevel = 'Read'));

        }

        return shares;
    }

    public List<MethodReview__Share> createMethodReviewShare(Id node) {

        List<MethodReview__Share> shares = new List<MethodReview__Share>();

        if(node == null) return shares;

        for(MethodReview__c review: methods) {

            if(reviewer == null ||
               review.Reviewer__c == reviewer)
                shares.add(  new MethodReview__Share(ParentId = review.Id ,
                                                     UserOrGroupId = node,
                                                     AccessLevel = 'Read'));

        }

        return shares;
    }

    public List<ReviewRating__Share> createReviewRatingShare(Id node) {

        List<ReviewRating__Share> shares = new List<ReviewRating__Share>();

        if(node == null) return shares;

        for(ReviewRating__c review: ratings) {

            if(reviewer == null ||
               review.Reviewer__c == reviewer)
                shares.add(  new ReviewRating__Share(ParentId = review.Id ,
                                                      UserOrGroupId = node,
                                                      AccessLevel = 'Read'));

        }

        return shares;
    }

    public List<AdditionalComment__Share> createAdditionalCommentShare(Id node) {

        List<AdditionalComment__Share> shares = new List<AdditionalComment__Share>();

        if(node == null) return shares;

        for(AdditionalComment__c comment: comments) {

            if(reviewer == null ||
               comment.Reviewer__c == reviewer)
                shares.add(  new AdditionalComment__Share(ParentId = comment.Id ,
                                                          UserOrGroupId = node,
                                                          AccessLevel = 'Read'));

        }

        return shares;
    }
    
    public List<ScorecardSupportComment__Share> createScorecardSupportCommentShare(Id node) {

        List<ScorecardSupportComment__Share> shares = new List<ScorecardSupportComment__Share>();

        if(node == null) return shares;
        
        for(ScorecardSupportComment__c ssc: ssupcomments) {

            if(reviewer == null ||
                ssc.Reviewer__c == reviewer)
                shares.add( new ScorecardSupportComment__Share(ParentId = ssc.Id ,
                                                              UserOrGroupId = node,
                                                              AccessLevel = 'Read'));

        }

        return shares;
    }
    
    public List<ScorecardSupportReview__Share> createScorecardSupportReviewShare(Id node) {

        List<ScorecardSupportReview__Share> shares = new List<ScorecardSupportReview__Share>();

        if(node == null) return shares;

        for(ScorecardSupportReview__c ssr: ssupreviews) {

            if(reviewer == null ||
                ssr.Reviewer__c == reviewer)
                shares.add( new ScorecardSupportReview__Share(ParentId = ssr.Id ,
                                                              UserOrGroupId = node,
                                                              AccessLevel = 'Read'));

        }

        return shares;
    }

    public PerformanceReview__Share createPerformanceReviewShare(Id node) {

        if(node == null) return null;

        return new PerformanceReview__Share(ParentId = review.Id ,
                                            UserOrGroupId = node,
                                            AccessLevel = 'Read');

    }

}