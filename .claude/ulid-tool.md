# ULID Generation Tool

## Location
`/Users/jorgen/github/devda/social_workout/tools/generate_ulid/ulid`

## Purpose
Generates ULIDs (Universally Unique Lexicographically Sortable Identifiers) for use in the database schema.

## Usage

### Generate a new ULID
```bash
/Users/jorgen/github/devda/social_workout/tools/generate_ulid/ulid generate
```

Output example:
```
01KE6BCK6J2139V7RNX64CJZZD
```

### Validate a ULID
```bash
/Users/jorgen/github/devda/social_workout/tools/generate_ulid/ulid validate 01KE6BCK6J2139V7RNX64CJZZD
```

## Database ID Format

All IDs in the database follow this pattern:
- Format: `{prefix}-{ULID}`
- Length: **exactly 30 characters**
- Prefix: `app-` (4 chars) for application-generated IDs, or `usr-` for user-generated IDs
- ULID: 26 characters

Examples:
```
app-01KE649R21JCQEZQX4WD88W769  (30 chars)
usr-01KE6BCK6J2139V7RNX64CJZZD  (30 chars)
```

## Implementation

Written in Go using the `github.com/oklog/ulid/v2` package.

Source: `/Users/jorgen/github/devda/social_workout/tools/generate_ulid/main.go`

## Generating Multiple IDs

For batch generation, use a loop:
```bash
for i in {1..10}; do
  echo "app-$(/Users/jorgen/github/devda/social_workout/tools/generate_ulid/ulid generate)"
done
```

This will output:
```
app-01KE6BCK6J2139V7RNX64CJZZD
app-01KE6BCK7M4567V8SQYZ5DKAAE
...
```
