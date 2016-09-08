rs.initiate(
	{
		_id: "rs-savino",
		version: 1,
		members: [
			{ _id: 0, host : "ubuntu-mongo1:27017" },
			{ _id: 1, host : "ubuntu-mongo2:27017" },
			{ _id: 2, host : "ubuntu-mongo3:27017" }
		]
	}
)
rs.add('ubuntu-mongo2:27017');
rs.add('ubuntu-mongo3:27017');
rs.status();
