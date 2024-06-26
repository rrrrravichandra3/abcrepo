global class HRStatusResponse 
{
	private String appId;
	private List<Screening> screens;	
	private String sumStatus;
	private String discreps;
	private Double percentcomp = 0.0;
		
	public HRStatusResponse()
	{
		screens = new List<Screening>();
	}

	public HRStatusResponse(String applicantId)
	{
		appId = applicantId;
		screens = new List<Screening>();
	}

	public String ApplicantId
	{
		get{ return appId; }
		set{ appId = value; }
	}
	public String SummaryStatus
	{
		get{ return sumStatus; }
		set{ sumStatus = value; }
	}
	public String Discrepancies
	{
		get{ return discreps; }
		set{ discreps = value; }
	}
	public Double PercentComplete
	{
		get{ return percentcomp; }
		set{ percentcomp = value; }
	}
	public List<Screening> Screenings
	{
		get{ return screens; }
		set{ screens = value; }
	}
}