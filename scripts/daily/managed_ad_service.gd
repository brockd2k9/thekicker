class_name ManagedAdService
extends AdService
## The Daily Challenge's ads, routed through the AdManager autoload, so they
## follow the same rules as every other ad (consent, test / real IDs, no SDK
## outside AdManager, mock in the editor, none on Steam).
## The Daily keeps its own placement names; they map to AdManager's here.

const PLACEMENTS := {
	AdService.RETRY: "DAILY_RETRY",
	AdService.SAVER: "STREAK_SAVER",
}


func platform_has_ads() -> bool:
	var m := _manager()
	return m != null and m.platform_has_ads()


func is_ready(_placement: String) -> bool:
	var m := _manager()
	return m != null and m.is_rewarded_ready()


func unavailable_text() -> String:
	var m := _manager()
	return m.unavailable_text() if m != null else super()


func _show(placement: String) -> bool:
	var m := _manager()
	if m == null:
		return false
	return await m.show_rewarded(str(PLACEMENTS.get(placement, placement)))


func _manager() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.root.get_node_or_null("AdManager") if tree != null and tree.root != null else null
