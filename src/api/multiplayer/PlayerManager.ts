import uWS, { type TemplatedApp } from "uWebSockets.js";
import { clearInterval } from "node:timers";
import { getLogger, type Logger } from "@logtape/logtape";
import type { PlayerState } from "../../common/types.ts";
import type { JsonOutput, JsonPlayer, JsonPlayerAsk, Player } from "../core/Constants.ts";
import type Controller from "../core/Controller.ts";
import { ENV_AGGRESSIVE_DISCONNECT, ENV_EXTRA_VERBOSE } from "../index.ts";

// Override the log function
const logger: Logger = getLogger(["multi", "PlayerManager"]);

/**
 * Creates a websocket server to handle player connections
 */
class PlayerManager {
	controller: Controller;

	webSocketServer: TemplatedApp;

	//playerList: Map<WS ID/IP ADDRESS, Player>;
	playerList: Map<string, Player>;

	/**
	 * Creates a Websocket Server
	 * @param {any} controller - The controller of the project
	 */
	constructor(controller: Controller) {
		this.controller = controller;
		this.playerList = new Map<string, Player>();

		this.webSocketServer = uWS
			.App()
			.listen(Number(process.env.HEADSET_WS_PORT), (token) => {
				if (token) {
					logger.info(`Creating monitor server on: ws://0.0.0.0:${Number(process.env.HEADSET_WS_PORT)}`);
					logger.debug("{token}", { token });
				} else {
					logger.error(`Failed to listen on the specified port ${process.env.HEADSET_WS_PORT}`);
				}
			})
			.ws("/*", {
				// Server doesn't compress yet
				// WebSocketSharp (Unity side) doesn't support deflating messages
				// https://github.com/sta/websocket-sharp/issues/580
				//: (uWS.SHARED_COMPRESSOR | uWS.SHARED_DECOMPRESSOR),

				open: (ws) => {
					const remoteAddr: string = Buffer.from(ws.getRemoteAddressAsText()).toString();
					logger.debug(`New ws connection from ${remoteAddr}, waiting for connection message...`);
					logger.trace(ws.toString());
				},
				// ======================================

				message: (ws, message) => {
					let jsonPlayer: JsonPlayer;
					try {
						jsonPlayer = JSON.parse(Buffer.from(message).toString());
					} catch (e) {
						logger.error("Failed to parse player message: {e}", { e });
						return;
					}

					// Resolve existing player for this socket if already authenticated
					const playerKey =
						this.getIndexByPlayerWs(ws) ?? (jsonPlayer.id ? this.getIndexByPlayerId(jsonPlayer.id) : undefined);
					if (playerKey && this.playerList.has(playerKey)) {
						this.playerList.get(playerKey)!.is_alive = true;
					}

					switch (jsonPlayer.type) {
						case "pong":
							if (playerKey && this.playerList.has(playerKey)) {
								this.playerList.get(playerKey)!.is_alive = true;
							}
							break;

						case "ping":
							if (playerKey) {
								this.sendMessageByWs(playerKey, {
									type: "pong",
									id: jsonPlayer.id,
								});
							}
							break;

						case "connection": {
							const existingKey =
								this.getIndexByPlayerId(jsonPlayer.id) ??
								(this.playerList.has(jsonPlayer.id) ? jsonPlayer.id : undefined);

							if (existingKey && this.playerList.has(existingKey)) {
								const player: Player = this.playerList.get(existingKey)!;

								logger.info(`Reconnecting player of id ${player.id}`);
								if (player.timeout) clearInterval(player.timeout);
								if (player.ws && player.ws !== ws) {
									try {
										player.ws.end(1000, "Replaced by new connection");
									} catch (_e) {}
								}
								player.ws = ws;
								player.connected = true;
								player.is_alive = true;
								player.date_connection = `${new Date().getHours().toString().padStart(2, "0")}:${new Date().getMinutes().toString().padStart(2, "0")}`;
								player.ping_interval = jsonPlayer.heartbeat || 5000;

								// Add in simulation if game already started and player is reconnecting
								if (!player.in_game) {
									this.addPlayerConnection(existingKey, true);
								}

								// Restart ping interval
								player.timeout = setInterval(() => this.sendHeartbeat(existingKey), player.ping_interval);

								this.notifyPlayerChange(existingKey);
								this.controller.notifyMonitor();
							} else {
								logger.info(`New connection of the player of id ${jsonPlayer.id}`);
								const newKey = jsonPlayer.id;

								this.playerList.set(newKey, {
									id: jsonPlayer.id,
									ws: ws,
									ping_interval: jsonPlayer.heartbeat || 5000,
									is_alive: true,
									connected: false,
									in_game: false,
									date_connection: "",
								});

								this.addPlayerConnection(newKey, true);

								// Trigger heartbeat
								this.playerList.get(newKey)!.timeout = setInterval(
									() => this.sendHeartbeat(newKey),
									jsonPlayer.heartbeat || 5000,
								);

								this.notifyPlayerChange(newKey);
								this.controller.notifyMonitor();
							}
							break;
						}

						case "expression":
							if (playerKey && this.playerList.has(playerKey)) {
								logger.trace(`[PLAYER ${this.playerList.get(playerKey)?.id}] Sent expression: {json}`, {
									json: jsonPlayer.expr,
								});
								this.controller.sendExpression(this.playerList.get(playerKey)!.id, jsonPlayer.expr!);
							}
							break;

						case "ask":
							{
								const askJsonPlayer: JsonPlayerAsk = JSON.parse(Buffer.from(message).toString());
								if (playerKey && this.playerList.has(playerKey)) {
									logger.trace(`[PLAYER ${this.playerList.get(playerKey)?.id}] Sent expression: {json}`, {
										json: askJsonPlayer,
									});
								}
								this.controller.sendAsk(askJsonPlayer);
							}
							break;

						case "disconnect_properly":
							ws.end(1000, playerKey ?? "");
							if (playerKey && this.playerList.has(playerKey)) {
								this.controller.purgePlayer(this.playerList.get(playerKey)!.id);
							}
							break;

						default:
							logger.warn(
								`The last message received from ${playerKey && this.playerList.has(playerKey) ? this.playerList.get(playerKey)?.id : "unknown"} had an unknown type\n{json}`,
								{ json: jsonPlayer },
							);
					}

					// Client is alive as he just communicated
					if (playerKey && this.playerList.has(playerKey)) this.playerList.get(playerKey)!.is_alive = true;
				},

				// ======================================

				close: (ws, code: number, message) => {
					// Try exact ws reference match first
					const playerKey: string | undefined = this.getIndexByPlayerWs(ws);

					if (!playerKey) {
						logger.debug("Can't find which player WebSocket was closed (might be unauthenticated or already replaced)");
					} else {
						try {
							const player = this.playerList.get(playerKey);
							if (player) {
								logger.info(`Connection closed with ${player.id}.\n\tCode: ${code}`);
								code !== 1000 ? logger.info(`, Reason: ${Buffer.from(message).toString()}`) : "";

								// Only mark disconnected if this close event is for the current active socket.
								// If the player already reconnected, player.ws points to the new socket and
								// we must not clobber the reconnected state.
								if (player.ws === ws) {
									logger.debug("Flagging player as disconnected");
									player.connected = false;
									clearInterval(player.timeout);
								} else {
									logger.debug(`Close event for stale WebSocket of ${player.id} — ignoring`);
								}
							}
						} catch (err) {
							logger.error("Error during close handling: {err}", { err });
						}
					}

					// Handle specific close codes
					switch (code) {
						case 1003:
							logger.error(`[Err ${code}] Unsupported data sent by the client.\nMessage: {message}`, { message });
							break;

						case 1006:
							logger.error(`[Err ${code}] Abnormal websocket closure with message: ${Buffer.from(message).toString()}`);
							break;

						case 1009:
							logger.error(`[Err ${code}] Message too big!`);
							if (message) {
								try {
									logger.error(`Player ${playerKey} - Message: ${Buffer.from(message).toString()}`);
									if (typeof message.byteLength !== "undefined") {
										logger.error(`Message size: ${message.byteLength} bytes`);
									}
								} catch (e) {
									const error = e as Error;
									logger.error("couldn't display error message: {error}", { error: error.message });
								}
							}
							break;

						case 1005:
							logger.warn(`[Err ${code}] Closed without reason; the game probably been closed in Unity IDE`);
							break;

						default:
							if (code !== 1000)
								// 1000 = Normal Closure
								logger.error(`[Err ${code}] Unexpected closure`);
							else logger.debug("Closing normally");
					}

					this.controller.notifyMonitor();
				},
			});
	}

	// Getters
	getIndexByPlayerId(id: string): string | undefined {
		if (this.playerList.has(id)) {
			return id;
		}
		let toReturn: string | undefined;
		for (const [key, player] of this.playerList) {
			if (player.id === id) {
				toReturn = key;
				break;
			}
		}
		if (toReturn === undefined) logger.error(`Cannot find player with ID ${id}`);

		return toReturn;
	}

	getIndexByPlayerWs(ws: uWS.WebSocket<unknown>): string | undefined {
		let toReturn: string | undefined;
		for (const [key, player] of this.playerList) {
			if (player.ws === ws) {
				toReturn = key;
				break;
			}
		}
		if (toReturn === undefined) logger.trace(`Cannot find player with WS ${ws}`);

		return toReturn;
	}

	/**
	 * Gets the state of a specific player
	 * @param {string} playerWsId - Player WS ID or Player ID
	 * @returns {PlayerState} - The state of the player
	 */
	getPlayerState(playerWsId: string): PlayerState | undefined {
		const key = this.playerList.has(playerWsId) ? playerWsId : this.getIndexByPlayerId(playerWsId);
		if (key && this.playerList.has(key)) {
			const player: Player = this.playerList.get(key)!;
			return { connected: player.connected, in_game: player.in_game, date_connection: player.date_connection };
		} else logger.warn(`Can't find player with ID ${playerWsId}`);
	}

	/**
	 * Gets the in_game ID of a specific player
	 * NB: The `playerWsId` is different from the in_game ID as the first one represent the IP address connecting to the mw
	 * @param {string} playerWsId - Player ID
	 * @returns {string} - The ID player
	 */
	getPlayerId(playerWsId: string): string | undefined {
		if (this.playerList.has(playerWsId)) {
			return this.playerList.get(playerWsId)?.id;
		}
		const key = this.getIndexByPlayerId(playerWsId);
		if (key && this.playerList.has(key)) {
			return this.playerList.get(key)?.id;
		}
		logger.warn(`Can't find player with ws ID ${playerWsId}`);
	}

	/**
	 * Gets array with all players under a format which can be JSON.stringify
	 * Removed attribute `ws` which is very verbose and not necessary
	 */
	getArrayPlayerList() {
		// Turn Map to a dictionary
		// Remove very verbose `ws` attribute
		return Object.fromEntries(
			Array.from(this.playerList.entries()).map(([, value]) => [
				value.id,
				{ ...value, timeout: undefined, ws: undefined },
			]),
		);
	}

	// Managing Player list

	/**
	 * Sets the connection state of a player
	 * @param {string} playerWsId - Player ID
	 * @param {boolean} connected - Connection status
	 */
	addPlayerConnection(playerWsId: string, connected: boolean) {
		const key = this.playerList.has(playerWsId) ? playerWsId : this.getIndexByPlayerId(playerWsId);
		if (!key || !this.playerList.has(key)) return;

		const player = this.playerList.get(key)!;
		player.connected = connected;
		player.date_connection = `${new Date().getHours().toString().padStart(2, "0")}:${new Date().getMinutes().toString().padStart(2, "0")}`;

		if (
			this.controller.gama_connector !== undefined &&
			!["NONE", "NOTREADY"].includes(this.controller.gama_connector.jsonGamaState.experiment_state)
		) {
			logger.debug(`Adding player ${player.id} to GAMA simulation...`);
			this.controller.addInGamePlayer(key);
			this.togglePlayerInGame(key, true);
		}
	}

	/**
	 * Withdraws a player
	 * @param {string} playerWsId - Player ID
	 */
	removePlayer(playerWsId: string) {
		logger.debug(`Deleting player ${playerWsId}`);

		// Manage both working with Player ID or Player IP
		const playerKey: string | undefined = this.playerList.has(playerWsId)
			? playerWsId
			: this.getIndexByPlayerId(playerWsId);

		if (playerKey && this.playerList.has(playerKey)) {
			const player = this.playerList.get(playerKey);
			try {
				// Properly close web socket
				player?.ws?.end(1000, playerKey);
			} catch (_e) {
				logger.warn(`${playerKey} is already disconnected from middleware\nFull log of player: {player}`, {
					player: player,
				});
			}

			if (ENV_AGGRESSIVE_DISCONNECT) {
				logger.debug("Aggressively deleting player");
				// Remove player
				this.playerList.delete(playerKey);
			}
		} else {
			logger.warn(`Can't remove un-existing player ${playerWsId}`);
		}
	}

	/**
	 * Disconnect every players
	 */
	removeAllPlayer() {
		logger.debug("Disconnect every player at once");

		for (const [playerWsId] of this.playerList) {
			this.removePlayer(playerWsId);
		}
	}

	closePlayerWS(playerWsId: string) {
		if (this.playerList.has(playerWsId)) {
			const player = this.playerList.get(playerWsId)!;
			player.connected = false;
			clearInterval(player.timeout);
			try {
				player.ws.end(1000, playerWsId);
			} catch (_e) {
				// Socket already closed (e.g. Unity closed Play Mode before the heartbeat fired)
				logger.warn(`${playerWsId} WebSocket already closed`);
			}
		}
	}

	// Interact with Player
	/**
	 * Sets the in-game status of a player
	 * @param {string} playerWsId - Player ID
	 * @param {boolean} inGame - In-game status
	 */
	togglePlayerInGame(playerWsId: string, inGame: boolean) {
		const playerIP: string = this.playerList.has(playerWsId) ? playerWsId : this.getIndexByPlayerId(playerWsId)!;

		if (this.playerList.has(playerIP)) {
			this.playerList.get(playerIP)!.in_game = inGame;
			this.notifyPlayerChange(playerIP);
		} else {
			logger.error(`Something strange happened while try to change in_game status for ${playerWsId} ${inGame}`);
		}
	}

	/**
	 * Sets all players' in-game status to false
	 */
	disableAllPlayerInGame() {
		logger.debug("Change in-game status of every player at once");

		for (const [playerWsId] of this.playerList) {
			this.togglePlayerInGame(playerWsId, false);
		}
	}

	addEveryPlayer(): void {
		logger.debug("Add every player at once");

		for (const [playerWsId, player] of this.playerList) {
			if (this.controller.gama_connector !== undefined && !player.in_game) {
				this.controller.gama_connector.addInGamePlayer(playerWsId);
				this.togglePlayerInGame(playerWsId, true);
			}
		}
	}

	/**
	 * Automatically send Heartbeat ping message to every player's open websocket
	 */
	sendHeartbeat(playerWsId: string): void {
		// Stop pinging if player already disconnected
		if (!this.playerList.has(playerWsId) || !this.playerList.get(playerWsId)?.connected) {
			logger.debug(`${playerWsId} is already disconnected, stop pinging...`);
			if (this.playerList.has(playerWsId)) clearInterval(this.playerList.get(playerWsId)?.timeout);
			return;
		} else if (!this.playerList.get(playerWsId)?.is_alive) {
			// Terminate ws of disconnected player
			logger.warn(`Terminating dead socket from ${this.playerList.get(playerWsId)?.id}`);
			this.closePlayerWS(playerWsId);
			this.controller.notifyMonitor();
			return;
		}

		this.playerList.get(playerWsId)!.is_alive = false;
		try {
			this.sendMessageByWs(playerWsId, { type: "ping" });
		} catch (e) {
			logger.error(`Error while sending ping to ${this.playerList.get(playerWsId)?.id})\n{e}`, { e });
		}
		logger.debug(`Sending ping to ${this.playerList.get(playerWsId)?.id}`);
	}

	/**
	 * Send the json_simulation to the players. It separates the json to send only the necessary information to the players.
	 * @returns
	 */
	broadcastSimulationOutput(jsonOutput: JsonOutput) {
		if (!jsonOutput.contents) return;

		try {
			jsonOutput.contents.forEach((element) => {
				element.id.forEach((idPlayer) => {
					const playerIp: string | undefined = this.getIndexByPlayerId(idPlayer);
					if (playerIp !== undefined) {
						const jsonOutputPlayer = {
							contents: element.contents,
							type: "json_output",
						};
						this.sendMessageByWs(playerIp, jsonOutputPlayer);
					}
				});
			});
		} catch (_exception) {
			logger.error("The following message hasn't the correct format: {jsonOutput}", { jsonOutput });
		}
	}

	/**
	 * Notifies players about a change in their state
	 * @param {number} playerWsId - The id of the player that needs to be informed about a change
	 */
	notifyPlayerChange(playerWsId: string) {
		if (this.playerList.has(playerWsId)) {
			const jsonPlayer: Player = this.playerList.get(playerWsId)!;

			const { ws, timeout, ...newJsonPlayer } = jsonPlayer;

			const jsonStatePlayer = {
				type: "json_state",
				id_player: jsonPlayer?.id,
			};

			this.sendMessageByWs(playerWsId, { ...jsonStatePlayer, ...newJsonPlayer });
			logger.debug(
				`[Player ${jsonPlayer?.id}] Sending state update ${JSON.stringify({ ...jsonStatePlayer, ...newJsonPlayer })}`,
			);
		}
	}

	/**
	 *
	 * @param playerWsId
	 * @param message
	 * @return Returns 1 for success, 2 for dropped due to backpressure limit, and 0 for built up backpressure that will drain over time.
	 * @return -1 if playerWsId missing or not connected
	 */
	//message sent is not necessarily a string, see PlayerManager, for example
	sendMessageByWs(playerWsId: string, message: unknown): number {
		let jsonPlayer!: Player;
		if (this.playerList.has(playerWsId) && this.playerList.get(playerWsId)?.connected)
			jsonPlayer = this.playerList.get(playerWsId)!;
		else {
			if (ENV_EXTRA_VERBOSE)
				if (!this.playerList.has(playerWsId))
					logger.error(`Missing player - Can't send a message to player ${playerWsId}`);
				else logger.warn(`Disconnected player - Can't send a message to player ${playerWsId}`);

			return -1;
		}

		try {
			return jsonPlayer.ws.send(JSON.stringify(message), false, true); // not binary, compress
		} catch (_e) {
			// Socket closed between the connected-check above and the send (race condition)
			logger.warn(`WebSocket for ${playerWsId} closed mid-send, marking disconnected`);
			jsonPlayer.connected = false;
			return 0;
		}
	}

	close() {
		// Notify players that they are removed
		for (const [, value] of this.playerList) {
			this.removePlayer(value.id);
		}

		this.controller.notifyMonitor();

		this.webSocketServer.close();
	}
}

export default PlayerManager;
