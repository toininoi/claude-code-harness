# Hokage Spin-Off Readiness

Last updated: 2026-05-17

## Conclusion

No public spin-off yet.

Claude Code Harness remains a Claude-first product. "Hokage" is currently the
v4 Go-native runtime line, and Hokage Core extraction is underway as an internal
architecture direction. Do not present `Hokage Harness` as a public cross-host
product until the gates below pass.

## Gate Scope

The spin-off gate covers only the adapters that are near enough to verify in
this repository:

- Claude Code
- Codex
- OpenCode

Cursor, Gemini, and Copilot are not public cross-host support claims in this phase.

## Claude/Codex/OpenCode Gate Status

| Gate | Current result | Evidence available | Blocking reason |
|---|---|---|---|
| Claude Code adapter | FAIL | Claude-first product surface exists; plugin validation already covers the current product baseline | Hokage Core contract checks are not yet part of `tests/validate-plugin.sh` |
| Codex adapter | FAIL | Codex skills and package tests exist as a compatibility surface | Codex bootstrap routing for Hokage Core has not been documented and tested as a spin-off gate |
| OpenCode adapter | FAIL | OpenCode mirror generation and `node scripts/validate-opencode.js` exist | Stale command/MCP setup surfaces must be cleaned before OpenCode can be treated as first-class adapter parity |
| Capability matrix | FAIL | Existing docs describe Claude/Codex hardening differences | Claude/Codex/OpenCode capability rows still need a dedicated test-backed matrix |
| Bootstrap routing | FAIL | Skill routing exists per host surface | Golden prompt routing has not been turned into a test-backed contract |
| Release preflight | FAIL | Release preflight already checks existing package drift | Adapter drift gates are not yet tied to release claims for Hokage Core |
| Positioning | PASS | README / README_ja use conservative extraction wording | Keep this wording until the other gates pass |

## Unsupported Host Reasons

| Host | Status | Reason |
|---|---|---|
| Cursor | Unsupported for public spin-off | Existing 2-agent handoff docs are not a full adapter: no verified bootstrap route, capability matrix, release gate, or runtime safety parity |
| Gemini | Unsupported for public spin-off | No repository-owned extension manifest, setup path, bootstrap proof, or verification command set exists in this phase |
| Copilot | Unsupported for public spin-off | No repository-owned marketplace/CLI adapter, bootstrap proof, or release-preflight integration exists in this phase |

## Next Adapter Candidates

| Candidate | Why it is next | Required proof before support claim |
|---|---|---|
| OpenCode | It already has generated mirrors and validation scripts, so the remaining work is bounded | Remove stale setup/docs assumptions, pass mirror sync, pass `node scripts/validate-opencode.js`, and document unsupported capabilities |
| Codex | It already has native skill surfaces and package tests | Document bootstrap routing, pass `bash tests/test-codex-package.sh`, and prove where Codex gates differ from Claude hooks |
| Cursor | It has existing 2-agent workflow docs, but not adapter parity | Define whether it is a handoff integration or a real adapter before adding any support claim |

## Allowed Public Wording

Use:

```text
Claude Code Harness is Claude-first, with Hokage Core extraction underway.
```

Do not use:

```text
Describe Hokage as a public cross-host product before these gates pass.
```

## Exit Criteria

The `No public spin-off yet` conclusion can change only when all of the
following are true:

- Claude Code, Codex, and OpenCode adapter gates are green.
- Capability differences are documented and test-backed.
- Bootstrap routing has golden prompt coverage or explicit unsupported results.
- Release preflight blocks only adapters claimed by that release.
- README / README_ja can state support without implying safety parity that the
  host cannot provide.
