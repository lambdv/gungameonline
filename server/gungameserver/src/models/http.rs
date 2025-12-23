use serde::{Deserialize, Serialize};

// UDP Game Types
#[derive(Serialize, Deserialize, Debug, Clone)]
enum ClientMessage {
    Position { x: f32, y: f32, z: f32, rx: f32, ry: f32, rz: f32 },
    Shoot { target_id: u32 },
    TakeDamage { damage: u32, attacker_id: u32 }, // For server validation
    Reload {},
    RequestState {}, // Client requesting their current state
    WeaponSwitch { weapon_id: u32 }, // Client switching weapons
}

#[derive(Serialize, Deserialize, Debug)]
enum ServerMessage {
    UpdatePosition { client_id: u32, x: f32, y: f32, z: f32, rx: f32, ry: f32, rz: f32 },
    PlayerShot { client_id: u32, target_id: u32 },
    PlayerStateUpdate {
        client_id: u32,
        health: u32,
        max_health: u32,
        ammo: u32,
        max_ammo: u32,
        is_reloading: bool,
        weapon_id: u32,
    },
    PlayerDamaged { client_id: u32, damage: u32, attacker_id: u32 },
    ReloadStarted { client_id: u32 },
    ReloadFinished { client_id: u32 },
    StateSync {  // Periodic full state synchronization for all players
        players: Vec<PlayerSyncState>,
    },
    WeaponSwitched { client_id: u32, weapon_id: u32 }, // Player switched weapons
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PlayerSyncState {
    pub id: u32,
    pub health: u32,
    pub max_health: u32,
    pub current_weapon_id: u32,
    pub current_ammo: u32,
    pub max_ammo: u32,
    pub is_reloading: bool,
}


#[derive(Serialize, Deserialize, Debug)]
pub struct CreateLobbyRequest {
    pub code: String,  // Unique lobby identifier
    pub max_players: Option<u32>,  // Optional player limit (defaults to 4)
    pub scene: Option<String>,  // Game scene/world for this lobby
}

/// Request to join an existing lobby
#[derive(Serialize, Deserialize, Debug)]
pub struct JoinLobbyRequest {
    pub player_name: String,  // Display name for the joining player
}


#[derive(Serialize, Deserialize, Debug)]
pub struct JoinLobbyResponse {
    pub lobby: LobbyInfo,
    pub player_id: u32,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct LobbyInfo {
    pub code: String,
    pub player_count: usize,
    pub max_players: u32,
    pub players: Vec<PlayerInfo>,
    pub server_ip: String,
    pub udp_port: u16,
    pub scene: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct PlayerInfo {
    pub id: u32,
    pub name: String,
}
