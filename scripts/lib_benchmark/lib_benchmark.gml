/// @function benchmark_start(name)
function benchmark_start(_name) {
	return {name: _name, start: get_timer()};
}


/// @function benchmark_end(benchmark);
function benchmark_end(_benchmark) {
	var result = benchmark_result(_benchmark)
	return string("{0} took {1}",_benchmark.name,result);
}

/// @function benchmark_result(benchmark)
function benchmark_result(_benchmark) {
	var sTime = _benchmark.start;
	var eTime = get_timer();	
	return string_format(((eTime - sTime)/1000),1,4) + "ms"
	}