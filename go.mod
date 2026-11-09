module github.com/corazawaf/coraza-proxy-wasm

go 1.25.0

require (
	github.com/corazawaf/coraza-wasilibs v0.2.0
	github.com/corazawaf/coraza/v3 v3.8.1
	github.com/stretchr/testify v1.11.1
	github.com/tetratelabs/proxy-wasm-go-sdk v0.24.0
	github.com/tidwall/gjson v1.18.0
)

// coraza v3.8.1 with upstream #1544 reverted (wasm heap growth under TinyGo), see third_party/coraza/4SH-FORK.md.
replace github.com/corazawaf/coraza/v3 => ./third_party/coraza

// wasilibs operator backends re-pointed at local forks (PR #330), see each fork's TIGERA-FORK.md.
replace github.com/wasilibs/go-re2 => ./third_party/go-re2

replace github.com/wasilibs/go-aho-corasick => ./third_party/go-aho-corasick

replace github.com/wasilibs/go-libinjection => ./third_party/go-libinjection

require (
	github.com/corazawaf/libinjection-go v0.3.3 // indirect
	github.com/davecgh/go-spew v1.1.2-0.20180830191138-d8f796af33cc // indirect
	github.com/goccy/go-json v0.10.5 // indirect
	github.com/goccy/go-yaml v1.19.2 // indirect
	github.com/gotnospirit/makeplural v0.0.0-20180622080156-a5f48d94d976 // indirect
	github.com/gotnospirit/messageformat v0.0.0-20221001023931-dfe49f1eb092 // indirect
	github.com/kaptinlin/go-i18n v0.1.4 // indirect
	github.com/kaptinlin/jsonschema v0.4.6 // indirect
	github.com/kr/pretty v0.1.0 // indirect
	github.com/magefile/mage v1.17.0 // indirect
	github.com/petar-dambovaliev/aho-corasick v0.0.0-20250424160509-463d218d4745 // indirect
	github.com/pmezard/go-difflib v1.0.1-0.20181226105442-5d4384ee4fb2 // indirect
	github.com/tetratelabs/wazero v1.7.3 // indirect
	github.com/tidwall/match v1.1.1 // indirect
	github.com/tidwall/pretty v1.2.1 // indirect
	github.com/valllabh/ocsf-schema-golang v1.0.3 // indirect
	github.com/wasilibs/go-aho-corasick v0.6.0 // indirect
	github.com/wasilibs/go-libinjection v0.5.0 // indirect
	github.com/wasilibs/go-re2 v1.6.0 // indirect
	golang.org/x/net v0.58.0 // indirect
	golang.org/x/sync v0.22.0 // indirect
	golang.org/x/text v0.41.0 // indirect
	google.golang.org/protobuf v1.36.11 // indirect
	gopkg.in/check.v1 v1.0.0-20180628173108-788fd7840127 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
	rsc.io/binaryregexp v0.2.0 // indirect
)
