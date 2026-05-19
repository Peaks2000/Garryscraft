# MC+GM

Experimental Minecraft Java <-> Garry's Mod bridge.

The authority lives in the GMod server. Minecraft clients connect directly to a
TCP listener hosted by the addon, using Minecraft offline mode, so no Microsoft
authentication is performed.

## What works in this prototype

- Minecraft Java 1.12.2 offline-mode handshake/login path.
- Spawn chunks include a simple floor sampled from GMod brush geometry.
- Minecraft server list status/ping.
- Chat forwarding:
  - Minecraft chat -> GMod chat.
  - GMod chat -> Minecraft chat.
- Position forwarding:
  - Minecraft movement packets are tracked in GMod.
  - Minecraft players are shown in GMod as simple moving proxy models.
  - GMod players are spawned into Minecraft as player entities and teleported
    as they move.
  - Minecraft tab list contains `[MC]` and `[GMod]` entries.
- Cross-game interaction:
  - GMod bullets and damage can hurt Minecraft proxies.
  - Minecraft users can attack visible GMod placeholders.
  - Minecraft chat from MC users is rebroadcast with a `[MC]` prefix.
  - Minecraft chat commands `/crowbar`, `/blast`, `/where`, `/proxy`, `/sync`,
    `/break`, `/debugblocks`, `/rebuildblocks`, and `/testblock` affect GMod or
    inspect the bridge state.
- Shared arena:
  - GMod players are spawned onto the bridge platform by default.
  - Nearby GMod platform/prop hitboxes are projected into Minecraft as filled
    stone-ish block volumes.
  - The bridge platform is protected from GMod damage by default.
  - Persistent Minecraft bridge blocks are stored in `garrysmod/data/mcgm/world.json`.
- Build continuity:
  - Minecraft block place/break packets update the stored bridge world.
  - Minecraft-created blocks appear in GMod as small frozen solid blocks.
  - The GMod bridge platform and MC-created blocks are protected from physgun,
    gravity gun, toolgun, and damage by default.
- Experimental prop projection:
  - Nearby GMod physics props are sampled and sent as simple Minecraft block
    changes.

## Requirements

Stock GMod Lua cannot open a raw TCP server. Install a LuaSocket-compatible GMod
binary module that exposes `require("socket")`.

The addon still runs inside the GMod server process; the socket module is only
the network primitive that Lua itself does not provide.

## Install

Copy this repository into a GMod addon folder, for example:

```text
garrysmod/addons/mcgm/
```

Then start the GMod server with the addon installed.

Or use the helper script:

```bash
chmod +x scripts/run-gmod-bridge.sh
GMOD_DIR="$HOME/gmod-ds" ./scripts/run-gmod-bridge.sh
```

If your server is somewhere else, change `GMOD_DIR`.

If you do not have the GMod dedicated server yet:

```bash
chmod +x scripts/install-gmod-server.sh
./scripts/install-gmod-server.sh
./scripts/run-gmod-bridge.sh
```

Install the socket module required by the Minecraft listener:

```bash
./scripts/install-gmod-luasocket.sh
```

Minecraft clients should connect with Java Edition 1.12.2 to:

```text
<gmod-server-ip>:25565
```

## Configuration

Edit [lua/mcgm/config.lua](lua/mcgm/config.lua).

Important settings:

- `port`: Minecraft listener port.
- `world_scale`: GMod units per Minecraft block.
- `enable_prop_blocks`: turns the prop-to-block experiment on/off.
- `prop_block_state`: Minecraft 1.12 block-state id used for projected props.
- `prop_scan_interval`: how often props are projected.
- `floor_block_state`: Minecraft 1.12 block-state id used for sampled floor.
- `minecraft_proxy_health`: health for Minecraft players represented in GMod.
- `minecraft_command_range`: range for Minecraft-originated GMod actions.
- `force_gmod_spawn_to_bridge`: move GMod players to the shared arena on spawn.
- `hitbox_sync_interval`: how often GMod prop/platform hitboxes are sent to MC.
- `shared_platform_destructible`: allow/prevent damage to the GMod platform.
- `shared_platform_z`: vertical placement of the GMod bridge platform.
- `hitbox_fill_blocks`: fill GMod hitbox projections instead of outlines.
- `minecraft_build_block_state`: MC block state used for MC-created blocks.
- `minecraft_block_model`: GMod model used for MC-created blocks.
- `debug_block_packets`: log MC place/break packet details to the GMod console.
- `debug_gmod_block_spawns`: log GMod entity spawns for MC-created blocks.
- `quiet_minecraft_system_chat`: suppress bridge system/debug chatter in MC chat.
- `debug_minecraft_movement`: log MC movement/proxy updates to GMod console.

Useful server console commands:

- `mcgm_spawn_bridge`: move all GMod players to the shared bridge spawn.
- `mcgm_world_save`: save the persistent Minecraft bridge block map.
- `mcgm_rebuild_blocks`: rebuild GMod block entities from stored MC blocks.
- `mcgm_test_block`: create one test MC-origin block at the bridge origin.

Reset the stored Minecraft bridge world while the server is stopped:

```bash
./scripts/reset-mcgm-world.sh
./scripts/run-gmod-bridge.sh
```

Minecraft clients can join the bridge without any GMod players connected. The
GMod dedicated server still needs to be running because it is the authority and
hosts the Minecraft listener.

## Notes

This is a first working scaffold, not a production-quality protocol
implementation. Minecraft clients expect chunks, dimensions, entity metadata,
and keepalives to be exactly right across versions. The next big milestone is
proper entity metadata, richer block projection, and collision-aware movement.
