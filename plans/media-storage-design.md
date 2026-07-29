# Media storage design — exercise video & progress photos

Status: **design proposal**, nothing implemented. Scope is deliberately narrow:
how we store, locate, secure, and move a user's media. Capture UI, the compare
screen, and feed integration are out of scope except where they constrain storage.

Covers backlog items 6 (Exercise Video Recording) and 17 (Progress Photos) in
`plans/high-level-tasks.md`.

---

## 1. The one idea everything else follows from

**The media record and the media bytes are two different things with two
different lifecycles.**

| | Media record (metadata) | Media bytes |
|---|---|---|
| Size | ~200 bytes | 10–200 MB |
| Always syncs? | Yes, always, every tier | No — depends on tier and settings |
| Lives in | SQLite / Postgres, same sync path as workouts | Device filesystem, photo library, or object store |
| Cost to us | ~nothing | dominates everything |

Once you accept this split, most of the hard questions dissolve:

- *"How do we map a video to an exercise?"* → the record does it, in SQL, like
  every other row in the schema.
- *"How do we find it after a phone change?"* → the record always syncs, so the
  new phone always knows the clip **exists**, what exercise and set it belongs
  to, and when it was shot. Whether the bytes arrive is a separate question with
  a separate answer.
- *"What's premium?"* → the bytes. Never the record.

The corollary is the single most important rule in this document:

> **Never key media off its storage location.** A file path, a `PHAsset`
> identifier, and an object-store key are all *locators*. Locators change,
> break, and differ per device. The identity is a ULID minted on device at
> capture and never changed.

---

## 2. Data model

Follows the existing conventions in `sqlite/schema.sql`: 30-char prefixed
ULIDs, `snake_case`, integer epoch timestamps, explicit FKs and indexes. Media
is user-created, so IDs use the `usr-` prefix.

### 2.1 `media_item` — the record (syncs)

```sql
-- Represents one captured video or photo. This row ALWAYS syncs, on every tier,
-- regardless of whether the bytes are backed up anywhere. It is the durable
-- identity of the media and the anchor for every query.
CREATE TABLE media_item (
  id TEXT PRIMARY KEY NOT NULL
    CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  owner_user_id TEXT NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('video','image')),

  -- Capture facts. Immutable after creation. Doubles as the re-link fingerprint
  -- when we have to find these bytes again in a photo library on a new device
  -- (see §5.2), so DO NOT let the UI edit any of these.
  captured_at   INTEGER NOT NULL,   -- epoch seconds, from the capture device
  duration_ms   INTEGER,            -- NULL for images
  width         INTEGER,
  height        INTEGER,
  byte_size     INTEGER,            -- of the plaintext, post-transcode
  content_hash  TEXT,               -- keyed BLAKE3 of plaintext, hex (see §6.4)

  -- Subject. Attach to the finest thing known; denormalize exercise_id upward
  -- so the "all my bench clips over time" query needs no joins. All nullable —
  -- a progress photo has no set, a form check between sets has no set either.
  exercise_id          TEXT,        -- denormalized for the timeline query
  workout_id           TEXT,
  workout_exercise_id  TEXT,
  exercise_set_id      TEXT,        -- finest grain: carries weight/reps context

  -- Lifecycle
  backup_policy TEXT NOT NULL DEFAULT 'local_only'
    CHECK (backup_policy IN ('local_only','cloud_backup')),
  visibility TEXT NOT NULL DEFAULT 'private'
    CHECK (visibility IN ('private','friends','link')),
  encryption TEXT NOT NULL DEFAULT 'none'
    CHECK (encryption IN ('none','e2ee_v1')),   -- present from day one so
                                                -- turning on E2EE is not a migration
  poster_key TEXT,                  -- object key of the tiny poster frame (§4.3)
  object_key TEXT,                  -- object key of the ciphertext blob; fresh
                                    -- random 128-bit value, NEVER the ULID (§4.2)
  deleted_at INTEGER,               -- tombstone; syncs; server purges after grace

  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),

  FOREIGN KEY(owner_user_id)       REFERENCES user_profile(id)     ON DELETE CASCADE,
  FOREIGN KEY(exercise_id)         REFERENCES exercise(id)         ON DELETE SET NULL,
  FOREIGN KEY(workout_id)          REFERENCES workout(id)          ON DELETE SET NULL,
  FOREIGN KEY(workout_exercise_id) REFERENCES workout_exercise(id) ON DELETE SET NULL,
  FOREIGN KEY(exercise_set_id)     REFERENCES exercise_set(id)     ON DELETE SET NULL
);

-- The compare-over-time query. This index IS the feature.
CREATE INDEX idx_media_item_exercise_time
  ON media_item(owner_user_id, exercise_id, captured_at DESC);
CREATE INDEX idx_media_item_workout       ON media_item(workout_id);
CREATE INDEX idx_media_item_set           ON media_item(exercise_set_id);
CREATE INDEX idx_media_item_content_hash  ON media_item(owner_user_id, content_hash);
```

Note the FKs are all `ON DELETE SET NULL`, matching how `workout_exercise.source_variant_id`
is treated: deleting a workout must not delete the user's video. An orphaned clip
still has `captured_at` and `exercise_id` and stays useful in the timeline.

### 2.2 `media_location` — the locators (device-local, does **not** sync)

```sql
-- Where the bytes for a media_item currently are, ON THIS DEVICE.
-- Deliberately NOT synced: a path on my iPhone is meaningless on my iPad.
-- The cloud object key is the exception and lives on media_item (see §4.2).
CREATE TABLE media_location (
  id TEXT PRIMARY KEY NOT NULL
    CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  media_item_id TEXT NOT NULL,
  locator_type TEXT NOT NULL
    CHECK (locator_type IN ('app_file','photo_library')),
  locator TEXT NOT NULL,     -- relative path under the app container, or
                             -- PHAsset.localIdentifier / MediaStore _ID
  state TEXT NOT NULL
    CHECK (state IN ('present','missing','evicted')),
  verified_at INTEGER,       -- last time we confirmed the bytes are really there
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  FOREIGN KEY(media_item_id) REFERENCES media_item(id) ON DELETE CASCADE,
  UNIQUE(media_item_id, locator_type)
);
```

A media item can legitimately have zero locations on a given device. That is a
normal state, not an error — it means "this clip exists, it isn't here". The UI
renders the poster with a "not on this device" badge.

### 2.3 `media_grant` — sharing (syncs)

```sql
-- One row per (item, recipient). Under E2EE, wrapped_cek is the item's content
-- key sealed to the recipient's public identity key; the server cannot read it.
CREATE TABLE media_grant (
  id TEXT PRIMARY KEY NOT NULL
    CHECK((id LIKE 'app-%' OR id LIKE 'usr-%') AND length(id) = 30),
  media_item_id TEXT NOT NULL,
  grantee_user_id TEXT,      -- NULL for a link share
  link_token_hash TEXT,      -- SHA-256 of the link token, for link shares
  wrapped_cek BLOB,          -- NULL when encryption='none'
  granted_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  revoked_at INTEGER,
  expires_at INTEGER,
  FOREIGN KEY(media_item_id)   REFERENCES media_item(id)   ON DELETE CASCADE,
  FOREIGN KEY(grantee_user_id) REFERENCES user_profile(id) ON DELETE CASCADE,
  CHECK ((grantee_user_id IS NOT NULL) <> (link_token_hash IS NOT NULL))
);
CREATE UNIQUE INDEX idx_media_grant_unique
  ON media_grant(media_item_id, grantee_user_id) WHERE grantee_user_id IS NOT NULL;
```

### 2.4 The query the whole feature exists for

```sql
-- "Show me every clip of my bench press, newest first, with the load I used."
SELECT m.id, m.captured_at, m.duration_ms, m.poster_key,
       s.weight, s.rep_count, s.unit, s.rpe
FROM media_item m
LEFT JOIN exercise_set s ON s.id = m.exercise_set_id
WHERE m.owner_user_id = ?1
  AND m.exercise_id   = ?2
  AND m.deleted_at IS NULL
ORDER BY m.captured_at DESC;
```

No template join, no plan-side dependency — consistent with the record-tree
guarantee the schema already makes.

---

## 3. Capture: the decision that determines whether any of this is affordable

Straight off a modern phone, video is enormous:

| Source | Bitrate | 45-second set |
|---|---|---|
| iPhone 4K/60 HEVC (~440 MB/min per Apple) | ~59 Mbps | **~330 MB** |
| iPhone 1080p/30 HEVC (~65 MB/min) | ~8.7 Mbps | ~49 MB |
| Our target: 720p/30, H.264 High | ~2.5 Mbps | **~14 MB** |

**Transcode on device, at capture, before anything else touches the file.**
720p/30 at ~2.5 Mbps is more than enough to see whether someone's back is
rounding. Keep the camera original only until the transcode verifies, then
delete it.

Also at capture time:

- **Hard-cap duration** at 60 s. A set is a set.
- **Strip all container metadata.** Especially GPS. A fitness app holding
  geotagged video of a user at the same gym at 06:00 every Tuesday is a
  stalking vector, and there is no feature that needs the coordinates.
  Strip unconditionally, not as a setting.
- **Generate the poster frame** (§4.3).
- **Compute the content hash** over the transcoded plaintext.

At 3 clips/workout × 4 workouts/week, this single decision moves per-user annual
storage from **~201 GB to ~8.6 GB** — a 23× cut. Costed out in §8.1, that is the
difference between a premium tier that goes cash-negative in year three and one
still comfortable in year ten. It is the highest-leverage decision in this
document.

---

## 4. Where the bytes live

### 4.1 Tier A — device only (free, default)

Bytes land in the app's private container:

- **iOS:** `Application Support/media/` — inside the container, included in
  iCloud Backup, not visible to other apps or to Files.
- **Android:** `context.filesDir/media/` — app-private, covered by file-based
  encryption, not on external storage.

Never `Caches/`, `tmp/`, or external storage: the OS will delete the first two
under disk pressure and the third is readable by anything with storage
permission.

### 4.2 Tier B — encrypted cloud backup (premium)

Ciphertext goes to an object store. **The selection criterion is zero egress
fees, not cheap storage** — video playback is egress-dominated, and §8.2 shows
this rules out both S3 Standard and, more surprisingly, every Glacier tier.
That leaves R2, Backblaze B2, or Wasabi; R2 is the working assumption here and
B2 is the live alternative (open question 6).

Object key (`media_item.object_key`) is a **fresh random 128-bit value, not the
media ULID.** A ULID leaked in a log or a screenshot must not be a bucket path.

Uploads: multipart/resumable, Wi-Fi + charging by default. A 15 MB upload on
gym Wi-Fi will fail partway through, repeatedly.

### 4.3 The poster frame changes the whole free-tier experience

Every item gets a poster: ~320 px longest edge, WebP/AVIF, ~20 KB. **Back the
poster up on every tier, including free.** 1 000 clips × 20 KB = 20 MB per user
— rounding error.

Why it matters: on a new phone, a free-tier user's exercise timeline is
*visually complete*. Every clip they ever shot is there, with its date, its
weight, its poster. The ones whose bytes didn't travel show a badge. Nothing
looks lost, nothing looks broken — and the upgrade prompt is honest ("get the
video itself back") rather than hostage-taking.

### 4.4 Eviction

If an item is cloud-backed, local bytes are an LRU cache — evict freely, keep
the poster, re-download on demand. If an item is `local_only`, **never
auto-evict**; warn about disk pressure and offer upgrade/export instead.

---

## 5. Phone change: how the video is still found

Split the question, because it has two different answers.

### 5.1 "Still found" — always solved

`media_item` syncs on every tier. New phone, new install, restored account: the
timeline is complete, correctly ordered, correctly attached to exercises and
sets, with posters. This is free and unconditional.

### 5.2 "Carries over" — three mechanisms, honestly ranked

There is no magic here. **Bytes that were never uploaded cannot be conjured onto
a new device.** What we can do is make the paths that do work reliable and
default-on.

**(1) Write into the user's own photo library — the best free-tier answer.**

Opt-in at capture (default on for free tier): save the transcoded clip into a
dedicated "Social Workout" album. iCloud Photos / Google Photos then does the
carrying, on storage the user is often already paying for.

The re-link problem: `PHAsset.localIdentifier` is a device-local UUID and does
**not** survive migration. So plant durable markers at write time:

- **Filename.** Write the file as `usr-<ULID>.mp4`. iOS preserves it as
  `PHAssetResource.originalFilename`; Android exposes it as
  `MediaStore.DISPLAY_NAME`. Directly queryable on the new device. Cheap and
  effective.
- **Container metadata.** Also embed the ULID in an MP4 `udta`/XMP field.
  Survives independently of filename handling.
- **Fingerprint fallback.** If both fail, match on `captured_at` (±2 s),
  `duration_ms` (±100 ms), and `width`/`height` — the fields §2.1 marks
  immutable. Confirm with the content hash before committing the link.

On first launch after migration, run a background re-link scan over the album,
write `media_location` rows for what it finds, and report "restored 412 of 419
clips" rather than silently half-working.

Tradeoff to surface in the UI, not bury: anything in the photo library is
readable by **any app the user grants photo access to**. That is a real
reduction in privacy versus the app container, and it is the price of free
durability. Let the user choose per-item, and default progress photos to
container-only.

**(2) OS backup — real on iOS, do not rely on it on Android.**

iCloud Backup covers the app container, so a full device restore brings
`Application Support/media/` with it. Android Auto Backup caps at 25 MB per app,
which is under two clips; Android device-to-device transfer is more complete but
not something to promise. Treat this as a bonus, never as the plan.

**(3) Direct transfer — always works, costs us nothing.**

A "move my library" flow: old phone stands up a one-shot local HTTP server, new
phone scans a QR containing address + one-time key, bytes stream over the LAN,
`media_location` rows are rewritten on arrival. Also useful as an export bundle
(clips + a manifest of the `media_item` rows) to Files/Drive.

This is worth building. It's the feature that makes the free tier feel generous
rather than crippled, and it costs zero infrastructure.

---

## 6. Security

### 6.1 Threat model — say out loud who we're defending against

| # | Adversary | Mitigation |
|---|---|---|
| 1 | Someone holding the **unlocked** phone | Biometric gate on the media tab; app-level lock |
| 2 | Someone holding a **locked/stolen** phone | OS encryption + iOS Data Protection class; app-private storage |
| 3 | **Us**, or anyone who breaches our object store | End-to-end encryption (§6.3) — the one that matters and the one most apps punt on |
| 4 | **Another user** of our service | Per-object server-side authz. IDOR is the #1 real bug in this feature |
| 5 | Network attacker | TLS; optional cert pinning |
| 6 | Logs / CDN / analytics leakage | No keys or tokens in query strings; short-lived narrowly-scoped signed URLs |

### 6.2 On-device at rest

iOS: set `NSFileProtectionCompleteUntilFirstUserAuthentication` as the floor;
`...Complete` for media if background access isn't needed. Android: app-private
`filesDir` inherits file-based encryption. Both are close to free — just don't
put media anywhere else.

### 6.3 End-to-end encryption for anything that leaves the device

**Key hierarchy**

```
Recovery passphrase ──Argon2id──▶ KEK_recovery  ─┐
Secure Enclave / StrongBox ─────▶ KEK_device    ─┼─▶ wrap(Master Key)   [any one unwraps]
iCloud Keychain / Blockstore ───▶ KEK_platform  ─┘

Master Key ──HKDF("cek-wrap")──▶ wraps each per-item content key (CEK)
Master Key ──HKDF("content-hash")──▶ keyed BLAKE3 for content_hash
Master Key ──wraps──▶ X25519 identity private key   (used for sharing, §6.5)
```

Three independent wraps of the same master key means three independent recovery
paths and any one suffices. In practice iCloud Keychain / Android Blockstore
means the overwhelming majority of users never see a passphrase — it just works
on the new phone — while the passphrase remains as the escape hatch.

**Per-item encryption**

- Random 256-bit CEK per item.
- Split plaintext into 1 MiB chunks; encrypt each **independently** with
  AES-256-GCM. Nonce = 4-byte random file prefix ‖ 8-byte big-endian chunk
  index. AAD = object key ‖ chunk index ‖ total chunk count.
- Independent chunks (rather than a sequential construction like libsodium's
  `secretstream`) is the deliberate choice: it gives **random access**, which
  is what makes ranged, seekable video playback possible without downloading
  and buffering the whole file.
- Binding the chunk index and total count into the AAD is what prevents
  reordering and truncation attacks that per-chunk AEAD would otherwise allow.
- Plaintext header: magic, version, chunk size, total plaintext length, nonce
  prefix — authenticated, never secret. `wrapped_cek` is stored in the DB for
  cloud objects and inside the file for export bundles (so a bundle is
  self-contained).

**Playback**: run a loopback HTTP server on `127.0.0.1`, point `AVPlayer` /
`ExoPlayer` at it, decrypt the chunks covering each requested byte range on the
fly. Standard pattern, works with both players' range requests.

**Why E2EE is nearly free here, and therefore worth doing.** The usual cost of
E2EE is losing server-side processing — no transcoding, no thumbnailing, no
moderation. But §3 already transcodes on device and §4.3 already makes the
poster on device, because that's where the camera is. There is no server-side
processing to lose. The server is a dumb byte store either way. The *only* real
cost is key recovery, and the platform keychains absorb most of that.

**Bonus: crypto-shredding.** GDPR erasure becomes "delete the wrapped key",
which is instant and covers backups and replicas without a purge pipeline.

### 6.4 What is explicitly *not* encrypted, and why

Media **metadata is cleartext** to the server: which exercise, when, how long,
how big. This is a deliberate scoping decision, not an oversight — the server
already holds the full workout history to power the feed, competitions, and
leaderboards, so encrypting `exercise_id` on the media row would protect
nothing that isn't trivially derivable from data right next to it.

Say this plainly in any user-facing privacy copy. "Your videos are
end-to-end encrypted" is true. "Everything is end-to-end encrypted" would not be.

One refinement: make `content_hash` a **keyed** BLAKE3 (key derived from the
master key) rather than a plain hash. Plain plaintext hashes let anyone with
the database confirm whether a user holds a specific known file, and let us
correlate the same file across users. Keying it preserves within-user dedup and
integrity checking while removing both.

### 6.5 Sharing

- Every user publishes an X25519 identity public key; the private half is
  wrapped by their master key.
- Sharing item → friend: seal the item's CEK to the friend's public key, write
  a `media_grant`. Server relays ciphertext it cannot read.
- Link sharing: generate a random link key, wrap the CEK to it, and put the
  key **in the URL fragment** — fragments are never sent to the server, so a
  link works while our logs stay clean. Store only `SHA-256(token)`.
- **Revocation is soft and we must say so.** Deleting a grant stops future
  fetches; it cannot un-see a video someone already downloaded. Don't imply
  otherwise in the UI.
- **"Share to feed" must never silently flip `visibility`.** Posting a clip
  creates an explicitly separate, separately-granted copy. One accidental
  toggle turning private form-check footage into a public post is the single
  worst bug this feature can have — make it structurally impossible rather
  than a code path to be careful in.

### 6.6 Server-side authorization

Every fetch resolves through:

```sql
SELECT 1 FROM media_item m
WHERE m.id = ?1 AND m.deleted_at IS NULL
  AND (m.owner_user_id = ?2
       OR EXISTS (SELECT 1 FROM media_grant g
                  WHERE g.media_item_id = m.id
                    AND g.grantee_user_id = ?2
                    AND g.revoked_at IS NULL
                    AND (g.expires_at IS NULL OR g.expires_at > strftime('%s','now'))));
```

Write the negative tests before the handler: another user's ID returns 404 (not
403 — don't confirm existence), a revoked grant returns 404, an expired grant
returns 404. Rate-limit fetches to blunt enumeration. Unguessable identifiers
are defence in depth, never the authorization check.

---

## 7. Deletion

Delete sets `deleted_at` and syncs the tombstone. Server purges the object and
poster after a grace period (30 days, undo window). Local bytes go immediately.

**A copy in the user's photo library belongs to them, not to us.** In-app
deletion must ask before touching it, and default to leaving it.

---

## 8. Premium gating — recommendation

Do **not** gate durability. "Pay or lose your videos" produces support tickets,
churn, and bad reviews, and the free tier already has honest durability paths
(§5.2).

| | Free | Premium |
|---|---|---|
| Media records + posters, everywhere, forever | ✅ | ✅ |
| Local storage, unlimited (device-bound) | ✅ | ✅ |
| Save to photo library + re-link on new phone | ✅ | ✅ |
| Direct device-to-device transfer / export | ✅ | ✅ |
| Encrypted cloud backup | — | ✅ (quota, e.g. 25 GB) |
| Instant access on every device, no transfer dance | — | ✅ |
| **Side-by-side compare against any historical clip** | last 30 days | ✅ full history |
| Longer clips (60 s → 3 min) | — | ✅ |

Sell the **comparison**, not the safety. Comparing today's depth against the
same lift six months ago is the thing people will actually pay for; it's also
the thing that's genuinely easier when the bytes are in the cloud, so the gate
is natural rather than artificial.

### 8.1 The arithmetic behind the quota

Reference user: 3 clips/workout × 4 workouts/week × 45 s = 624 clips ≈ **7.8 h of
video per year**. Sizes are Apple's documented HEVC capture rates (Settings >
Camera > Record Video). Costs are Cloudflare R2 list, $0.015/GB-month, zero egress.

| Capture setting | MB/min | GB/year | Year 1 (accumulating) | $/yr to *retain* |
|---|---|---|---|---|
| 4K/60 | 440 | 201 | $18.10 | **$36.20** |
| 4K/30 | 170 | 78 | $6.99 | **$13.99** |
| 1080p/30 | 65 | 30 | $2.67 | **$5.35** |
| 720p/30 @ 2.5 Mbps (§3 target) | 18.8 | 8.6 | $0.77 | **$1.54** |

Two columns because storage **accumulates**: during year one you hold the average,
roughly half the final total. The right column is what that year's footage costs
every year thereafter. Unit rate for re-deriving with other assumptions: one
minute of 4K/60 stored for a year costs **$0.077**; at 720p/30, **$0.0033**.

**Storage compounds; subscription revenue does not.** Against $8/month premium —
$96/yr, or **$81.60 net** after Apple's 15% cut:

| Cost that year | Y1 | Y3 | Y5 | Y10 |
|---|---|---|---|---|
| 4K/60 full resolution | $18 | **$90** ⚠️ | $163 | $344 |
| 4K/30 full resolution | $7 | $35 | $63 | **$133** ⚠️ |
| 720p transcode | $0.77 | $3.86 | $6.94 | $14.65 |

Retaining full-resolution 4K/60 goes **cash-negative in year 3 on storage alone**,
before compute, egress, or support. 4K/30 lasts until roughly year 7. The
transcoded tier is still at 18% of net revenue in year *ten*. This is the
quantitative case for §3, and it is not close.

And that's a moderate user. Someone filming every set (15 clips × 5 workouts/week)
at 4K/60 generates **1.26 TB/year** — $226/yr to retain, underwater in year one.
Hence a hard quota, not merely a retention policy.

A 25 GB quota is ~3 years of the transcoded moderate user, costs $0.38/month, and
leaves room for retention rules later ("clips older than 18 months kept only if
pinned or attached to a PR").

**Egress, not storage, is what makes S3 wrong here.** Same moderate user at 4K/60,
assuming each clip is watched 3× per year: R2 $36/yr versus S3 **$110/yr**, of
which $54 is pure egress. Video is an egress-dominated workload.

### 8.2 Why not cold storage

The obvious reaction to $36/yr is "put it in Glacier." That is the wrong axis,
and the arithmetic says so clearly. Full res, 201 GB/yr, steady state, each clip
retrieved ~1×/yr:

| Provider | Storage/yr | Retrieval + egress | **Total/yr** | Min. duration | Latency |
|---|---|---|---|---|---|
| Backblaze B2 | $14.48 | $0 | **$14.48** | — | ms |
| Wasabi | $16.65 | $0 | $16.65 | 90 d | ms |
| S3 Glacier Deep Archive | $2.39 | **$18.60** | $20.99 | 180 d | 12–48 h |
| R2 Infrequent Access | $24.13 | $2.01 | $26.14 | 30 d | ms |
| S3 Glacier Flexible (bulk) | $8.69 | $18.10 | $26.79 | 90 d | 5–12 h |
| S3 Glacier Instant Retrieval | $9.65 | $24.13 | $33.78 | 90 d | ms |
| R2 | $36.20 | $0 | $36.20 | — | ms |
| S3 Standard | $55.50 | $18.10 | $73.60 | — | ms |

Deep Archive cuts storage 15× and then **returns the entire saving as retrieval
and egress fees** — landing above plain Backblaze while making the user wait up
to two days. Break-even against B2 is **0.65 retrievals per clip per year**;
below that cold wins, above it egress-free hot wins. Since "pull up an old clip
and compare" is the entire product, we will be above that line.

Cold storage optimizes GB-months. This workload's cost is GB-transferred.

Two further traps if anyone revisits this:

- **Minimum storage duration** (90 d Glacier, 180 d Deep Archive) — a user
  deleting a bad take after a day is still billed for six months, and this
  feature will produce many deleted takes.
- **Minimum billable object size** — Glacier IR bills 128 KB per object, so the
  20 KB posters of §4.3 would bill at 6.4× actual. Posters must never go cold.

**Ranked levers**, from the $36.20 baseline:

| Lever | Cost/yr | vs baseline |
|---|---|---|
| Baseline: 4K/60 on R2 | $36.20 | — |
| **Transcode to 720p (§3), stay on R2** | **$1.55** | **23×** |
| Keep 4K/60, move to Deep Archive | $20.99 | 1.7× |
| Transcode + Backblaze B2 | $0.62 | 58× |

Transcoding beats every storage-tier choice by an order of magnitude, at zero
latency cost. After it we are at ~$1.55/user-year and the question is closed —
do not build a lifecycle pipeline to save $1/user/year.

If more is wanted, the next move is **evaluating B2 against R2** (2.5× cheaper,
also egress-free, and in Cloudflare's Bandwidth Alliance so free egress into a
CDN survives). R2's counter-advantages are uncapped egress with no fair-use
ratio and native Workers integration for edge auth and signed URLs.

Cold storage *does* fit exactly one thing: an explicit "archive my untouched 4K
originals" add-on, where restores are genuinely rare and a "we're restoring your
originals, we'll notify you" flow makes 12–48 h acceptable. That is cold by
design, not cold as a cost fix for the working set.

The lever that beats every infrastructure choice, though, is a **product** one:
back up only clips the user *pins*, not everything. At ~15% pinned that is
another 6.7× on top of all of the above. See open question 5.

Caveats: figures are HEVC — a user shooting "Most Compatible" (H.264) roughly
doubles them. Excludes operations (~$0.01/user-year) and AEAD overhead (16 bytes
per 1 MiB chunk, 0.0015%), both noise. Prices are list as of writing; re-check
before committing to a subscription price.

---

## 9. Staged delivery

The app is in early prototyping (`mobile/CLAUDE.md`); going straight at E2EE
cloud sync would stall everything. Each stage ships independently and none
requires migrating the previous one — which is precisely why `encryption`,
`backup_policy`, and `content_hash` are on `media_item` from the very first
migration even though stage 0 leaves them at their defaults.

**Stage 0 — local, no server.** `media_item` + `media_location`, capture with
transcode + metadata stripping + poster, attach to `exercise_set`, and the
compare-over-time timeline. Proves the feature is wanted before a byte of
infrastructure exists.

**Stage 1 — device-local durability.** Photo library option, filename/metadata
markers, re-link scanner, export bundle + direct transfer. Solves phone change
for free-tier users at zero infra cost.

**Stage 2 — encrypted cloud backup (premium).** Key hierarchy, chunked AEAD,
resumable upload, loopback playback proxy, quota, authz tests.

**Stage 3 — sharing.** Identity keys, grants, link shares, and the deliberately
separate feed-post copy.

---

## 10. Open questions

1. **Is E2EE right for v1 of the cloud tier?** The alternative — server-side
   encryption with per-user KMS keys and strict authz — is meaningfully simpler
   and fully recoverable. §6.3 argues E2EE is nearly free *here* specifically
   because there's no server-side processing to give up, but the recovery UX is
   a real cost and worth a deliberate decision rather than drifting into it.
2. **Photo library on or off by default for free users?** On maximises
   durability; off maximises privacy. Current lean: on for exercise video, off
   for progress photos, both per-item overridable.
3. **Does a clip attach to a set or to a `workout_exercise`?** §2.1 supports
   both. Set-level gives the load context that makes comparison meaningful;
   exercise-level is what people will actually tap. Probably: default to set,
   fall back to exercise leg.
4. **Retention past the quota** — hard stop, or evict oldest-unpinned? Hard stop
   is honest; eviction is friendlier. Needs a product call, not a technical one.
5. **Back up everything, or only pinned clips?** §8.2 shows this is a bigger cost
   lever than any provider or tier choice (~6.7× at 15% pinned), and it may also
   be the better *product*: most clips are watched once and never again, and a
   curated "these are my reference lifts" set is arguably more useful than an
   undifferentiated archive. Against that, "pin before it's safe" is a footgun
   that loses user data. Possible middle: auto-pin PRs and anything the user
   replays more than once.
6. **B2 versus R2** (§8.2) — 2.5× on storage against uncapped egress and Workers
   integration. Only worth resolving once cloud backup is real; the transcode
   decision dwarfs it either way.
