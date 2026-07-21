# Post Flow: Creation → Edit → Publish

## Overview

```
CREATE ──→ EDIT (dump/polish/tags) ──→ SUBMIT ──→ PUBLISH
  │              │                        │           │
  │              │                        │           ▼
  │              │                        │      LinkedIn / X
  │              ▼                        ▼
  │         Auto-save (800ms)     Embedding + Status
  │                                  draft → pending
  ▼
 New Post (UUID, draft)
```

---

## 1. POST CREATION

**Entry:** User opens create post screen.

```
PostEditNotifier.build()
  │
  ├─ Generates new UUID
  ├─ Empty dump, no content
  ├─ Default platforms: [linkedin, x]
  ├─ Status: draft
  ├─ postBaseTags: []
  ├─ postBaseTagsEmbedding: null
  ├─ trendsBasePublishTags: []
  └─ _isNew = true (not saved to DB yet)
```

**First save:** Only happens when user adds content (dump, links, etc.). Auto-save triggers after 800ms debounce.

---

## 2. EDITING — What the user fills in

```
┌─────────────────────────────────────────────┐
│  EDIT TAB                                   │
│                                             │
│  [Dump]           ← raw text/ideas          │
│  [Platform]       ← linkedin, x             │
│  [Category]       ← required for publish    │
│  [Media]          ← images (videos TODO)    │
│  [LinkedIn Content] ← manual or from polish │
│  [X Content]        ← manual or from polish │
│  [Post Base Tags]   ← manual or from polish │
│  [Trending Tags]    ← auto-selected by RAG  │
│                      user can toggle each    │
└─────────────────────────────────────────────┘
```

Every field change → `_updateAndScheduleSave()` → 800ms debounce → save to DB.

When LinkedIn/X content changes → `isEmbedded = false`, status reverts to `draft` if was `pending`.

---

## 3. POLISH (Gemini AI)

**Trigger:** User taps "Polish" button.

```
polish()
  │
  ├─ Validate: dump not empty, platforms selected, API key set
  │
  ├─ Read settings (postTagMode, postTagMin, postTagMax, postTagExact)
  │
  ├─ Build prompt via GeminiService.buildPolishPrompt()
  │   (single source of truth — same prompt used in debug copy)
  │
  ├─ Call Gemini API → returns:
  │   ├─ linkedin_content
  │   ├─ twitter_content
  │   └─ tags[] (3-10 or exact N based on settings)
  │
  ├─ Update post with new content + tags
  │
  ├─ EMBED EACH TAG INDIVIDUALLY:
  │   for each tag in postBaseTags:
  │     ├─ Normalize: "javascript_regex" → "javascript regex"
  │     │             "objectFromEntries" → "object from entries"
  │     ├─ Embed via MiniLM (384-dim, on-device)
  │     └─ Add to allEmbeddings[]
  │
  ├─ Store postBaseTagsEmbedding = JSON array of arrays
  │   e.g. [[0.1,0.2,...], [0.3,0.4,...], ...]
  │
  ├─ Save to DB
  │
  ├─ Status → draft, isEmbedded → false
  │
  └─ RUN RAG FILTER (see section 5)
```

---

## 4. MANUAL TAG EDIT (add/remove post base tags)

```
updatePostBaseTags(tags)
  │
  ├─ Save tags to post
  │
  └─ _embedAndFilterTags(tags)
       │
       ├─ IF tags empty:
       │   ├─ postBaseTagsEmbedding → "[]"
       │   ├─ trendsBasePublishTags → []
       │   ├─ selectedTrendTags → {} (0 selected)
       │   └─ RETURN
       │
       ├─ Embed each tag individually (same as polish)
       ├─ Store postBaseTagsEmbedding = JSON array
       └─ RUN RAG FILTER (see section 5)
```

---

## 5. RAG FILTER — Trending Tag Selection

**When it runs:**

- After polish
- After manual tag add/remove
- On page open (edit/create) if postBaseTags exist

```
filterTrendingTagsByRag(trending, topK)
  │
  ├─ Read cached postBaseTagsEmbedding (JSON array of arrays)
  ├─ IF empty/null → return (no selection)
  │
  ├─ FOR EACH post base tag embedding:
  │   │
  │   ├─ Split tag into words for keyword boost:
  │   │   "javascript_regex" → {"javascript", "regex"}
  │   │
  │   ├─ FOR EACH trending tag:
  │   │   │
  │   │   ├─ Cosine similarity (tag embedding vs trending embedding)
  │   │   │
  │   │   ├─ Keyword boost (+0.5):
  │   │   │   trending "javascript" ∩ post words {"javascript","regex"}
  │   │   │   → match found → +0.5
  │   │   │
  │   │   └─ Score = cosine + keyword boost
  │   │
  │   └─ TAKE TOP 5 trending tags for this post tag
  │
  ├─ MERGE across all post tags:
  │   Keep HIGHEST score per trending tag
  │
  ├─ SORT by score descending
  │
  ├─ TAKE TOP K (from settings: trendTagsPerPost, default 5)
  │
  └─ Update:
      ├─ selectedTrendTags → suggested set
      ├─ ragSuggestedTags → suggested set
      └─ trendsBasePublishTags → suggested list (saved to DB)
```

**Example:**

```
Post tags: [javascript_regex, string_manipulation, pattern_matching]

Per "javascript regex" → top 5: javascript, webdev, node, frontend, react
Per "string manipulation" → top 5: javascript, webdev, node, performance, css
Per "pattern matching" → top 5: javascript, webdev, design, frontend, react

Merged (highest score per tag):
  javascript ──── 0.95 (keyword boost + embedding)
  webdev ──────── 0.72
  frontend ────── 0.68
  node ─────────── 0.65
  react ────────── 0.61
  design ──────── 0.58  ← outside top 5
  performance ── 0.55  ← outside top 5
  css ──────────── 0.52  ← outside top 5

Final top 5: javascript, webdev, frontend, node, react
```

---

## 6. PAGE OPEN (Edit/Create)

```
_TagSelectionSection builds:
  │
  ├─ Read postBaseTags, postBaseTagsEmbedding, trending
  │
  ├─ IF postBaseTags not empty AND trending available:
  │   │
  │   ├─ Cached embeddings exist?
  │   │   ├─ YES → filterTrendingTagsByRag() (uses cache, no re-embed)
  │   │   └─ NO  → updatePostBaseTags() (embeds + saves + filters)
  │   │
  │   └─ Trending tags UI updates:
  │       ├─ SELECTED section: tags with ✕ icon (tap to deselect)
  │       └─ AVAILABLE section: greyed tags with ✓ icon (tap to select)
  │
  └─ IF postBaseTags empty:
      └─ Show hint: "Add or polish post tags to get smart tag suggestions"
```

---

## 7. SUBMIT

**Trigger:** User taps "Submit" button.

```
submit()
  │
  ├─ No content at all → soft-delete (isRemoved = true)
  │
  ├─ Already published → return null
  │
  ├─ Not all platforms filled → status stays draft
  │
  └─ All platforms filled:
      │
      ├─ Compute POST EMBEDDING (different from tag embedding!):
      │   content = linkedinContent + postBaseTags joined
      │   embedding = MiniLM.embedChunked(content)
      │   → stored in post.embedding (for queue/similarity features)
      │
      ├─ Status → pending
      ├─ isEmbedded → true
      ├─ Save to DB
      │
      └─ Re-run RAG filter (trending tags may shift)
```

**Two different embeddings on a post:**

```
┌──────────────────────────────────────────────────────┐
│ post.embedding              (content embedding)      │
│   Source: linkedinContent + postBaseTags joined       │
│   Format: comma-separated doubles "0.1,0.2,..."      │
│   Used for: queue ranking, post similarity            │
│   Created at: submit time                             │
├──────────────────────────────────────────────────────┤
│ post.postBaseTagsEmbedding  (per-tag embeddings)     │
│   Source: each postBaseTag embedded individually      │
│   Format: JSON array of arrays [[...],[...],...]      │
│   Used for: RAG trending tag selection                │
│   Created at: polish time / manual tag edit            │
└──────────────────────────────────────────────────────┘
```

---

## 8. PUBLISH

**Trigger:** User taps "Publish" button (or copy-to-platform).

```
publish(post)
  │
  ├─ GUARDS:
  │   ├─ Category must be selected
  │   └─ Must have remaining targets (not already published)
  │
  ├─ BUILD FINAL CONTENT:
  │   │
  │   ├─ Collect all tags:
  │   │   allTags = postBaseTags + trendsBasePublishTags
  │   │   → deduplicate, prefix with #
  │   │
  │   └─ Append tags to content:
  │       "LinkedIn content here...\n\n#javascript #webdev #react"
  │
  ├─ Resolve media (images only, videos TODO)
  │
  ├─ Publish to each platform (LinkedIn API, X API)
  │
  ├─ Record publish result per platform
  │
  └─ Update status:
      ├─ All platforms done → published
      └─ Some done → partialPublished
```

---

## 9. SETTINGS THAT AFFECT THE FLOW

```
┌─────────────────────────────────────────────┐
│ TRENDING section                            │
│   trendFetchCount (default 7)               │
│     → dev.to per_page param                 │
│   trendTagsPerPost (default 5)              │
│     → top K for RAG selection               │
├─────────────────────────────────────────────┤
│ POST section                                │
│   postTagMode: "range" or "exact"           │
│   postTagMin (default 3)                    │
│   postTagMax (default 10)                   │
│   postTagExact (default 5)                  │
│     → controls Gemini tag extraction count  │
├─────────────────────────────────────────────┤
│ PUBLISHING section                          │
│   publishPerWeek (default 3)                │
│   copyToLinkedin / copyToX (manual mode)    │
└─────────────────────────────────────────────┘
```

---

## 10. USER TOGGLE — Manual Trending Tag Selection

```
User taps a trending tag chip:
  │
  toggleTrendTag(tag)
  │
  ├─ Add or remove from selectedTrendTags set
  ├─ Update trendsBasePublishTags (saved to DB)
  │
  └─ UI updates:
      ├─ Selected → moves to "Selected" section with ✕
      └─ Deselected → moves to "Available" section with ✓
```

RAG suggestions are the initial selection. User can always override by tapping.

---

## 11. DEBUG COPY (10-tap Easter Egg)

```
Tap save indicator 10x within 3 seconds:
  │
  ├─ Copies full JSON to clipboard:
  │   {
  │     dump, links, platforms, category, media,
  │     linkedinContent, xContent,
  │     postBaseTags,
  │     trendingTags: { selected, unselected },
  │     polishConfig: { hookType, structure, ... },
  │     systemPrompt: (built from GeminiService.buildPolishPrompt)
  │   }
  │
  └─ Shows snackbar: "Full post data copied for debugging"
```

---

## Status Lifecycle

```
draft ──────→ pending ──────→ published
  ▲              │                │
  │              │                ▼
  └──────────────┘          partialPublished
  (content changed)           (some platforms done)
```

- **draft:** content exists but not all platforms filled, or content changed after submit
- **pending:** all platforms filled + embedding computed, ready to publish
- **published:** all selected platforms published
- **partialPublished:** some platforms published, others remaining
