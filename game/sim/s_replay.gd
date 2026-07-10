class_name SimReplay
extends RefCounted
# Replay wire format: a run is its input log. Strict version match, no
# migrations (two-top rule) — a sim-affecting change bumps SIM_VERSION
# and old replays are viewed with old builds, not converted.
#
# layout: "CHKR" | u16 version | u16 round | u32 len | len input bytes

const MAGIC := [0x43, 0x48, 0x4B, 0x52]

static func encode(round_n: int, inputs: PackedByteArray) -> PackedByteArray:
	var b := PackedByteArray()
	for m in MAGIC:
		b.append(m)
	_u16(b, SimC.SIM_VERSION)
	_u16(b, round_n)
	_u32(b, inputs.size())
	b.append_array(inputs)
	return b

static func decode(b: PackedByteArray) -> Dictionary:
	# returns {} on any mismatch — caller treats that as "not playable here"
	if b.size() < 12:
		return {}
	for i in range(4):
		if b[i] != MAGIC[i]:
			return {}
	var ver := b[4] | (b[5] << 8)
	if ver != SimC.SIM_VERSION:
		return {}
	var round_n := b[6] | (b[7] << 8)
	var n := b[8] | (b[9] << 8) | (b[10] << 16) | (b[11] << 24)
	if b.size() != 12 + n:
		return {}
	return { "version": ver, "round": round_n, "inputs": b.slice(12) }

static func _u16(b: PackedByteArray, v: int) -> void:
	b.append(v & 0xFF)
	b.append((v >> 8) & 0xFF)

static func _u32(b: PackedByteArray, v: int) -> void:
	b.append(v & 0xFF)
	b.append((v >> 8) & 0xFF)
	b.append((v >> 16) & 0xFF)
	b.append((v >> 24) & 0xFF)
