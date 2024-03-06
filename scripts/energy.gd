extends Node

func speed_to_shield_cost(speed: float):
	if in_range(speed, 0, 500):
		return speed / 10
	elif in_range(speed, 500, INF):
		return speed / 14
	
func in_range(value: float, min_value: float, max_value: float):
	return value >= min_value and value < max_value
