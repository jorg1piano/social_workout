# Social Workout — Mobile (Flutter)

## Project phase

This app is in **early prototyping**. Speed of iteration matters more than
polish. Hardcoded values and shortcuts are fine.

## Adding new features

The home screen (`FeatureListScreen` in `lib/main.dart`) is a simple `ListView`
that acts as a feature launcher. Each feature is a `ListTile` in the column.

To add a new feature:

1. Build the feature screen in `lib/features/<feature_name>/`.
2. Add a new `ListTile` to the `children` list in `FeatureListScreen`.
3. Hardcode any IDs or sample data needed — no routing layer or dynamic
   discovery is required at this stage.
