public class DataUtil 
{
	public DataUtil(){}
	
	public string formatYearMonth(String tagName, String yr, String mo)
	{
		String ret = '';
		if(yr==null)
		{
			ret = '<' + tagName + '><s1:YearMonth>1900-01</s1:YearMonth></' + tagName + '>';
		}
		else if(mo==null)
		{
			ret = '<' + tagName + '><s1:YearMonth>' + yr + '-01</s1:YearMonth></' + tagName + '>';
		}
		else if((yr.length()==2 || yr.length()==4) && (mo.length()==1 || mo.length()==2))
		{
			if(yr.length()==2)
			{
				if(Integer.valueOf(yr) >= System.today().year()+10)
				{
					yr = '19' + yr;
				}else{
					yr = '20' + yr;
				}
			}
			if(mo.length()==1)
			{
				mo = '0' + mo;
			}
			ret = '<' + tagName + '><s1:YearMonth>' + yr + '-' + mo + '</s1:YearMonth></' + tagName + '>';
		}
		else
		{ 
			ret = '<' + tagName + '><s1:YearMonth>1900-01</s1:YearMonth></' + tagName + '>';
		}
		return ret;
	}
	public string formatPhone(String fone)
	{
		if(fone==null)
		{
			return '';
		}else{
			String f = fone.replaceAll('[^0-9]','');
			if(f.length() == 10)
			{									
			}else if(f.length() == 11){
				if(f.substring(0,1) != '1')
				{
					return fone;
				}else{
					f = f.substring(1);
				}
			}else{
				return fone;
			}
	//		return f.substring(0,3) + '-' + f.substring(3,6) + '-' + f.substring(6);
			return f;
		}
	}
}