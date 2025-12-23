use std::collections::HashMap;
use super::game::Player;

pub type LobbyCode = String;

#[derive(Debug)]
pub struct Lobby {
    pub code: LobbyCode,
    pub players: HashMap<u32, Player>,
    pub max_players: u32,
    pub dummy_player: Option<Player>,
    pub client_addresses: HashMap<u32, std::net::SocketAddr>, // player_id -> client address
    pub scene: String,
}

pub enum Scene{
    World
}