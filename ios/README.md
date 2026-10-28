# Kitchen Curator for iPhone and iPad

Native SwiftUI companion application. This folder is reserved for the Xcode project.

## Planned architecture
- SwiftUI navigation and responsive iPhone/iPad layouts
- Local-first persistence
- Shared JSON recipe interchange format with the desktop app
- Import/share extension for recipe links
- Optional CloudKit sync after local import/export is tested

## Shared recipe interchange (draft)
```json
{
  "schema_version": 1,
  "id": "recipe-uuid",
  "title": "Example recipe",
  "source_url": null,
  "servings": 4,
  "ingredients": [
    {"name": "flour", "quantity": 2, "unit": "cups"}
  ],
  "steps": ["Mix ingredients", "Cook until done"],
  "tags": []
}
```

Do not assume that this draft schema matches the existing macOS SQLite tables until an explicit migration and compatibility test is completed.

See [iOS milestone](https://github.com/righteousboy07/kitchen-curator/issues/1).
