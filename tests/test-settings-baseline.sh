#!/usr/bin/env bash
# test-settings-baseline.sh
# Phase 62.1.4 + 62.2.5: settings template baseline 検証
#
# 検証内容:
#   (1) deniedDomains baseline が 4+ 件 (Phase 62.1.4)
#   (2) deniedDomains に metadata exfil endpoints (3 件) が含まれる
#   (3) deniedDomains に Phase 62.1.4 で追加した paste-site 系が含まれる
#   (4) skillOverrides は許容 (template に存在しても任意、強制しない)
#   (5) `.claude-plugin/settings.json` の baseline と template の整合性

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_SETTINGS="${ROOT_DIR}/.claude-plugin/settings.json"
SECURITY_TEMPLATE="${ROOT_DIR}/templates/claude/settings.security.json.template"

[ -f "${SECURITY_TEMPLATE}" ] || {
  echo "FAIL (0): ${SECURITY_TEMPLATE} does not exist"
  exit 1
}

# (1) deniedDomains baseline が 4+ 件 in template (Phase 62.1.4 canonical baseline)
TEMPLATE_DOMAINS_COUNT="$(jq -r '.sandbox.network.deniedDomains | length' "${SECURITY_TEMPLATE}")"
if [ "${TEMPLATE_DOMAINS_COUNT}" -lt 4 ]; then
  echo "FAIL (1): ${SECURITY_TEMPLATE} has only ${TEMPLATE_DOMAINS_COUNT} deniedDomains; Phase 62.1.4 requires 4+"
  exit 1
fi

# (2) metadata exfil endpoints (cloud metadata) 3 件
for required in '169.254.169.254' 'metadata.google.internal' 'metadata.azure.com'; do
  if ! jq -e --arg d "${required}" '.sandbox.network.deniedDomains | index($d) != null' "${SECURITY_TEMPLATE}" >/dev/null; then
    echo "FAIL (2): ${SECURITY_TEMPLATE} missing required metadata domain: ${required}"
    exit 1
  fi
done

# (3) Phase 62.1.4 paste-site additions
for paste_site in 'pastebin.com' 'transfer.sh' '0x0.st'; do
  if ! jq -e --arg d "${paste_site}" '.sandbox.network.deniedDomains | index($d) != null' "${SECURITY_TEMPLATE}" >/dev/null; then
    echo "FAIL (3): ${SECURITY_TEMPLATE} missing Phase 62.1.4 paste-site domain: ${paste_site}"
    exit 1
  fi
done

# (4) skillOverrides は許容 (任意)
# 存在する場合は 3 mode のいずれかであること
if jq -e 'has("skillOverrides")' "${SECURITY_TEMPLATE}" >/dev/null; then
  MODE="$(jq -r '.skillOverrides' "${SECURITY_TEMPLATE}")"
  case "${MODE}" in
    off|user-invocable-only|name-only) ;;
    *)
      echo "FAIL (4): skillOverrides must be off|user-invocable-only|name-only, got: ${MODE}"
      exit 1
      ;;
  esac
fi
# template に skillOverrides が存在しないことは許容 (Phase 62.2.5 方針: harness-init は default を入れない)

# (5) `.claude-plugin/settings.json` (Harness 自身の plugin config) の baseline
# self-protection で edit deny されているため、template と完全一致は user 手動同期が必要。
# ここでは少なくとも metadata exfil 3 件が存在することを確認する (regression 防止)。
if [ -f "${PLUGIN_SETTINGS}" ]; then
  for required in '169.254.169.254' 'metadata.google.internal' 'metadata.azure.com'; do
    if ! jq -e --arg d "${required}" '.sandbox.network.deniedDomains | index($d) != null' "${PLUGIN_SETTINGS}" >/dev/null; then
      echo "FAIL (5): ${PLUGIN_SETTINGS} missing baseline metadata domain: ${required}"
      exit 1
    fi
  done

  PLUGIN_DOMAINS_COUNT="$(jq -r '.sandbox.network.deniedDomains | length' "${PLUGIN_SETTINGS}")"
  TEMPLATE_DOMAINS_COUNT_INT="${TEMPLATE_DOMAINS_COUNT}"
  if [ "${PLUGIN_DOMAINS_COUNT}" -lt "${TEMPLATE_DOMAINS_COUNT_INT}" ]; then
    echo "WARN (5): ${PLUGIN_SETTINGS} has ${PLUGIN_DOMAINS_COUNT} deniedDomains; template canonical has ${TEMPLATE_DOMAINS_COUNT_INT}."
    echo "  user 手動同期が必要 (Phase 62.1.4): pastebin.com, transfer.sh, 0x0.st, paste.ee, termbin.com, ix.io"
    # NOTE: WARN only (not FAIL) since plugin settings.json edit is intentionally
    # blocked by self-protection guardrail. The user must manually sync.
  fi
fi

# (6) skillOverrides governance doc が存在 (Phase 62.2.5)
SKILL_OVERRIDES_DOC="${ROOT_DIR}/docs/skill-overrides-policy.md"
[ -f "${SKILL_OVERRIDES_DOC}" ] || {
  echo "FAIL (6): ${SKILL_OVERRIDES_DOC} not found (Phase 62.2.5)"
  exit 1
}
for required_mode in 'off' 'user-invocable-only' 'name-only'; do
  if ! grep -q "${required_mode}" "${SKILL_OVERRIDES_DOC}"; then
    echo "FAIL (6): skill-overrides-policy.md missing mode '${required_mode}'"
    exit 1
  fi
done

echo "PASS: test-settings-baseline.sh (Phase 62.1.4 + 62.2.5) — 6 観点 (1 WARN 許容)"
