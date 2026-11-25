class_name NoneStoreBackend
extends StoreBackend
## Steam / desktop release: no store. Everything is the base default.

var reason := ""


func _init(m: Node = null, why: String = "") -> void:
	super(m)
	reason = why


func status_text() -> String:
	return "no store" + (" (%s)" % reason if reason != "" else "")
