global class Screening 
{
	private String scrName;
	private String scrType;
	private String ordStatus;
	private String resStatus;
	
	public Screening(){}
	
	public Screening(String screeningName, String screeningType, String orderStat, String resultStat)
	{
		scrName = screeningName;
		scrType = screeningType;
		ordStatus = orderStat;
		resStatus = resultStat;
	}
	public String ScreenName
	{
		get{ return scrName; }
		set{ scrName = value; }
	}
	public String ScreenType
	{
		get{ return scrType; }
		set{ scrType = value; }
	}
	public String OrderStatus
	{
		get{ return ordStatus; }
		set{ ordStatus = value; }
	}
	public String ResultStatus
	{
		get{ return resStatus; }
		set{ resStatus = value; }
	}	
}