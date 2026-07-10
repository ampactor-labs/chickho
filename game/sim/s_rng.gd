class_name SimRNG
extends RefCounted
# xorshift32 kept in the low 32 bits of GDScript's int64: every operation
# is masked, so results are identical on every platform. Never use the
# engine RNG anywhere the sim (or an offer) can see.

var state: int = 1

func _init(seed_v: int = 1) -> void:
	state = seed_v & 0xFFFFFFFF
	if state == 0:
		state = 0x9E3779B9

func next() -> int:
	var x := state
	x = (x ^ ((x << 13) & 0xFFFFFFFF)) & 0xFFFFFFFF
	x = (x ^ (x >> 17)) & 0xFFFFFFFF
	x = (x ^ ((x << 5) & 0xFFFFFFFF)) & 0xFFFFFFFF
	state = x
	return x

func below(n: int) -> int:
	# n small (item picks), modulo bias is irrelevant here
	return next() % n
