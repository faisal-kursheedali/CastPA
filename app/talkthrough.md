# CastPA — Interview Walkthrough

A local-first, single-user content publishing app (Flutter). Draft, AI-polish, transcribe, and publish posts to LinkedIn/X — no backend server.

---

## 1. Product summary (say this first, ~30s)

"CastPA is a local-first content publishing tool for solo creators. You dump a raw thought (typed or voice), AI polishes it into platform-specific posts, then you queue and publish to LinkedIn/X. There's no backend — the SQLite DB itself lives in a synced folder (Dropbox/Drive), so multiple devices share state through file sync instead of a server."

---

## 2. Live demo flow (walk this in the app)

| Step | Screen / File | What to show |
|---|---|---|
| Onboarding | [folder_setup_screen.dart](lib/presentation/screens/onboarding/folder_setup_screen.dart) | Pick the sync folder — mention this is what makes the DB shareable across devices |
| Create post | [create_post_screen.dart](lib/presentation/screens/post/create_post_screen.dart) | Voice note or typed dump |
| Transcription | [whisper_transcription_service.dart:26](lib/data/services/whisper_transcription_service.dart#L26) | `_whisper!.transcribe(...)` — runs fully on-device |
| AI polish | [gemini_service.dart:139](lib/data/services/gemini_service.dart#L139) | `polishPost()` → calls Gemini, returns per-platform content + tags + hook/structure metadata |
| Preview tabs | `post_edit_tab` / `post_preview_tab` (under [lib/presentation/screens/post/](lib/presentation/screens/post/)) | Show LinkedIn vs X differ in length/formatting |
| Queue | [queue_screen.dart](lib/presentation/screens/queue/queue_screen.dart), route in [app_router.dart:89-100](lib/presentation/routing/app_router.dart#L89-L100) | draft → pending → partialPublished → published |
| Trending | [trending_service.dart](lib/data/services/trending_service.dart) | Live trend tags pulled from dev.to (primary source), filtered by Gemini |

---

## 3. Architecture (code dive)

```
lib/domain          entities + repository interfaces (pure Dart)
lib/data
  ├─ database        Drift/SQLite (AppDatabase, LocalDatabase)
  ├─ repositories     interface implementations
  └─ services         Gemini, OAuth, Publish, Embedding, Whisper, Trending, DbSync
lib/application
  └─ providers        Riverpod providers/notifiers (state glue)
lib/presentation
  ├─ screens
  ├─ widgets
  └─ routing          go_router
lib/core             constants, theme, errors, utils
```

### Entry point & DI wiring
**File:** [lib/main.dart](lib/main.dart)
- [main.dart:12-13](lib/main.dart#L12-L13) — `WidgetsFlutterBinding.ensureInitialized()` first, since we do async work before `runApp`.
- [main.dart:14-21](lib/main.dart#L14-L21) — `BootstrapService` loads device ID + configured sync folder path *before* the DB opens, because the DB path itself depends on whether a sync folder is set.
- [main.dart:23](lib/main.dart#L23) — `AppDatabase(dbPath)` — opened directly from the sync folder path when configured. Comment at [main.dart:17-20](lib/main.dart#L17-L20) explains the "vessel" design: every Drift write lands in `castpa.db` immediately; SQLite handles cross-connection visibility at the file level.
- [main.dart:38-43](lib/main.dart#L38-L43) — `ProviderContainer` built manually (not via `ProviderScope` widget) with `overrides` for `databaseProvider`/`localDatabaseProvider`, so the real `db` instance is injected before any provider reads it. Then wrapped in `UncontrolledProviderScope` at [main.dart:62-67](lib/main.dart#L62-L67).
- [main.dart:46-60](lib/main.dart#L46-L60) — `DbSyncService` only starts if `bootstrap.hasSyncFolder`. Wired to `db.tableUpdates().listen(...)` at [main.dart:57](lib/main.dart#L57) so every local write is timestamped for conflict detection.
- [main.dart:71-110](lib/main.dart#L71-L110) — `_AppRoot` disposes the sync watcher on teardown and clears the share-intent folder on app resume (`didChangeAppLifecycleState`).

**Talking point:** "I build the `ProviderContainer` manually before `runApp` instead of using the default `ProviderScope` widget, specifically so I can inject already-opened services (DB, sync watcher) with real dependencies rather than lazily creating them inside widget build."

### Routing
**File:** [lib/presentation/routing/app_router.dart](lib/presentation/routing/app_router.dart)
- [app_router.dart:59-129](lib/presentation/routing/app_router.dart#L59-L129) — `GoRouter` with a `ShellRoute` ([:62-71](lib/presentation/routing/app_router.dart#L62-L71)) wrapping Home/Settings in a bottom `NavigationBar` (`AppShell`, [:15-57](lib/presentation/routing/app_router.dart#L15-L57)), plus flat routes for post creation/detail, queue-by-status, category manager, folder setup/browser, and debug screens (DB inspector).
- [app_router.dart:89-100](lib/presentation/routing/app_router.dart#L89-L100) — queue route takes `:status` as a path param and a `week` query param; `partialPublished` posts get folded into the `published` filter view ([:95-97](lib/presentation/routing/app_router.dart#L95-L97)).

---

## 4. AI/ML deep dive — full RAG pipeline (lead with this section, it's the core ML story)

This is the part to walk slowest through: it's a real, small-scale RAG system — no vector DB, hand-rolled cosine similarity, embeddings stored as JSON in SQLite.

### Step 1 — Trending tag fetch → Gemini filter → embed → store
**File:** [lib/data/services/trending_service.dart](lib/data/services/trending_service.dart)
1. **Fetch raw candidates** — [:97-109](lib/data/services/trending_service.dart#L97-L109) `_fetchGlobalTrendTopics()`: tries dev.to tags first ([:113-133](lib/data/services/trending_service.dart#L113-L133) `_fetchFromDevTo`), falls back to Hacker News titles → Gemini keyword extraction ([:136-159](lib/data/services/trending_service.dart#L136-L159) `_fetchFromHackerNews` + [gemini_service.dart:356-407](lib/data/services/gemini_service.dart#L356-L407) `extractKeywordsFromTitles`), then a final Gemini-only fallback ([gemini_service.dart:411-457](lib/data/services/gemini_service.dart#L411-L457) `fetchGlobalTrendTopics`).
2. **Gemini filter (system prompt for curation)** — [trending_service.dart:52-61](lib/data/services/trending_service.dart#L52-L61) calls `_geminiService.filterTrendingTags(trendTopics)`. The actual prompt lives at [gemini_service.dart:459-518](lib/data/services/gemini_service.dart#L459-L518) — rules for what counts as a "real" hashtag are hardcoded in the prompt text at [:469-478](lib/data/services/gemini_service.dart#L469-L478) (drop event/meta/generic tags, keep real tech tags).
3. **Convert to vectors** — [trending_service.dart:66-76](lib/data/services/trending_service.dart#L66-L76): for the filtered tag list, computes one combined embedding (`fullEmbedding`, all tags joined) **and** one embedding per individual tag (`eachEmbedding`) via `_embeddingService.embedChunked(...)` ([embedding_service.dart:83-119](lib/data/services/embedding_service.dart#L83-L119) — chunks text into 320-char windows with 75% overlap, embeds each chunk, averages + re-normalizes).
4. **Store in DB** — [trending_service.dart:78-91](lib/data/services/trending_service.dart#L78-L91) builds a `Trending` entity and calls `_trendingRepo.saveTrending(trending)`. Table schema: [app_database.dart:120-138](lib/data/database/app_database.dart#L120-L138) `Trendings` table — vectors are stored as JSON-encoded arrays in plain `TEXT` columns: `fullEmbeddingJson` ([:126-127](lib/data/database/app_database.dart#L126-L127)) and `eachEmbeddingJson` ([:128-129](lib/data/database/app_database.dart#L128-L129)). **No vector DB — just JSON blobs in SQLite, decoded back into `List<double>` at read time.**

### Step 2 — Post polish: Gemini system prompt returns post-based tags
**File:** [lib/data/services/gemini_service.dart](lib/data/services/gemini_service.dart)
- [:61-137](lib/data/services/gemini_service.dart#L61-L137) `buildPolishPrompt()` — this is the system/user prompt sent to Gemini. It asks for hook type, structure, per-platform content, **and** a `tags` array (rules at [:115-123](lib/data/services/gemini_service.dart#L115-L123): must be real, actively-used hashtags, not invented ones).
- [:139-243](lib/data/services/gemini_service.dart#L139-L243) `polishPost()` sends the prompt to Gemini (`gemini-2.5-flash-lite`, model constant at [:40](lib/data/services/gemini_service.dart#L40)), regex-extracts the JSON block from the raw text response ([:209](lib/data/services/gemini_service.dart#L209)), and parses `tags` at [:218-222](lib/data/services/gemini_service.dart#L218-L222).
- Caller: [post_edit_notifier.dart:502-603](lib/application/notifiers/post_edit_notifier.dart#L502-L603) `polish()` — takes `result.tags` ([:544-546](lib/application/notifiers/post_edit_notifier.dart#L544-L546)), then **embeds each tag individually** ([:548-559](lib/application/notifiers/post_edit_notifier.dart#L548-L559)) via `embService.embedChunked(tagText)`, and stores the array-of-vectors as JSON in `postBaseTagsEmbedding` ([:569](lib/application/notifiers/post_edit_notifier.dart#L569)) — column defined at [app_database.dart:21](lib/data/database/app_database.dart#L21).

### Step 3 — Tag-based similarity: selecting trending tags for a post (the actual "RAG" retrieval step)
**File:** [lib/application/notifiers/post_edit_notifier.dart](lib/application/notifiers/post_edit_notifier.dart), function `filterTrendingTagsByRag` at [:366-453](lib/application/notifiers/post_edit_notifier.dart#L366-L453)
- [:371-372](lib/application/notifiers/post_edit_notifier.dart#L371-L372) — reads back the post's cached tag embeddings (`postBaseTagsEmbedding` JSON, from Step 2) instead of re-embedding.
- [:381-384](lib/application/notifiers/post_edit_notifier.dart#L381-L384) — parses the JSON string back into `List<List<double>>`.
- [:390-426](lib/application/notifiers/post_edit_notifier.dart#L390-L426) — the actual retrieval loop: for **each post tag**, scores it against **every trending tag** using a hybrid score:
  - **Cosine similarity** between the post tag's vector and the trend tag's stored vector — [:411-414](lib/application/notifiers/post_edit_notifier.dart#L411-L414), calling `embService.cosineSimilarity(tagVec, trending.eachEmbedding[i])` — the actual cosine math lives at [embedding_service.dart:121-131](lib/data/services/embedding_service.dart#L121-L131) (plain dot-product / (‖a‖·‖b‖)).
  - **+0.5 keyword-match bonus** if the tag words literally intersect ([:394-409](lib/application/notifiers/post_edit_notifier.dart#L394-L409)) — a hybrid semantic + lexical score, not pure vector search.
- [:418-426](lib/application/notifiers/post_edit_notifier.dart#L418-L426) — keeps the top-5 trend tags **per post tag** (`perTagTopN = 5`, [:388](lib/application/notifiers/post_edit_notifier.dart#L388)), then merges across all post tags keeping the max score per trend tag (dedup).
- [:428-432](lib/application/notifiers/post_edit_notifier.dart#L428-L432) — final ranking sorted by score, sliced to `topK` (user-configurable via Settings → `trendTagsPerPost`, default 5).
- [:444](lib/application/notifiers/post_edit_notifier.dart#L444) — full scoring detail (`perTagDebug`, `mergedDebug`, `finalDebug`) is kept in `RagDebugData` and surfaced in a dedicated **RAG debug screen** (`rag_debug_screen`) — good to open live and show the actual per-tag score table.

**One-paragraph pitch:** "This is a small hand-rolled RAG system, not a hosted vector DB. Both trending tags and post tags get embedded on-device with the same MiniLM model so they live in the same vector space; embeddings are just JSON arrays in SQLite columns. Retrieval is a brute-force cosine similarity scan (post tags is always a handful, trending tags ~10-20, so no ANN index is needed) blended with a lexical keyword-match bonus, and only the fallback path (TF-IDF) is used if the on-device model fails to load."

---

## 5. LinkedIn / X OAuth — where it's wired

**Core PKCE logic:** [lib/data/services/oauth_service.dart](lib/data/services/oauth_service.dart)
- [:10-11](lib/data/services/oauth_service.dart#L10-L11) — static redirect URI + custom URL scheme `castpa`.
- [:34-101](lib/data/services/oauth_service.dart#L34-L101) `connectLinkedIn()` — builds the LinkedIn `/oauth/v2/authorization` URL ([:40-46](lib/data/services/oauth_service.dart#L40-L46)), opens it via `FlutterWebAuth2.authenticate` ([:48-51](lib/data/services/oauth_service.dart#L48-L51)), validates `state` ([:62-64](lib/data/services/oauth_service.dart#L62-L64)), exchanges the code for tokens ([:67-77](lib/data/services/oauth_service.dart#L67-L77)).
- [:103-198](lib/data/services/oauth_service.dart#L103-L198) `connectX()` — same flow but with full PKCE: `_randomString`/`_s256` helpers at [:26-32](lib/data/services/oauth_service.dart#L26-L32), `code_challenge`/`S256` params at [:114-122](lib/data/services/oauth_service.dart#L114-L122), verifier sent at token exchange [:164](lib/data/services/oauth_service.dart#L164).

**UI trigger + token persistence:** [lib/presentation/screens/settings/settings_screen.dart](lib/presentation/screens/settings/settings_screen.dart)
- [:71](lib/presentation/screens/settings/settings_screen.dart#L71) — `OAuthService` instantiated directly in the screen (not via Riverpod provider for this call site).
- [:228-259](lib/presentation/screens/settings/settings_screen.dart#L228-L259) `_connectLinkedIn()` — calls `_oauth.connectLinkedIn(...)`, then saves `linkedinAuthToken`/`linkedinRefreshToken` through `settingsNotifierProvider.notifier.save(...)` ([:235-242](lib/presentation/screens/settings/settings_screen.dart#L235-L242)).
- [:261-269](lib/presentation/screens/settings/settings_screen.dart#L261-L269) `_disconnectLinkedIn()` — clears the tokens.

**Storage:** [lib/data/database/app_database.dart:56-87](lib/data/database/app_database.dart#L56-L87) `Settings` table — `linkedinAuthToken`/`linkedinRefreshToken`/`xAuthToken`/`xRefreshToken` are plain nullable `TEXT` columns (single-row table, `rowId` primary key defaulting to `1`). Mapped in [lib/data/repositories/settings_repository_impl.dart:18](lib/data/repositories/settings_repository_impl.dart#L18) (read) and [:48](lib/data/repositories/settings_repository_impl.dart#L48) (write).

**Consumption at publish time:** [lib/application/notifiers/publish_notifier.dart:82-84](lib/application/notifiers/publish_notifier.dart#L82-L84) — reads `settings.linkedinAuthToken`/`settings.xAuthToken` straight out of the settings notifier and passes them into `PublishService.publish(...)`.

---

## 6. The two "hard problem" stories (go deep here if asked)

### A. Sync without a backend
**File:** [lib/data/services/db_sync_service.dart](lib/data/services/db_sync_service.dart)
- [:15-34](lib/data/services/db_sync_service.dart#L15-L34) — class doc explains the strategy: watch `castpa.db` for external file changes; only back up when *this* device wrote recently (real conflict risk), not on every idle sync from another device.
- [:38-40](lib/data/services/db_sync_service.dart#L38-L40) — `notifyLocalWrite()` stamps `_lastLocalWriteAt`, called from [main.dart:57](lib/main.dart#L57) on every table update.
- [:42-53](lib/data/services/db_sync_service.dart#L42-L53) — `start()` watches the parent directory for `modify`/`create` events filtered to the exact `watchedDbPath`.
- [:55-67](lib/data/services/db_sync_service.dart#L55-L67) — `_onExternalChange` debounces 300ms, then checks `_wasRecentlyActive()` ([:70-73](lib/data/services/db_sync_service.dart#L70-L73), 7-minute window) before deciding to back up.
- [:75-100](lib/data/services/db_sync_service.dart#L75-L100) — `_backup()` copies the DB into a `.backups/` folder with a timestamp; `_pruneBackups` ([:102-124](lib/data/services/db_sync_service.dart#L102-L124)) keeps only the most recent 10.

**Honest limitation to state if asked:** this is last-write-wins at the file level, not a real CRDT/merge — the backup is a safety net for *recovering* from a conflict, not resolving one automatically.

### B. Hybrid AI — cloud generation + on-device inference
**Cloud (Gemini):** [lib/data/services/gemini_service.dart](lib/data/services/gemini_service.dart)
- [:38-41](lib/data/services/gemini_service.dart#L38-L41) — model = `gemini-2.5-flash-lite`, separate embedding model `text-embedding-004`.
- [:61-137](lib/data/services/gemini_service.dart#L61-L137) — `buildPolishPrompt()` dynamically builds hook/structure/tag-count instructions based on user settings (`hookType`, `structure`, `postTagMode`, etc.) — this is the core "AI polish" prompt.
- [:139-243](lib/data/services/gemini_service.dart#L139-L243) — `polishPost()` calls Gemini, regex-extracts the JSON blob from the response ([:209](lib/data/services/gemini_service.dart#L209)), parses into `PolishResult`.
- [:459-518](lib/data/services/gemini_service.dart#L459-L518) — `filterTrendingTags()` — a second Gemini call specifically to curate raw dev.to tags down to real, actively-used hashtags (rules baked into the prompt at [:469-478](lib/data/services/gemini_service.dart#L469-L478)).

**On-device (TFLite MiniLM):** [lib/data/services/embedding_service.dart](lib/data/services/embedding_service.dart)
- [:10-18](lib/data/services/embedding_service.dart#L10-L18) — 384-dim embeddings via `all-MiniLM-L6-v2`, lazy-loaded.
- [:28](lib/data/services/embedding_service.dart#L28), [:46-61](lib/data/services/embedding_service.dart#L46-L61) — macOS-specific quirk: manually copies the TFLite C dylib into the app bundle's `Contents/resources/` on first run because `tflite_flutter`'s FFI binding expects a fixed path — good "gnarly platform bug" story.
- [:151-158](lib/data/services/embedding_service.dart#L151-L158) — resizes input tensors dynamically per sequence length, then **must** re-fetch tensor references after `allocateTensors()` (comment at [:155-156](lib/data/services/embedding_service.dart#L155-L156) — stale pointers cause an FFI crash otherwise). Good example of debugging a native-interop footgun.
- [:180-193](lib/data/services/embedding_service.dart#L180-L193) — handles both pooled (`[1,384]`) and per-token (`[1,seqLen,384]`) output shapes, mean-pooling over the attention mask when needed.
- [:271-306](lib/data/services/embedding_service.dart#L271-L306) — TF-IDF cosine-similarity fallback (`rankAgainst`) used when the model isn't available at all — graceful degradation.

**Local transcription:** [lib/data/services/whisper_transcription_service.dart](lib/data/services/whisper_transcription_service.dart)
- [:7](lib/data/services/whisper_transcription_service.dart#L7) — uses Whisper `base` model (~145MB), downloaded on demand.
- [:26-32](lib/data/services/whisper_transcription_service.dart#L26-L32) — `TranscribeRequest` with `isNoTimestamps: true, splitOnWord: true`.

### C. Publishing pipeline
**File:** [lib/data/services/publish_service.dart](lib/data/services/publish_service.dart)
- [:20-89](lib/data/services/publish_service.dart#L20-L89) — `_uploadLinkedInImage()`: two-step LinkedIn media upload (register asset → PUT binary to the returned `uploadUrl`), returns the asset URN.
- [:91-210](lib/data/services/publish_service.dart#L91-L210) — `publishToLinkedIn()`: fetches author URN from `/v2/userinfo` ([:111-114](lib/data/services/publish_service.dart#L111-L114)), uploads any images, builds `ugcPost` body with either `shareMediaCategory: NONE` or `IMAGE` ([:148-163](lib/data/services/publish_service.dart#L148-L163)), posts to `/v2/ugcPosts`.
- [:212-263](lib/data/services/publish_service.dart#L212-L263) — `publishToX()`: single POST to `/2/tweets` — much simpler, no media support yet (matches the known TODO in `publish_notifier.dart` about video/image support being LinkedIn/X-image-only).
- [:265-290](lib/data/services/publish_service.dart#L265-L290) — `publish()` orchestrates both targets sequentially, returning a `List<PublishResult>`.

---

## 7. Anticipated Q&A

| Question | Answer |
|---|---|
| Why no backend? | Single-user tool — sync folder does double duty as storage + multi-device sync, avoids hosting cost/complexity. |
| How do conflicting writes get resolved? | Not automatically — [db_sync_service.dart:55-67](lib/data/services/db_sync_service.dart#L55-L67) only creates a timestamped backup when a local write happened within the last 7 minutes of an external change landing. It's a safety net for manual recovery, last-write-wins at the file level. |
| Why Riverpod? | Manual `ProviderContainer` construction ([main.dart:38-43](lib/main.dart#L38-L43)) lets me inject real service instances before `runApp`, and `overrideWith` makes testing straightforward. |
| Why on-device Whisper/MiniLM instead of full cloud? | Cost + privacy for content that doesn't need cloud-grade quality — transcription and similarity/dedup don't need to leave the device; Gemini is reserved for content generation where quality matters most. |
| Hardest bug you hit? | TFLite FFI: tensor references become stale after `allocateTensors()` and reading them crashes — fixed by re-fetching tensors post-allocation ([embedding_service.dart:155-158](lib/data/services/embedding_service.dart#L155-L158)). Also the macOS dylib path issue ([:46-61](lib/data/services/embedding_service.dart#L46-L61)). |
| What's not built yet? | Video publishing (images only currently — see TODO in `publish_notifier.dart`), tag intelligence/blocklist system, `share_plus` OS-level share-sheet integration. |
| Why no vector DB (Pinecone/pgvector/etc.)? | Scale doesn't need it — trending tags are ~10-20 per week, post tags are a handful. Brute-force cosine similarity over JSON-decoded arrays ([post_edit_notifier.dart:390-426](lib/application/notifiers/post_edit_notifier.dart#L390-L426)) is O(n·m) and trivially fast at this size; adding a vector index would be premature infra for a single-user local app. |
| Why embed tags individually instead of one big embedding? | Retrieval granularity — scoring per post-tag against per-trend-tag ([:390-416](lib/application/notifiers/post_edit_notifier.dart#L390-L416)) lets you match "flutter" to "flutterdev" precisely, instead of one blurred average vector for the whole post diluting the signal. |
| Why blend cosine similarity with a keyword-match bonus instead of pure vector search? | Small MiniLM embeddings on short tag strings (1-2 words) are noisy — the flat +0.5 lexical bonus ([:409](lib/application/notifiers/post_edit_notifier.dart#L409)) acts as a cheap re-ranker so an exact/near-exact word match always beats a merely "semantically close" one. |
| What happens if the on-device model fails to load? | `EmbeddingService.isModelAvailable` ([embedding_service.dart:63](lib/data/services/embedding_service.dart#L63)) flips false and `embed()`/`embedChunked()` return `[]`; the app still has the TF-IDF cosine fallback (`rankAgainst`, [:271-306](lib/data/services/embedding_service.dart#L271-L306)) though it isn't currently wired into the tag-matching path — an honest gap worth naming if asked. |
