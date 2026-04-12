# Social Workout App - High-Level Feature List

## What's Built Already

- **Active Workout Tracking** - live workout screen with set logging, weight/reps, set types, variant swapping, previous session data
- **SQLite Schema** - 14 tables, exercise catalog (209 exercises), template/execution split, social feed tables
- **Data Layer** - DAOs, models, ULID generation, offline-first persistence

---

## Features to Explore

### Core Workout

1. **Workout Template Browser** - pick a template to start a workout from
2. **Template Builder/Editor** - create and edit workout templates
3. **Rest Timer** - configurable per-exercise countdown timer between sets, with pause/resume
4. **Workout Pause Timer** - pause an active workout (phone call, waiting for equipment) without losing elapsed time tracking
5. **Superset / Circuit Support** - group exercises to perform back-to-back

### During & After Workout

6. **Exercise Video Recording** - record yourself performing a set (e.g. film your dips for form check), attach clips to specific exercises/sets
7. **Workout Summary Screen** - shown after finishing a workout: duration, volume, PRs hit, exercises completed, comparison to previous session
8. **Workout History** - list of past workouts with details

### Planning & Goals

9. **Workout Planner** - schedule workouts ahead of time, assign templates to days, drag to reschedule
10. **Goal Setting** - set targets like "lose 5 kg by June", "bench 100 kg", "work out 4x/week" with deadlines and progress tracking
11. **Progressive Overload Hints** - suggest weight/rep increases based on history
12. **Workout Suggestions** - recommend next workout based on muscle group recovery

### Progress & Statistics

13. **Workout Statistics Pages** - detailed stats: total workouts, avg duration, favorite exercises, volume per muscle group, frequency heatmap
14. **Progress Charts** - volume/weight trends per exercise over time
15. **Personal Records** - auto-detect and celebrate PRs (1RM, volume, etc.)
16. **Body Measurements Tracking** - weight, body fat, tape measurements over time
17. **Progress Photos** - timestamped photo log with comparison view
18. **Weekly Volume Summary** - per-muscle-group volume breakdown

### Social & Competition

19. **Social Feed** - see friends' completed workouts, PRs, streaks
20. **Likes & Comments** - engage with friends' posts
21. **User Profiles** - bio, stats, workout count, streaks
22. **Friend System** - add/follow friends
23. **Streak Tracking** - daily/weekly workout consistency streaks with milestones
24. **Competitions** - challenge friends (most workouts, highest volume, first to PR), leaderboards, time-boxed challenges

### Quality of Life

25. **Search & Filter Exercises** - by muscle group, equipment, name
26. **Custom Exercises** - user-defined exercises beyond the catalog
27. **Workout Notes** - free-text notes per workout or per exercise
28. **Unit Preferences** - kg/lbs toggle
29. **Export Data** - CSV/JSON export of workout history

### Integrations

30. **Apple Watch Sync** - start/track workouts from watch, heart rate data, workout rings integration
31. **HealthKit Integration** - push workouts to Apple Health, pull body weight/heart rate

### Backend & Sync

32. **Go API Server** - scaffold the backend
33. **Offline Sync Engine** - CRDT or last-write-wins sync with server
34. **Auth & Accounts** - sign up / login
