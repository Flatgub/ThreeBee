function library_get_all() {
	static map = ds_map_create();
	return map;
	}

function library_present(_name) {
	var map = library_get_all();
	return ds_map_exists(map, _name);
	}
	
function library_declare(_name) {
	var map = library_get_all();
	map[? _name] = true;
	}