extends Resource
class_name PlayerData
@export_category("Horizontal Movement")
@export var maxSpeed: float = 200.0
@export var timeToReachMaxSpeed: float = 0.2
@export var timeToReachZeroSpeed: float = 0.2
@export_category("Vertical Movement")
@export var jumpHeight: float = 2.0
@export var jumps: int = 1
@export var gravityScale: float = 20.0
@export var terminalVelocity: float = 500.0
@export var descendingGravityFactor: float = 1.3
@export var shortHopAct: bool = true
@export var jumpVariable: float = 2.0
@export_category("Dash Params")
@export var dashes: int = 1
@export var dashTime: float = 2.5
@export var dashMagnitude: float = 4.0
