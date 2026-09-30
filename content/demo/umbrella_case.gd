extends RefCounted


func get_clues() -> Array:
	return [
		{
			"id": "case_request",
			"title": "Missing Umbrella Description",
			"source": "Owner's claim request",
			"reliability": "Direct owner description",
			"tags": ["case", "identity"],
			"contradiction_tags": [],
			"detail": "Nora Vale left a navy umbrella on the lobby rack at about 8:40 PM. Its handle has a yellow electrical-tape repair and a small brass duck-head cap."
		},
		{
			"id": "forecast_board",
			"title": "Rain Forecast",
			"source": "Lobby notice board",
			"reliability": "Routine public notice",
			"tags": ["weather", "paper"],
			"contradiction_tags": [],
			"detail": "Heavy rain began before closing. A wet umbrella would have been obvious and inconvenient indoors."
		},
		{
			"id": "dry_outline",
			"title": "Dry Outline on the Rack",
			"source": "Lobby umbrella rack",
			"reliability": "Direct observation",
			"tags": ["physical", "lobby_move"],
			"contradiction_tags": [],
			"detail": "One hook is dry inside a field of rainwater. Something remained there until after the rain had already started."
		},
		{
			"id": "ticket_47b",
			"title": "Claim Ticket 47B",
			"source": "Lost-and-found board",
			"reliability": "Contemporaneous paper record",
			"tags": ["paper", "identity", "lost_and_found"],
			"contradiction_tags": [],
			"detail": "Ticket 47B: NAVY UMBRELLA / YELLOW-TAPED HANDLE / BRASS BIRD CAP. Logged to Cabinet B at 8:58 PM."
		},
		{
			"id": "alex_statement",
			"title": "Alex's Lobby Transfer",
			"source": "Alex, front desk",
			"reliability": "Named witness",
			"tags": ["witness", "lobby_move", "alex_cleared"],
			"contradiction_tags": [],
			"detail": "Alex says he cleared the lobby rack at 8:55 PM and carried the navy umbrella to Lost & Found before returning to the desk."
		},
		{
			"id": "closing_log",
			"title": "Closing Log Entry",
			"source": "Front desk clipboard",
			"reliability": "Contemporaneous staff log",
			"tags": ["paper", "lobby_move", "alex_cleared"],
			"contradiction_tags": [],
			"detail": "8:56 PM — ALEX: rack cleared; one navy umbrella sent east hall. Alex signs back onto desk duty at 8:59 PM."
		},
		{
			"id": "cabinet_trace",
			"title": "Cabinet B Water Ring",
			"source": "Lost & Found Cabinet B",
			"reliability": "Direct physical trace",
			"tags": ["physical", "cabinet_intermediate"],
			"contradiction_tags": ["stayed_in_cabinet"],
			"detail": "Cabinet B is empty, but its lower shelf has a fresh crescent water ring and one short strand of yellow tape adhesive."
		},
		{
			"id": "shift_board",
			"title": "Closing Shift Board",
			"source": "Staff office",
			"reliability": "Posted staff assignment",
			"tags": ["paper", "mina_route", "identity"],
			"contradiction_tags": [],
			"detail": "Mina Reyes is assigned the 9:00 PM east-hall sweep and rear service close. Her initials are MR."
		},
		{
			"id": "wet_property_policy",
			"title": "Wet Property Procedure",
			"source": "Staff handbook",
			"reliability": "Written procedure",
			"tags": ["paper", "reason", "drying"],
			"contradiction_tags": ["theft"],
			"detail": "Soaking lost property must be moved to the rear drying rail before overnight storage to protect paper records and donation cartons."
		},
		{
			"id": "transfer_tag",
			"title": "MR Transfer Tag",
			"source": "Storage overflow shelf",
			"reliability": "Physical staff tag",
			"tags": ["paper", "cabinet_intermediate", "mina_route"],
			"contradiction_tags": ["stayed_in_cabinet"],
			"detail": "A damp transfer tag marked 47B / REAR DRY / MR is caught beneath an empty umbrella sleeve."
		},
		{
			"id": "fan_timer",
			"title": "Rear Fan Timer",
			"source": "Maintenance panel",
			"reliability": "Mechanical record",
			"tags": ["physical", "mina_route", "drying"],
			"contradiction_tags": [],
			"detail": "The loading-bay exhaust fan was manually switched on at 9:07 PM, matching Mina's rear-service closing assignment."
		},
		{
			"id": "mina_statement",
			"title": "Mina's Second Transfer",
			"source": "Mina Reyes",
			"reliability": "Named witness against physical evidence",
			"tags": ["witness", "mina_route"],
			"contradiction_tags": ["stayed_in_cabinet"],
			"detail": "Mina remembers taking a soaking navy umbrella from Cabinet B onto the service route during her east-hall sweep."
		},
		{
			"id": "mina_reason",
			"title": "Why Mina Moved It",
			"source": "Mina Reyes",
			"reliability": "Witness statement consistent with policy",
			"tags": ["witness", "reason", "drying"],
			"contradiction_tags": ["theft"],
			"detail": "Mina moved the umbrella because it was dripping onto paper claim files and donation cartons. She intended to return it after it dried."
		},
		{
			"id": "rear_drying_rail",
			"title": "Rear Drying Rail",
			"source": "Loading bay",
			"reliability": "Direct observation",
			"tags": ["physical", "drying", "service_route"],
			"contradiction_tags": ["theft"],
			"detail": "The rear rail is wet beneath one empty hook. A yellow tape fiber clings to the rail beside fresh navy fabric dye."
		},
		{
			"id": "umbrella_recovered",
			"title": "Nora's Umbrella Recovered",
			"source": "Loading bay drying rail",
			"reliability": "Direct recovery",
			"tags": ["resolution"],
			"contradiction_tags": ["theft"],
			"detail": "Behind a folded safety curtain hangs the navy umbrella: yellow-taped handle, brass duck-head cap, still damp but intact."
		},
	]


func get_deductions() -> Array:
	return [
		{
			"id": "identity_47b",
			"title": "Ticket 47B is Nora's umbrella.",
			"description": "The paper record describes the same distinctive object reported missing.",
			"required_clue_ids": ["case_request", "ticket_47b"],
			"minimum_support": 2,
			"prerequisite_deductions": [],
			"refute_evidence_tags": [],
			"refute_contradiction_tags": []
		},
		{
			"id": "lobby_to_lost_found",
			"title": "The umbrella moved from the lobby to Lost & Found.",
			"description": "The first disappearance was a routine staff transfer, not the final loss.",
			"required_clue_ids": ["dry_outline", "alex_statement", "closing_log"],
			"minimum_support": 2,
			"prerequisite_deductions": ["identity_47b"],
			"refute_evidence_tags": [],
			"refute_contradiction_tags": []
		},
		{
			"id": "cabinet_was_intermediate",
			"title": "Cabinet B was only an intermediate stop.",
			"description": "Ticket 47B reached the cabinet, then the item left it again.",
			"required_clue_ids": ["ticket_47b", "cabinet_trace", "transfer_tag"],
			"minimum_support": 2,
			"prerequisite_deductions": ["lobby_to_lost_found"],
			"refute_evidence_tags": [],
			"refute_contradiction_tags": []
		},
		{
			"id": "mina_service_route",
			"title": "Mina carried 47B through the service route.",
			"description": "Mina's assignment, transfer evidence, service timing, or her own statement converge on the same second move.",
			"required_clue_ids": ["shift_board", "transfer_tag", "fan_timer", "mina_statement"],
			"minimum_support": 2,
			"prerequisite_deductions": ["cabinet_was_intermediate"],
			"refute_evidence_tags": [],
			"refute_contradiction_tags": []
		},
		{
			"id": "drying_not_theft",
			"title": "The umbrella was moved to dry, not stolen.",
			"description": "The second transfer follows the center's wet-property procedure and ends at the rear drying rail.",
			"required_clue_ids": ["wet_property_policy", "mina_reason", "rear_drying_rail"],
			"minimum_support": 2,
			"prerequisite_deductions": ["mina_service_route"],
			"refute_evidence_tags": [],
			"refute_contradiction_tags": []
		},
		{
			"id": "alex_took_it",
			"title": "Alex kept the umbrella.",
			"description": "A plausible early accusation if the first transfer is mistaken for the final disappearance.",
			"required_clue_ids": ["case_request"],
			"minimum_support": 1,
			"prerequisite_deductions": [],
			"refute_evidence_tags": ["alex_cleared"],
			"refute_contradiction_tags": []
		},
		{
			"id": "outside_theft",
			"title": "Someone stole it from Cabinet B.",
			"description": "The empty cabinet can look like theft until the internal transfer chain becomes visible.",
			"required_clue_ids": ["cabinet_trace"],
			"minimum_support": 1,
			"prerequisite_deductions": [],
			"refute_evidence_tags": ["drying"],
			"refute_contradiction_tags": ["theft"]
		},
	]


func get_witnesses() -> Dictionary:
	return {
		"alex": {
			"name": "ALEX",
			"role": "WESTSIDE COMMUNITY CENTER // FRONT DESK",
			"portrait": "alex",
			"opening": "Alex looks up from the front desk. “You’re still hunting that umbrella?”"
		},
		"mina": {
			"name": "MINA REYES",
			"role": "WESTSIDE COMMUNITY CENTER // CLOSING STAFF",
			"portrait": "mina",
			"opening": "Mina folds her arms beneath the shift board. “If this is about closing, make it quick.”"
		}
	}
