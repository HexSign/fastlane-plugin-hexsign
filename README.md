<p align="center">
  <a href="https://hexsign.io">
    <img src="https://hexsign.io/logo.png" alt="HexSign" height="64" />
  </a>
</p>

<h1 align="center">fastlane-plugin-hexsign</h1>

<p align="center">
  Fastlane actions for <a href="https://hexsign.io">HexSign</a> — fetch Apple signing material in your lanes.
</p>

---

## Install

Add to your project's `Pluginfile`:

```ruby
gem "fastlane-plugin-hexsign"
```

Then:

```sh
bundle install
```

The plugin shells out to the `hexsign` CLI. You must install it separately:

```sh
brew install hexsign
```

…or use the [hexsign/hexsign-cli](https://github.com/hexsign/hexsign-cli) GitHub Action in CI.

## Authentication

The CLI auto-detects machine mode when these env vars are set:

```sh
HEXSIGN_CLIENT_ID=…
HEXSIGN_CLIENT_SECRET=…
```

Provision a service credential in the [HexSign dashboard](https://dashboard.hexsign.net) under **Settings → CLI Tokens**.

## Actions

### `hexsign_certificates_download`

Downloads a signing certificate (`.p12` + `.password`).

```ruby
hexsign_certificates_download(
  id: ENV["HEXSIGN_CERT_ID"],
  output_dir: "build/sign"
)
```

| Option | Env | Required | Description |
|---|---|---|---|
| `id` | `HEXSIGN_CERTIFICATE_ID` | yes | Certificate ID |
| `output_dir` | `HEXSIGN_CERTIFICATE_OUTPUT_DIR` | no | Output directory |
| `filename` | `HEXSIGN_CERTIFICATE_FILENAME` | no | Base filename (no extension) |

### `hexsign_profiles_download`

Downloads a provisioning profile (`.mobileprovision`).

```ruby
hexsign_profiles_download(
  id: ENV["HEXSIGN_PROFILE_ID"],
  output_dir: "build/sign"
)
```

| Option | Env | Required | Description |
|---|---|---|---|
| `id` | `HEXSIGN_PROFILE_ID` | yes | Provisioning profile ID |
| `output_dir` | `HEXSIGN_PROFILE_OUTPUT_DIR` | no | Output directory |
| `filename` | `HEXSIGN_PROFILE_FILENAME` | no | Filename (no extension) |

### `hexsign_certificates_download_by_type`

Downloads **every** signing certificate of a given type for one Apple Developer
team. Survives certificate rotation: no UUID to update when a cert is renewed.

Returns an array of `{ p12:, password: }` hashes — one per downloaded certificate.

```ruby
pairs = hexsign_certificates_download_by_type(
  type:       "IOS_DISTRIBUTION",
  team_id:    "ABCDE12345",
  output_dir: "build/sign"
)
# => [{ p12: "build/sign/foo.p12", password: "build/sign/foo.password" }, ...]
```

| Option | Env | Required | Description |
|---|---|---|---|
| `type` | `HEXSIGN_CERTIFICATE_TYPE` | yes | Apple cert type (e.g. `IOS_DISTRIBUTION`) |
| `team_id` | `HEXSIGN_TEAM_ID` | yes | Apple Developer team id |
| `output_dir` | `HEXSIGN_CERTIFICATE_OUTPUT_DIR` | no | Output directory |

### `hexsign_profiles_download_by_bundle_id`

Downloads **every** provisioning profile for a bundle identifier. Survives
profile rotation: no UUID to update when a profile is regenerated.

Returns an array of absolute paths to the downloaded `.mobileprovision` files.

```ruby
paths = hexsign_profiles_download_by_bundle_id(
  bundle_id:  "com.example.app",
  team_id:    "ABCDE12345",   # optional — scopes across linked Apple accounts
  output_dir: "build/sign"
)
# => ["build/sign/foo.mobileprovision", "build/sign/bar.mobileprovision"]
```

| Option | Env | Required | Description |
|---|---|---|---|
| `bundle_id` | `HEXSIGN_BUNDLE_ID` | yes | App bundle identifier (exact match) |
| `team_id` | `HEXSIGN_TEAM_ID` | no | Apple Developer team id — scopes across linked accounts |
| `output_dir` | `HEXSIGN_PROFILE_OUTPUT_DIR` | no | Output directory |

## Example lane

```ruby
lane :beta do
  hexsign_certificates_download(id: ENV["HEXSIGN_CERT_ID"],   output_dir: "build/sign")
  hexsign_profiles_download    (id: ENV["HEXSIGN_PROFILE_ID"], output_dir: "build/sign")

  import_certificate(
    certificate_path:     "build/sign/certificate.p12",
    certificate_password: File.read("build/sign/certificate.password").strip,
    keychain_name:        "build.keychain"
  )

  gym(scheme: "MyApp")
end
```

## Development

```sh
bundle install
bundle exec rake          # runs rspec + rubocop
```

## Contributing & security

- Bugs / feature requests: open a GitHub issue.
- Security vulnerabilities: email **support@hexsign.io** — please do **not** open a public issue.

## License

[MIT](LICENSE).
