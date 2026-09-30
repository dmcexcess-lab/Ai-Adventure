extends RefCounted

func get_definitions() -> Array:
	return [
		{
			"id": "packet_not_random_damage",
			"title": "The packet is not random damage.",
			"description": "The surviving packet structure is too coherent to dismiss as accidental corruption.",
			"required_clue_ids": [
				"packet_impossible_timestamp",
				"packet_survival_phrase"
			],
			"required_tags": [],
			"minimum_support": 2,
			"prerequisite_deductions": [],
			"refute_evidence_tags": [],
			"refute_contradiction_tags": ["random_damage_confirmed"],
			"skill_insight": {
				"skill": "reasoning",
				"threshold": 2,
				"text": "The independent structure of the surviving fields matters more than their wording."
			}
		},
		{
			"id": "packet_contains_temporal_claim",
			"title": "The packet contains a genuine temporal claim.",
			"description": "The packet is making a claim about chronology rather than merely containing malformed metadata.",
			"required_clue_ids": [],
			"required_tags": ["temporal"],
			"minimum_support": 1,
			"prerequisite_deductions": ["packet_not_random_damage"],
			"refute_evidence_tags": ["timestamp_spoof"],
			"refute_contradiction_tags": [],
			"skill_insight": {}
		},
		{
			"id": "corridor_record_is_independent",
			"title": "The corridor record is an independent trace.",
			"description": "The building's physical service record exists outside the workstation's own data path.",
			"required_clue_ids": ["corridor_service_sticker"],
			"required_tags": ["physical"],
			"minimum_support": 1,
			"prerequisite_deductions": [],
			"refute_evidence_tags": ["forged_physical_record"],
			"refute_contradiction_tags": [],
			"skill_insight": {}
		}
	]
