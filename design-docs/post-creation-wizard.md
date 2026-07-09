# Post creation wizard — design notes

## Goal

Split post creation into stages so that progress is never lost, especially
before/during large file uploads. The core mechanism: **create the `post`
row (as `DRAFT`) at the first step**, then every later step writes against
that existing `post_id` instead of accumulating state client-side until a
final submit.

## Flow

1. **Basic info** — title, description, post type.
   Client-side only until the user clicks Next.

2. **Create draft** *(checkpoint)* — `INSERT INTO post (...) VALUES (..., status = 'DRAFT')`.
   Returns `post_id`. From this point on, closing the tab or crashing loses
   at most the current step's unsaved edits, not the whole post.

3. **Type-specific fields** — form generated from `post_type_field` rows for
   this post's `post_type_id`. Each field write is its own small,
   independent save against `post_id`.

4. **Upload files** *(checkpoint)* — attach media to the draft. Each file
   upload is its own operation tied to `post_id`; a failed large upload
   doesn't take the rest of the draft down with it.

5. **Review & publish** — validates required fields (`post_type_field.is_required`),
   then `UPDATE post SET status = 'PUBLISHED', published_at = NOW() WHERE post_id = ?`.

## Rules for each step

- **Autosave within a step, not just between steps.** Debounce saves on
  text fields (e.g. on blur or a few seconds of inactivity) rather than
  only persisting on "Next."

- **Lock `post_type` after step 1.** Changing type mid-draft would orphan
  already-entered `post_type_field` values. If a user wants a different
  type, they abandon the draft and start over, or use an explicit
  "change type" action that warns and clears type-specific data.

- **Don't gate uploads behind other steps.** Let users drag-and-drop files
  as soon as the draft exists (right after step 2), so someone with a large
  video isn't forced through the rest of the form first.

- **Defer required-field validation to publish, not draft save.** A
  half-filled draft must still be saveable; only enforce `is_required` at
  the final "Publish" action.

- **Surface a "My drafts" list.** `SELECT * FROM post WHERE created_by = ?
  AND status = 'DRAFT'`. This is the recovery path if a browser crash
  strands someone mid-wizard.

- **Decide a stale-draft cleanup policy.** Open question: do empty/abandoned
  drafts get purged after N days, or persist indefinitely? Matters for
  `uq_post_title` / `uq_post_slug` collisions with forgotten drafts.

## Open / follow-up items

- A general `post_file` join table (shape similar to `post_tag`) is needed
  to attach uploaded media to any post — currently only `vote_option_image`
  links media to content.
- Stored procedure signatures for: create-draft, attach-field-value,
  attach-file, publish — not yet drafted.
