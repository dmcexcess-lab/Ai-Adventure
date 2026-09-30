extends RefCounted

func get_definitions() -> Array:
	return [
		{
			"id": "mara_bell",
			"name": "Mara Bell",
			"role": "Building manager",
			"start_node": "greeting",
			"nodes": {
				"greeting": {
					"line": "Mara looks up from a stack of maintenance slips. \"If this is about the intercom, it already had its service call.\"",
					"choices": [
						{
							"id": "ask_service",
							"topic_id": "service_call",
							"text": "What was serviced yesterday?",
							"next_node": "service_answer",
							"conditions": {},
							"effects": [
								{"type": "open_topic", "topic_id": "service_call"},
								{"type": "trust_delta", "amount": 1}
							]
						},
						{
							"id": "ask_packet",
							"topic_id": "impossible_packet",
							"text": "I have a machine timestamp that hasn't happened yet.",
							"next_node": "packet_answer",
							"conditions": {"clues_all": ["packet_impossible_timestamp"]},
							"effects": [
								{"type": "open_topic", "topic_id": "impossible_packet"},
								{"type": "set_flag", "flag": "mara_heard_packet_claim", "value": true}
							],
							"once_key": "mara_packet_question"
						},
						{
							"id": "read_mara",
							"topic_id": "mara_read",
							"text": "Watch her reaction instead of pressing the point.",
							"conditions": {"clues_all": ["packet_impossible_timestamp"]},
							"effects": [],
							"skill_check": {
								"check_id": "mara_read_evasion",
								"skill": "empathy",
								"threshold": 3,
								"modifier": 0,
								"context": "Read Mara's reaction to the impossible timestamp"
							},
							"success_node": "empathy_read_success",
							"failure_node": "empathy_read_failure",
							"success_effects": [
								{"type": "trust_delta", "amount": 1},
								{"type": "acquire_clue", "clue_id": "packet_impossible_timestamp", "detail_level": 2}
							],
							"failure_effects": [
								{"type": "open_topic", "topic_id": "mara_direct_route"}
							],
							"once_key": "mara_empathy_attempt"
						},
						{
							"id": "ask_failed_route",
							"topic_id": "service_record",
							"text": "Forget the read. Show me the paper trail.",
							"next_node": "record_answer",
							"conditions": {
								"failed_approaches_all": ["mara_read_evasion"],
								"topics_open_all": ["service_call"]
							},
							"effects": [
								{"type": "open_topic", "topic_id": "service_record"},
								{"type": "acquire_clue", "clue_id": "corridor_service_sticker", "detail_level": 1}
							]
						},
						{
							"id": "ask_copy",
							"topic_id": "service_record",
							"text": "Can I see the service record?",
							"next_node": "record_answer",
							"conditions": {
								"min_trust": 1,
								"flags": {"mara_heard_packet_claim": true}
							},
							"effects": [
								{"type": "open_topic", "topic_id": "service_record"},
								{"type": "acquire_clue", "clue_id": "corridor_service_sticker", "detail_level": 1}
							]
						},
						{
							"id": "leave",
							"text": "That's all for now.",
							"end": true,
							"conditions": {},
							"effects": []
						}
					]
				},
				"service_answer": {
					"line": "\"The intercom clock and relay. Same unit, same wall. I signed the slip myself.\"",
					"choices": [
						{"id": "back", "text": "Something else.", "next_node": "greeting", "conditions": {}, "effects": []}
					]
				},
				"packet_answer": {
					"line": "Her expression flattens. \"Then either your clock is wrong, or mine is about to become interesting.\"",
					"choices": [
						{"id": "back", "text": "Something else.", "next_node": "greeting", "conditions": {}, "effects": []}
					]
				},
				"empathy_read_success": {
					"line": "She glances at the timestamp, then at yesterday's carbon copy before answering. The hesitation is tiny, but specific: she trusts the paper more than your machine.",
					"choices": [
						{"id": "back", "text": "Follow the paper trail.", "next_node": "greeting", "conditions": {}, "effects": []}
					]
				},
				"empathy_read_failure": {
					"line": "Whatever Mara thinks, her face gives you nothing useful. The human read is a dead end; the records are not.",
					"choices": [
						{"id": "back", "text": "Use the records instead.", "next_node": "greeting", "conditions": {}, "effects": []}
					]
				},
				"record_answer": {
					"line": "She slides the carbon copy across the desk. The physical service date is yesterday.",
					"choices": [
						{"id": "back", "text": "Something else.", "next_node": "greeting", "conditions": {}, "effects": []}
					]
				},
				"timestamp_reaction": {
					"line": "Mara studies the timestamp twice. \"That terminal clock was synchronized after yesterday's service. Here—compare it with the paper slip.\"",
					"choices": [
						{"id": "back", "text": "Continue.", "next_node": "greeting", "conditions": {}, "effects": []}
					]
				}
			},
			"evidence_reactions": [
				{
					"id": "show_impossible_timestamp",
					"evidence_ids": ["packet_impossible_timestamp"],
					"evidence_tags": ["temporal"],
					"conditions": {},
					"next_node": "timestamp_reaction",
					"once_key": "mara_saw_impossible_timestamp",
					"effects": [
						{"type": "record_reaction", "reaction_id": "mara_saw_impossible_timestamp"},
						{"type": "set_flag", "flag": "mara_timestamp_shown", "value": true},
						{"type": "trust_delta", "amount": 1},
						{"type": "acquire_clue", "clue_id": "corridor_service_sticker", "detail_level": 1}
					]
				}
			]
		}
	]
