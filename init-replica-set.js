rs.initiate(
	{
		_id: "rs-savino",
		version: 1,
		members: [
			{ _id: 0, host : "mongodb0.example.net:27017" },
			{ _id: 1, host : "mongodb1.example.net:27017" },
			{ _id: 2, host : "mongodb2.example.net:27017" }
		]
	}
)
rs.add('ubuntu-mongo2:27017');
rs.add('ubuntu-mongo3:27017');
rs.status();
