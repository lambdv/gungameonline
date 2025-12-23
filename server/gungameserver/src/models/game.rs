use serde::{Deserialize, Serialize};
use std::time::SystemTime;

#[derive(Debug, Clone)]
pub struct Player {
    pub id: u32,
    pub name: String,
    pub position: (f32, f32, f32),
    pub rotation: (f32, f32, f32),
    pub last_update: SystemTime,

    // Health state
    pub current_health: u32,
    pub max_health: u32,

    // Weapon and ammo state
    pub current_weapon_id: u32,
    pub current_ammo: u32,
    pub max_ammo: u32,

    // Reload state
    pub is_reloading: bool,
    pub reload_end_time: Option<SystemTime>,

    // Combat timing
    pub last_shot_time: SystemTime,
}


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WeaponData {
    pub id: u32,
    pub name: String,
    pub damage: u32,
    pub fire_rate: f32,
    pub range: f32,
    pub reload_time: f32,
    pub ammo: u32,
}
