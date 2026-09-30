extends RefCounted

func get_definitions() -> Array:
	return [
		{
			"id": "packet_impossible_timestamp",
			"title": "Impossible Timestamp",
			"source": "Workstation // Packet 03",
			"reliability": "Direct artifact",
			"tags": ["technical", "temporal", "packet"],
			"contradiction_tags": ["ordinary_timestamp", "simple_local_forgery"],
			"temporal_provenance": "Captured before E; timestamp claims a later chronology.",
			"detail_levels": [
				{
					"level": 1,
					"text": "Packet 03 carries a timestamp later than the workstation's current clock. The mismatch is too large to be a normal write delay."
				},
				{
					"level": 2,
					"text": "The same impossible time appears in more than one field inside the packet. A single damaged metadata value would not explain both."
				}
			]
		},
		{
			"id": "packet_survival_phrase",
			"title": "The Surviving Sentence",
			"source": "Workstation // Packet 03",
			"reliability": "Direct artifact",
			"tags": ["language", "identity", "packet"],
			"contradiction_tags": ["random_corruption"],
			"temporal_provenance": "Sender chronology unknown.",
			"detail_levels": [
				{
					"level": 1,
					"text": "The final intact sentence reads: SHE REFUSED TO FORGET. SHE REFUSED TO DIE."
				}
			]
		},
		{
			"id": "corridor_service_sticker",
			"title": "Fresh Service Sticker",
			"source": "Apartment Corridor // Intercom",
			"reliability": "Physical trace",
			"tags": ["physical", "mundane_record", "building"],
			"contradiction_tags": [],
			"temporal_provenance": "",
			"detail_levels": [
				{
					"level": 1,
					"text": "The intercom carries a paper service sticker dated yesterday. It can later serve as an independent mundane record."
				}
			]
		}
	]
