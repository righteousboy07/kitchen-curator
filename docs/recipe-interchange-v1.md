# Recipe interchange schema (draft v1)

The macOS and iOS apps must agree on a portable recipe format before synchronization.

```json
{
  "schema_version": 1,
  "id": "6dc86c53-b96d-40b2-98c0-a7ecadcecd74",
  "title": "Example pasta",
  "source": {"url": null, "provider": null, "video_id": null},
  "servings": 2,
  "ingredients": [{"id": "ingredient-1", "name": "Pasta", "quantity": 200, "unit": "g", "note": null}],
  "steps": [{"id": "step-1", "text": "Cook pasta according to package directions.", "duration_seconds": null}],
  "tags": ["dinner"],
  "updated_at": "2026-10-28T00:00:00Z"
}
```

## Rules
- Stable IDs are required for recipes, ingredients, and steps.
- Store ingredient quantities as numbers and units as strings, without silently converting units.
- Preserve the original source URL and attribution.
- A recipe can be created offline.
- Import should be idempotent by recipe ID and preserve edits.
- Reject unknown major schema versions rather than silently dropping data.
- This is a draft contract, **not yet implemented or tested** in either app.
