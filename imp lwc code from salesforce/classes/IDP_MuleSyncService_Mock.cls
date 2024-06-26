@IsTest
Global class IDP_MuleSyncService_Mock implements HttpCalloutMock {
    Global HttpResponse respond(HTTPRequest req) {
        /*sample request
        [
            {
				"salesforceID":"a3rc000001zczG6AAI",
                "employeeID":"736158",
                "developmentItem":"IDPO-000016-Action One",
                "additionalInformation":"Support 1",
                "statusWID":"55483f63a1b801b8469350d8334b290e",
                "developmentItemWID":"WD1234",
                "completedDate":"2020-02-28",
                "isDeleted":false
         	},
            {
				"salesforceID":"a3rc000001zczG6AAI",
                "employeeID":"736159",
                "developmentItem":"IDPO-000016-Action two",
                "additionalInformation":"Support 2",
                "statusWID":"55483f63a1b801b8469350d8334b290F",
                "developmentItemWID":"WD12345",
                "completedDate":"2020-02-27",
                "isDeleted":false
             }
        ]*/
        
        
        /*sample response
        [
            {
                "salesforceID": "SF_IDP_ACTION_ID1",
                "developmentItemWID": "WD_DEVELOPMENT_ITEM_WID",
                "message": "successful",
				"status":"success"
            },
			{
                "salesforceID": "SF_IDP_ACTION_ID2",
                "developmentItemWID": "WD_DEVELOPMENT_ITEM_WID",
                "message": "successful",
                "status":"success"
            }
        ]*/
        HttpResponse res = new HttpResponse();
        List<String> actionColl= new List<String>();
        List<String> workdayIds= new List<String>();
        List<IDP_MuleSyncService_ResponseWrapper> coll =(List<IDP_MuleSyncService_ResponseWrapper>) 
            System.JSON.deserialize(req.getBody(), List<IDP_MuleSyncService_ResponseWrapper>.class);
        for(IDP_MuleSyncService_ResponseWrapper wrp : coll){
            actionColl.add(wrp.salesforceID );
            workdayIds.add(wrp.developmentItemWID);
        }
        
        res.setBody('[{ ' +
                    '    "salesforceID": "' + actionColl[0] + '", ' +
                    '    "developmentItemWID": "' +workdayIds[0] + '",'+
                    '    "message": "successful",'+
                    '    "status": "success"'+
                    '},'+
                    '{ ' +
                    '    "salesforceID": "' + actionColl[1] + '", ' +
                    '    "developmentItemWID": "' +workdayIds[1] + '",'+
                    '    "message": "success",'+
                    '    "status": "success"'+
                    '}] ');
        res.setStatusCode(200);
        return res;
    }
}