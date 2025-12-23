use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::Json,
};
use crate::models::{AppState, CreateLobbyRequest, JoinLobbyRequest, JoinLobbyResponse, LobbyInfo, PlayerInfo};

// HTTP API Handlers
pub async fn create_lobby(
    State(state): State<AppState>,
    Json(request): Json<CreateLobbyRequest>,
) -> Result<Json<LobbyInfo>, StatusCode> {
    let mut server = state.write().await;

    let max_players = request.max_players.unwrap_or(4);
    let scene = request.scene.unwrap_or_else(|| "world".to_string());
    match server.create_lobby(request.code.clone(), max_players, scene.clone()) {
        Ok(_) => {
            if let Some(lobby) = server.get_lobby(&request.code) {
                let lobby_info = LobbyInfo {
                    code: lobby.code.clone(),
                    player_count: lobby.players.len(),
                    max_players: lobby.max_players,
                    players: lobby.players.values().map(|p| PlayerInfo {
                        id: p.id,
                        name: p.name.clone(),
                    }).collect(),
                    server_ip: "127.0.0.1".to_string(), // In production, get actual server IP
                    udp_port: 8081,
                    scene: lobby.scene.clone(),
                };
                Ok(Json(lobby_info))
            } else {
                Err(StatusCode::INTERNAL_SERVER_ERROR)
            }
        }
        Err(_) => Err(StatusCode::CONFLICT),
    }
}

pub async fn join_lobby(
    State(state): State<AppState>,
    Path(code): Path<String>,
    Json(request): Json<JoinLobbyRequest>,
) -> Result<Json<JoinLobbyResponse>, StatusCode> {
    let mut server = state.write().await;

    match server.join_lobby(&code, request.player_name) {
        Ok(player_id) => {
            if let Some(lobby) = server.get_lobby(&code) {
                let lobby_info = LobbyInfo {
                    code: lobby.code.clone(),
                    player_count: lobby.players.len(),
                    max_players: lobby.max_players,
                    players: lobby.players.values().map(|p| PlayerInfo {
                        id: p.id,
                        name: p.name.clone(),
                    }).collect(),
                    server_ip: "127.0.0.1".to_string(),
                    udp_port: 8081,
                    scene: lobby.scene.clone(),
                };

                let response = JoinLobbyResponse {
                    lobby: lobby_info,
                    player_id,
                };
                Ok(Json(response))
            } else {
                Err(StatusCode::NOT_FOUND)
            }
        }
        Err(_) => Err(StatusCode::NOT_FOUND),
    }
}


pub async fn get_lobby(
    State(state): State<AppState>,
    Path(code): Path<String>,
) -> Result<Json<LobbyInfo>, StatusCode> {
    let server = state.read().await;

    match server.get_lobby(&code) {
        Some(lobby) => {
            let lobby_info = LobbyInfo {
                code: lobby.code.clone(),
                player_count: lobby.players.len(),
                max_players: lobby.max_players,
                players: lobby.players.values().map(|p| PlayerInfo {
                    id: p.id,
                    name: p.name.clone(),
                }).collect(),
                server_ip: "127.0.0.1".to_string(),
                udp_port: 8081,
                scene: lobby.scene.clone(),
            };
            Ok(Json(lobby_info))
        }
        None => Err(StatusCode::NOT_FOUND),
    }
}



pub async fn list_lobbies(State(state): State<AppState>) -> Json<Vec<LobbyInfo>> {
    println!("HTTP: List lobbies request received");
    let server = state.read().await;

    let lobbies: Vec<LobbyInfo> = server.lobbies.values().map(|lobby| {
        LobbyInfo {
            code: lobby.code.clone(),
            player_count: lobby.players.len(),
            max_players: lobby.max_players,
            players: lobby.players.values().map(|p| PlayerInfo {
                id: p.id,
                name: p.name.clone(),
            }).collect(),
            server_ip: "127.0.0.1".to_string(),
            udp_port: 8081,
            scene: lobby.scene.clone(),
        }
    }).collect();

    println!("HTTP: Returning {} lobbies", lobbies.len());
    Json(lobbies)
}