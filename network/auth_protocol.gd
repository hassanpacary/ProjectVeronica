class_name AuthProtocol
extends RefCounted

## auth_protocol - AuthProtocol refCounted
##
## Authentication payload exchanged by the client and the server.


#region ─────────────────────────────────── SERVER ─────────────────────────────────────

## Server auth_data: client acceptance, and the server version.
static func encode_server_payload(
		accepted: bool,
		server_version: String
) -> PackedByteArray:
	return JSON.stringify(
			{"accepted": accepted, "version": server_version}
	).to_utf8_buffer()


## Returns the server auth_data if every field has the expected type.
static func decode_server_payload(payload: PackedByteArray) -> Dictionary:
	# Check every type before using the data.
	var auth_data: Variant = JSON.parse_string(payload.get_string_from_utf8())

	if auth_data is not Dictionary:
		return {}

	var fields: Dictionary = auth_data
	if fields.get("accepted") is not bool or fields.get("version") is not String:
		return {}

	return fields

#endregion


#region ─────────────────────────────────── CLIENT ─────────────────────────────────────

## Client auth data: the game version.
static func encode_client_payload(version: String) -> PackedByteArray:
	return JSON.stringify({"version": version}).to_utf8_buffer()


## Returns the client auth data if every field has the expected type.
static func decode_client_payload(payload: PackedByteArray) -> String:
	# Check every type before using the data.
	var auth_data: Variant = JSON.parse_string(payload.get_string_from_utf8())

	if auth_data is not Dictionary:
		return ""

	var fields: Dictionary = auth_data
	var version: Variant = fields.get("version")

	if version is not String:
		return ""

	return version

#endregion
