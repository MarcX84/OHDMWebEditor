/* 
 * Script-Datei die die Listen der Tags aus OSM-Enthält und Sie in 
 * eine Liste von Listen speichert
 */



var standardTags = ["aerialway", "aeroway", "amenity", "barrier",
  "boundary", "building", "craft", "emergency", "geological", "highway",
  "historic", "landuse", "leisure", "man made", "military", "natural",
  "office", "places", "power", "public transport", "Railway", "route",
  "shop", "sport", "tourism", "Waterway", "addresses", "annotation",
  "name", "properties", "references", "restrictions", "user defined"];

var tmp = ["cable_car", "chair_lift", "drag_lift", "gondola", "goods",
  "j-bar", "magic_carpet", "mixed_lift", "platter", "pylon", "rope_tow",
  "station", "t-bar", "zip_line", "user defined"];

var unterTags = [];   // Liste von Listen der Untertags
unterTags.push(tmp);

tmp = ["aerodrome", "apron", "gate", "helipad", "hangar", "navigationaid",
  "runway", "taxiway", "terminal", "windstock", "user defined"];

unterTags.push(tmp);

tmp = ["bar", "bbq", "biergarten", "cafe", "drinking_water", "fast_food",
  "foof_court", "ice_cream", "pub", "restaurant", "college", "kindergarten",
  "library", "public_bookcase", "school", "university", "bicycle_parking",
  "bicycle_repair_station", "bicycle_rental", "boat_sharing", "bus_station",
  "car_rental", "car_sharing", "car_wash", "charging_station",
  "ferry_terminal", "fuel", "grit_bin", "parking", "parking_entrance",
  "parking_space", "taxi", "atm", "bank", "bureau_de_change", "baby_hatch",
  "clinic", "dentist", "doctors", "hospital", "nursing_home", "pharmacy",
  "social_facility", "veterinary", "arts_centre", "brothel", "casino",
  "cinema", "community_centre", "fountain", "gambling", "nightclub",
  "planetarium", "social_centre", "stripclub", "studio", "swingerclub",
  "theatre", "animal_boarding", "animal_shelter", "bench", "clock",
  "courthouse", "coworking_space", "crematorium", "crypt", "dojo", "embassy",
  "fire_station", "grave_yard", "gym", "hunting_stand", "game_feeding",
  "marketplace", "photo_booth", "place_of_worship", "police", "post_box",
  "post_office", "prison", "ranger_station", "register_office", "recycling",
  "rescue_station", "sauna", "shelter", "shower", "telephone", "toilets",
  "townhall", "vending_machine", "waste_basket", "waste_disposal",
  "watering_place", "water_point", "user defined"];

unterTags.push(tmp);

tmp = ["cable_barrier", "city_wall", "ditch", "fence", "guard_rail",
  "handrail", "hedge", "kerb", "retaining_wall", "wall", "block",
  "bollard", "border_control", "bump_gate", "bus_trap", "cattle_grid",
  "chain", "cycle_barrier", "debris", "entrance", "full-height_turnstile",
  "gate", "hampshire_gate", "height_restrictor", "horse_stile",
  "jersey_barrier", "kent_carriage_gap", "kissing_gate", "lift_gate",
  "log", "motorcycle_barrier", "rope", "sally_port", "spikes", "stile",
  "sumb_buster", "swing_gate", "toll_booth", "turnstile", "yes",
  "user defined"];

unterTags.push(tmp);

tmp = ["administrative", "maritime", "national_park", "political",
  "postal_code", "religious_administration", "protected_area",
  "user defined"];
unterTags.push(tmp);

tmp = ["apartments", "farm", "hotel", "house", "detached", "residential",
  "dormitory", "terrace", "houseboat", "static_caravan", "commercial",
  "industrial", "retail", "warehouse", "cathedral", "chapel", "church",
  "mosque", "temple", "synagogue", "shrine", "civic", "hospital", "school",
  "stadium", "train_station", "transportation", "university", "public",
  "barn", "bridge", "bunker", "cabin", "construction", "cowshed",
  "farm_auxiliary", "garage", "garages", "greenhouse", "hangar", "hut",
  "roof", "shed", "stable", "sty", "transformer_tower", "service", "ruins",
  "yes", "user defined", "entrance", "height", "building:levels",
  "building:fireproof"];
//ab entrance sonderbehandlung
unterTags.push(tmp);

tmp = ["agricultural_engines", "basket_maker", "beekeeper", "blacksmith",
  "brewery", "boatbuilder", "bookbinder", "carpenter", "carpet_layer",
  "caterer", "clockmaker", "confectionery", "dressmaker", "electrician",
  "floorer", "gardener", "glaziery", "handicraft", "hvac", "insulation",
  "jeweller", "key_cutter", "locksmith", "metal_construction", "optican",
  "painter", "parquet_layer", "photographer", "photographic_laboratory",
  "plasterer", "plumber", "pottery", "rigger", "roofer", "saddler",
  "sailmaker", "sawmill", "scaffolder", "sculptor", "shoemaker",
  "stand_builder", "stonemason", "sun_protection", "chimney_sweeper",
  "tailor", "tiler", "tinsmith", "upholsterer", "watchmaker",
  "window_construction", "winery", "user defined"];
unterTags.push(tmp);

tmp = ["ambulance_station", "defibrillator", "fire_extinguisher",
  "fire_flapper", "fire_hose", "fire_hydrant", "water_tank",
  "lifeguard_base", "lifeguard_tower", "lifeguard_platform",
  "lifeguard_place", "assembly_point", "access_point", "phone",
  "ses_station", "siren", "user defined"];
unterTags.push(tmp);

tmp = ["moraine", "outcrop", "paleontological_site", "user defined"];
unterTags.push(tmp);

tmp = ["motorway", "trunk", "primary", "secondary", "tertiary",
  "unclassified", "residential", "service", "motorway_link", "trunk_link",
  "primary_link", "secondary_link", "tertiary_link", "living_street",
  "pedestrian", "track", "bus_guideway", "raceway", "road", "footway",
  "cycleway", "bridleway", "steps", "path", "proposed", "construction",
  ////////////Special///////////////
  "abutters", "bicycle_road", "driving_side", "ford", "ice_road", "incline",
  "junction", "lanes", "lit", "motorroad", "mountain_pass", "mtb:scale",
  "mtb:scale:uphill", "mtb:scale:imba", "mtb:description", "overtaking",
  "parking:condition", "parking:lane", "passing_places", "sac_scale",
  "service", "surface", "tactile_paving", "tracktype", "traffic_calming",
  "trial_visibility", "winter_road",
  ///////////Special - End///////////
  "bus_stop", "crossing", "emergency_access_point", "escape", "give_way",
  "mini_roundabout", "motorway_junction", "passing_place", "rest_area",
  "speed_camera", "street_lamp", "services", "stop", "traffic_signals",
  "turning_circle", "user defined"];
unterTags.push(tmp);
//cycleway spezialbehandlung

tmp = ["archaeological_site", "aircraft", "battlefield", "boundary_stone",
  "building", "castle", "cannon", "city_gate", "citywalls", "farm", "fort",
  "manor", "memorial", "monument", "optical_telegraph", "ruins",
  "rune_stones", "ship", "tomb", "wayside_cross", "wayside_shrine",
  "wreck", "yes", "user defined"];
unterTags.push(tmp);

tmp = ["allotments", "basin", "brownfield", "cementry", "commercial",
  "constuction", "farmland", "farmyard", "forest", "garages", "grass",
  "greenfield", "greenhouse_horticulture", "industrial", "landfill",
  "meadow", "military", "orchard", "peat_cutting", "plant_nursery", "port",
  "quarry", "railway", "redreation_ground", "reservoir", "residential",
  "retail", "salt_pound", "village_green", "vineyard", "user defined"];
unterTags.push(tmp);

tmp = ["adult_gaming_centre", "amusement_arcade", "beach_resort",
  "bandstand", "bird_hide", "dance", "dog_park", "firepit", "fishing",
  "garden", "golf_course", "hackerspace", "ice_rink", "marina",
  "miniature_golf", "nature_reserve", "park", "pitch", "playground",
  "slipway", "sports_centre", "stadium", "summer_camp", "swimming_pool",
  "swimming_area", "track", "water_park", "wildlife_hide", "user defined"];
unterTags.push(tmp);

tmp = ["adit", "beacon", "breakwater", "bridge", "bunker_silo",
  "campanile", "chimney", "communications_tower", "crane", "cross",
  "cutline", "clearcut", "embankment", "dyke", "flagpole", "gasometer",
  "groyne", "kiln", "lighthouse", "mast", "mineshaft", "monitoring_station",
  "offshore_platform", "petrolium_well", "pier", "pipeline",
  "reservoir_covered", "silo", "snow_fence", "snow_met", "storage_tank",
  "street_cabinet", "surveillance", "survey_point", "tower",
  "wastewater_plant", "watermill", "water_tower", "water_well", "water_tap",
  "water_works", "windmill", "works", "user defined"];
unterTags.push(tmp);

tmp = ["airfield", "bunker", "barracks", "checkpoint", "danger_area",
  "naval_base", "nuclear_explosion_site", "obstacle_course", "range",
  "training_area", "user defined"];
unterTags.push(tmp);

tmp = ["wood", "tree_row", "tree", "scrub", "heath", "moor", "grassland",
  "fell", "bare_rock", "scree", "shingle", "sand", "mud", "water",
  "wetland", "glacier", "bay", "beach", "coastline", "spring", "peak",
  "volcano", "valley", "ridge", "arete", "cliff", "saddle", "rock", "stone",
  "sinkhole", "cave_entrance", "user defined"];
unterTags.push(tmp);

tmp = ["accountant", "administrative", "architect", "association", "company",
  "educational_institution", "employment_agency", "estate_agent", "forestry",
  "foundation", "goverment", "guide", "insurance", "it", "lawyer",
  "newspaper", "ngo", "notary", "political_party", "private_investigator",
  "quango", "real_estate_agent", "register", "religion", "research", "tax",
  "tax_advisor", "telecommunication", "travel_agent", "water_utility",
  "user defined"];
unterTags.push(tmp);

tmp = ["country", "state", "region", "province", "district", "county",
  "municipality", "city", "borough", "suburb", "quarter", "neighbourhood",
  "city_block", "plot", "town", "village", "hamlet", "isolated_dwelling",
  "farm", "allotments", "continent", "archipelago", "island", "islet",
  "locality", "user defined", "population", "name", "place_numbers",
  "postal_code", "reference_point", "is_in"];
unterTags.push(tmp);
///////ab population special

tmp = ["plant", "cable", "converter", "generator", "heliostat", "line",
  "minor_line", "pole", "substation", "switch", "tower", "transformer",
  "user defined"];
unterTags.push(tmp);

tmp = ["stop_position", "platform", "station", "stop_area", "user defined"];
unterTags.push(tmp);

tmp = ["abandoned", "construction", "disused", "funicular", "light_rail",
  "miniature", "monorail", "narrow_gauge", "preserved", "rail", "subway",
  "tram",
  ///////////////Special - Start//////////
  "bridge", "cutting", "electrified", "embankment", "frequency", "service",
  "tracks", "tunnel", "usage", "voltage",
  //////////////Special - Ende///////////
  "halt", "station", "subway_entrance", "tram_stop", "buffer_stop", "derail",
  "crossing", "level_crossing", "signal", "switch", "railway_crossing",
  "turntable", "roundhouse", "user defined"];
unterTags.push(tmp);

tmp = ["route", "bus", "inline_skates", "canoe", "detour", "ferry",
  "hiking", "horse", "light_rail", "mtb", "nordic_walking", "pipeline",
  "piste", "power", "railway", "road", "running", "ski", "train", "tram",
  "user defined"];
unterTags.push(tmp);

tmp = ["alcohol", "bakery", "beverages", "butcher", "cheese", "chocolate",
  "coffee", "confectionery", "convenience", "deli", "dairy", "farm",
  "greengrocer", "pasta", "pastry", "seafood", "tea", "wine",
  "department_store", "general", "kiosk", "mall", "supermarket",
  "baby_goods", "bag", "boutique", "clothes", "fabric", "fashion", "jewelry",
  "leather", "shoes", "tailor", "watches", "chairity", "second_hand",
  "variety_store", "beauty", "chemsi", "cosmetics", "erotic", "hairdresser",
  "hearing_aids", "herbalist", "massage", "medical_supply", "optician",
  "tattoo", "bathroom_furnishing", "doityourself", "energy", "florist",
  "furnace", "garden_centre", "garden_furniture", "gas", "glaziery",
  "hardware", "houseware", "locksmith", "paint", "trade", "antiques", "bed",
  "candles", "carpet", "curtain", "furniture", "interior_decoration",
  "kitchen", "window_blind", "computer", "electronics", "hifi",
  "mobile_phone", "radiotechnics", "vacuum_cleaner", "bicycle", "car",
  "car_repair", "car_parts", "fishing", "free_flying", "hunting", "motorcycle",
  "outdoor", "scuba_diving", "sports", "tyres", "water_sports", "art",
  "craft", "frame", "games", "model", "music", "musical_instrument",
  "photo", "trophy", "video", "video_games", "anime", "books", "gift",
  "newsagent", "stationery", "ticket", "copyshop", "dry_cleaning",
  "e-cigarette", "funeral_directors", "laundry", "money_lender",
  "pawnbroker", "pet", "pyrotechnics", "religion", "storage_rental",
  "tobacco", "toys", "travel_agency", "vacant", "weapons", "user defined"];
unterTags.push(tmp);

tmp = ["9pin", "10pin", "american_football", "aikido", "archery",
  "athletics", "australian_football", "base", "badminton", "bandy",
  "baseball", "basketball", "beachvolleyball", "billiards", "bmx",
  "bobsleigh", "boules", "bowls", "boxing", "canadian_football",
  "canoe", "chess", "cliff_diving", "climbing", "climbing_adventure",
  "cockfighting", "cricket", "croquet", "curling", "cycling", "curling",
  "cycling", "darts", "dog_racing", "equestrian", "fencing",
  "field_hockey", "free_flying", "gaelic_games", "golf", "gymnastics",
  "handball", "hapkido", "horseshoes", "horse_racing", "ice_hockey",
  "ice_skating", "ice_stock", "judo", "karting", "kitesurfing", "korfball",
  "model_aerodrome", "motocross", "motor", "multi", "obstacle_course",
  "orienteering", "paddle_tenis", "paragliding", "pelota", "racquet",
  "rc_car", "roller_skating", "rowing", "rugby_league", "rugby_union",
  "running", "safety_training", "sailing", "scuba_diving", "shooting",
  "skateboard", "skiing", "soccer", "surfing", "swimming", "table_tennis",
  "table_soccer", "taekwondo", "tennis", "toboggan", "volleyball",
  "water_polo", "water_ski", "weightlifting", "wrestling", "user defined"];
unterTags.push(tmp);

tmp = ["alpine_hut", "apartment", "attraction", "artwork", "camp_site",
  "caravan_site", "chalet", "gallery", "guest_house", "hostel", "hotel",
  "information", "motel", "museum", "picnic_site", "theme_park",
  "viewpoint", "wilderness_hut", "zoo", "yes", "user defined"];
unterTags.push(tmp);

tmp = ["river", "riverbank", "stream", "brook", "canal", "drain", "ditch",
  "dock", "boatyard", "dam", "weir", "waterfall", "lock_gate",
  "turning_point", "water_point",
  ///////Special-Start////////    
  "intermittent", "lock", "mooring", "service", "tunnel",
  //////Special-End//////////
  "user defined"];
unterTags.push(tmp);

tmp = ["addr:housenumber", "addr:housename", "addr:street", "addr:place",
  "addr:postcode", "addr:flats", "addr:city", "addr:country", "addr:full",
  "addr:hamlet", "addr:suburb", "addr:subdistrict", "addr:district",
  "addr:province", "addr:state", "addr:interpolation", "addr:inclusion"];
unterTags.push(tmp);

tmp = ["attribution", "comment", "description", "email", "fax", "fixme",
  "image", "note", "phone", "source", "source:name", "source_ref", "todo",
  "url", "website", "wikipedia"];
unterTags.push(tmp);

tmp = ["name", "alt_name", "int_name", "loc_name", "nat_name",
  "official_name", "old_name", "reg_name", "short_name", "sorting_name"];
unterTags.push(tmp);

tmp = ["area", "bridge", "covered", "crossing", "cutting", "disused",
  "drive_through", "drive_in", "electrified", "ele", "embankment",
  "end_date", "est_width", "fire_object:tyype", "fire_operator",
  "fire_rank", "frequency", "inscription", "internet_access", "layer",
  "leaf_cycle", "leaf_type", "location", "narrow", "nudism",
  "opening_hours", "operator", "power_supply:schedule", "start_date",
  "service_times", "tactile_paving", "tidal", "TMC:LocationCode",
  "tunnel", "toilets:wheelchair", "wheelchair", "width"];
unterTags.push(tmp);

tmp = ["iata", "icao", "int_ref", "lcn_ref", "nat_ref", "ncn_ref",
  "old_ref", "rcn_ref", "ref", "reg_ref", "source_ref"];
unterTags.push(tmp);

tmp = ["access", "agricultural", "atv", "bdouble", "bicycle", "boat",
  "emergency", "foot", "forestry", "goods", "hazmat", "hgv", "horse",
  "inline_skates", "lhv", "mofa", "moped", "motorboat", "motorcar",
  "motorcycle", "motor_vehicle", "psv", "roadtrain", "ski", "tank",
  "vehicle", "4wd_only", "charge", "maxheight", "maxlength", "maxspeed",
  "maxstay", "maxweight", "maxwidth", "minspeed", "noexit", "oneway",
  "Relation:restriction", "toll", "traffic_sign"];
unterTags.push(tmp);


