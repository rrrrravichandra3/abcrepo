@isTest
private class IFB_CSVReaderTest{ 
    /**
     * Test some use cases for reading IETF RFC 4180-compliant CSV values.
    */
    public static testMethod void readIETFRFC4180CSVValueTest() {
        String data = null;  // Placeholder for data to use in testing.
        
        System.debug(data = IFB_Parser.CRLF);
        new IFB_CSVReader.CSVValue('', false, IFB_Parser.CRLF)
                .assertEquals(IFB_CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = '""' + IFB_Parser.CRLF);
        new IFB_CSVReader.CSVValue('', true, IFB_Parser.CRLF)
                .assertEquals(IFB_CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = '"",asdf' + IFB_Parser.CRLF);
        new IFB_CSVReader.CSVValue('', true, IFB_Parser.COMMA)
                .assertEquals(IFB_CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = ',asdf' + IFB_Parser.CRLF);
        new IFB_CSVReader.CSVValue('', false, IFB_Parser.COMMA)
                .assertEquals(IFB_CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = '"' + IFB_Parser.CRLF + '",blah' + IFB_Parser.CRLF);
        new IFB_CSVReader.CSVValue(IFB_Parser.CRLF, true, IFB_Parser.COMMA)
                .assertEquals(IFB_CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = '"""marty""","""chang"""' + IFB_Parser.CRLF);
        new IFB_CSVReader.CSVValue('"marty"', true, IFB_Parser.COMMA)
                .assertEquals(IFB_CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = '"com""pli""cate' + IFB_Parser.CRLF + 'd"'
                + IFB_Parser.CRLF);
        new IFB_CSVReader.CSVValue('com"pli"cate' + IFB_Parser.CRLF + 'd', true, IFB_Parser.CRLF)
                .assertEquals(IFB_CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = 'asdf' + IFB_Parser.CRLF);
        new IFB_CSVReader.CSVValue('asdf', false, IFB_Parser.CRLF)
                .assertEquals(IFB_CSVReader.readIETFRFC4180CSVValue(data));
    }
	
    /**
     * Tests one case of parsing a CSV file that contains the following data:
     *
     * abc,"def","g""h""i"
     * "j
     * kl","m
     * n""o""",
    */
    public static testMethod void readIETFRFC4180CSVFile() {
      String data = 'abc,"def","g""h""i"' + IFB_Parser.CRLF + '"j' + IFB_Parser.CRLF
             + 'kl","m' + IFB_Parser.CRLF + 'n""o""",';
      
      List<List<String>> fileValues =
             IFB_CSVReader.readIETFRFC4180CSVFile(Blob.valueOf(data));
    }

}