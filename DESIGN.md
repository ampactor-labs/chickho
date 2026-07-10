# chickho — the ultimate form

One sentence: an async multiplayer party platformer where a group chat
shares one increasingly cursed level, every run is a deterministic
replay a few KB long, and each round resolves into a spectacle video
the chat watches without installing anything.

## Why this is the form

Three facts converge on it.

First, Ultimate Chicken Horse's race phase is already parallel. Racers
don't collide; the game is placement mind-games plus simultaneous solo
runs plus shared scoring. Nothing about the run requires the other
players to be present while you do it.

Second, a deterministic sim turns a run into a file. That's the
two-top thesis transplanted: record the input log, replay it anywhere,
bit-identical. And this game needs the easy half only — no rollback,
no prediction, no resync. Record and replay.

Third, mobile multiplayer is asynchronous whether you design for it or
not. Four friends are never on phones at the same moment, but a group
chat plays a round-per-hour game forever. The chat is the lobby.

UCH compressed to what survives the phone: place a trap on your own
time, run the same locked level as everyone else on your own time,
then watch all the runs race as ghosts in one resolution replay where
your saw dunks your friend by name.

## The loop, front to back

A match is 2 to 8 people behind an invite link, playing to a target
score with UCH-faithful rules: points for finishing, a first-finish
bonus, trap kills credited to the trap's owner, and the too-easy rule
(everyone finishes, nobody scores).

Each round has two gates. Gate one, placement: everyone gets the same
item offer and places one piece; the level locks when the last piece
lands or the timer lapses. Gate two, the run: everyone races the same
locked level solo; a recorded input log is the submission. If you miss
the window, your best previous run replays as your entry — it will
probably die to the new traps, which is both the punishment and the
comedy. Resolution then plays every run simultaneously as ghosts,
credits each death ("Dana's saw dunks Alex"), applies scoring, and
emits the share card.

Live play falls out instead of being built: couch mode is pass-and-play
placement with hotseat runs, and when the whole group happens to be
online the gates collapse to real-time UCH in all but name.

Solo is the daily: one seeded level for everyone, raced against your
own ghosts plus three strangers' replays drawn from the day's pool,
with a leaderboard. It's the game you have before you've convinced any
friends, the content between rounds, and the funnel into matches.

## Distribution

Products here die on the distribution wall, so the wall is a design
input. Every loop emits an artifact into a chat: the invite is a link,
the turn ping is a notification, and the resolution is a video that
autoplays inline in iMessage or WhatsApp — the Wordle square, except
it's your friend dying to your saw. Watching costs no click and no
install. The link under the video opens the web build to play the
level immediately; installing the app is an upgrade for regulars, never
the price of first contact.

## Tech shape

Godot 4, one codebase, exported to iOS, Android, and web.

- `sim/` — a pure deterministic module: integer math only, no engine
  physics, own PCG RNG, fixed timestep, input-log in and state out,
  zero node dependencies, runs headless. If GDScript determinism
  proves leaky in practice, the fallback is the two-top `fixed_math`
  crate behind GDExtension; that risk is retired in M2, not discovered
  in M4.
- `render/` — reads sim state, interpolates, carries all juice; never
  writes back.
- `replay/` — versioned format, strict sim_version match, no
  migrations (two-top rule). Any sim-affecting change bumps the
  version; the web player can keep old versions around cheaply.
- server — one thin match service on Railway: Postgres, a bucket for
  replays, REST plus push notifications for turn pings. Replays are
  the wire format. There are no game servers to run.
- share video — rendered on-device at resolution time; determinism
  means any client renders identical frames, so the phone that closes
  the round mints the clip.
- CI — the two-top harness pattern ported: cross-platform determinism
  matrix (linux, macOS, Windows, Android, web headless) diffing
  per-frame checksums, plus a replay fuzz soak.

## Income

Cosmetics only: critters, hats, trails, dunk taunts, maybe a founder
pack. Traps and movement are never sold — pay-for-power kills a party
game's trash-talk economy, which is the actual product. No crypto.
The architecture keeps server cost near zero, so the business has to
clear a low bar, not a miracle.

## Named risks

1. Two-gate friction. Async waits twice per round. Mitigations:
   timers with the stale-ghost auto-entry, gates that collapse when
   everyone's online, and the daily filling the gaps.
2. GDScript determinism is a discipline, not a guarantee. The CI
   matrix lands in M2, before any multiplayer exists, because
   retrofitting determinism is the one mistake this architecture
   cannot survive. Two-top proved the verification pattern.
3. Async trades the live-race adrenaline for group-chat theater. This
   is the one real gamble; the resolution replay has to carry the
   drama. The spike's grin test is the proxy: if dunking your own
   ghost is funny alone, dunking Dana is funnier in company.
4. Godot web export weight. Video-first sharing means spectators never
   pay it; players pay it once and the PWA caches it.

## Build order

Every milestone ships something playable.

- M1 feel — Godot project, deterministic sim, touch controls, the
  spike's solo-ghost loop rebuilt properly. The spike's tuned numbers
  are the feel spec.
- M2 determinism — replay format, versioning, CI matrix, fuzz soak.
- M3 daily — seeded levels, stranger-ghost pools, leaderboard; first
  public build (web plus TestFlight/itch).
- M4 matches — Railway service, invite links, async rounds, resolution
  replays.
- M5 spectacle — share video, push notifications, cosmetics, store
  launch.

The HTML spike (`index.html`, and the published artifact) stays as the
feel reference and the cheapest place to test loop variants before
they're worth porting.
