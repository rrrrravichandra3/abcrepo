public class lightCastSkills {

    public List<Attributions> attributions;
    public List<Data> data;

	public class Attributions {
		public String name;
		public String text;
	}

	public class Type {
		public String id;
		public String name;
	}

	public class Skill {
		public String description;
		public String descriptionSource;
		public String id;
		public String infoUrl;
		public String name;
		public List<Tags> tags;
		public Type type;
	}

	public class Data {
		public Double confidence;
		public Skill skill;
	}

	public class Tags_Z {
	}

	public class Skill_Z {
		public String description;
		public Object descriptionSource;
		public String id;
		public String infoUrl;
		public String name;
		public List<Tags_Z> tags;
		public Type type;
	}

	public class Tags {
		public String key;
		public String value;
	}

	
	public static LightCastSkills parse(String json) {
		return (LightCastSkills) System.JSON.deserialize(json, LightCastSkills.class);
	}
}