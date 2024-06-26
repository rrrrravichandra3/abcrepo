public with sharing class OfferFieldHistoryUtils {

	private static Boolean run = true;

     public static Boolean runOnce() {
        if (run) {
            run = false;
            return true;
        } else {
            return run; 
        }
    }
    
	// job req if field changed
	public static void addOfferFieldRecords( Set<Id> OfferIdSets, List<OfferFieldHistory__c> AllFieldUpdates ){

/*
		system.debug('>>>> called me >');

		List<OfferFieldHistory__c> FinalList = new List<OfferFieldHistory__c>();
		Map<Id, ts2__Offer__c> ContainPlcOfferMap = new Map<Id, ts2__Offer__c>();
		
		//* to da
		//Please add the date restriction to the query
		
		List<ts2__Offer__c> ContainPlcOfferList = [select Id from ts2__Offer__c where Id in (select Offer__c from ts2__Placement__c where Offer__c in : OfferIdSets and Workday_Sync_Status__c = 'Synchronized' and createddate >= : Date.newInstance(2015,7,1) )];

		for ( ts2__Offer__c offer : ContainPlcOfferList ){
			ContainPlcOfferMap.put( offer.Id , offer );
		}
		
		for ( OfferFieldHistory__c ofh : AllFieldUpdates ){
			
			if( ContainPlcOfferMap.containsKey( ofh.Offer__c ) ){
			
				FinalList.add( ofh );
			}
		
		}
		
		if ( FinalList.size() > 0 ){
			insert FinalList;
		}
	*/
	}
	
	public static OfferFieldHistory__c CreateEntry( String fieldchanged, String newvalue, String oldvalue, Id offerId  ){
		
		OfferFieldHistory__c entry = new OfferFieldHistory__c();
		entry.FieldChanged__c = fieldchanged;
		entry.NewValue__c = newvalue;
		entry.OldValue__c = oldvalue;
		entry.DateChanged__c = Date.today();
		
		return entry;
	}
	
	public static void CheckField( String fieldName, String newvalue, String oldvalue, Id offerId, Set<Id> OfferIdSet, List<OfferFieldHistory__c> possibleList ){
		if ( newvalue != oldvalue ){
			OfferIdSet.add ( offerId );
			OfferFieldHistory__c newentry = CreateEntry( fieldName, newvalue, oldvalue, offerId );
			possibleList.add( newentry );	 
		}
	}
	
	public static void MapPlcField ( List<OfferFieldHistory__c> OFHlist ){
		/*
		Set<Id> offerSetIds = new Set<Id>();
		Map<Id, Id> OfferPlcMap = new Map<Id, Id>();
		

		for ( OfferFieldHistory__c ofh : OFHlist ){
			offerSetIds.add ( ofh.offer__c );
		}
		
		List<ts2__Placement__c> plaList = [select Id, Offer__c from ts2__Placement__c where Offer__c in : offerSetIds];
		
		for ( ts2__Placement__c p : plaList ){
			OfferPlcMap.put( p.Offer__c ,p.Id );
		}
		
		for ( OfferFieldHistory__c ofh : OFHlist ){
			ofh.Placement__c = OfferPlcMap.get( ofh.Offer__c );		
		}
	*/
	}
	
	public static void SetIdMaps( List<OfferFieldHistory__c> OFHlist  ){
		Set<Id> Idsets = new Set<Id>();
		Set<Id> RecordIds = new Set<Id>();
		
		for ( OfferFieldHistory__c ofh : OFHlist ){

			String id = '';
			if ( ofh.NewValue__c != null )
				id = String.escapeSingleQuotes( ofh.NewValue__c );

			if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
					
				Idsets.add( ofh.NewValue__c );
				Idsets.add( ofh.OldValue__c );
				RecordIds.add ( ofh.id );
        	}        	
        	
        }

	    if ( Idsets.size() > 0 && RecordIds.size() > 0 ){
	    	MapIdFields( Idsets, RecordIds );
	    }        			
		
	}
	
	@future
	public static void MapIdFields( Set<Id> Idsets , Set<Id> recordIdsets ){
		
		List<User> userList = [ select Id, firstname, lastname from User where Id in : Idsets ];
		List<TF2_Business_Site__c> bslist = [select Id, Name from TF2_Business_Site__c where Id in : Idsets ];
		List<TF2_Department__c> cclist = [select Id, Name from TF2_Department__c where Id in : Idsets ];
		List<TF2_PCC__c> pcclist = [select Id, Name from TF2_PCC__c where Id in : Idsets ];
		List<OfferFieldHistory__c> updatelist = new List<OfferFieldHistory__c> ();		
		
		Map<Id, String> UniversalNameMap = new Map<Id, String>();

		for ( User u : userList ){	
			UniversalNameMap.put( u.Id, u.firstname + ' ' + u.lastname );
		}

		for ( TF2_Business_Site__c bs : bslist ){	
			UniversalNameMap.put( bs.Id, bs.Name );
		}
		
		for ( TF2_Department__c d : cclist ){
			UniversalNameMap.put( d.Id, d.Name );		
		}
		
		for ( TF2_PCC__c pcc : pcclist ){
			UniversalNameMap.put( pcc.Id, pcc.Name );		
		}		
				
		for ( OfferFieldHistory__c ofh : [select NewValue__c, OldValue__c from OfferFieldHistory__c where Id in : recordIdsets] ){
			
			//Mapping the Id back to their name
			if ( UniversalNameMap.get( ofh.NewValue__c ) != null )
				ofh.NewValue__c = UniversalNameMap.get( ofh.NewValue__c );
			if ( UniversalNameMap.get( ofh.OldValue__c ) != null )			
				ofh.OldValue__c = UniversalNameMap.get( ofh.OldValue__c );		
			
			updatelist.add ( ofh );
			
		}
		
		if ( updatelist.size() > 0 )
			update updatelist;
			
	}
	
	
	
}