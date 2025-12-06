extends Resource
class_name PlayerData
@export_category("Horizontal Movement")
##absolute maximum speed a player can go excepting dash
@export var maxSpeed: float = 500.0
##used to calc accelerations
@export var timeToReachMaxSpeed: float = 0.02
##used to calc deac
@export var timeToReachZeroSpeed: float = 0.02
@export_category("Vertical Movement")
@export var jumpHeight: float = 70.0
@export var jumps: int = 1
##basic gravity
@export var gravityScale: float = 2.0
##maximum speed a player can fall at
@export var terminalVelocity: float = 500.0
##gravity modifier when descending
@export var descendingGravityFactor: float = 1.3
##bool to enable variable jump height depending on the button press time
@export var shortHopAct: bool = true
## factor for variable jump height. Higher this is, the shorter  the jump
@export var jumpVariable: float = 2.0
@export_category("Dash Params")
@export var dashes: int = 1
##time for which the player dashes
@export var dashTime: float = 0.05
##dash cooldown time
@export var dashCoolTime: float = 1.0
##velocity of player during the dash(needs to be quite high)
@export var dashMagnitude: float = 2000
@export_category("Thruster Params")
@export var thruster_force: float = -900.0
@export var thruster_max_fuel: float = 1.8
@export var thruster_drain_rate: float = 1.0
@export var thruster_refill_rate: float = 0.6
@export var thruster_refill_delay: float = 0.4
