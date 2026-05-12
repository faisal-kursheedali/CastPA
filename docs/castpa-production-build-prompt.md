# Castpa Production Build Prompt

You are building **Castpa**, a **production-grade local-first Flutter application** for **macOS desktop and Android mobile** from a **single Flutter codebase**.

Your job is to implement the full app with strong architecture, clean UX, robust state handling, solid persistence, and realistic production-quality code. Do not produce a toy demo, placeholder-only app, or static mockup. Build the app as if it is intended to be shipped and maintained.

The app is called **Castpa**.

---

## 1. Product Summary

Castpa is a personal content publishing app for solo creators.

The user should be able to:

1. Capture raw ideas quickly.
2. Edit them into post drafts.
3. Polish them with AI into platform-specific content for LinkedIn and X.
4. Add and manage categories.
5. Attach media.
6. See queue-based workflows:
   - Draft
   - Pending
   - Partial Published
   - Published
7. Preview the final post in platform-like UI cards.
8. Publish to LinkedIn and X.
9. Use a shared cloud-synced folder across devices.
10. Keep all core content local-first.

The app is **not** a cloud backend product. The app stores its data locally and uses a **user-selected cloud-synced folder** such as Google Drive or iCloud Drive so the same data can appear across devices.

---

## 2. Platforms and Tech Requirements

Build for:

- macOS
- Android

Single codebase:

- Flutter

Required implementation direction:

- Use Flutter with maintainable architecture
- Use SQLite for local persistence
- Use robust repository/service separation
- Use models and domain entities cleanly
- Prefer production-grade package choices
- Handle async, lifecycle, navigation, and persistence carefully

Recommended architecture:

- `presentation`
- `application`
- `domain`
- `data`

or a similarly strong feature-first structure.

Recommended packages:

- `drift` for SQLite
- `path_provider`
- `file_picker`
- `uuid`
- `flutter_secure_storage` only if needed later, but for MVP tokens may remain in DB
- routing package if useful
- state management package if useful, such as Riverpod

Do not overengineer, but do build real working foundations.

---

## 3. Core Product Rules

### 3.1 Local-first rule

All user content is local-first.

All primary app data lives in a **user-selected sync folder**:

```text
[selected sync folder]/
├── castpa.db
└── media/
```

The app itself does not implement cloud sync.

The app only reads/writes inside that folder.

Sync is handled externally by the user's own sync provider.

### 3.2 Local bootstrap rule

Even though the main app data is stored in the shared sync folder, the app must still locally store a tiny bootstrap config so it knows where the DB lives on next launch.

Locally store:

- `device_id`
- `sync_folder_path`

This local bootstrap config is required because the app cannot query `castpa.db` until it first knows where that DB file is.

---

## 4. Multi-Device Sync Logic

The app supports multiple devices using the same synced folder.

### First launch flow

1. Ask the user to select a sync folder.
2. Generate or detect a `device_id`.
3. Ensure `media/` exists.
4. Ensure `castpa.db` exists.
5. Open DB from the selected folder.
6. Check the `device` table:
   - if current `device_id` exists, update its path
   - if not, insert a new row
7. Save local bootstrap config:
   - `device_id`
   - `sync_folder_path`

### Subsequent launch flow

1. Read local bootstrap config.
2. If path missing or invalid, ask user to select folder again.
3. Open DB from that path.
4. Upsert `device` table entry for current device.
5. Refresh local bootstrap config if path changed.

### Important behavior

- Never create duplicate `device` rows for the same device ID.
- Device rows are keyed by `device_id`.
- `root_folder_path` can change over time and must be updated.

---

## 5. Database Schema

Use SQLite.

Use migrations.

Use production-safe modeling.

Arrays should be stored as JSON-encoded text in SQLite, but exposed in app code as typed lists.

### 5.1 `post` table

Fields:

- `id`
- `dump`
- `linkedin_content`
- `twitter_content`
- `embedding`
- `category_id`
- `links`
- `post_base_tags`
- `category_base_publish_tags_json`
- `trends_base_publish_tags_json`
- `media_ids`
- `selected_platforms`
- `published_platforms`
- `status`
- `created_at`
- `updated_at`

Meaning:

- `dump`: raw user text
- `linkedin_content`: polished LinkedIn content
- `twitter_content`: polished X content
- `embedding`: vector based on `linkedin_content`
- `category_id`: one category per post
- `links`: list of strings
- `post_base_tags`: Gemini-generated post-specific tags
- `category_base_publish_tags_json`: final category tags frozen only after full publish
- `trends_base_publish_tags_json`: final trend tags frozen only after full publish
- `media_ids`: list of attached media IDs
- `selected_platforms`: editorial intent chosen in edit mode
- `published_platforms`: cumulative successful publish destinations
- `status`: `draft | pending | partial_published | published`

### 5.2 `media` table

- `id`
- `original_filename`
- `stored_filename`
- `added_date`

### 5.3 `settings` table

- `linkedin_auth_token`
- `linkedin_refresh_token`
- `x_auth_token`
- `x_refresh_token`
- `gemini_token`
- `publish_per_week`

For MVP, tokens may remain in SQLite.

If you encode them, clearly treat that as convenience only, not true security.

### 5.4 `device` table

- `device_id`
- `device_name`
- `root_folder_path`

### 5.5 `publish` table

- `id`
- `post_id`
- `published_date`
- `platform` -> Array of string (["linkedin", "x"])
- `device_id`

This table is publish history / audit trail.

### 5.6 `category` table

- `id`
- `name`
- `description`
- `created_date`
- `status`

`status` is:

- `active`
- `inactive`

Delete in UI must be soft-delete only.

### 5.7 `trending` table

- `id`
- `trend_topics`
- `category_topics`
- `added_date`
- `full_embedding`
- `each_embedding`

Important:

- `trend_topics` = global broad trend topics
- `category_topics` = category-derived tags built from all app categories for MVP
- `full_embedding` = embedding of combined `trend_topics`
- `each_embedding` = per-topic embeddings for `trend_topics`
- no embeddings needed for `category_topics` in MVP

Each row in `trending` represents a **weekly snapshot**.

One row = one weekly trend fetch.

---

## 6. Status Rules

### `draft`

- initial state
- incomplete or not fully polished

### `pending`

- polished content exists for all selected platforms
- ready to publish

### `partial_published`

- some selected platforms successfully published
- not all selected platforms are complete yet

### `published`

- all selected platforms successfully published

When fully published:

- freeze current category tags into `category_base_publish_tags_json`
- freeze current trend tags into `trends_base_publish_tags_json`

Do **not** freeze those values on `partial_published`.

---

## 7. Home Screen / App Shell

Use bottom navigation with exactly:

- Home
- Settings

All other screens are full-screen routes pushed on top.

### Home layout

#### Top-left

Weekly publish progress ring:

- published this week / `publish_per_week`

Color thresholds:

- 0–40% red
- 40–70% orange
- 70–100% green

Tap action:

- navigate to Published List filtered to current week

#### Top-right

- primary button: `Publish post`
  - opens Pending List
- secondary button: `Complete drafts`
  - opens Draft List

#### Center

- big `Create new post` action

#### Bottom shortcuts

- Pending List
- Published List
- Partial Published List
- Category Manager

---

## 8. Settings Screen

Must include:

- Connect LinkedIn
- Connect X
- Gemini API token field
- Publish per week field
- Change folder path / connect folder
- App version display

Hidden behavior:

- tap version number 5 times quickly to open Device Info screen

### Device Info screen

Read-only list of devices with:

- device name
- device ID
- root folder path

---

## 9. Category Manager

There is a dedicated Category Manager page.

Access it from Home bottom shortcuts.

### Category list UI

Each tile shows:

- title
- description
- date

Top-right on each tile:

- 3-dot menu

Menu options:

- Edit category
- Delete category

### Create category

Top-right `+` button on page opens popup.

Popup fields:

- title
- description
- date

Rules:

- title must be unique
- new category defaults to `active`

### Edit category

Uses same popup as create.

Fields prefilled.

Uniqueness rule:

- same existing title is allowed for the same row
- only fail if changed title matches another category

### Delete category

Do not physically delete.

Instead:

- set `status = inactive`

### Important category behavior

- posts map by `category_id`, not by category name
- if category name changes, old posts still belong to same category ID
- inactive categories must still appear in filters because historical posts depend on them
- in post creation/edit, each post can have only **one** category
- in list filters, user can select **multiple** categories

---

## 10. Queue Screens

Build these queue screens:

- Draft List
- Pending List
- Partial Published List
- Published List

All queues should use the same reusable list/table foundation.

### Common queue features

- category filter
- today / this week / this month filters
- list view / table view toggle
- sort options -> date and time

Category filter rules:

- multi-select
- show both active and inactive categories
- filter by `category_id`

### Draft List

- show `status = draft`

### Pending List

- show `status = pending`

### Partial Published List

- show `status = partial_published`
- include trend-based sorting too

### Published List

- show `status = published`
- tap row opens detail page with locked edit

---

## 11. RAG / Trend Sort Logic

Pending and Partial Published list screens support:

<!-- - sort by RAG -->

- sort by trend

### Fetching logic

When user taps trend/RAG sort:

1. Get current date/time.
2. Find most recent `trending` row.
3. Check whether `added_date` is in the same calendar week as now.
4. If yes, reuse it.
5. If no:
   - fetch new broad trend topics
   - build category topics
   - store new `trending` row

### Trend sources for MVP

#### `trend_topics`

Use broad topics from:

- CS
- tech
- learning

#### `category_topics`

For MVP:

- derive from **all categories in the app**
- not per-post
- not per-category relation table

### Embedding logic

Use only `trend_topics` for embeddings.

Store:

- `full_embedding`
- `each_embedding`

Then compare:

- post embedding vs `full_embedding`

Use cosine similarity for sorting.

Corner cases:

- stale trending row
- missing embeddings
- empty polished LinkedIn content
- vector length mismatch
- malformed stored JSON

If vector invalid:

- similarity should fall back safely, not crash

---

## 12. Post Creation and Post Detail

There are two related flows:

- Create Post
- Post Detail

## 12.1 Create Post

Tabs:

- Edit
- Preview

Default tab:

- Edit

If no polished content yet:

- Preview should show meaningful empty state message
- not broken blank screen

### Create post save rule

If user exits with all fields empty:

- do not save record

If any meaningful field has content:

- save as draft

Meaningful fields include:

- dump
- links
- selected platforms
- polished content
- tags
- category
- media

## 12.2 Post Detail

Used for posts opened from queues.

Tabs:

- Preview
- Edit

Behavior varies by status.

### Draft / Pending detail

- normal preview + edit access

### Partial Published detail

- Preview shown first
- Edit tab locked by default
- Preview uses **dynamic current-week** category and trend tags from `trending`
- 5 taps on locked edit opens tag-only edit screen
- 10 taps on locked edit opens full edit screen

### Published detail

- Preview shown first
- Edit tab locked
- Preview uses frozen:
  - `category_base_publish_tags_json`
  - `trends_base_publish_tags_json`

---

## 13. Post Edit Tab Requirements

In Create Post and editable Post Detail:

### Fields order

1. Dump
2. Record audio button
3. Links
4. Platform checkboxes
5. Category selector
6. Media attachments
7. Platform-specific polished content fields
8. Tag fields - 3 fields (post base, category base, trend base)
9. Polish button

### Dump

- multiline text
- autosaved

### Record audio

- records audio
- uses local Whisper
- appends transcript to dump
- does not replace existing dump
- runs in background
- show loading/progress state

### Links

- multiple links
- can add more

### Platform selection

After links, show checkboxes for:

- LinkedIn
- X

Default:

- both checked for new post (this check box checked based on what all platform loggedin in seeting screen)

Behavior:

- if LinkedIn checked, show LinkedIn content field
- if X checked, show X content field
- if unchecked, hide corresponding field
- `selected_platforms` is updated from these controls

### Category

- dropdown / picker
- one category per post

### Media

Two actions:

- select from existing library
- upload new file

Upload rules:

- copy file into `media/`
- rename to UUID-based stored filename
- keep original filename in DB
- append media ID to post

Unlink rules:

- remove reference only
- do not delete actual file or media row

---

## 14. Tag Model

There are **3 separate tag fields** in edit/preview flows.

### 14.1 Post base tags

- generated by Gemini when user hits Polish
- relatively stable
- changes when Polish is run again
- persisted on post as `post_base_tags`

### 14.2 Category tags

- prefilled from current week `trending.category_topics`
- editable by user in UI
- dynamic before full publish
- not persisted before full publish
- when fully published, freeze into `category_base_publish_tags_json`

### 14.3 Trend tags

- prefilled from current week `trending.trend_topics`
- editable by user in UI
- dynamic before full publish
- not persisted before full publish
- when fully published, freeze into `trends_base_publish_tags_json`

### Important published behavior

Before full publish:

- category tags and trend tags are dynamic

After full publish:

- show frozen saved values, not new current week values

### Final display order

When user sees final combined tags, order should be:

1. post base tags
2. category tags
3. trend tags

---

## 15. Polish Flow

When user taps `Polish`:

1. Validate:
   - dump exists
   - at least one platform selected
   - Gemini token available
2. Send dump to Gemini
3. Receive:
   - polished LinkedIn content
   - polished X content
   - post-specific tags
4. Save post-specific tags as `post_base_tags`
5. Load current week's trending row or fetch it
6. Prefill category tags and trend tags
7. Generate embedding from `linkedin_content`
8. Save post
9. Update status:
   - `pending` if all selected platforms have polished content
   - else `draft`

Corner cases:

- only LinkedIn selected
- only X selected
- polish fails partially
- Gemini returns malformed data
- no Gemini token
- network timeout

Do not crash.

Show user-friendly error states. -> just dont fill the polished conetnet (on select platfomr text field and post base tags)

---

## 16. Preview Tab Requirements

Preview must not just show raw edit text.

It must show **platform-like preview cards**.

### LinkedIn preview

Create a realistic LinkedIn-style card:

- avatar
- author name
- optional role/subtitle
- post text
- tags
- reaction/action row

### X preview

Create a realistic X-style card:

- avatar
- display name
- handle
- post text
- tags
- reply / repost / like / analytics row

### Visibility rules

- if LinkedIn selected, show LinkedIn card
- if X selected, show X card
- if platform not selected, do not show its card

### Empty-state rule

If no polished content yet:

- show friendly empty state
- explain that user must polish first

---

## 17. Publish Target Behavior

In Preview tab, show publish target checklist.

But do **not** show platforms not in `selected_platforms`.

Rules:

- Publish checklist must reflect selected platforms
- if only LinkedIn selected in edit, Preview must show only LinkedIn target
- if only X selected, show only X
- if both selected, show both

### Published platform logic

Use:

- `selected_platforms`
- `published_platforms`

Compute:

- remaining targets = `selected_platforms - published_platforms`

if there any thing in remaining targets then post status will be "partial_publish" -> when the uyser comes back to post with status partial_publish -> in the preview tab -> show only this platform check box clikable (anothr platform chek box - checked - unclikable)

### Preview behavior by status

#### Pending / Draft

- publish target list shows currently selected platforms

#### Partial Published

- show only remaining unpublished platforms as actionable
- already published platforms shown as complete / non-actionable if desired

#### Published

- publish button disabled

### Publish button label

Make it explicit, e.g.:

- `Publish to LinkedIn`
- `Publish to X`
- `Publish to LinkedIn and X`
- `Publish to remaining platforms`

---

## 18. Publish Flow

When user taps Publish:

1. Validate:
   - at least one selected platform
   - polished content exists for all selected publish targets
   - category selected
2. Determine remaining targets
3. Only publish to targets not yet present in `published_platforms`
4. Show confirmation popup listing actual target platforms
5. Call LinkedIn / X APIs
6. For each success:
   - insert row into `publish`
   - append platform into `published_platforms`
7. Recompute status:
   - if all selected platforms published -> `published`
   - else -> `partial_published`
8. If status became fully `published`:
   - save visible category tags to `category_base_publish_tags_json`
   - save visible trend tags to `trends_base_publish_tags_json`

Corner cases:

- one platform succeeds, one fails -> just nmake the post as partial_publish and add the succeded platform in published_platfomr
<!-- - retry later
- duplicate publish attempt -->
- API timeout
- token expired
- platform temporarily disconnected

Never republish to already-published platform by mistake.

---

## 19. OAuth Requirements

Build proper OAuth integration for:

- LinkedIn
- X

Allo user to connect to the platform from the app

### Requirement

Users must not manually paste access tokens.

The app should support:

1. provider configuration in settings
2. auth start flow
3. redirect handling
4. code exchange
5. token persistence
6. refresh token flow if supported

### MVP limitation

If provider credentials are not available during development, still implement strong architecture:

- OAuth service abstraction
- provider-specific config
- auth session state
- redirect parsing support
- token storage and refresh contract

Make the design production-ready even if live credentials are inserted later.

---

## 20. Media Library

Build shared media library behavior.

### Media source of truth

- DB row in `media`
- physical file in `/media`

### Media picker

- show all library items
- show previews where possible
- allow multi-select

### Upload new

- file picker
- copy into media folder
- rename to UUID
- preserve original filename in DB

### Remove from post

- unlink only
- keep library item and file

### Out of scope for MVP

- global delete from disk

---

## 21. Auto-Save

All create/edit changes should autosave.

### Rules

- debounce ~800ms
- show subtle status:
  - Saving…
  - Saved
  - Error

### Corner cases

- rapid typing
- route pop during save
- switching tabs
- hidden edit mode for partial publish
- create-post empty exit cleanup

---

## 22. Folder and File Safety

The app writes only to:

- selected sync folder
- local bootstrap config area

Validate and handle:

- missing folder
- moved folder
- permission denied
- folder no longer exists
- media subfolder missing
- DB file missing

If folder invalid:

- prompt user to reconnect path

---

## 23. UX Quality Expectations

Do not build generic ugly admin UI.

Make it feel intentional and polished.

### UI expectations

- clean spacing
- good typography
- mobile and desktop support
- responsive layouts
- cards that feel productized
- queue screens should feel like working surfaces
- preview cards should feel visually platform-specific

### macOS/Desktop behavior

- wider layouts
- cards and forms should scale well
- avoid stretched awkward mobile-only layouts

### Android behavior

- comfortable touch targets
- smooth scrolling
- sensible stacking

---

## 24. Reliability and Corner Cases

Handle all of these gracefully:

- app launch without folder configured
- invalid folder path
- missing DB
- stale trending data
- malformed JSON arrays from DB
- empty publish targets
- no polished content
- no category chosen
- partial publish retries
- publish after one platform already succeeded
- locked edit on published
- 5-tap unlock on partial-published
- 10-tap unlock on partial-published
- changing selected platforms after polish
- deselecting platform with existing polished content
- category renamed after posts already exist
- inactive category still used in historical posts
- app restart during draft editing
- auth config incomplete
- token expired
- Gemini unavailable
- trend fetch unavailable

The app must fail safely and never corrupt local data.

---

## 25. Production Code Expectations

Write code as if this will be maintained by a real team.

Requirements:

- clean architecture
- no giant god widget
- no hardcoded placeholder-only flows for core app logic
- isolate UI from persistence/service logic
- use real models and repositories
- prepare for future testing
- keep naming precise
- use enums for platform/status types
- use typed conversions for JSON arrays
- handle migrations

Also implement:

- form validation
- repository abstractions
- service abstractions for Gemini, OAuth, trends, embeddings
- local bootstrap service
- publish service

---

## 26. Minimum Deliverable Expectation

The final implementation should be a **working Flutter project**, not just documentation or a visual prototype.

At minimum it must include:

1. Working app shell
2. Working folder connect/bootstrap flow
3. Real SQLite persistence
4. Working category manager
5. Working create/edit/preview post flow
6. Platform checkboxes affecting content fields and preview cards
7. Working queue screens
8. Partial vs published state handling
9. Trending weekly snapshot logic
10. Tag lifecycle logic
11. OAuth architecture and working flow where credentials permit
12. Publish workflow architecture

---

## 27. Implementation Priority Order

Build in this order:

1. Project architecture and routing
2. Local bootstrap config
3. SQLite schema and migrations
4. Repositories and models
5. Settings and folder connection
6. Category manager
7. Post create/edit/autosave
8. Preview UI
9. Queue screens
10. Trending weekly snapshot logic
11. Polish flow
12. Publish flow
13. OAuth integration
14. Media flow
15. Whisper integration

---

## 28. Final Instruction

Build Castpa as a real, production-grade Flutter app for macOS and Android with strong persistence, good UX, careful local-first behavior, and exact adherence to the product logic described above.

Do not simplify away the tricky parts.

Do not collapse nuanced state rules.

Do not replace core workflows with placeholders unless explicitly marked temporary and architected for completion.

Aim for code that can genuinely evolve into a shipping product.
