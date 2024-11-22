extends Node3D
class_name Portal

@export var linked_portal: Portal
@export var player_camera: Camera3D
@export var output_rotation: int = 0

@export var portal_size: Vector3

@onready var render_mesh: MeshInstance3D = $RenderMesh

@onready var portalcam_viewport: SubViewport = $Viewport
@onready var portalcam_parent: Node3D = $Viewport/Portalcam
@onready var portalcam_camera: Camera3D = $Viewport/Portalcam/Camera3D

func _ready() -> void:
	render_mesh.mesh = BoxMesh.new()
	render_mesh.mesh.size = portal_size
	render_mesh.mesh.material = ShaderMaterial.new()
	render_mesh.mesh.material.shader = preload("res://portal.gdshader")


func _process(delta: float) -> void:
	# Move portalcam parent to linked portal
	portalcam_parent.global_position = linked_portal.global_position
	# Rotate portalcam parent to match linked portal + 180° 
	portalcam_parent.rotation = linked_portal.rotation + Vector3(0, deg_to_rad(output_rotation), 0)
	# Move portalcam in relation to portalcam parent to match player in relation to this portal
	portalcam_camera.position = to_local(player_camera.global_position)
	# Set rotation of portalcam to match playercam
	portalcam_camera.rotation = player_camera.rotation
	
	# Make portal camera and viewport match the player camera
	portalcam_viewport.size = get_window().size
	portalcam_camera.fov = player_camera.fov
	
	# Moving near clip plane as close to portal as possible
	# Custom projection would be better here, but not yet possible in Godot.
	var portal_size = linked_portal.render_mesh.mesh.size
	var max_size = max(portal_size.x, portal_size.y, portal_size.z) * 0.5
	var distance = portalcam_camera.global_position.distance_to(linked_portal.global_position)
	if distance > max_size:
		portalcam_camera.near = distance - max_size
		
	# Map portalcam texture to render mesh with portal shader
	# Since it uses screen-space and the cams always have identical distances,
	# No need to cut anything out. Works like simple greenscreen.
	var material: ShaderMaterial = render_mesh.mesh.surface_get_material(0)
	material.set_shader_parameter("texture_albedo", portalcam_viewport.get_texture())
	render_mesh.mesh.surface_set_material(0, material)
	
